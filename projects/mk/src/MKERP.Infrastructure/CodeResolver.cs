using Microsoft.EntityFrameworkCore;

namespace MKERP.Infrastructure;

internal static class CodeResolver
{
    public static Task<long> GetRequiredIdAsync(ERPDbContext db, string groupKey, string key, CancellationToken cancellationToken) =>
        db.Codes.AsNoTracking()
            .Where(c => c.IsActive && c.Key == key && db.CodeGroups.Any(g => g.Id == c.CodeGroupId && g.IsActive && g.Key == groupKey))
            .Select(c => c.Id)
            .SingleAsync(cancellationToken);
}
