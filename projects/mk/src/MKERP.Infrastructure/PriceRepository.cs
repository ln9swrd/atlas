using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class PriceRepository(ERPDbContext db) : IPriceRepository
{
    public async Task<IReadOnlyList<Price>> GetActiveAsync(
        long? partnerId = null,
        long? itemId = null,
        CancellationToken cancellationToken = default)
    {
        var query = db.Prices.AsNoTracking().Where(x => x.IsActive);
        if (partnerId.HasValue) query = query.Where(x => x.PartnerId == partnerId.Value);
        if (itemId.HasValue) query = query.Where(x => x.ItemId == itemId.Value);
        return await query
            .OrderBy(x => x.PartnerId)
            .ThenBy(x => x.ItemId)
            .ThenByDescending(x => x.EffectiveFrom)
            .ThenByDescending(x => x.Priority)
            .ThenByDescending(x => x.Id)
            .ToListAsync(cancellationToken);
    }

    public Task<Price?> GetApplicableAsync(
        long partnerId,
        long itemId,
        DateTime orderDate,
        CancellationToken cancellationToken = default) =>
        db.Prices.AsNoTracking()
            .Where(x => x.IsActive
                && x.PartnerId == partnerId
                && x.ItemId == itemId
                && x.EffectiveFrom <= orderDate)
            .OrderByDescending(x => x.EffectiveFrom)
            .ThenByDescending(x => x.Priority)
            .ThenByDescending(x => x.Id)
            .FirstOrDefaultAsync(cancellationToken);
    public async Task AddAsync(Price price, CancellationToken cancellationToken = default)
    {
        db.Prices.Add(price);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PRICE", price.Id, "CREATE", null, price, cancellationToken: cancellationToken);
    }

    public async Task DeactivateAsync(long id, CancellationToken cancellationToken = default)
    {
        var price = await db.Prices.SingleAsync(x => x.Id == id, cancellationToken);
        var before = new Price
        {
            Id = price.Id, PartnerId = price.PartnerId, ItemId = price.ItemId,
            UnitPrice = price.UnitPrice, EffectiveFrom = price.EffectiveFrom,
            Priority = price.Priority, IsActive = price.IsActive,
            CreatedAt = price.CreatedAt, UpdatedAt = price.UpdatedAt
        };
        price.IsActive = false;
        price.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PRICE", price.Id, "DEACTIVATE", before, price, "실제 삭제 없음", cancellationToken);
    }
}
