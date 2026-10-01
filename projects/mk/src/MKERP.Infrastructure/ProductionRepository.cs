using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class ProductionRepository(ERPDbContext db) : IProductionRepository
{
    public async Task<string> GetNextDocumentNoAsync(DateTime productionDate, CancellationToken cancellationToken = default)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.PRODUCTION").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", productionDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.Productions.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        return pattern.Replace("{yyyyMM}", productionDate.ToString("yyyyMM")).Replace("{seq4}", (count + 1).ToString("D4"));
    }

    public async Task CompleteAsync(Production production, ProductionDetail detail, string mkLotNo, CancellationToken cancellationToken = default)
    {
        var inTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "IN", cancellationToken);
        var lossTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "LOSS", cancellationToken);
        var productionSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "PRODUCTION", cancellationToken);
        var defectSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "PRODUCTION_DEFECT", cancellationToken);
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.Productions.Add(production);
        await db.SaveChangesAsync(cancellationToken);
        detail.ProductionId = production.Id;
        db.ProductionDetails.Add(detail);
        await db.SaveChangesAsync(cancellationToken);

        var lot = await db.Lots.SingleOrDefaultAsync(x => x.MkLotNo == mkLotNo.Trim(), cancellationToken);
        if (lot is null) { lot = new Lot { MkLotNo = mkLotNo.Trim(), CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow }; db.Lots.Add(lot); await db.SaveChangesAsync(cancellationToken); }
        await AddMovementAsync(inTypeId, detail.ProductionQty, productionSourceId, production.Id, production.ProductionDate, detail.ItemId, lot.Id, null, cancellationToken);
        if (detail.DefectQty > 0)
            await AddMovementAsync(lossTypeId, detail.DefectQty, defectSourceId, production.Id, production.ProductionDate, detail.ItemId, lot.Id, null, cancellationToken);

        await AuditLogger.WriteAsync(db, "TB_PRODUCTION", production.Id, "CREATE", null, production, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PRODUCTION_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task CancelAsync(long productionId, CancellationToken cancellationToken = default)
    {
        var cancelledStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CANCELLED", cancellationToken);
        var productionSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "PRODUCTION", cancellationToken);
        var defectSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "PRODUCTION_DEFECT", cancellationToken);
        var cancelSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "PRODUCTION_CANCEL", cancellationToken);
        var inTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "IN", cancellationToken);
        var outTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OUT", cancellationToken);
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var production = await db.Productions.SingleOrDefaultAsync(x => x.Id == productionId, cancellationToken)
            ?? throw new InvalidOperationException("생산 문서를 찾을 수 없습니다.");
        if (production.StatusId == cancelledStatusId)
            throw new InvalidOperationException("이미 취소된 생산 문서입니다.");

        var movements = await db.InOuts.Where(x => x.SourceId == productionId &&
            (x.SourceTypeId == productionSourceId || x.SourceTypeId == defectSourceId) &&
            x.StatusId != cancelledStatusId).ToListAsync(cancellationToken);
        if (movements.Count == 0)
            throw new InvalidOperationException("생산에 연결된 입출고 내역이 없습니다.");

        var movementIds = movements.Select(x => x.Id).ToList();
        var details = await db.InOutDetails.Where(x => movementIds.Contains(x.InOutId)).ToListAsync(cancellationToken);
        var netProduced = details.Join(movements, d => d.InOutId, h => h.Id, (d, h) => new { d, h })
            .GroupBy(x => x.d.ItemId)
            .ToDictionary(x => x.Key, x => x.Sum(v => v.h.MovementTypeId == inTypeId || v.h.MovementTypeId == openingTypeId || v.h.MovementTypeId == adjustTypeId ? v.d.Quantity : -v.d.Quantity));

        foreach (var pair in netProduced)
        {
            var available = await GetAvailableAsync(pair.Key, cancellationToken);
            if (available < pair.Value)
                throw new InvalidOperationException($"재고가 부족하여 생산 취소할 수 없습니다. 품목 ID {pair.Key}, 필요 {pair.Value}, 현재 {available}");
        }

        var now = DateTime.UtcNow;
        foreach (var movement in movements.OrderBy(x => x.MovementTypeId == "IN" ? 1 : 0))
        {
            movement.StatusId = cancelledStatusId;
            movement.UpdatedAt = now;
            foreach (var originalDetail in details.Where(x => x.InOutId == movement.Id))
            {
                var reverseType = movement.MovementTypeId == inTypeId ? outTypeId : inTypeId;
                await AddMovementAsync(reverseType, originalDetail.Quantity, cancelSourceId, production.Id, movement.MovementDate, originalDetail.ItemId, originalDetail.LotId, originalDetail.PartnerLotId, cancellationToken);
            }
        }

        production.StatusId = cancelledStatusId;
        production.UpdatedAt = now;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PRODUCTION", production.Id, "CANCEL", null, production, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private async Task<decimal> GetAvailableAsync(long itemId, CancellationToken cancellationToken)
    {
        var cancelledStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CANCELLED", cancellationToken);
        var inTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "IN", cancellationToken);
        var openingTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OPENING", cancellationToken);
        var adjustTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "ADJUST", cancellationToken);
        var outTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OUT", cancellationToken);
        var lossTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "LOSS", cancellationToken);
        var rows = await db.InOuts.AsNoTracking()
            .Where(x => x.StatusId != cancelledStatusId)
            .Join(db.InOutDetails.AsNoTracking().Where(x => x.ItemId == itemId), h => h.Id, d => d.InOutId, (h, d) => new { h.MovementTypeId, d.Quantity })
            .ToListAsync(cancellationToken);
        return rows.Where(x => x.MovementTypeId == inTypeId || x.MovementTypeId == openingTypeId || x.MovementTypeId == adjustTypeId).Sum(x => x.Quantity)
            - rows.Where(x => x.MovementTypeId == outTypeId || x.MovementTypeId == lossTypeId).Sum(x => x.Quantity);
    }

    private async Task AddMovementAsync(long typeId, decimal quantity, long sourceTypeId, long sourceId, DateTime date, long itemId, long? lotId, long? partnerLotId, CancellationToken cancellationToken)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.INOUT").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", date.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.InOuts.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        var documentNo = pattern.Replace("{yyyyMM}", date.ToString("yyyyMM")).Replace("{seq4}", (count + 1).ToString("D4"));
        var now = DateTime.UtcNow;
        var header = new InOut { DocumentNo = documentNo, MovementDate = date, MovementTypeId = typeId, SourceTypeId = sourceTypeId, SourceId = sourceId, StatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CONFIRMED", cancellationToken), CreatedAt = now, UpdatedAt = now };
        db.InOuts.Add(header);
        await db.SaveChangesAsync(cancellationToken);
        db.InOutDetails.Add(new InOutDetail { InOutId = header.Id, ItemId = itemId, LotId = lotId, PartnerLotId = partnerLotId, Quantity = quantity });
        await db.SaveChangesAsync(cancellationToken);
    }
}
