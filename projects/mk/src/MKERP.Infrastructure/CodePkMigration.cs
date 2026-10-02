using Microsoft.Data.Sqlite;

namespace MKERP.Infrastructure;

internal static class CodePkMigration
{
    public static async Task EnsureAsync(SqliteConnection connection, CancellationToken cancellationToken)
    {
        await AddColumnAsync(connection, "TB_ITEM", "ITEM_CATEGORY_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_PARTNER", "PARTNER_TYPE_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_SALES_ORDER", "STATUS_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_PURCHASE_ORDER", "STATUS_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_PRODUCTION", "STATUS_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_INOUT", "MOVEMENT_TYPE_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_INOUT", "SOURCE_TYPE_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_INOUT", "STATUS_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_ORDER_PROCESS_HISTORY", "SOURCE_TYPE_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_ORDER_PROCESS_HISTORY", "ACTION_ID", cancellationToken);
        await AddColumnAsync(connection, "TB_AUDIT_LOG", "ACTION_ID", cancellationToken);

        await ExecuteAsync(connection, @"UPDATE TB_ITEM SET ITEM_CATEGORY_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='ITEM_CATEGORY' AND c.CODE_KEY=TB_ITEM.ITEM_CATEGORY_CODE) WHERE ITEM_CATEGORY_ID IS NULL AND ITEM_CATEGORY_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_PARTNER SET PARTNER_TYPE_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='PARTNER_TYPE' AND c.CODE_KEY=TB_PARTNER.PARTNER_TYPE_CODE) WHERE PARTNER_TYPE_ID IS NULL AND PARTNER_TYPE_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_SALES_ORDER SET STATUS_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='DOCUMENT_STATUS' AND c.CODE_KEY=TB_SALES_ORDER.STATUS_CODE) WHERE STATUS_ID IS NULL AND STATUS_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_PURCHASE_ORDER SET STATUS_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='DOCUMENT_STATUS' AND c.CODE_KEY=TB_PURCHASE_ORDER.STATUS_CODE) WHERE STATUS_ID IS NULL AND STATUS_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_PRODUCTION SET STATUS_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='DOCUMENT_STATUS' AND c.CODE_KEY=TB_PRODUCTION.STATUS_CODE) WHERE STATUS_ID IS NULL AND STATUS_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_INOUT SET MOVEMENT_TYPE_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='INOUT_TYPE' AND c.CODE_KEY=TB_INOUT.MOVEMENT_TYPE_CODE) WHERE MOVEMENT_TYPE_ID IS NULL AND MOVEMENT_TYPE_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_INOUT SET SOURCE_TYPE_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='SOURCE_TYPE' AND c.CODE_KEY=TB_INOUT.SOURCE_TYPE_CODE) WHERE SOURCE_TYPE_ID IS NULL AND SOURCE_TYPE_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_INOUT SET STATUS_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='DOCUMENT_STATUS' AND c.CODE_KEY=TB_INOUT.STATUS_CODE) WHERE STATUS_ID IS NULL AND STATUS_CODE IS NOT NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_ORDER_PROCESS_HISTORY SET SOURCE_TYPE_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='SOURCE_TYPE' AND c.CODE_KEY=TB_ORDER_PROCESS_HISTORY.SOURCE_TYPE_CODE) WHERE SOURCE_TYPE_ID IS NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_ORDER_PROCESS_HISTORY SET ACTION_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='ORDER_PROCESS_ACTION' AND c.CODE_KEY=TB_ORDER_PROCESS_HISTORY.ACTION_CODE) WHERE ACTION_ID IS NULL;", cancellationToken);
        await ExecuteAsync(connection, @"UPDATE TB_AUDIT_LOG SET ACTION_ID=(SELECT CODE_ID FROM TB_CODE c JOIN TB_CODE_GROUP g ON g.CODE_GROUP_ID=c.CODE_GROUP_ID WHERE g.GROUP_KEY='AUDIT_ACTION' AND c.CODE_KEY=TB_AUDIT_LOG.ACTION_CODE) WHERE ACTION_ID IS NULL;", cancellationToken);

        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_ITEM_CATEGORY_ID ON TB_ITEM(ITEM_CATEGORY_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_PARTNER_TYPE_ID ON TB_PARTNER(PARTNER_TYPE_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_SALES_ORDER_STATUS_ID ON TB_SALES_ORDER(STATUS_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_PURCHASE_ORDER_STATUS_ID ON TB_PURCHASE_ORDER(STATUS_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_PRODUCTION_STATUS_ID ON TB_PRODUCTION(STATUS_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_INOUT_MOVEMENT_TYPE_ID ON TB_INOUT(MOVEMENT_TYPE_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_INOUT_SOURCE_TYPE_ID ON TB_INOUT(SOURCE_TYPE_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_INOUT_STATUS_ID ON TB_INOUT(STATUS_ID);", cancellationToken);
        await ExecuteAsync(connection, "CREATE INDEX IF NOT EXISTS IX_AUDIT_ACTION_ID ON TB_AUDIT_LOG(ACTION_ID);", cancellationToken);
    }

    private static async Task AddColumnAsync(SqliteConnection connection, string table, string column, CancellationToken cancellationToken)
    {
        await using var check = connection.CreateCommand();
        check.CommandText = $"PRAGMA table_info({table});";
        await using var reader = await check.ExecuteReaderAsync(cancellationToken);
        while (await reader.ReadAsync(cancellationToken))
            if (string.Equals(reader.GetString(1), column, StringComparison.OrdinalIgnoreCase))
                return;

        await reader.DisposeAsync();
        await using var alter = connection.CreateCommand();
        alter.CommandText = $"ALTER TABLE {table} ADD COLUMN {column} INTEGER REFERENCES TB_CODE(CODE_ID);";
        await alter.ExecuteNonQueryAsync(cancellationToken);
    }

    private static async Task ExecuteAsync(SqliteConnection connection, string sql, CancellationToken cancellationToken)
    {
        await using var command = connection.CreateCommand();
        command.CommandText = sql;
        await command.ExecuteNonQueryAsync(cancellationToken);
    }
}
