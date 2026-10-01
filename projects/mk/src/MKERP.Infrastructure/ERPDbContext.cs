using Microsoft.EntityFrameworkCore;
using MKERP.Domain;

namespace MKERP.Infrastructure;

public sealed class ERPDbContext(DbContextOptions<ERPDbContext> options) : DbContext(options)
{
    public DbSet<SystemSetting> SystemSettings => Set<SystemSetting>();
    public DbSet<CodeGroup> CodeGroups => Set<CodeGroup>();
    public DbSet<Code> Codes => Set<Code>();
    public DbSet<Item> Items => Set<Item>();
    public DbSet<ItemGrade> ItemGrades => Set<ItemGrade>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();
    public DbSet<Partner> Partners => Set<Partner>();
    public DbSet<PartnerItem> PartnerItems => Set<PartnerItem>();
    public DbSet<Price> Prices => Set<Price>();
    public DbSet<SalesOrder> SalesOrders => Set<SalesOrder>();
    public DbSet<SalesOrderDetail> SalesOrderDetails => Set<SalesOrderDetail>();
    public DbSet<PurchaseOrder> PurchaseOrders => Set<PurchaseOrder>();
    public DbSet<PurchaseOrderDetail> PurchaseOrderDetails => Set<PurchaseOrderDetail>();
    public DbSet<Production> Productions => Set<Production>();
    public DbSet<ProductionDetail> ProductionDetails => Set<ProductionDetail>();
    public DbSet<Lot> Lots => Set<Lot>();
    public DbSet<PartnerLot> PartnerLots => Set<PartnerLot>();
    public DbSet<LotPartnerLot> LotPartnerLots => Set<LotPartnerLot>();
    public DbSet<InOut> InOuts => Set<InOut>();
    public DbSet<InOutDetail> InOutDetails => Set<InOutDetail>();
    public DbSet<OrderProcessHistory> OrderProcessHistories => Set<OrderProcessHistory>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<SystemSetting>(e =>
        {
            e.ToTable("TB_SYSTEM_SETTING");
            e.HasKey(x => x.Key);
            e.Property(x => x.Key).HasColumnName("SETTING_KEY");
            e.Property(x => x.Value).HasColumnName("SETTING_VALUE").IsRequired();
            e.Property(x => x.ValueType).HasColumnName("VALUE_TYPE").IsRequired();
            e.Property(x => x.Description).HasColumnName("DESCRIPTION");
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
        });

        modelBuilder.Entity<CodeGroup>(e =>
        {
            e.ToTable("TB_CODE_GROUP");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("CODE_GROUP_ID");
            e.Property(x => x.Key).HasColumnName("GROUP_KEY").IsRequired();
            e.Property(x => x.Name).HasColumnName("GROUP_NAME").IsRequired();
            e.Property(x => x.Description).HasColumnName("DESCRIPTION");
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.HasIndex(x => x.Key).IsUnique();
        });

        modelBuilder.Entity<Code>(e =>
        {
            e.ToTable("TB_CODE");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("CODE_ID");
            e.Property(x => x.CodeGroupId).HasColumnName("CODE_GROUP_ID");
            e.Property(x => x.Key).HasColumnName("CODE_KEY").IsRequired();
            e.Property(x => x.Name).HasColumnName("CODE_NAME").IsRequired();
            e.Property(x => x.SortOrder).HasColumnName("SORT_ORDER");
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.Property(x => x.Description).HasColumnName("DESCRIPTION");
            e.HasIndex(x => new { x.CodeGroupId, x.Key }).IsUnique();
        });

        modelBuilder.Entity<ItemGrade>(e =>
        {
            e.ToTable("TB_ITEM_GRADE");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("ITEM_GRADE_ID");
            e.Property(x => x.Code).HasColumnName("GRADE_CODE").IsRequired();
            e.Property(x => x.Name).HasColumnName("GRADE_NAME").IsRequired();
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.HasIndex(x => x.Code).IsUnique();
        });

