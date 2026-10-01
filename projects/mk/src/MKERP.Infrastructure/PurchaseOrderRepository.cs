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

    public async Task AddAsync(PurchaseOrder order, PurchaseOrderDetail detail, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.PurchaseOrders.Add(order); await db.SaveChangesAsync(cancellationToken);
        detail.PurchaseOrderId = order.Id; db.PurchaseOrderDetails.Add(detail); await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ConfirmAsync(long purchaseOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == purchaseOrderId, cancellationToken);
        if (order.StatusCode != "DRAFT") throw new InvalidOperationException("작성중 상태의 발주만 확정할 수 있습니다.");
        var detail = await db.PurchaseOrderDetails.SingleAsync(x => x.PurchaseOrderId == purchaseOrderId, cancellationToken);
        var movement = await CreateMovementAsync(order, detail, "IN", "PURCHASE_ORDER", cancellationToken);
        var before = Snapshot(order); order.StatusCode = "CONFIRMED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CONFIRM", before, order, note: $"IN={movement.Id}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task CancelAsync(long purchaseOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == purchaseOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("확정 상태의 발주만 취소할 수 있습니다.");
        var detail = await db.PurchaseOrderDetails.SingleAsync(x => x.PurchaseOrderId == purchaseOrderId, cancellationToken);
        var movement = await db.InOuts.Where(x => x.SourceTypeCode == "PURCHASE_ORDER" && x.SourceId == purchaseOrderId && x.StatusCode != "CANCELLED").OrderByDescending(x => x.Id).FirstOrDefaultAsync(cancellationToken);
        if (movement is null) throw new InvalidOperationException("연결된 입고 거래를 찾을 수 없습니다.");
        movement.StatusCode = "CANCELLED"; movement.UpdatedAt = DateTime.UtcNow;
        var reverse = await CreateMovementAsync(order, detail, "OUT", "PURCHASE_ORDER_CANCEL", cancellationToken);
        var before = Snapshot(order); order.StatusCode = "CANCELLED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CANCEL", before, order, note: $"REVERSE_OUT={reverse.Id}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private static PurchaseOrder Snapshot(PurchaseOrder x) => new() { Id=x.Id, DocumentNo=x.DocumentNo, OrderDate=x.OrderDate, PartnerId=x.PartnerId, DueDate=x.DueDate, StatusCode=x.StatusCode, Note=x.Note, CreatedAt=x.CreatedAt, UpdatedAt=x.UpdatedAt };

    private async Task<InOut> CreateMovementAsync(PurchaseOrder order, PurchaseOrderDetail detail, string type, string source, CancellationToken cancellationToken)
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

    public async Task<IReadOnlyList<PurchaseOrder>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.PurchaseOrders.AsNoTracking().OrderByDescending(x => x.OrderDate).ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
}
