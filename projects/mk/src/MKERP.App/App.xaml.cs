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
            string requestPath;
            try
            {
                var requestDirectory = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "MKERP");
                Directory.CreateDirectory(requestDirectory);
                requestPath = Path.Combine(requestDirectory, "license-request.json");
                var requestUnsigned = new LicenseActivationRequestUnsigned
                {
                    MachineFingerprint = machine,
                    CreatedAtUtc = DateTime.UtcNow,
                    DevicePublicKey = DeviceIdentity.GetOrCreatePublicKey()
                };
                var request = new LicenseActivationRequest
                {
                    Product = requestUnsigned.Product,
                    MachineFingerprint = requestUnsigned.MachineFingerprint,
                    CreatedAtUtc = requestUnsigned.CreatedAtUtc,
                    DevicePublicKey = requestUnsigned.DevicePublicKey,
                    RequestSignature = DeviceIdentity.SignRequest(requestUnsigned)
                };
                File.WriteAllText(
                    requestPath,
                    System.Text.Json.JsonSerializer.Serialize(
                        request,
                        new System.Text.Json.JsonSerializerOptions { WriteIndented = true }));
            }
            catch (Exception ex)
            {
                MessageBox.Show(
                    $"MK ERP 라이선스가 유효하지 않습니다.\n\n{validation.Message}\n\n라이선스 요청 파일을 생성하지 못했습니다.\n\n{ex.Message}",
                    "MK ERP 라이선스", MessageBoxButton.OK, MessageBoxImage.Error);
                Shutdown(2);
                return;
            }

            MessageBox.Show(
                $"MK ERP 라이선스가 유효하지 않습니다.\n\n{validation.Message}\n\n이 PC의 라이선스 요청 파일이 생성되었습니다.\n\n{requestPath}\n\n이 파일을 발급자에게 보내고, 받은 license.json을 다시 설치하십시오.",
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