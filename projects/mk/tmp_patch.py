from pathlib import Path

def replace(fn, old, new):
    p=Path(fn)
    s=p.read_text(encoding="utf-8")
    if old not in s:
        raise RuntimeError(f"not found: {fn}")
    p.write_text(s.replace(old,new), encoding="utf-8")

replace(r"D:\Atlas\projects\mk\src\MKERP.Infrastructure\SalesOrderRepository.cs", """    public async Task AddAsync(SalesOrder order, SalesOrderDetail detail, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.SalesOrders.Add(order);
        await db.SaveChangesAsync(cancellationToken);
        detail.SalesOrderId = order.Id;
        db.SalesOrderDetails.Add(detail);
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }
""", """    public async Task AddAsync(SalesOrder order, IReadOnlyList<SalesOrderDetail> details, CancellationToken cancellationToken = default)
    {
        if (details.Count == 0) throw new InvalidOperationException("수주 상세가 없습니다.");
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.SalesOrders.Add(order);
        await db.SaveChangesAsync(cancellationToken);
        foreach (var detail in details) { detail.SalesOrderId = order.Id; db.SalesOrderDetails.Add(detail); }
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_SALES_ORDER", order.Id, "CREATE", null, order, note: $"DETAIL_COUNT={details.Count}", cancellationToken: cancellationToken);
        foreach (var detail in details) await AuditLogger.WriteAsync(db, "TB_SALES_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }
""")

replace(r"D:\Atlas\projects\mk\src\MKERP.Infrastructure\PurchaseOrderRepository.cs", """    public async Task AddAsync(PurchaseOrder order, PurchaseOrderDetail detail, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.PurchaseOrders.Add(order); await db.SaveChangesAsync(cancellationToken);
        detail.PurchaseOrderId = order.Id; db.PurchaseOrderDetails.Add(detail); await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }
""", """    public async Task AddAsync(PurchaseOrder order, IReadOnlyList<PurchaseOrderDetail> details, CancellationToken cancellationToken = default)
    {
        if (details.Count == 0) throw new InvalidOperationException("발주 상세가 없습니다.");
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.PurchaseOrders.Add(order); await db.SaveChangesAsync(cancellationToken);
        foreach (var detail in details) { detail.PurchaseOrderId = order.Id; db.PurchaseOrderDetails.Add(detail); }
        await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CREATE", null, order, note: $"DETAIL_COUNT={details.Count}", cancellationToken: cancellationToken);
        foreach (var detail in details) await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }
""")
print("repository replacements complete")
