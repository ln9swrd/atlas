using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class PurchaseOrderRepository(ERPDbContext db) : IPurchaseOrderRepository
{
    public async Task<string> GetNextDocumentNoAsync(DateTime orderDate, CancellationToken cancellationToken = default)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.PURCHASE_ORDER").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.PurchaseOrders.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        return pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM")).Replace("{seq4}", (count + 1).ToString("D4"));
    }

    public async Task AddAsync(PurchaseOrder order, IReadOnlyList<PurchaseOrderDetail> details, CancellationToken cancellationToken = default)
    {
        if (details.Count == 0) throw new ArgumentException("발주 상세가 없습니다.", nameof(details));
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.PurchaseOrders.Add(order); await db.SaveChangesAsync(cancellationToken);
        foreach (var detail in details) { detail.PurchaseOrderId = order.Id; db.PurchaseOrderDetails.Add(detail); }
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        foreach (var detail in details)
            await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ConfirmAsync(long purchaseOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == purchaseOrderId, cancellationToken);
        if (order.StatusCode != "DRAFT") throw new InvalidOperationException("작성중 상태의 발주만 확정할 수 있습니다.");
        var before = Snapshot(order); order.StatusCode = "CONFIRMED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CONFIRM", before, order, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ProcessAsync(long purchaseOrderId, decimal quantity, CancellationToken cancellationToken = default)
    {
        var detail = await db.PurchaseOrderDetails.AsNoTracking().SingleAsync(x => x.PurchaseOrderId == purchaseOrderId, cancellationToken);
        await ProcessDetailAsync(detail.Id, quantity, cancellationToken);
    }

    public async Task ProcessDetailAsync(long purchaseOrderDetailId, decimal quantity, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0) throw new InvalidOperationException("입고수량은 0보다 커야 합니다.");
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var detail = await db.PurchaseOrderDetails.SingleAsync(x => x.Id == purchaseOrderDetailId, cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == detail.PurchaseOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("확정 상태의 발주만 입고 처리할 수 있습니다.");
        var remaining = detail.OrderQty - detail.ProcessedQty;
        if (quantity > remaining) throw new InvalidOperationException($"입고 잔량을 초과했습니다. 잔량: {remaining:N2}");
        var movement = await CreateMovementAsync(order, detail, quantity, "IN", "PURCHASE_ORDER", cancellationToken);
        var movementDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
        await AddProcessHistoryAsync("PURCHASE_ORDER", detail.Id, movementDetail.Id, quantity, "PROCESS", null, cancellationToken);
        detail.ProcessedQty += quantity;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "PROCESS", null, detail, note: $"IN_QTY={quantity:N2}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task CancelAsync(long purchaseOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == purchaseOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("확정 상태의 발주만 취소할 수 있습니다.");
        var details = await db.PurchaseOrderDetails.Where(x => x.PurchaseOrderId == purchaseOrderId).ToListAsync(cancellationToken);
        var movements = await db.InOuts.Where(x => x.SourceTypeCode == "PURCHASE_ORDER" && x.SourceId == purchaseOrderId && x.StatusCode != "CANCELLED").ToListAsync(cancellationToken);
        foreach (var detail in details)
        {
            var originalHistories = await db.OrderProcessHistories.Where(x => x.SourceTypeCode == "PURCHASE_ORDER" && x.SourceDetailId == detail.Id && x.ActionCode == "PROCESS").OrderBy(x => x.Id).ToListAsync(cancellationToken);
            var processed = originalHistories.Sum(x => x.ProcessQty);
            if (processed <= 0) continue;
            var available = await GetAvailableAsync(detail.ItemId, cancellationToken);
            if (available < processed) throw new InvalidOperationException($"취소에 필요한 재고가 부족합니다. 현재 재고: {available:N2}, 회수 수량: {processed:N2}");
        }
        foreach (var movement in movements) { movement.StatusCode = "CANCELLED"; movement.UpdatedAt = DateTime.UtcNow; }
        foreach (var detail in details)
        {
            var originalHistories = await db.OrderProcessHistories.Where(x => x.SourceTypeCode == "PURCHASE_ORDER" && x.SourceDetailId == detail.Id && x.ActionCode == "PROCESS").OrderBy(x => x.Id).ToListAsync(cancellationToken);
            var processed = originalHistories.Sum(x => x.ProcessQty);
            if (processed <= 0) continue;
            var reverseMovement = await CreateMovementAsync(order, detail, processed, "OUT", "PURCHASE_ORDER_CANCEL", cancellationToken);
            var reverseDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == reverseMovement.Id, cancellationToken);
            foreach (var history in originalHistories)
                await AddProcessHistoryAsync("PURCHASE_ORDER", detail.Id, reverseDetail.Id, history.ProcessQty, "REVERSE", history.Id, cancellationToken);
        }
        var before = Snapshot(order); order.StatusCode = "CANCELLED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CANCEL", before, order, note: $"REVERSE_OUT_QTY={details.Sum(x => x.ProcessedQty):N2}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private async Task AddProcessHistoryAsync(string sourceType, long sourceDetailId, long inOutDetailId, decimal quantity, string actionCode, long? reversesHistoryId, CancellationToken cancellationToken)
    {
        db.OrderProcessHistories.Add(new OrderProcessHistory { SourceTypeCode=sourceType, SourceDetailId=sourceDetailId, InOutDetailId=inOutDetailId, ProcessQty=quantity, ActionCode=actionCode, ReversesHistoryId=reversesHistoryId, CreatedAt=DateTime.UtcNow });
        await db.SaveChangesAsync(cancellationToken);
    }

    private static PurchaseOrder Snapshot(PurchaseOrder x) => new() { Id=x.Id, DocumentNo=x.DocumentNo, OrderDate=x.OrderDate, PartnerId=x.PartnerId, DueDate=x.DueDate, StatusCode=x.StatusCode, Note=x.Note, CreatedAt=x.CreatedAt, UpdatedAt=x.UpdatedAt };

    private async Task<decimal> GetAvailableAsync(long itemId, CancellationToken cancellationToken) =>
        (await db.InOuts.AsNoTracking().Where(x => x.StatusCode != "CANCELLED").Join(db.InOutDetails, h => h.Id, d => d.InOutId, (h,d) => new {h,d}).Where(x => x.d.ItemId == itemId).ToListAsync(cancellationToken)).Sum(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST" ? x.d.Quantity : -x.d.Quantity);

    private async Task<InOut> CreateMovementAsync(PurchaseOrder order, PurchaseOrderDetail detail, decimal quantity, string type, string source, CancellationToken cancellationToken)
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

    public async Task<IReadOnlyList<PurchaseOrder>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.PurchaseOrders.AsNoTracking().OrderByDescending(x => x.OrderDate).ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
}
