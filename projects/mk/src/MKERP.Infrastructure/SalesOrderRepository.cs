using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class SalesOrderRepository(ERPDbContext db) : ISalesOrderRepository
{
    public async Task<string> GetNextDocumentNoAsync(DateTime orderDate, CancellationToken cancellationToken = default)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.SALES_ORDER").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.SalesOrders.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        return pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM")).Replace("{seq4}", (count + 1).ToString("D4"));
    }

    public async Task AddAsync(SalesOrder order, IReadOnlyList<SalesOrderDetail> details, CancellationToken cancellationToken = default)
    {
        if (details.Count == 0) throw new ArgumentException("수주 상세가 없습니다.", nameof(details));
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.SalesOrders.Add(order);
        await db.SaveChangesAsync(cancellationToken);
        foreach (var detail in details) { detail.SalesOrderId = order.Id; db.SalesOrderDetails.Add(detail); }
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        foreach (var detail in details)
            await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task UpdateAsync(SalesOrder order, IReadOnlyList<SalesOrderDetail> details, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var current = await db.SalesOrders.SingleAsync(x => x.Id == order.Id, cancellationToken);
        if (current.StatusCode != "DRAFT") throw new InvalidOperationException("작성 상태의 수주만 수정할 수 있습니다.");
        var existing = await db.SalesOrderDetails.Where(x => x.SalesOrderId == order.Id).ToListAsync(cancellationToken);
        foreach (var row in existing)
            if (!details.Any(x => x.Id == row.Id)) row.IsActive = false;
        foreach (var row in details)
        {
            var target = existing.SingleOrDefault(x => x.Id == row.Id);
            if (target is null) { row.SalesOrderId = order.Id; row.IsActive = true; db.SalesOrderDetails.Add(row); }
            else
            {
                target.ItemId = row.ItemId; target.PartnerItemId = row.PartnerItemId; target.PriceId = row.PriceId;
                target.OrderQty = row.OrderQty; target.AppliedUnitPrice = row.AppliedUnitPrice; target.Amount = row.Amount;
                target.DueDate = row.DueDate; target.Note = row.Note; target.IsActive = true;
            }
        }
        current.PartnerId = order.PartnerId; current.OrderDate = order.OrderDate; current.DueDate = order.DueDate;
        current.Note = order.Note; current.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        foreach (var row in existing)
        {
            var action = row.IsActive ? "UPDATE" : "LOGICAL_DELETE";
            await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", row.Id, action, null, row, cancellationToken: cancellationToken);
        }
        foreach (var row in details.Where(x => existing.All(e => e.Id != x.Id)))
            await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", row.Id, "CREATE", null, row, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", current.Id, "UPDATE", null, current, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ConfirmAsync(long salesOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusCode != "DRAFT") throw new InvalidOperationException("작성중 상태의 수주만 확정할 수 있습니다.");
        var before = Snapshot(order);
        order.StatusCode = "CONFIRMED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CONFIRM", before, order, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ProcessAsync(long salesOrderId, decimal quantity, CancellationToken cancellationToken = default)
    {
        var detail = await db.SalesOrderDetails.AsNoTracking().SingleAsync(x => x.SalesOrderId == salesOrderId, cancellationToken);
        throw new InvalidOperationException("Lot??吏?뺥빐???⑸땲?? ?곸꽭 泥섎━ 湲곕뒫???ъ슜?섏꽭??");
    }

    public async Task ProcessDetailAsync(long salesOrderDetailId, decimal quantity, string mkLotNo, string partnerLotNo, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0) throw new InvalidOperationException("異쒓퀬?섎웾? 0蹂대떎 而ㅼ빞 ?⑸땲??");
        if (string.IsNullOrWhiteSpace(mkLotNo) || string.IsNullOrWhiteSpace(partnerLotNo))
            throw new InvalidOperationException("異쒓퀬 泥섎━?먮뒗 MK Lot No? 嫄곕옒泥?Lot No媛 ?꾩슂?⑸땲??");
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var detail = await db.SalesOrderDetails.SingleAsync(x => x.Id == salesOrderDetailId, cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == detail.SalesOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("?뺤젙 ?곹깭???섏＜留?異쒓퀬 泥섎━?????덉뒿?덈떎.");
        var remaining = detail.OrderQty - detail.ProcessedQty;
        if (quantity > remaining) throw new InvalidOperationException($"異쒓퀬 ?붾웾??珥덇낵?덉뒿?덈떎. ?붾웾: {remaining:N2}");
        var lot = await db.Lots.SingleOrDefaultAsync(x => x.MkLotNo == mkLotNo, cancellationToken)
            ?? throw new InvalidOperationException($"MK Lot??李얠쓣 ???놁뒿?덈떎: {mkLotNo}");
        var partnerLot = await db.PartnerLots.SingleOrDefaultAsync(x => x.PartnerId == order.PartnerId && x.PartnerLotNo == partnerLotNo, cancellationToken)
            ?? throw new InvalidOperationException($"嫄곕옒泥?Lot??李얠쓣 ???놁뒿?덈떎: {partnerLotNo}");
        if (!await db.LotPartnerLots.AnyAsync(x => x.LotId == lot.Id && x.PartnerLotId == partnerLot.Id, cancellationToken))
            throw new InvalidOperationException("?낅젰??MK Lot怨?嫄곕옒泥?Lot??愿怨꾧? ?깅줉?섏뼱 ?덉? ?딆뒿?덈떎.");
        var available = await GetLotAvailableAsync(detail.ItemId, lot.Id, partnerLot.Id, cancellationToken);
        if (available < quantity) throw new InvalidOperationException($"?좏깮??Lot ?ш퀬媛 遺議깊빀?덈떎. ?꾩옱 ?ш퀬: {available:N2}, 異쒓퀬 ?붿껌: {quantity:N2}");
        var movement = await CreateMovementAsync(order, detail, quantity, "OUT", "SALES_ORDER", cancellationToken);
        var movementDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
        movementDetail.LotId = lot.Id;
        movementDetail.PartnerLotId = partnerLot.Id;
        await db.SaveChangesAsync(cancellationToken);
        await AddProcessHistoryAsync("SALES_ORDER", detail.Id, movementDetail.Id, quantity, "PROCESS", null, cancellationToken);
        detail.ProcessedQty += quantity;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "PROCESS", null, detail, note: $"OUT_QTY={quantity:N2},LOT={mkLotNo}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private async Task<decimal> GetLotAvailableAsync(long itemId, long lotId, long partnerLotId, CancellationToken cancellationToken)
    {
        var rows = await db.InOuts.AsNoTracking()
            .Where(x => x.StatusCode != "CANCELLED")
            .Join(db.InOutDetails.AsNoTracking(), h => h.Id, d => d.InOutId, (h,d) => new {h,d})
            .Where(x => x.d.ItemId == itemId && x.d.LotId == lotId && x.d.PartnerLotId == partnerLotId)
            .ToListAsync(cancellationToken);
        return rows.Where(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST").Sum(x => x.d.Quantity)
             - rows.Where(x => x.h.MovementTypeCode is "OUT" or "LOSS").Sum(x => x.d.Quantity);
    }
    public async Task CancelAsync(long salesOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusCode != "CONFIRMED") throw new InvalidOperationException("?뺤젙 ?곹깭???섏＜留?痍⑥냼?????덉뒿?덈떎.");
        var details = await db.SalesOrderDetails.Where(x => x.SalesOrderId == salesOrderId).ToListAsync(cancellationToken);
        var movements = await db.InOuts.Where(x => x.SourceTypeCode == "SALES_ORDER" && x.SourceId == salesOrderId && x.StatusCode != "CANCELLED").ToListAsync(cancellationToken);
        foreach (var movement in movements) { movement.StatusCode = "CANCELLED"; movement.UpdatedAt = DateTime.UtcNow; }

        foreach (var detail in details)
        {
            var histories = await db.OrderProcessHistories.Where(x => x.SourceTypeCode == "SALES_ORDER" && x.SourceDetailId == detail.Id && x.ActionCode == "PROCESS").OrderBy(x => x.Id).ToListAsync(cancellationToken);
            foreach (var history in histories)
            {
                var original = await db.InOutDetails.AsNoTracking().SingleAsync(x => x.Id == history.InOutDetailId, cancellationToken);
                var movement = await CreateMovementAsync(order, detail, history.ProcessQty, "IN", "SALES_ORDER_CANCEL", cancellationToken);
                var reverseDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
                reverseDetail.LotId = original.LotId;
                reverseDetail.PartnerLotId = original.PartnerLotId;
                await db.SaveChangesAsync(cancellationToken);
                await AddProcessHistoryAsync("SALES_ORDER", detail.Id, reverseDetail.Id, history.ProcessQty, "REVERSE", history.Id, cancellationToken);
            }
        }

        var before = Snapshot(order);
        order.StatusCode = "CANCELLED";
        order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CANCEL", before, order, note: $"REVERSE_IN_QTY={details.Sum(x => x.ProcessedQty):N2}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }
    private async Task AddProcessHistoryAsync(string sourceType, long sourceDetailId, long inOutDetailId, decimal quantity, string actionCode, long? reversesHistoryId, CancellationToken cancellationToken)
    {
        db.OrderProcessHistories.Add(new OrderProcessHistory { SourceTypeCode=sourceType, SourceDetailId=sourceDetailId, InOutDetailId=inOutDetailId, ProcessQty=quantity, ActionCode=actionCode, ReversesHistoryId=reversesHistoryId, CreatedAt=DateTime.UtcNow });
        await db.SaveChangesAsync(cancellationToken);
    }

    private static SalesOrder Snapshot(SalesOrder x) => new() { Id=x.Id, DocumentNo=x.DocumentNo, OrderDate=x.OrderDate, PartnerId=x.PartnerId, DueDate=x.DueDate, StatusCode=x.StatusCode, Note=x.Note, CreatedAt=x.CreatedAt, UpdatedAt=x.UpdatedAt };

    private async Task<decimal> GetAvailableAsync(long itemId, CancellationToken cancellationToken) =>
        (await db.InOuts.AsNoTracking().Where(x => x.StatusCode != "CANCELLED")
            .Join(db.InOutDetails, h => h.Id, d => d.InOutId, (h,d) => new {h,d}).Where(x => x.d.ItemId == itemId).ToListAsync(cancellationToken))
            .Sum(x => x.h.MovementTypeCode is "IN" or "OPENING" or "ADJUST" ? x.d.Quantity : -x.d.Quantity);

    private async Task<InOut> CreateMovementAsync(SalesOrder order, SalesOrderDetail detail, decimal quantity, string type, string source, CancellationToken cancellationToken)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.INOUT").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.InOuts.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        var movement = new InOut { DocumentNo=pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM")).Replace("{seq4}", (count+1).ToString("D4")), MovementDate=order.OrderDate, MovementTypeCode=type, PartnerId=order.PartnerId, SourceTypeCode=source, SourceId=order.Id, StatusCode="CONFIRMED", CreatedAt=DateTime.UtcNow, UpdatedAt=DateTime.UtcNow };
        db.InOuts.Add(movement); await db.SaveChangesAsync(cancellationToken);
        db.InOutDetails.Add(new InOutDetail { InOutId=movement.Id, ItemId=detail.ItemId, Quantity=quantity, UnitPrice=detail.AppliedUnitPrice, Amount=quantity * detail.AppliedUnitPrice });
        await db.SaveChangesAsync(cancellationToken);
        return movement;
    }

    public async Task<IReadOnlyList<SalesOrder>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.SalesOrders.AsNoTracking().OrderByDescending(x => x.OrderDate).ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
}
