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
    public async Task<string> RestoreAsync(string backupPath, CancellationToken cancellationToken = default)
    {
        if (!File.Exists(backupPath)) throw new FileNotFoundException("Backup file not found.", backupPath);
        var fullBackupPath = Path.GetFullPath(backupPath);
        var fullDatabasePath = Path.GetFullPath(databasePath);
        if (string.Equals(fullBackupPath, fullDatabasePath, StringComparison.OrdinalIgnoreCase))
            throw new InvalidOperationException("The current database cannot be used as the restore source.");
        var directory = Path.GetDirectoryName(fullDatabasePath)!;
        Directory.CreateDirectory(directory);
        await using (var connection = new SqliteConnection("Data Source=" + fullBackupPath + ";Mode=ReadOnly"))
        {
            await connection.OpenAsync(cancellationToken);
            await using var command = connection.CreateCommand();
            command.CommandText = "PRAGMA integrity_check;";
            var result = Convert.ToString(await command.ExecuteScalarAsync(cancellationToken));
            if (!string.Equals(result, "ok", StringComparison.OrdinalIgnoreCase))
                throw new InvalidDataException("Backup integrity check failed: " + result);
        }
        if (File.Exists(fullDatabasePath))
        {
            var safetyCopy = Path.Combine(directory, "MKERP_pre_restore_" + DateTime.Now.ToString("yyyyMMdd_HHmmss") + ".db");
            File.Copy(fullDatabasePath, safetyCopy, false);
        }
        File.Copy(fullBackupPath, fullDatabasePath, true);
        return fullDatabasePath;
    }}
