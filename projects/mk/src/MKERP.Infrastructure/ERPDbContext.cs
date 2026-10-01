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
    }
}
