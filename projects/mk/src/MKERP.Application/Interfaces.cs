using MKERP.Domain;

namespace MKERP.Application;

public interface ISettingsRepository
{
    Task<SystemSetting?> GetAsync(string key, CancellationToken cancellationToken = default);
    Task<string?> GetValueAsync(string key, CancellationToken cancellationToken = default);
}

public interface ICodeRepository
{
    Task<IReadOnlyList<Code>> GetActiveAsync(string groupKey, CancellationToken cancellationToken = default);
}

public interface IDatabaseInitializer
{
    Task InitializeAsync(CancellationToken cancellationToken = default);
}

public interface IItemRepository
{
    Task<IReadOnlyList<Item>> GetActiveAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<ItemGrade>> GetGradesAsync(CancellationToken cancellationToken = default);
    Task AddAsync(Item item, CancellationToken cancellationToken = default);
    Task UpdateAsync(Item item, CancellationToken cancellationToken = default);
    Task DeactivateAsync(long id, CancellationToken cancellationToken = default);
}

public interface IPartnerRepository
{
    Task<IReadOnlyList<Partner>> GetActiveAsync(CancellationToken cancellationToken = default);
    Task AddAsync(Partner partner, CancellationToken cancellationToken = default);
    Task UpdateAsync(Partner partner, CancellationToken cancellationToken = default);
    Task DeactivateAsync(long id, CancellationToken cancellationToken = default);
}

public interface IPartnerItemRepository
{
    Task<IReadOnlyList<PartnerItem>> GetActiveAsync(long? partnerId = null, CancellationToken cancellationToken = default);
    Task AddAsync(PartnerItem partnerItem, CancellationToken cancellationToken = default);
    Task UpdateAsync(PartnerItem partnerItem, CancellationToken cancellationToken = default);
    Task DeactivateAsync(long id, CancellationToken cancellationToken = default);
}

public interface IPriceRepository
{
    Task<IReadOnlyList<Price>> GetActiveAsync(long? partnerId = null, long? itemId = null, CancellationToken cancellationToken = default);
    Task<Price?> GetApplicableAsync(long partnerId, long itemId, DateTime orderDate, CancellationToken cancellationToken = default);
    Task AddAsync(Price price, CancellationToken cancellationToken = default);
    Task DeactivateAsync(long id, CancellationToken cancellationToken = default);
}

public interface IPurchaseOrderRepository
{
    Task<string> GetNextDocumentNoAsync(DateTime orderDate, CancellationToken cancellationToken = default);
    Task AddAsync(PurchaseOrder order, PurchaseOrderDetail detail, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<PurchaseOrder>> GetRecentAsync(CancellationToken cancellationToken = default);
}

public interface IInOutRepository
{
    Task<string> GetNextDocumentNoAsync(DateTime movementDate, CancellationToken cancellationToken = default);
    Task AddAsync(InOut header, InOutDetail detail, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<InOut>> GetRecentAsync(CancellationToken cancellationToken = default);
    Task<IReadOnlyList<InventoryRow>> GetInventoryAsync(DateTime asOfDate, CancellationToken cancellationToken = default);
}

public sealed class InventoryRow
{
    public long ItemId { get; init; }
    public string ItemCode { get; init; } = string.Empty;
    public string ItemName { get; init; } = string.Empty;
    public decimal Opening { get; init; }
    public decimal Inbound { get; init; }
    public decimal Outbound { get; init; }
    public decimal Ending => Opening + Inbound - Outbound;
}

public interface ISalesOrderRepository
{
    Task<string> GetNextDocumentNoAsync(DateTime orderDate, CancellationToken cancellationToken = default);
    Task AddAsync(SalesOrder order, SalesOrderDetail detail, CancellationToken cancellationToken = default);
    Task<IReadOnlyList<SalesOrder>> GetRecentAsync(CancellationToken cancellationToken = default);
}
