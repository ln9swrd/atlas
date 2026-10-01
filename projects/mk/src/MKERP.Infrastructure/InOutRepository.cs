using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class InOutRepository(ERPDbContext db) : IInOutRepository
{
    public async Task<string> GetNextDocumentNoAsync(DateTime movementDate, CancellationToken cancellationToken = default)
    {
        var pattern = await db.SystemSettings.AsNoTracking()
            .Where(x => x.Key == "DOC_NO.INOUT").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", movementDate.ToString("yyyyMM"));
        var marker = "{seq4}";
        var prefixText = prefix[..prefix.IndexOf(marker, StringComparison.Ordinal)];
        var count = await db.InOuts.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        return pattern.Replace("{yyyyMM}", movementDate.ToString("yyyyMM"))
            .Replace(marker, (count + 1).ToString("D4"));
    }

    public async Task AddAsync(InOut header, InOutDetail detail, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.InOuts.Add(header);
        await db.SaveChangesAsync(cancellationToken);
        detail.InOutId = header.Id;
        db.InOutDetails.Add(detail);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_INOUT", header.Id, "CREATE", null, header, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_INOUT_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<InOut>> GetRecentAsync(CancellationToken cancellationToken = default)
    {
        return await db.InOuts.AsNoTracking().OrderByDescending(x => x.MovementDate)
            .ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
    }    public async Task<IReadOnlyList<InventoryRow>> GetInventoryAsync(DateTime asOfDate, CancellationToken cancellationToken = default)
    {
        var items = await db.Items.AsNoTracking().Where(x => x.IsActive).OrderBy(x => x.Code).ToListAsync(cancellationToken);
        var movements = await db.InOuts.AsNoTracking()
            .Where(x => x.MovementDate <= asOfDate && x.StatusCode != "CANCELLED")
            .Join(db.InOutDetails.AsNoTracking(), h => h.Id, d => d.InOutId, (h, d) => new { h, d })
            .ToListAsync(cancellationToken);

        return items.Select(item =>
        {
            var rows = movements.Where(x => x.d.ItemId == item.Id);
            var inbound = rows.Where(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST")
                .Sum(x => x.d.Quantity);
            var outbound = rows.Where(x => x.h.MovementTypeCode is "OUT" or "LOSS")
                .Sum(x => x.d.Quantity);
            var before = rows.Where(x => x.h.MovementDate < asOfDate);
            var opening = before.Where(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST")
                .Sum(x => x.d.Quantity) - before.Where(x => x.h.MovementTypeCode is "OUT" or "LOSS")
                .Sum(x => x.d.Quantity);
            var today = rows.Where(x => x.h.MovementDate == asOfDate);
            var dayIn = today.Where(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST").Sum(x => x.d.Quantity);
            var dayOut = today.Where(x => x.h.MovementTypeCode is "OUT" or "LOSS").Sum(x => x.d.Quantity);
            return new InventoryRow { ItemId = item.Id, ItemCode = item.Code, ItemName = item.Name,
                Opening = opening, Inbound = dayIn, Outbound = dayOut };
        }).ToList();
    }
}