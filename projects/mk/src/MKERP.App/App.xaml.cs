using System.IO;
using System.Windows;
using Microsoft.EntityFrameworkCore;
using WpfApplication = System.Windows.Application;
using MKERP.Infrastructure;
using MKERP.Licensing;

namespace MKERP.App;

public partial class App : WpfApplication
{
    protected override async void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        var license = new LicenseService();
        var validation = license.ValidateInstalledLicense();
        if (!validation.IsValid)
        {
            var machine = LicenseService.GetMachineFingerprint();
            MessageBox.Show(
                $"MK ERP 라이선스가 유효하지 않습니다.\n\n{validation.Message}\n\n이 PC의 활성화 코드:\n{machine}\n\n발급받은 license.json을 프로그램 폴더에 넣고 다시 실행하십시오.",
                "MK ERP 라이선스", MessageBoxButton.OK, MessageBoxImage.Stop);
            Shutdown(2);
            return;
        }

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