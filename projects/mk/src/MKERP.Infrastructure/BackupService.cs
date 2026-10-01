using Microsoft.Data.Sqlite;

namespace MKERP.Infrastructure;

public sealed class BackupService(string databasePath)
{
    public async Task<string?> BackupIfDueAsync(CancellationToken cancellationToken = default)
    {
        var directory = Path.Combine(Path.GetDirectoryName(databasePath)!, "backup");
        Directory.CreateDirectory(directory);

        var latest = Directory.EnumerateFiles(directory, "MKERP_*.db", SearchOption.TopDirectoryOnly)
            .Select(path => new FileInfo(path))
            .OrderByDescending(file => file.LastWriteTimeUtc)
            .FirstOrDefault();

        if (latest is not null && DateTime.UtcNow - latest.LastWriteTimeUtc < TimeSpan.FromDays(7))
            return null;

        var destination = Path.Combine(directory, $"MKERP_{DateTime.Now:yyyyMMdd_HHmmss}.db");
        await using var connection = new SqliteConnection($"Data Source={databasePath}");
        await connection.OpenAsync(cancellationToken);
        await using var command = connection.CreateCommand();
        command.CommandText = $"VACUUM INTO '{destination.Replace("'", "''")}'";
        await command.ExecuteNonQueryAsync(cancellationToken);

        var retentionCutoff = DateTime.UtcNow.AddMonths(-6);
        foreach (var oldBackup in Directory.EnumerateFiles(directory, "MKERP_*.db", SearchOption.TopDirectoryOnly)
                     .Select(path => new FileInfo(path))
                     .Where(file => file.LastWriteTimeUtc < retentionCutoff))
        {
            oldBackup.Delete();
        }

        return destination;
    }
}
