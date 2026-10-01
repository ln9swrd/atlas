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
    }

    public async Task UpdateAsync(Item item, CancellationToken cancellationToken = default)
    {
        db.Items.Update(item);
        await db.SaveChangesAsync(cancellationToken);
    }

    public async Task DeactivateAsync(long id, CancellationToken cancellationToken = default)
    {
        var item = await db.Items.SingleAsync(x => x.Id == id, cancellationToken);
        item.IsActive = false;
        item.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
    }
}
