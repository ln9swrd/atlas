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
        var draftStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "DRAFT", cancellationToken);
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var current = await db.SalesOrders.SingleAsync(x => x.Id == order.Id, cancellationToken);
        if (current.StatusId != draftStatusId) throw new InvalidOperationException("작성 상태의 수주만 수정할 수 있습니다.");
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
        var draftStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "DRAFT", cancellationToken);
        var confirmedStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CONFIRMED", cancellationToken);
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusId != draftStatusId) throw new InvalidOperationException("작성중 상태의 수주만 확정할 수 있습니다.");
        var before = Snapshot(order);
        order.StatusId = confirmedStatusId; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CONFIRM", before, order, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ProcessAsync(long salesOrderId, decimal quantity, CancellationToken cancellationToken = default)
    {
        var detail = await db.SalesOrderDetails.AsNoTracking().SingleAsync(x => x.SalesOrderId == salesOrderId, cancellationToken);
        throw new InvalidOperationException("Lot을 지정해야 합니다. 상세 처리 기능을 사용하세요.");
    }

    public async Task ProcessDetailAsync(long salesOrderDetailId, decimal quantity, string mkLotNo, string partnerLotNo, CancellationToken cancellationToken = default)
    {
        var confirmedStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CONFIRMED", cancellationToken);
        var outTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OUT", cancellationToken);
        var salesSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "SALES_ORDER", cancellationToken);
        var processActionId = await CodeResolver.GetRequiredIdAsync(db, "ORDER_PROCESS_ACTION", "PROCESS", cancellationToken);
        if (quantity <= 0) throw new InvalidOperationException("출고수량은 0보다 커야 합니다.");
        if (string.IsNullOrWhiteSpace(mkLotNo) || string.IsNullOrWhiteSpace(partnerLotNo))
            throw new InvalidOperationException("출고 처리에는 MK Lot No와 거래처 Lot No가 필요합니다.");
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var detail = await db.SalesOrderDetails.SingleAsync(x => x.Id == salesOrderDetailId, cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == detail.SalesOrderId, cancellationToken);
        if (order.StatusId != confirmedStatusId) throw new InvalidOperationException("확정 상태의 수주만 출고 처리할 수 있습니다.");
        var remaining = detail.OrderQty - detail.ProcessedQty;
        if (quantity > remaining) throw new InvalidOperationException($"출고 수량이 잔량을 초과했습니다. 잔량: {remaining:N2}");
        var lot = await db.Lots.SingleOrDefaultAsync(x => x.MkLotNo == mkLotNo, cancellationToken)
            ?? throw new InvalidOperationException($"MK Lot을 찾을 수 없습니다: {mkLotNo}");
        var partnerLot = await db.PartnerLots.SingleOrDefaultAsync(x => x.PartnerId == order.PartnerId && x.PartnerLotNo == partnerLotNo, cancellationToken)
            ?? throw new InvalidOperationException($"거래처 Lot을 찾을 수 없습니다: {partnerLotNo}");
        if (!await db.LotPartnerLots.AnyAsync(x => x.LotId == lot.Id && x.PartnerLotId == partnerLot.Id, cancellationToken))
            throw new InvalidOperationException("선택한 MK Lot과 거래처 Lot의 관계가 등록되어 있지 않습니다.");
        var available = await GetLotAvailableAsync(detail.ItemId, lot.Id, partnerLot.Id, cancellationToken);
        if (available < quantity) throw new InvalidOperationException($"선택한 Lot의 재고가 부족합니다. 현재 재고: {available:N2}, 출고 요청: {quantity:N2}");
        var movement = await CreateMovementAsync(order, detail, quantity, outTypeId, salesSourceId, cancellationToken);
        var movementDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
        movementDetail.LotId = lot.Id;
        movementDetail.PartnerLotId = partnerLot.Id;
        await db.SaveChangesAsync(cancellationToken);
        await AddProcessHistoryAsync(salesSourceId, detail.Id, movementDetail.Id, quantity, processActionId, null, cancellationToken);
        detail.ProcessedQty += quantity;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "PROCESS", null, detail, note: $"OUT_QTY={quantity:N2},LOT={mkLotNo}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private async Task<decimal> GetLotAvailableAsync(long itemId, long lotId, long partnerLotId, CancellationToken cancellationToken)
    {
        var cancelledStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CANCELLED", cancellationToken);
        var inTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "IN", cancellationToken);
        var openingTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OPENING", cancellationToken);
        var adjustTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "ADJUST", cancellationToken);
        var outTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OUT", cancellationToken);
        var lossTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "LOSS", cancellationToken);
        var rows = await db.InOuts.AsNoTracking()
            .Where(x => x.StatusId != cancelledStatusId)
            .Join(db.InOutDetails.AsNoTracking(), h => h.Id, d => d.InOutId, (h,d) => new {h,d})
            .Where(x => x.d.ItemId == itemId && x.d.LotId == lotId && x.d.PartnerLotId == partnerLotId)
            .ToListAsync(cancellationToken);
        return rows.Where(x => x.h.MovementTypeId == inTypeId || x.h.MovementTypeId == openingTypeId || x.h.MovementTypeId == adjustTypeId).Sum(x => x.d.Quantity)
             - rows.Where(x => x.h.MovementTypeId == outTypeId || x.h.MovementTypeId == lossTypeId).Sum(x => x.d.Quantity);
    }
    public async Task CancelAsync(long salesOrderId, CancellationToken cancellationToken = default)
    {
        var confirmedStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CONFIRMED", cancellationToken);
        var cancelledStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CANCELLED", cancellationToken);
        var inTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "IN", cancellationToken);
        var salesSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "SALES_ORDER", cancellationToken);
        var cancelSourceId = await CodeResolver.GetRequiredIdAsync(db, "SOURCE_TYPE", "SALES_ORDER_CANCEL", cancellationToken);
        var processActionId = await CodeResolver.GetRequiredIdAsync(db, "ORDER_PROCESS_ACTION", "PROCESS", cancellationToken);
        var reverseActionId = await CodeResolver.GetRequiredIdAsync(db, "ORDER_PROCESS_ACTION", "REVERSE", cancellationToken);
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.SalesOrders.SingleAsync(x => x.Id == salesOrderId, cancellationToken);
        if (order.StatusId != confirmedStatusId) throw new InvalidOperationException("확정 상태의 수주만 취소할 수 있습니다.");
        var details = await db.SalesOrderDetails.Where(x => x.SalesOrderId == salesOrderId).ToListAsync(cancellationToken);
        var movements = await db.InOuts.Where(x => x.SourceTypeId == salesSourceId && x.SourceId == salesOrderId && x.StatusId != cancelledStatusId).ToListAsync(cancellationToken);
        foreach (var movement in movements) { movement.StatusId = cancelledStatusId; movement.UpdatedAt = DateTime.UtcNow; }

        foreach (var detail in details)
        {
            var histories = await db.OrderProcessHistories.Where(x => x.SourceTypeId == salesSourceId && x.SourceDetailId == detail.Id && x.ActionId == processActionId).OrderBy(x => x.Id).ToListAsync(cancellationToken);
            foreach (var history in histories)
            {
                var original = await db.InOutDetails.AsNoTracking().SingleAsync(x => x.Id == history.InOutDetailId, cancellationToken);
                var movement = await CreateMovementAsync(order, detail, history.ProcessQty, inTypeId, cancelSourceId, cancellationToken);
                var reverseDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
                reverseDetail.LotId = original.LotId;
                reverseDetail.PartnerLotId = original.PartnerLotId;
                await db.SaveChangesAsync(cancellationToken);
                await AddProcessHistoryAsync(salesSourceId, detail.Id, reverseDetail.Id, history.ProcessQty, reverseActionId, history.Id, cancellationToken);
            }
        }

        var before = Snapshot(order);
        order.StatusId = cancelledStatusId;
        order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CANCEL", before, order, note: $"REVERSE_IN_QTY={details.Sum(x => x.ProcessedQty):N2}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }
    private async Task AddProcessHistoryAsync(long sourceTypeId, long sourceDetailId, long inOutDetailId, decimal quantity, long actionId, long? reversesHistoryId, CancellationToken cancellationToken)
    {
        db.OrderProcessHistories.Add(new OrderProcessHistory { SourceTypeId=sourceTypeId, SourceDetailId=sourceDetailId, InOutDetailId=inOutDetailId, ProcessQty=quantity, ActionId=actionId, ReversesHistoryId=reversesHistoryId, CreatedAt=DateTime.UtcNow });
        await db.SaveChangesAsync(cancellationToken);
    }

    private static SalesOrder Snapshot(SalesOrder x) => new() { Id=x.Id, DocumentNo=x.DocumentNo, OrderDate=x.OrderDate, PartnerId=x.PartnerId, DueDate=x.DueDate, StatusId=x.StatusId, Note=x.Note, CreatedAt=x.CreatedAt, UpdatedAt=x.UpdatedAt };

    private async Task<decimal> GetAvailableAsync(long itemId, CancellationToken cancellationToken)
    {
        var cancelledStatusId = await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CANCELLED", cancellationToken);
        var inTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "IN", cancellationToken);
        var openingTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OPENING", cancellationToken);
        var adjustTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "ADJUST", cancellationToken);
        var outTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "OUT", cancellationToken);
        var lossTypeId = await CodeResolver.GetRequiredIdAsync(db, "INOUT_TYPE", "LOSS", cancellationToken);
        return
        (await db.InOuts.AsNoTracking().Where(x => x.StatusId != cancelledStatusId)
            .Join(db.InOutDetails, h => h.Id, d => d.InOutId, (h,d) => new {h,d}).Where(x => x.d.ItemId == itemId).ToListAsync(cancellationToken))
            .Sum(x => x.h.MovementTypeId == inTypeId || x.h.MovementTypeId == openingTypeId || x.h.MovementTypeId == adjustTypeId ? x.d.Quantity : -x.d.Quantity);
    }

    private async Task<InOut> CreateMovementAsync(SalesOrder order, SalesOrderDetail detail, decimal quantity, long typeId, long sourceTypeId, CancellationToken cancellationToken)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.INOUT").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.InOuts.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        var movement = new InOut { DocumentNo=pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM")).Replace("{seq4}", (count+1).ToString("D4")), MovementDate=order.OrderDate, MovementTypeId=typeId, PartnerId=order.PartnerId, SourceTypeId=sourceTypeId, SourceId=order.Id, StatusId=await CodeResolver.GetRequiredIdAsync(db, "DOCUMENT_STATUS", "CONFIRMED", cancellationToken), CreatedAt=DateTime.UtcNow, UpdatedAt=DateTime.UtcNow };
        db.InOuts.Add(movement); await db.SaveChangesAsync(cancellationToken);
        db.InOutDetails.Add(new InOutDetail { InOutId=movement.Id, ItemId=detail.ItemId, Quantity=quantity, UnitPrice=detail.AppliedUnitPrice, Amount=quantity * detail.AppliedUnitPrice });
        await db.SaveChangesAsync(cancellationToken);
        return movement;
    }

    public async Task<IReadOnlyList<SalesOrder>> GetRecentAsync(CancellationToken cancellationToken = default)
    {
        var orders = await db.SalesOrders.AsNoTracking().OrderByDescending(x => x.OrderDate).ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
        var partners = await db.Partners.AsNoTracking().ToDictionaryAsync(x => x.Id, x => x.Name, cancellationToken);
        var statuses = await new CodeRepository(db).GetActiveAsync("DOCUMENT_STATUS", cancellationToken);
        var statusNames = statuses.ToDictionary(x => x.Id, x => x.Name);
        foreach (var order in orders)
        {
            order.PartnerName = partners.GetValueOrDefault(order.PartnerId, string.Empty);
            order.StatusName = statusNames.GetValueOrDefault(order.StatusId, string.Empty);
        }
        return orders;
    }
}
