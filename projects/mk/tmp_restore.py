from pathlib import Path
def restore(fn, sig, marker, block):
 p=Path(fn); s=p.read_text(encoding="utf-8"); a=s.index("    public async Task AddAsync("); b=s.index(marker,a); p.write_text(s[:a]+block+s[b:],encoding="utf-8")
restore(r"D:\Atlas\projects\mk\src\MKERP.Infrastructure\SalesOrderRepository.cs","", "    public async Task ConfirmAsync", """    public async Task AddAsync(SalesOrder order, SalesOrderDetail detail, CancellationToken cancellationToken = default)
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

""")
restore(r"D:\Atlas\projects\mk\src\MKERP.Infrastructure\PurchaseOrderRepository.cs","", "    public async Task ConfirmAsync", """    public async Task AddAsync(PurchaseOrder order, PurchaseOrderDetail detail, CancellationToken cancellationToken = default)
    {
        await using var tx = await db.Database.BeginTransactionAsync(cancellationToken);
        db.PurchaseOrders.Add(order); await db.SaveChangesAsync(cancellationToken);
        detail.PurchaseOrderId = order.Id; db.PurchaseOrderDetails.Add(detail); await db.SaveChangesAsync(cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER", order.Id, "CREATE", null, order, cancellationToken: cancellationToken);
        await AuditLogger.WriteAsync(db, "TB_PURCHASE_ORDER_DETAIL", detail.Id, "CREATE", null, detail, cancellationToken: cancellationToken);
        await tx.CommitAsync(cancellationToken);
    }

""")
print("restored")
