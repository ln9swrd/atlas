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

        await EnsureOrderProcessedQtyAsync(connection, "TB_SALES_ORDER_DETAIL", "SALES_ORDER_ID", "SALES_ORDER");
        await EnsureOrderProcessedQtyAsync(connection, "TB_PURCHASE_ORDER_DETAIL", "PURCHASE_ORDER_ID", "PURCHASE_ORDER");

        await ExecuteNonQueryAsync(connection,
            "CREATE UNIQUE INDEX IF NOT EXISTS UX_LOT_MK_LOT_NO ON TB_LOT(MK_LOT_NO);",
            cancellationToken);
        await ExecuteNonQueryAsync(connection,
            "CREATE UNIQUE INDEX IF NOT EXISTS UX_PARTNER_LOT_NO ON TB_PARTNER_LOT(PARTNER_ID, PARTNER_LOT_NO);",
            cancellationToken);
        await ExecuteNonQueryAsync(connection,
            "CREATE INDEX IF NOT EXISTS IX_PRICE_PARTNER_ITEM_DATE ON TB_PRICE(PARTNER_ID, ITEM_ID, EFFECTIVE_FROM, PRIORITY, IS_ACTIVE);",
            cancellationToken);
        await ExecuteNonQueryAsync(connection,
            "CREATE INDEX IF NOT EXISTS IX_SALES_ORDER_DETAIL_PRICE ON TB_SALES_ORDER_DETAIL(PRICE_ID);",
            cancellationToken);
        await ExecuteNonQueryAsync(connection,
            "CREATE INDEX IF NOT EXISTS IX_PURCHASE_ORDER_DETAIL_PRICE ON TB_PURCHASE_ORDER_DETAIL(PRICE_ID);",
            cancellationToken);
        await EnsureOrderProcessHistoryAsync(connection, cancellationToken);
    }

    private static async Task EnsureOrderProcessedQtyAsync(SqliteConnection connection, string detailTable, string orderIdColumn, string sourceType)
    {
        if (!await HasColumnAsync(connection, detailTable, "PROCESSED_QTY", CancellationToken.None))
            await ExecuteNonQueryAsync(connection, $"ALTER TABLE {detailTable} ADD COLUMN PROCESSED_QTY NUMERIC NOT NULL DEFAULT 0;", CancellationToken.None);

        var movementType = sourceType == "SALES_ORDER" ? "OUT" : "IN";
        var sql = $"UPDATE {detailTable} SET PROCESSED_QTY = COALESCE((SELECT SUM(d.QUANTITY) FROM TB_INOUT h JOIN TB_INOUT_DETAIL d ON d.INOUT_ID=h.INOUT_ID WHERE h.SOURCE_TYPE_CODE='{sourceType}' AND h.SOURCE_ID={detailTable}.{orderIdColumn} AND h.MOVEMENT_TYPE_CODE='{movementType}' AND h.STATUS_CODE <> 'CANCELLED'), 0)";
        await ExecuteNonQueryAsync(connection, sql, CancellationToken.None);
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
