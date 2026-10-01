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
    }
}
