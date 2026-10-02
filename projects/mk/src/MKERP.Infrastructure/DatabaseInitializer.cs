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
        await EnsureDetailActiveAsync(connection, "TB_SALES_ORDER_DETAIL");
        await EnsureDetailActiveAsync(connection, "TB_PURCHASE_ORDER_DETAIL");

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
        await CodePkMigration.EnsureAsync(connection, cancellationToken);
    }

    private static async Task EnsureDetailActiveAsync(SqliteConnection connection, string table)
    {
        if (!await HasColumnAsync(connection, table, "IS_ACTIVE", CancellationToken.None))
            await ExecuteNonQueryAsync(connection, $"ALTER TABLE {table} ADD COLUMN IS_ACTIVE INTEGER NOT NULL DEFAULT 1;", CancellationToken.None);
    }

    private static async Task EnsureOrderProcessedQtyAsync(SqliteConnection connection, string detailTable, string orderIdColumn, string sourceType)
    {
        if (!await HasColumnAsync(connection, detailTable, "PROCESSED_QTY", CancellationToken.None))
            await ExecuteNonQueryAsync(connection, $"ALTER TABLE {detailTable} ADD COLUMN PROCESSED_QTY NUMERIC NOT NULL DEFAULT 0;", CancellationToken.None);

        var movementType = sourceType == "SALES_ORDER" ? "OUT" : "IN";
        var sql = $"UPDATE {detailTable} SET PROCESSED_QTY = COALESCE((SELECT SUM(d.QUANTITY) FROM TB_INOUT h JOIN TB_INOUT_DETAIL d ON d.INOUT_ID=h.INOUT_ID WHERE h.SOURCE_TYPE_CODE='{sourceType}' AND h.SOURCE_ID={detailTable}.{orderIdColumn} AND h.MOVEMENT_TYPE_CODE='{movementType}' AND h.STATUS_CODE <> 'CANCELLED'), 0)";
        await ExecuteNonQueryAsync(connection, sql, CancellationToken.None);
    }

    private static async Task EnsureOrderProcessHistoryAsync(SqliteConnection connection, CancellationToken cancellationToken)
    {
        await ExecuteNonQueryAsync(connection, "CREATE TABLE IF NOT EXISTS TB_ORDER_PROCESS_HISTORY (ORDER_PROCESS_HISTORY_ID INTEGER PRIMARY KEY AUTOINCREMENT, SOURCE_TYPE_CODE TEXT NOT NULL, SOURCE_DETAIL_ID INTEGER NOT NULL, INOUT_DETAIL_ID INTEGER NOT NULL, PROCESS_QTY NUMERIC NOT NULL CHECK (PROCESS_QTY > 0), ACTION_CODE TEXT NOT NULL, REVERSES_HISTORY_ID INTEGER, CREATED_AT TEXT NOT NULL, FOREIGN KEY (INOUT_DETAIL_ID) REFERENCES TB_INOUT_DETAIL(INOUT_DETAIL_ID), FOREIGN KEY (REVERSES_HISTORY_ID) REFERENCES TB_ORDER_PROCESS_HISTORY(ORDER_PROCESS_HISTORY_ID));", cancellationToken);
        await ExecuteNonQueryAsync(connection, "CREATE INDEX IF NOT EXISTS IX_ORDER_PROCESS_SOURCE ON TB_ORDER_PROCESS_HISTORY(SOURCE_TYPE_CODE, SOURCE_DETAIL_ID, CREATED_AT);", cancellationToken);
        await ExecuteNonQueryAsync(connection, "CREATE INDEX IF NOT EXISTS IX_ORDER_PROCESS_INOUT_DETAIL ON TB_ORDER_PROCESS_HISTORY(INOUT_DETAIL_ID);", cancellationToken);

        // Existing releases had one order detail per order. Backfill only unambiguous rows.
        await ExecuteNonQueryAsync(connection, "INSERT INTO TB_ORDER_PROCESS_HISTORY (SOURCE_TYPE_CODE, SOURCE_DETAIL_ID, INOUT_DETAIL_ID, PROCESS_QTY, ACTION_CODE, CREATED_AT) SELECT h.SOURCE_TYPE_CODE, CASE h.SOURCE_TYPE_CODE WHEN 'SALES_ORDER' THEN (SELECT MIN(d2.SALES_ORDER_DETAIL_ID) FROM TB_SALES_ORDER_DETAIL d2 WHERE d2.SALES_ORDER_ID=h.SOURCE_ID AND d2.ITEM_ID=d.ITEM_ID AND (SELECT COUNT(*) FROM TB_SALES_ORDER_DETAIL d3 WHERE d3.SALES_ORDER_ID=h.SOURCE_ID AND d3.ITEM_ID=d.ITEM_ID)=1) WHEN 'PURCHASE_ORDER' THEN (SELECT MIN(d2.PURCHASE_ORDER_DETAIL_ID) FROM TB_PURCHASE_ORDER_DETAIL d2 WHERE d2.PURCHASE_ORDER_ID=h.SOURCE_ID AND d2.ITEM_ID=d.ITEM_ID AND (SELECT COUNT(*) FROM TB_PURCHASE_ORDER_DETAIL d3 WHERE d3.PURCHASE_ORDER_ID=h.SOURCE_ID AND d3.ITEM_ID=d.ITEM_ID)=1) END, d.INOUT_DETAIL_ID, d.QUANTITY, 'PROCESS', h.CREATED_AT FROM TB_INOUT h JOIN TB_INOUT_DETAIL d ON d.INOUT_ID=h.INOUT_ID LEFT JOIN TB_ORDER_PROCESS_HISTORY ph ON ph.INOUT_DETAIL_ID=d.INOUT_DETAIL_ID WHERE h.SOURCE_TYPE_CODE IN ('SALES_ORDER','PURCHASE_ORDER') AND h.MOVEMENT_TYPE_CODE IN ('OUT','IN') AND h.STATUS_CODE <> 'CANCELLED' AND ph.ORDER_PROCESS_HISTORY_ID IS NULL AND CASE h.SOURCE_TYPE_CODE WHEN 'SALES_ORDER' THEN (SELECT COUNT(*) FROM TB_SALES_ORDER_DETAIL d3 WHERE d3.SALES_ORDER_ID=h.SOURCE_ID AND d3.ITEM_ID=d.ITEM_ID) WHEN 'PURCHASE_ORDER' THEN (SELECT COUNT(*) FROM TB_PURCHASE_ORDER_DETAIL d3 WHERE d3.PURCHASE_ORDER_ID=h.SOURCE_ID AND d3.ITEM_ID=d.ITEM_ID) END = 1;", cancellationToken);
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
