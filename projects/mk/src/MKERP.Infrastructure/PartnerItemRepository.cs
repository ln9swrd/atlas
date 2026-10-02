using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class PartnerItemRepository(ERPDbContext db) : IPartnerItemRepository
{
    public async Task<IReadOnlyList<PartnerItem>> GetActiveAsync(long? partnerId = null, CancellationToken cancellationToken = default)
    {
        var query = db.PartnerItems.AsNoTracking().Where(x => x.IsActive);
        if (partnerId.HasValue) query = query.Where(x => x.PartnerId == partnerId.Value);
        return await query.OrderBy(x => x.PartnerId).ThenBy(x => x.ItemId).ToListAsync(cancellationToken);
    }

    public async Task AddAsync(PartnerItem partnerItem, CancellationToken cancellationToken = default)
    {
        db.PartnerItems.Add(partnerItem);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PARTNER_ITEM", partnerItem.Id, "CREATE", null, partnerItem, cancellationToken: cancellationToken);
    }

    public async Task UpdateAsync(PartnerItem partnerItem, CancellationToken cancellationToken = default)
    {
        var before = await db.PartnerItems.AsNoTracking().SingleAsync(x => x.Id == partnerItem.Id, cancellationToken);
        db.PartnerItems.Update(partnerItem);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PARTNER_ITEM", partnerItem.Id, "UPDATE", before, partnerItem, cancellationToken: cancellationToken);
    }

    public async Task DeactivateAsync(long id, CancellationToken cancellationToken = default)
    {
        var row = await db.PartnerItems.SingleAsync(x => x.Id == id, cancellationToken);
        var before = new PartnerItem { Id = row.Id, PartnerId = row.PartnerId, ItemId = row.ItemId, PartnerItemCode = row.PartnerItemCode, PartnerItemName = row.PartnerItemName, IsActive = row.IsActive };
        row.IsActive = false;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PARTNER_ITEM", row.Id, "DEACTIVATE", before, row, "실제 삭제 없음", cancellationToken);
    }
}
