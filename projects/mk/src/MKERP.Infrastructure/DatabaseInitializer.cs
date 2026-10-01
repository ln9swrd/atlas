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
        await EnsureMigrationsAsync(connection, cancellationToken);
    }

    private static async Task EnsureMigrationsAsync(SqliteConnection connection, CancellationToken cancellationToken)
    {
        if (!await HasColumnAsync(connection, "TB_PRICE", "PRIORITY", cancellationToken))
        {
            await ExecuteNonQueryAsync(connection, "ALTER TABLE TB_PRICE ADD COLUMN PRIORITY INTEGER NOT NULL DEFAULT 0;", cancellationToken);
        }

        if (!await HasColumnAsync(connection, "TB_SALES_ORDER_DETAIL", "PRICE_ID", cancellationToken))
        {
            await ExecuteNonQueryAsync(connection, "ALTER TABLE TB_SALES_ORDER_DETAIL ADD COLUMN PRICE_ID INTEGER;", cancellationToken);
        }

        if (!await HasColumnAsync(connection, "TB_PURCHASE_ORDER_DETAIL", "PRICE_ID", cancellationToken))
        {
            await ExecuteNonQueryAsync(connection, "ALTER TABLE TB_PURCHASE_ORDER_DETAIL ADD COLUMN PRICE_ID INTEGER;", cancellationToken);
        }

        await ExecuteNonQueryAsync(connection,
            "CREATE INDEX IF NOT EXISTS IX_PRICE_PARTNER_ITEM_DATE ON TB_PRICE(PARTNER_ID, ITEM_ID, EFFECTIVE_FROM, PRIORITY, IS_ACTIVE);",
            cancellationToken);
        await ExecuteNonQueryAsync(connection,
            "CREATE INDEX IF NOT EXISTS IX_SALES_ORDER_DETAIL_PRICE ON TB_SALES_ORDER_DETAIL(PRICE_ID);",
            cancellationToken);
        await ExecuteNonQueryAsync(connection,
            "CREATE INDEX IF NOT EXISTS IX_PURCHASE_ORDER_DETAIL_PRICE ON TB_PURCHASE_ORDER_DETAIL(PRICE_ID);",
            cancellationToken);
    }

    private static async Task<bool> HasColumnAsync(SqliteConnection connection, string table, string column, CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = $"PRAGMA table_info({table});";
        await using var reader = await command.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
        {
            if (string.Equals(reader.GetString(1), column, StringComparison.OrdinalIgnoreCase))
                return true;
        }
        return false;
    }

    private static async Task ExecuteNonQueryAsync(SqliteConnection connection, string sql, CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        await command.ExecuteNonQueryAsync(cancellationToken);
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
