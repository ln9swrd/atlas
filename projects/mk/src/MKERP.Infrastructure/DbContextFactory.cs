using Microsoft.EntityFrameworkCore;

namespace MKERP.Infrastructure;

public static class DbContextFactory
{
    public static ERPDbContext Create(string databasePath)
    {
        var options = new DbContextOptionsBuilder<ERPDbContext>()
            .UseSqlite($"Data Source={databasePath}")
            .Options;
        return new ERPDbContext(options);
    }
}
