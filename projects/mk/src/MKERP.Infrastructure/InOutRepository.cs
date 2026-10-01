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

    public async Task AddAsync(InOut header, IReadOnlyList<InOutDetail> details, CancellationToken cancellationToken = default)
    {
        if (details.Count == 0) throw new ArgumentException("입출고 상세가 없습니다.", nameof(details));
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.InOuts.Add(header);
        await db.SaveChangesAsync(cancellationToken);
        foreach (var detail in details) { detail.InOutId = header.Id; db.InOutDetails.Add(detail); }
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_INOUT", header.Id, "CREATE", null, header, cancellationToken: cancellationToken);
        foreach (var detail in details)
            await AuditLogger.WriteAsync(db, "TB_INOUT_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task<IReadOnlyList<InOut>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.InOuts.AsNoTracking().OrderByDescending(x => x.MovementDate)
            .ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<InOutLotRow>> GetRecentLotDetailsAsync(CancellationToken cancellationToken = default) =>
        await (from h in db.InOuts.AsNoTracking()
               join d in db.InOutDetails.AsNoTracking() on h.Id equals d.InOutId
               join i in db.Items.AsNoTracking() on d.ItemId equals i.Id
               join l0 in db.Lots.AsNoTracking() on d.LotId equals l0.Id into lots
               from l in lots.DefaultIfEmpty()
               join pl0 in db.PartnerLots.AsNoTracking() on d.PartnerLotId equals pl0.Id into partnerLots
               from pl in partnerLots.DefaultIfEmpty()
               orderby h.MovementDate descending, h.Id descending, d.Id
               select new InOutLotRow
               {
                   DocumentNo = h.DocumentNo, MovementDate = h.MovementDate, MovementTypeId = h.MovementTypeId,
                   ItemCode = i.Code, ItemName = i.Name,
                   MkLotNo = l == null ? string.Empty : l.MkLotNo,
                   PartnerLotNo = pl == null ? string.Empty : pl.PartnerLotNo,
                   Quantity = d.Quantity
               }).Take(500).ToListAsync(cancellationToken);

    public async Task<IReadOnlyList<InventoryRow>> GetInventoryAsync(DateTime asOfDate, CancellationToken cancellationToken = default)
    {
        var items = await db.Items.AsNoTracking().Where(x => x.IsActive).OrderBy(x => x.Code).ToListAsync(cancellationToken);
        var movements = await db.InOuts.AsNoTracking().Where(x => x.MovementDate <= asOfDate && x.StatusId != cancelledStatusId)
            .Join(db.InOutDetails.AsNoTracking(), h => h.Id, d => d.InOutId, (h, d) => new { h, d }).ToListAsync(cancellationToken);
        return items.Select(item =>
        {
            var rows = movements.Where(x => x.d.ItemId == item.Id);
            var inbound = rows.Where(x => x.h.MovementTypeId == inTypeId || x.h.MovementTypeId == openingTypeId || x.h.MovementTypeId == adjustTypeId).Sum(x => x.d.Quantity);
            var outbound = rows.Where(x => x.h.MovementTypeId == outTypeId || x.h.MovementTypeId == lossTypeId).Sum(x => x.d.Quantity);
            var before = rows.Where(x => x.h.MovementDate < asOfDate);
            var opening = before.Where(x => x.h.MovementTypeId == inTypeId || x.h.MovementTypeId == openingTypeId || x.h.MovementTypeId == adjustTypeId).Sum(x => x.d.Quantity)
                - before.Where(x => x.h.MovementTypeId == outTypeId || x.h.MovementTypeId == lossTypeId).Sum(x => x.d.Quantity);
            var today = rows.Where(x => x.h.MovementDate == asOfDate);
            var dayIn = today.Where(x => x.h.MovementTypeId == inTypeId || x.h.MovementTypeId == openingTypeId || x.h.MovementTypeId == adjustTypeId).Sum(x => x.d.Quantity);
            var dayOut = today.Where(x => x.h.MovementTypeId == outTypeId || x.h.MovementTypeId == lossTypeId).Sum(x => x.d.Quantity);
            return new InventoryRow { ItemId = item.Id, ItemCode = item.Code, ItemName = item.Name, Opening = opening, Inbound = dayIn, Outbound = dayOut };
        }).ToList();
    }

    public async Task<IReadOnlyList<LotInventoryRow>> GetLotInventoryAsync(DateTime asOfDate, CancellationToken cancellationToken = default)
    {
        var rows = await (from h in db.InOuts.AsNoTracking()
                          join d in db.InOutDetails.AsNoTracking() on h.Id equals d.InOutId
                          join i in db.Items.AsNoTracking() on d.ItemId equals i.Id
                          join l in db.Lots.AsNoTracking() on d.LotId equals l.Id
                          join pl0 in db.PartnerLots.AsNoTracking() on d.PartnerLotId equals pl0.Id into pls
                          from pl in pls.DefaultIfEmpty()
                          where h.MovementDate <= asOfDate && h.StatusId != "CANCELLED"
                          select new { h, d, i, l, pl }).ToListAsync(cancellationToken);

        return rows.GroupBy(x => new { x.d.LotId, x.d.PartnerLotId, x.l.MkLotNo, PartnerLotNo = x.pl == null ? "" : x.pl.PartnerLotNo, x.i.Code, x.i.Name })
            .Select(g => new LotInventoryRow
            {
                LotId = g.Key.LotId!.Value,
                PartnerLotId = g.Key.PartnerLotId,
                MkLotNo = g.Key.MkLotNo,
                PartnerLotNo = g.Key.PartnerLotNo,
                ItemCode = g.Key.Code,
                ItemName = g.Key.Name,
                Inbound = g.Where(x => x.h.MovementTypeId == inTypeId || x.h.MovementTypeId == openingTypeId || x.h.MovementTypeId == adjustTypeId).Sum(x => x.d.Quantity),
                Outbound = g.Where(x => x.h.MovementTypeId == outTypeId || x.h.MovementTypeId == lossTypeId).Sum(x => x.d.Quantity)
            }).OrderBy(x => x.ItemCode).ThenBy(x => x.MkLotNo).ThenBy(x => x.PartnerLotNo).ToList();
    }
    public async Task<(long LotId, long PartnerLotId)> EnsureLotsAsync(long partnerId, string mkLotNo, string partnerLotNo, CancellationToken cancellationToken = default)
    {
        var now = DateTime.UtcNow;
        var lot = await db.Lots.SingleOrDefaultAsync(x => x.MkLotNo == mkLotNo, cancellationToken);
        if (lot is null) { lot = new Lot { MkLotNo = mkLotNo, CreatedAt = now, UpdatedAt = now }; db.Lots.Add(lot); await db.SaveChangesAsync(cancellationToken); }
        var partnerLot = await db.PartnerLots.SingleOrDefaultAsync(x => x.PartnerId == partnerId && x.PartnerLotNo == partnerLotNo, cancellationToken);
        if (partnerLot is null) { partnerLot = new PartnerLot { PartnerId = partnerId, PartnerLotNo = partnerLotNo, CreatedAt = now, UpdatedAt = now }; db.PartnerLots.Add(partnerLot); await db.SaveChangesAsync(cancellationToken); }
        if (!await db.LotPartnerLots.AnyAsync(x => x.LotId == lot.Id && x.PartnerLotId == partnerLot.Id, cancellationToken))
        {
            db.LotPartnerLots.Add(new LotPartnerLot { LotId = lot.Id, PartnerLotId = partnerLot.Id, CreatedAt = now });
            await db.SaveChangesAsync(cancellationToken);
        }
        return (lot.Id, partnerLot.Id);
    }
}
