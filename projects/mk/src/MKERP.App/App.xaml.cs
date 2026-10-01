using System.IO;
using System.Windows;
using Microsoft.EntityFrameworkCore;
using WpfApplication = System.Windows.Application;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class App : WpfApplication
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
        try
        {
            await new BackupService(databasePath).BackupIfDueAsync();
        }
        catch (Exception ex)
        {
            MessageBox.Show($"주간 백업을 생성하지 못했습니다.\n{ex.Message}", "백업 경고", MessageBoxButton.OK, MessageBoxImage.Warning);
        }

        var window = new MainWindow();
        window.Show();
    }
}