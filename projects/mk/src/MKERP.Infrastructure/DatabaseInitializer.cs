using Microsoft.Data.Sqlite;
using MKERP.Application;

namespace MKERP.Infrastructure;

public sealed class DatabaseInitializer(string databasePath) : IDatabaseInitializer
{
    public async Task InitializeAsync(CancellationToken cancellationToken = default)
    {
        Directory.CreateDirectory(Path.GetDirectoryName(databasePath)!);

        await using var connection = new SqliteConnection($"Data Source={databasePath}");
        await connection.OpenAsync(cancellationToken);

        await ExecuteScriptAsync(connection, "database/schema.sql", cancellationToken);
        await ExecuteScriptAsync(connection, "database/seed.sql", cancellationToken);
    }

    private static async Task ExecuteScriptAsync(SqliteConnection connection, string relativePath, CancellationToken cancellationToken)
    {
        var path = Path.Combine(AppContext.BaseDirectory, relativePath);
        if (!File.Exists(path))
            throw new FileNotFoundException($"Database script not found: {path}");

        var sql = await File.ReadAllTextAsync(path, cancellationToken);
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}
