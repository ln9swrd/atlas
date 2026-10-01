using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class PurchaseOrderRepository(ERPDbContext db) : IPurchaseOrderRepository
{
    public async Task<string> GetNextDocumentNoAsync(DateTime orderDate, CancellationToken cancellationToken = default)
    {
        var pattern = await db.SystemSettings.AsNoTracking()
            .Where(x => x.Key == "DOC_NO.PURCHASE_ORDER")
            .Select(x => x.Value)
            .SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.PurchaseOrders.CountAsync(
            x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        return pattern
            .Replace("{yyyyMM}", orderDate.ToString("yyyyMM"))
            .Replace("{seq4}", (count + 1).ToString("D4"));
    }

    public async Task AddAsync(
        PurchaseOrder order,
        PurchaseOrderDetail detail,
        CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.PurchaseOrders.Add(order);
        await db.SaveChangesAsync(cancellationToken);
        detail.PurchaseOrderId = order.Id;
        db.PurchaseOrderDetails.Add(detail);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<PurchaseOrder>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.PurchaseOrders.AsNoTracking()
            .OrderByDescending(x => x.OrderDate)
            .ThenByDescending(x => x.Id)
            .Take(100)
            .ToListAsync(cancellationToken);
}
