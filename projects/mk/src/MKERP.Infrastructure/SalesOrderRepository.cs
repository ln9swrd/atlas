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

    public async Task AddAsync(SalesOrder order, SalesOrderDetail detail, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.SalesOrders.Add(order);
        await db.SaveChangesAsync(cancellationToken);
        detail.SalesOrderId = order.Id;
        db.SalesOrderDetails.Add(detail);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ConfirmAsync(long salesOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusCode != "DRAFT") throw new InvalidOperationException("작성중 상태의 수주만 확정할 수 있습니다.");
        var detail = await db.SalesOrderDetails.SingleAsync(x => x.SalesOrderId == salesOrderId, cancellationToken);
        var available = await GetAvailableAsync(detail.ItemId, cancellationToken);
        if (available < detail.OrderQty) throw new InvalidOperationException($"재고가 부족합니다. 현재 재고: {available:N2}, 출고 요청: {detail.OrderQty:N2}");
        await CreateMovementAsync(order, detail, "OUT", "SALES_ORDER", cancellationToken);
        var before = new SalesOrder { Id=order.Id, DocumentNo=order.DocumentNo, OrderDate=order.OrderDate, PartnerId=order.PartnerId, DueDate=order.DueDate, StatusCode=order.StatusCode, Note=order.Note, CreatedAt=order.CreatedAt, UpdatedAt=order.UpdatedAt };
        order.StatusCode = "CONFIRMED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CONFIRM", before, order, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task CancelAsync(long salesOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("확정 상태의 수주만 취소할 수 있습니다.");
        var detail = await db.SalesOrderDetails.SingleAsync(x => x.SalesOrderId == salesOrderId, cancellationToken);
        var movement = await db.InOuts.Where(x => x.SourceTypeCode == "SALES_ORDER" && x.SourceId == salesOrderId && x.StatusCode != "CANCELLED").OrderByDescending(x => x.Id).FirstOrDefaultAsync(cancellationToken);
        if (movement is null) throw new InvalidOperationException("연결된 출고 거래를 찾을 수 없습니다.");
        var available = await GetAvailableAsync(detail.ItemId, cancellationToken);
        if (available < detail.OrderQty) throw new InvalidOperationException($"취소에 필요한 재고가 부족합니다. 현재 재고: {available:N2}, 복원 수량: {detail.OrderQty:N2}");
        movement.StatusCode = "CANCELLED"; movement.UpdatedAt = DateTime.UtcNow;
        var reverse = await CreateMovementAsync(order, detail, "IN", "SALES_ORDER_CANCEL", cancellationToken);
        var before = new SalesOrder { Id=order.Id, DocumentNo=order.DocumentNo, OrderDate=order.OrderDate, PartnerId=order.PartnerId, DueDate=order.DueDate, StatusCode=order.StatusCode, Note=order.Note, CreatedAt=order.CreatedAt, UpdatedAt=order.UpdatedAt };
        order.StatusCode = "CANCELLED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CANCEL", before, order, note: $"REVERSE_IN={reverse.Id}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private async Task<decimal> GetAvailableAsync(long itemId, CancellationToken cancellationToken) =>
        (await db.InOuts.AsNoTracking().Where(x => x.StatusCode != "CANCELLED")
            .Join(db.InOutDetails, h => h.Id, d => d.InOutId, (h,d) => new {h,d}).Where(x => x.d.ItemId == itemId).ToListAsync(cancellationToken))
            .Sum(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST" ? x.d.Quantity : -x.d.Quantity);

    private async Task<InOut> CreateMovementAsync(SalesOrder order, SalesOrderDetail detail, string type, string source, CancellationToken cancellationToken)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.INOUT").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.InOuts.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        var movement = new InOut { DocumentNo=pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM")).Replace("{seq4}", (count+1).ToString("D4")), MovementDate=order.OrderDate, MovementTypeCode=type, PartnerId=order.PartnerId, SourceTypeCode=source, SourceId=order.Id, StatusCode="CONFIRMED", CreatedAt=DateTime.UtcNow, UpdatedAt=DateTime.UtcNow };
        db.InOuts.Add(movement); await db.SaveChangesAsync(cancellationToken);
        db.InOutDetails.Add(new InOutDetail { InOutId=movement.Id, ItemId=detail.ItemId, Quantity=detail.OrderQty, UnitPrice=detail.AppliedUnitPrice, Amount=detail.Amount });
        await db.SaveChangesAsync(cancellationToken);
        return movement;
    }

    public async Task<IReadOnlyList<SalesOrder>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.SalesOrders.AsNoTracking().OrderByDescending(x => x.OrderDate).ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
}