        modelBuilder.Entity<Item>(e =>
        {
            e.ToTable("TB_ITEM");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("ITEM_ID");
            e.Property(x => x.Code).HasColumnName("ITEM_CODE").IsRequired();
            e.Property(x => x.Name).HasColumnName("ITEM_NAME").IsRequired();
            e.Property(x => x.CategoryCode).HasColumnName("ITEM_CATEGORY_CODE").IsRequired();
            e.Property(x => x.GradeId).HasColumnName("GRADE_ID");
            e.Property(x => x.UnitCode).HasColumnName("UNIT_CODE").IsRequired();
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => x.Code).IsUnique();
        });

        modelBuilder.Entity<AuditLog>(e =>
        {
            e.ToTable("TB_AUDIT_LOG");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("AUDIT_LOG_ID");
            e.Property(x => x.EntityName).HasColumnName("ENTITY_NAME").IsRequired();
            e.Property(x => x.EntityId).HasColumnName("ENTITY_ID");
            e.Property(x => x.ActionCode).HasColumnName("ACTION_CODE").IsRequired();
            e.Property(x => x.Actor).HasColumnName("ACTOR");
            e.Property(x => x.OccurredAt).HasColumnName("OCCURRED_AT").IsRequired();
            e.Property(x => x.BeforeJson).HasColumnName("BEFORE_JSON");
            e.Property(x => x.AfterJson).HasColumnName("AFTER_JSON");
            e.Property(x => x.Note).HasColumnName("NOTE");
        });

        modelBuilder.Entity<Partner>(e =>
        {
            e.ToTable("TB_PARTNER");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PARTNER_ID");
            e.Property(x => x.Code).HasColumnName("PARTNER_CODE").IsRequired();
            e.Property(x => x.Name).HasColumnName("PARTNER_NAME").IsRequired();
            e.Property(x => x.TypeCode).HasColumnName("PARTNER_TYPE_CODE").IsRequired();
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => x.Code).IsUnique();
        });

        modelBuilder.Entity<PartnerItem>(e =>
        {
            e.ToTable("TB_PARTNER_ITEM");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PARTNER_ITEM_ID");
            e.Property(x => x.PartnerId).HasColumnName("PARTNER_ID").IsRequired();
            e.Property(x => x.ItemId).HasColumnName("ITEM_ID").IsRequired();
            e.Property(x => x.PartnerItemCode).HasColumnName("PARTNER_ITEM_CODE");
            e.Property(x => x.PartnerItemName).HasColumnName("PARTNER_ITEM_NAME");
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.HasIndex(x => new { x.PartnerId, x.ItemId });
        });

        modelBuilder.Entity<Price>(e =>
        {
            e.ToTable("TB_PRICE");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PRICE_ID");
            e.Property(x => x.PartnerId).HasColumnName("PARTNER_ID").IsRequired();
            e.Property(x => x.ItemId).HasColumnName("ITEM_ID").IsRequired();
            e.Property(x => x.UnitPrice).HasColumnName("UNIT_PRICE").IsRequired();
            e.Property(x => x.EffectiveFrom).HasColumnName("EFFECTIVE_FROM").IsRequired();
            e.Property(x => x.Priority).HasColumnName("PRIORITY").IsRequired();
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => new { x.PartnerId, x.ItemId, x.EffectiveFrom, x.Priority });
        });

        modelBuilder.Entity<PurchaseOrder>(e =>
        {
            e.ToTable("TB_PURCHASE_ORDER");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PURCHASE_ORDER_ID");
            e.Property(x => x.DocumentNo).HasColumnName("DOCUMENT_NO").IsRequired();
            e.Property(x => x.OrderDate).HasColumnName("ORDER_DATE").IsRequired();
            e.Property(x => x.PartnerId).HasColumnName("PARTNER_ID").IsRequired();
            e.Property(x => x.DueDate).HasColumnName("DUE_DATE");
            e.Property(x => x.StatusCode).HasColumnName("STATUS_CODE").IsRequired();
            e.Property(x => x.Note).HasColumnName("NOTE");
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => x.DocumentNo).IsUnique();
        });

        modelBuilder.Entity<PurchaseOrderDetail>(e =>
        {
            e.ToTable("TB_PURCHASE_ORDER_DETAIL");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PURCHASE_ORDER_DETAIL_ID");
            e.Property(x => x.PurchaseOrderId).HasColumnName("PURCHASE_ORDER_ID").IsRequired();
            e.Property(x => x.ItemId).HasColumnName("ITEM_ID").IsRequired();
            e.Property(x => x.PriceId).HasColumnName("PRICE_ID");
            e.Property(x => x.OrderQty).HasColumnName("ORDER_QTY").IsRequired();
            e.Property(x => x.ProcessedQty).HasColumnName("PROCESSED_QTY").IsRequired();
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.Property(x => x.AppliedUnitPrice).HasColumnName("APPLIED_UNIT_PRICE").IsRequired();
            e.Property(x => x.Amount).HasColumnName("AMOUNT").IsRequired();
            e.Property(x => x.DueDate).HasColumnName("DUE_DATE");
            e.Property(x => x.Note).HasColumnName("NOTE");
            e.HasIndex(x => x.PriceId);
        });

        modelBuilder.Entity<Production>(e =>
        {
            e.ToTable("TB_PRODUCTION");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PRODUCTION_ID");
            e.Property(x => x.DocumentNo).HasColumnName("DOCUMENT_NO").IsRequired();
            e.Property(x => x.ProductionDate).HasColumnName("PRODUCTION_DATE").IsRequired();
            e.Property(x => x.StatusCode).HasColumnName("STATUS_CODE").IsRequired();
            e.Property(x => x.Note).HasColumnName("NOTE");
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => x.DocumentNo).IsUnique();
        });

        modelBuilder.Entity<ProductionDetail>(e =>
        {
            e.ToTable("TB_PRODUCTION_DETAIL");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PRODUCTION_DETAIL_ID");
            e.Property(x => x.ProductionId).HasColumnName("PRODUCTION_ID").IsRequired();
            e.Property(x => x.ItemId).HasColumnName("ITEM_ID").IsRequired();
            e.Property(x => x.ProductionQty).HasColumnName("PRODUCTION_QTY").IsRequired();
            e.Property(x => x.DefectQty).HasColumnName("DEFECT_QTY").IsRequired();
            e.HasIndex(x => x.ItemId);
        });

        modelBuilder.Entity<Lot>(e =>
        {
            e.ToTable("TB_LOT");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("LOT_ID");
            e.Property(x => x.MkLotNo).HasColumnName("MK_LOT_NO").IsRequired();
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => x.MkLotNo).IsUnique();
        });

        modelBuilder.Entity<PartnerLot>(e =>
        {
            e.ToTable("TB_PARTNER_LOT");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("PARTNER_LOT_ID");
            e.Property(x => x.PartnerId).HasColumnName("PARTNER_ID").IsRequired();
            e.Property(x => x.PartnerLotNo).HasColumnName("PARTNER_LOT_NO").IsRequired();
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => new { x.PartnerId, x.PartnerLotNo }).IsUnique();
        });

        modelBuilder.Entity<LotPartnerLot>(e =>
        {
            e.ToTable("TB_LOT_PARTNER_LOT");
            e.HasKey(x => new { x.LotId, x.PartnerLotId });
            e.Property(x => x.LotId).HasColumnName("LOT_ID");
            e.Property(x => x.PartnerLotId).HasColumnName("PARTNER_LOT_ID");
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
        });

        modelBuilder.Entity<InOut>(e =>
        {
            e.ToTable("TB_INOUT");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("INOUT_ID");
            e.Property(x => x.DocumentNo).HasColumnName("DOCUMENT_NO").IsRequired();
            e.Property(x => x.MovementDate).HasColumnName("MOVEMENT_DATE").IsRequired();
            e.Property(x => x.MovementTypeCode).HasColumnName("MOVEMENT_TYPE_CODE").IsRequired();
            e.Property(x => x.PartnerId).HasColumnName("PARTNER_ID");
            e.Property(x => x.SourceTypeCode).HasColumnName("SOURCE_TYPE_CODE");
            e.Property(x => x.SourceId).HasColumnName("SOURCE_ID");
            e.Property(x => x.StatusCode).HasColumnName("STATUS_CODE").IsRequired();
            e.Property(x => x.Note).HasColumnName("NOTE");
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => x.DocumentNo).IsUnique();
        });

        modelBuilder.Entity<InOutDetail>(e =>
        {
            e.ToTable("TB_INOUT_DETAIL");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("INOUT_DETAIL_ID");
            e.Property(x => x.InOutId).HasColumnName("INOUT_ID").IsRequired();
            e.Property(x => x.ItemId).HasColumnName("ITEM_ID").IsRequired();
            e.Property(x => x.LotId).HasColumnName("LOT_ID");
            e.Property(x => x.PartnerLotId).HasColumnName("PARTNER_LOT_ID");
            e.Property(x => x.Quantity).HasColumnName("QUANTITY").IsRequired();
            e.Property(x => x.UnitPrice).HasColumnName("UNIT_PRICE");
            e.Property(x => x.Amount).HasColumnName("AMOUNT");
            e.HasIndex(x => x.ItemId);
        });

        modelBuilder.Entity<OrderProcessHistory>(e =>
        {
            e.ToTable("TB_ORDER_PROCESS_HISTORY");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("ORDER_PROCESS_HISTORY_ID");
            e.Property(x => x.SourceTypeCode).HasColumnName("SOURCE_TYPE_CODE").IsRequired();
            e.Property(x => x.SourceDetailId).HasColumnName("SOURCE_DETAIL_ID").IsRequired();
            e.Property(x => x.InOutDetailId).HasColumnName("INOUT_DETAIL_ID").IsRequired();
            e.Property(x => x.ProcessQty).HasColumnName("PROCESS_QTY").IsRequired();
            e.Property(x => x.ActionCode).HasColumnName("ACTION_CODE").IsRequired();
            e.Property(x => x.ReversesHistoryId).HasColumnName("REVERSES_HISTORY_ID");
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.HasIndex(x => new { x.SourceTypeCode, x.SourceDetailId, x.CreatedAt });
            e.HasIndex(x => x.InOutDetailId);
        });

        modelBuilder.Entity<SalesOrder>(e =>
        {
            e.ToTable("TB_SALES_ORDER");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("SALES_ORDER_ID");
            e.Property(x => x.DocumentNo).HasColumnName("DOCUMENT_NO").IsRequired();
            e.Property(x => x.OrderDate).HasColumnName("ORDER_DATE").IsRequired();
            e.Property(x => x.PartnerId).HasColumnName("PARTNER_ID").IsRequired();
            e.Property(x => x.DueDate).HasColumnName("DUE_DATE");
            e.Property(x => x.StatusCode).HasColumnName("STATUS_CODE").IsRequired();
            e.Property(x => x.Note).HasColumnName("NOTE");
            e.Property(x => x.CreatedAt).HasColumnName("CREATED_AT").IsRequired();
            e.Property(x => x.UpdatedAt).HasColumnName("UPDATED_AT").IsRequired();
            e.HasIndex(x => x.DocumentNo).IsUnique();
        });

        modelBuilder.Entity<SalesOrderDetail>(e =>
        {
            e.ToTable("TB_SALES_ORDER_DETAIL");
            e.HasKey(x => x.Id);
            e.Property(x => x.Id).HasColumnName("SALES_ORDER_DETAIL_ID");
            e.Property(x => x.SalesOrderId).HasColumnName("SALES_ORDER_ID").IsRequired();
            e.Property(x => x.ItemId).HasColumnName("ITEM_ID").IsRequired();
            e.Property(x => x.PartnerItemId).HasColumnName("PARTNER_ITEM_ID");
            e.Property(x => x.PriceId).HasColumnName("PRICE_ID");
            e.Property(x => x.OrderQty).HasColumnName("ORDER_QTY").IsRequired();
            e.Property(x => x.ProcessedQty).HasColumnName("PROCESSED_QTY").IsRequired();
            e.Property(x => x.IsActive).HasColumnName("IS_ACTIVE").IsRequired();
            e.Property(x => x.AppliedUnitPrice).HasColumnName("APPLIED_UNIT_PRICE").IsRequired();
            e.Property(x => x.Amount).HasColumnName("AMOUNT").IsRequired();
            e.Property(x => x.DueDate).HasColumnName("DUE_DATE");
            e.Property(x => x.Note).HasColumnName("NOTE");
            e.HasIndex(x => x.PriceId);
        });
    }
}
