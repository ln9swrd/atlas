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
