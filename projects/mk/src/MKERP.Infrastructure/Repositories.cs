using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class SettingsRepository(ERPDbContext db) : ISettingsRepository
{
    public Task<SystemSetting?> GetAsync(string key, CancellationToken cancellationToken = default) =>
        db.SystemSettings.AsNoTracking().SingleOrDefaultAsync(x => x.Key == key, cancellationToken);

    public async Task<string?> GetValueAsync(string key, CancellationToken cancellationToken = default) =>
        (await GetAsync(key, cancellationToken))?.Value;
}

public sealed class CodeRepository(ERPDbContext db) : ICodeRepository
{
    public async Task<IReadOnlyList<Code>> GetActiveAsync(string groupKey, CancellationToken cancellationToken = default) =>
        await db.Codes.AsNoTracking()
            .Where(x => x.IsActive && db.CodeGroups.Any(g => g.Id == x.CodeGroupId && g.Key == groupKey && g.IsActive))
            .OrderBy(x => x.SortOrder)
            .ToListAsync(cancellationToken);
}

public sealed class ItemRepository(ERPDbContext db) : IItemRepository
{
    public async Task<IReadOnlyList<Item>> GetActiveAsync(CancellationToken cancellationToken = default) =>
        await db.Items.AsNoTracking().Where(x => x.IsActive).OrderBy(x => x.Code).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<ItemGrade>> GetGradesAsync(CancellationToken cancellationToken = default) =>
        await db.ItemGrades.AsNoTracking().Where(x => x.IsActive).OrderBy(x => x.Code).ToListAsync(cancellationToken);

    public async Task AddAsync(Item item, CancellationToken cancellationToken = default)
    {
        db.Items.Add(item);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_ITEM", item.Id, "CREATE", null, item, cancellationToken: cancellationToken);
    }

    public async Task UpdateAsync(Item item, CancellationToken cancellationToken = default)
    {
        var before = await db.Items.AsNoTracking().SingleAsync(x => x.Id == item.Id, cancellationToken);
        db.Items.Update(item);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_ITEM", item.Id, "UPDATE", before, item, cancellationToken: cancellationToken);
    }

    public async Task DeactivateAsync(long id, CancellationToken cancellationToken = default)
    {
        var item = await db.Items.SingleAsync(x => x.Id == id, cancellationToken);
        var before = new Item { Id = item.Id, Code = item.Code, Name = item.Name, CategoryId = item.CategoryId, GradeId = item.GradeId, UnitCode = item.UnitCode, IsActive = item.IsActive, CreatedAt = item.CreatedAt, UpdatedAt = item.UpdatedAt };
        item.IsActive = false;
        item.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_ITEM", item.Id, "DEACTIVATE", before, item, "실제 삭제 없음", cancellationToken);
    }
}

public sealed class PartnerRepository(ERPDbContext db) : IPartnerRepository
{
    public async Task<IReadOnlyList<Partner>> GetActiveAsync(CancellationToken cancellationToken = default) =>
        await db.Partners.AsNoTracking().Where(x => x.IsActive).OrderBy(x => x.Code).ToListAsync(cancellationToken);

    public async Task AddAsync(Partner partner, CancellationToken cancellationToken = default)
    {
        db.Partners.Add(partner);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PARTNER", partner.Id, "CREATE", null, partner, cancellationToken: cancellationToken);
    }

    public async Task UpdateAsync(Partner partner, CancellationToken cancellationToken = default)
    {
        var before = await db.Partners.AsNoTracking().SingleAsync(x => x.Id == partner.Id, cancellationToken);
        db.Partners.Update(partner);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PARTNER", partner.Id, "UPDATE", before, partner, cancellationToken: cancellationToken);
    }

    public async Task DeactivateAsync(long id, CancellationToken cancellationToken = default)
    {
        var partner = await db.Partners.SingleAsync(x => x.Id == id, cancellationToken);
        var before = new Partner { Id = partner.Id, Code = partner.Code, Name = partner.Name, TypeId = partner.TypeId, IsActive = partner.IsActive, CreatedAt = partner.CreatedAt, UpdatedAt = partner.UpdatedAt };
        partner.IsActive = false;
        partner.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PARTNER", partner.Id, "DEACTIVATE", before, partner, "실제 삭제 없음", cancellationToken);
    }
}
