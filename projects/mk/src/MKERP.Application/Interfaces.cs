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
