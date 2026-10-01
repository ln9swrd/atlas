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
