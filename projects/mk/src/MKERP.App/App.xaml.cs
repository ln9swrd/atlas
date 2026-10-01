using System.IO;
using System.Windows;
using Microsoft.EntityFrameworkCore;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class App : Application
{
    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var dataDirectory = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "MKERP");

        var databasePath = Path.Combine(dataDirectory, "MKERP.db");
        await using var db = new ERPDbContext(
            new DbContextOptionsBuilder<ERPDbContext>()
                .UseSqlite($"Data Source={databasePath}")
                .Options);

        await new DatabaseInitializer(databasePath).InitializeAsync();

        var window = new MainWindow();
        window.Show();
    }
}