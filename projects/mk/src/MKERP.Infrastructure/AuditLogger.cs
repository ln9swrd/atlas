using System.Text.Json;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public static class AuditLogger
{
    public static async Task WriteAsync(
        ERPDbContext db, string entityName, long? entityId, string action,
        object? before, object? after, string? note = null,
        CancellationToken cancellationToken = default)
    {
        var actionId = await CodeResolver.GetRequiredIdAsync(db, "AUDIT_ACTION", action, cancellationToken);
        db.Set<AuditLog>().Add(new AuditLog
        {
            EntityName = entityName,
            EntityId = entityId,
            ActionId = actionId,
            Actor = Environment.UserName,
            OccurredAt = DateTime.UtcNow,
            BeforeJson = before is null ? null : JsonSerializer.Serialize(before),
            AfterJson = after is null ? null : JsonSerializer.Serialize(after),
            Note = note
        });
        await db.SaveChangesAsync(cancellationToken);
    }
}
