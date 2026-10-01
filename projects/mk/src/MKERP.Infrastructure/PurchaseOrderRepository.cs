using Microsoft.EntityFrameworkCore;
using MKERP.Application;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class PurchaseOrderRepository(ERPDbContext db) : IPurchaseOrderRepository
{
    public async Task<string> GetNextDocumentNoAsync(DateTime orderDate, CancellationToken cancellationToken = default)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.PURCHASE_ORDER").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.PurchaseOrders.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        return pattern.Replace("{yyyyMM}", orderDate.ToString("yyyyMM")).Replace("{seq4}", (count + 1).ToString("D4"));
    }

    public async Task AddAsync(PurchaseOrder order, IReadOnlyList<PurchaseOrderDetail> details, CancellationToken cancellationToken = default)
    {
        if (details.Count == 0) throw new ArgumentException("諛쒖＜ ?곸꽭媛 ?놁뒿?덈떎.", nameof(details));
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.PurchaseOrders.Add(order); await db.SaveChangesAsync(cancellationToken);
        foreach (var detail in details) { detail.PurchaseOrderId = order.Id; db.PurchaseOrderDetails.Add(detail); }
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        foreach (var detail in details)
            await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task UpdateAsync(PurchaseOrder order, IReadOnlyList<PurchaseOrderDetail> details, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var current = await db.PurchaseOrders.SingleAsync(x => x.Id == order.Id, cancellationToken);
        if (current.StatusId != "DRAFT") throw new InvalidOperationException("?묒꽦 ?곹깭??諛쒖＜留??섏젙?????덉뒿?덈떎.");
        var existing = await db.PurchaseOrderDetails.Where(x => x.PurchaseOrderId == order.Id).ToListAsync(cancellationToken);
        foreach (var row in existing)
            if (!details.Any(x => x.Id == row.Id)) row.IsActive = false;
        foreach (var row in details)
        {
            var target = existing.SingleOrDefault(x => x.Id == row.Id);
            if (target is null) { row.PurchaseOrderId = order.Id; row.IsActive = true; db.PurchaseOrderDetails.Add(row); }
            else
            {
                target.ItemId = row.ItemId; target.PriceId = row.PriceId;
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
            await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", row.Id, action, null, row, cancellationToken: cancellationToken);
        }
        foreach (var row in details.Where(x => existing.All(e => e.Id != x.Id)))
            await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", row.Id, "CREATE", null, row, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", current.Id, "UPDATE", null, current, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ConfirmAsync(long purchaseOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == purchaseOrderId, cancellationToken);
        if (order.StatusId != "DRAFT") throw new InvalidOperationException("?묒꽦以??곹깭??諛쒖＜留??뺤젙?????덉뒿?덈떎.");
        var before = Snapshot(order); order.StatusId = "CONFIRMED"; order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CONFIRM", before, order, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    public async Task ProcessAsync(long purchaseOrderId, decimal quantity, CancellationToken cancellationToken = default)
    {
        var detail = await db.PurchaseOrderDetails.AsNoTracking().SingleAsync(x => x.PurchaseOrderId == purchaseOrderId, cancellationToken);
        throw new InvalidOperationException("Lot??筌왖?類λ퉸????몃빍?? ?怨멸쉭 筌ｌ꼶??疫꿸퀡????????뤾쉭??");
    }

    public async Task ProcessDetailAsync(long purchaseOrderDetailId, decimal quantity, string mkLotNo, string partnerLotNo, CancellationToken cancellationToken = default)
    {
        if (quantity <= 0) throw new InvalidOperationException("??껎??롮쎗?? 0癰귣????뚣끉鍮???몃빍??");
        if (string.IsNullOrWhiteSpace(mkLotNo) || string.IsNullOrWhiteSpace(partnerLotNo))
            throw new InvalidOperationException("??껎?筌ｌ꼶??癒?뮉 MK Lot No?? 椰꾧퀡?믭㎗?Lot No揶쎛 ?袁⑹뒄??몃빍??");
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var detail = await db.PurchaseOrderDetails.SingleAsync(x => x.Id == purchaseOrderDetailId, cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == detail.PurchaseOrderId, cancellationToken);
        if (order.StatusId != "CONFIRMED") throw new InvalidOperationException("?類ㅼ젟 ?怨밴묶??獄쏆뮇竊쒙쭕???껎?筌ｌ꼶???????됰뮸??덈뼄.");
        var remaining = detail.OrderQty - detail.ProcessedQty;
        if (quantity > remaining) throw new InvalidOperationException($"??껎??遺얠쎗???λ뜃???됰뮸??덈뼄. ?遺얠쎗: {remaining:N2}");
        var lotPair = await EnsureLotsAsync(order.PartnerId, mkLotNo, partnerLotNo, cancellationToken);
        var movement = await CreateMovementAsync(order, detail, quantity, "IN", "PURCHASE_ORDER", cancellationToken);
        var movementDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
        movementDetail.LotId = lotPair.LotId;
        movementDetail.PartnerLotId = lotPair.PartnerLotId;
        await db.SaveChangesAsync(cancellationToken);
        await AddProcessHistoryAsync("PURCHASE_ORDER", detail.Id, movementDetail.Id, quantity, "PROCESS", null, cancellationToken);
        detail.ProcessedQty += quantity;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "PROCESS", null, detail, note: $"IN_QTY={quantity:N2},LOT={mkLotNo}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

    private async Task<(long LotId, long PartnerLotId)> EnsureLotsAsync(long partnerId, string mkLotNo, string partnerLotNo, CancellationToken cancellationToken)
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
    public async Task CancelAsync(long purchaseOrderId, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        var order = await db.PurchaseOrders.SingleAsync(x => x.Id == purchaseOrderId, cancellationToken);
        if (order.StatusId != "CONFIRMED") throw new InvalidOperationException("?類ㅼ젟 ?怨밴묶??獄쏆뮇竊쒙쭕??띯뫁???????됰뮸??덈뼄.");
        var details = await db.PurchaseOrderDetails.Where(x => x.PurchaseOrderId == purchaseOrderId).ToListAsync(cancellationToken);
        var movements = await db.InOuts.Where(x => x.SourceTypeId == "PURCHASE_ORDER" && x.SourceId == purchaseOrderId && x.StatusId != "CANCELLED").ToListAsync(cancellationToken);

        foreach (var detail in details)
        {
            var histories = await db.OrderProcessHistories.Where(x => x.SourceTypeId == "PURCHASE_ORDER" && x.SourceDetailId == detail.Id && x.ActionId == "PROCESS").OrderBy(x => x.Id).ToListAsync(cancellationToken);
            var processed = histories.Sum(x => x.ProcessQty);
            if (processed <= 0) continue;
            var available = await GetAvailableAsync(detail.ItemId, cancellationToken);
            if (available < processed) throw new InvalidOperationException($"?띯뫁????袁⑹뒄?????у첎? ?봔鈺곌퉲鍮??덈뼄. ?袁⑹삺 ???? {available:N2}, ???땾 ??롮쎗: {processed:N2}");
        }

        foreach (var movement in movements) { movement.StatusId = "CANCELLED"; movement.UpdatedAt = DateTime.UtcNow; }

        foreach (var detail in details)
        {
            var histories = await db.OrderProcessHistories.Where(x => x.SourceTypeId == "PURCHASE_ORDER" && x.SourceDetailId == detail.Id && x.ActionId == "PROCESS").OrderBy(x => x.Id).ToListAsync(cancellationToken);
            foreach (var history in histories)
            {
                var original = await db.InOutDetails.AsNoTracking().SingleAsync(x => x.Id == history.InOutDetailId, cancellationToken);
                var movement = await CreateMovementAsync(order, detail, history.ProcessQty, "OUT", "PURCHASE_ORDER_CANCEL", cancellationToken);
                var reverseDetail = await db.InOutDetails.SingleAsync(x => x.InOutId == movement.Id, cancellationToken);
                reverseDetail.LotId = original.LotId;
                reverseDetail.PartnerLotId = original.PartnerLotId;
                await db.SaveChangesAsync(cancellationToken);
                await AddProcessHistoryAsync("PURCHASE_ORDER", detail.Id, reverseDetail.Id, history.ProcessQty, "REVERSE", history.Id, cancellationToken);
            }
        }

        var before = Snapshot(order);
        order.StatusId = "CANCELLED";
        order.UpdatedAt = DateTime.UtcNow;
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CANCEL", before, order, note: $"REVERSE_OUT_QTY={details.Sum(x => x.ProcessedQty):N2}", cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }
    private async Task AddProcessHistoryAsync(string sourceType, long sourceDetailId, long inOutDetailId, decimal quantity, string actionCode, long? reversesHistoryId, CancellationToken cancellationToken)
    {
        db.OrderProcessHistories.Add(new OrderProcessHistory { SourceTypeId=sourceType, SourceDetailId=sourceDetailId, InOutDetailId=inOutDetailId, ProcessQty=quantity, ActionId=actionCode, ReversesHistoryId=reversesHistoryId, CreatedAt=DateTime.UtcNow });
        await db.SaveChangesAsync(cancellationToken);
    }

    private static PurchaseOrder Snapshot(PurchaseOrder x) => new() { Id=x.Id, DocumentNo=x.DocumentNo, OrderDate=x.OrderDate, PartnerId=x.PartnerId, DueDate=x.DueDate, StatusId=x.StatusId, Note=x.Note, CreatedAt=x.CreatedAt, UpdatedAt=x.UpdatedAt };

    private async Task<decimal> GetAvailableAsync(long itemId, CancellationToken cancellationToken) =>
        (await db.InOuts.AsNoTracking().Where(x => x.StatusId != "CANCELLED").Join(db.InOutDetails, h => h.Id, d => d.InOutId, (h,d) => new {h,d}).Where(x => x.d.ItemId == itemId).ToListAsync(cancellationToken)).Sum(x => x.h.MovementTypeId is "IN" or "OPENING" or "ADJUST" ? x.d.Quantity : -x.d.Quantity);

    private async Task<InOut> CreateMovementAsync(PurchaseOrder order, PurchaseOrderDetail detail, decimal quantity, string type, string source, CancellationToken cancellationToken)
    {
        var pattern = await db.SystemSettings.AsNoTracking().Where(x => x.Key == "DOC_NO.INOUT").Select(x => x.Value).SingleAsync(cancellationToken);
        var prefix = pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM"));
        var prefixText = prefix[..prefix.IndexOf("{seq4}", StringComparison.Ordinal)];
        var count = await db.InOuts.CountAsync(x => x.DocumentNo.StartsWith(prefixText), cancellationToken);
        var movement = new InOut { DocumentNo=pattern.Replace("{yyyyMM}", order.OrderDate.ToString("yyyyMM")).Replace("{seq4}", (count+1).ToString("D4")), MovementDate=order.OrderDate, MovementTypeId=type, PartnerId=order.PartnerId, SourceTypeId=source, SourceId=order.Id, StatusId="CONFIRMED", CreatedAt=DateTime.UtcNow, UpdatedAt=DateTime.UtcNow };
        db.InOuts.Add(movement); await db.SaveChangesAsync(cancellationToken);
        db.InOutDetails.Add(new InOutDetail { InOutId=movement.Id, ItemId=detail.ItemId, Quantity=quantity, UnitPrice=detail.AppliedUnitPrice, Amount=quantity * detail.AppliedUnitPrice });
        await db.SaveChangesAsync(cancellationToken);
        return movement;
    }

    public async Task<IReadOnlyList<PurchaseOrder>> GetRecentAsync(CancellationToken cancellationToken = default) =>
        await db.PurchaseOrders.AsNoTracking().OrderByDescending(x => x.OrderDate).ThenByDescending(x => x.Id).Take(100).ToListAsync(cancellationToken);
}
