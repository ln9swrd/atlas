using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class SalesOrderRepository(ERPDbContext db) : ISalesOrderRepository
{
    public async Task<string> GetNextDocumentNoAsync(DateTime orderDate, CancellationToken cancellationToken = default)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.SALES_ORDER").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.SalesOrders.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        return pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM")).Replace("{seq4}", (count + 1).ToString("D4"));
    }

    public async Task AddAsync(SalesOrder order, IReadOnlyList<SalesOrderDetail> details, CancellationToken cancellationToken = default)
    {
        if (details.Count == 0) throw new ArgumentException("수주 상세가 없습니다.", nameof(details));
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.SalesOrders.Add(order);
        await db.SaveChangesAsync(cancellationToken);
        foreach (var detail in details) { detail.SalesOrderId = order.Id; db.SalesOrderDetails.Add(detail); }
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        foreach (var detail in details)
            await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ConfirmAsync(long salesOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusCode != "DRAFT") throw new InvalidOperationException("작성중 상태의 수주만 확정할 수 있습니다.");
        var before = Snapshot(order);
        order.StatusCode = "CONFIRMED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CONFIRM", before, order, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ProcessAsync(long salesOrderId, decimal quantity, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0) throw new InvalidOperationException("출고수량은 0보다 커야 합니다.");
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("확정 상태의 수주만 출고 처리할 수 있습니다.");
        var detail = await db.SalesOrderDetails.SingleAsync(x => x.SalesOrderId == salesOrderId, cancellationToken);
        var remaining = detail.OrderQty - detail.ProcessedQty;
        if (quantity > remaining) throw new InvalidOperationException($"출고 잔량을 초과했습니다. 잔량: {remaining:N2}");
        var available = await GetAvailableAsync(detail.ItemId, cancellationToken);
        if (available < quantity) throw new InvalidOperationException($"재고가 부족합니다. 현재 재고: {available:N2}, 출고 요청: {quantity:N2}");
        var movement = await CreateMovementAsync(order, detail, quantity, "OUT", "SALES_ORDER", cancellationToken);
        var movementDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
        await AddProcessHistoryAsync("SALES_ORDER", detail.Id, movementDetail.Id, quantity, "PROCESS", null, cancellationToken);
        detail.ProcessedQty += quantity;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "PROCESS", null, detail, note: $"OUT_QTY={quantity:N2}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task CancelAsync(long salesOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("확정 상태의 수주만 취소할 수 있습니다.");
        var detail = await db.SalesOrderDetails.SingleAsync(x => x.SalesOrderId == salesOrderId, cancellationToken);
        var movements = await db.InOuts.Where(x => x.SourceTypeCode == "SALES_ORDER" && x.SourceId == salesOrderId && x.StatusCode != "CANCELLED").ToListAsync(cancellationToken);
        var originalHistories = await db.OrderProcessHistories.Where(x => x.SourceTypeCode == "SALES_ORDER" && x.SourceDetailId == detail.Id && x.ActionCode == "PROCESS").OrderBy(x => x.Id).ToListAsync(cancellationToken);
        var processed = movements.Join(db.InOutDetails, h => h.Id, d => d.InOutId, (h,d) => d.Quantity).Sum();
        if (processed > 0)
        {
            // 출고 취소는 기존 OUT을 취소하고 동일 수량을 IN으로 복원하므로 현재 재고 부족을 이유로 취소를 막지 않는다.
            foreach (var movement in movements) { movement.StatusCode = "CANCELLED"; movement.UpdatedAt = DateTime.UtcNow; }
            var reverseMovement = await CreateMovementAsync(order, detail, processed, "IN", "SALES_ORDER_CANCEL", cancellationToken);
            var reverseDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == reverseMovement.Id, cancellationToken);
            if (originalHistories.Count == 0)
                await AddProcessHistoryAsync("SALES_ORDER", detail.Id, reverseDetail.Id, processed, "REVERSE", null, cancellationToken);
            else
                foreach (var history in originalHistories)
                    await AddProcessHistoryAsync("SALES_ORDER", detail.Id, reverseDetail.Id, history.ProcessQty, "REVERSE", history.Id, cancellationToken);
        }
        var before = Snapshot(order);
        order.StatusCode = "CANCELLED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CANCEL", before, order, note: $"REVERSE_IN_QTY={processed:N2}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private async Task AddProcessHistoryAsync(string sourceType, long sourceDetailId, long inOutDetailId, decimal quantity, string actionCode, long? reversesHistoryId, CancellationToken cancellationToken)
    {
        db.OrderProcessHistories.Add(new OrderProcessHistory { SourceTypeCode=sourceType, SourceDetailId=sourceDetailId, InOutDetailId=inOutDetailId, ProcessQty=quantity, ActionCode=actionCode, ReversesHistoryId=reversesHistoryId, CreatedAt=DateTime.UtcNow });
        await db.SaveChangesAsync(cancellationToken);
    }

    private static SalesOrder Snapshot(SalesOrder x) => new() { Id=x.Id, DocumentNo=x.DocumentNo, OrderDate=x.OrderDate, PartnerId=x.PartnerId, DueDate=x.DueDate, StatusCode=x.StatusCode, Note=x.Note, CreatedAt=x.CreatedAt, UpdatedAt=x.UpdatedAt };

    private async Task<decimal> GetAvailableAsync(long itemId, CancellationToken cancellationToken) =>
        (await db.InOuts.AsNoTracking().Where(x => x.StatusCode != "CANCELLED")
            .Join(db.InOutDetails, h => h.Id, d => d.InOutId, (h,d) => new {h,d}).Where(x => x.d.ItemId == itemId).ToListAsync(cancellationToken))
            .Sum(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST" ? x.d.Quantity : -x.d.Quantity);

    private async Task<InOut> CreateMovementAsync(SalesOrder order, SalesOrderDetail detail, decimal quantity, string type, string source, CancellationToken cancellationToken)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.INOUT").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.InOuts.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        var movement = new InOut { DocumentNo=pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM")).Replace("{seq4}", (count+1).ToString("D4")), MovementDate=order.OrderDate, MovementTypeCode=type, PartnerId=order.PartnerId, SourceTypeCode=source, SourceId=order.Id, StatusCode="CONFIRMED", CreatedAt=DateTime.UtcNow, UpdatedAt=DateTime.UtcNow };
        db.InOuts.Add(movement); await db.SaveChangesAsync(cancellationToken);
        db.InOutDetails.Add(new InOutDetail { InOutId=movement.Id, ItemId=detail.ItemId, Quantity=quantity, UnitPrice=detail.AppliedUnitPrice, Amount=quantity * detail.AppliedUnitPrice });
        await db.SaveChangesAsync(cancellationToken);
        return movement;
    }

    public async Task<IReadOnlyList<SalesOrder>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.SalesOrders.AsNoTracking().OrderByDescending(x => x.OrderDate).ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
}
