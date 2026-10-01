using System.Security.Cryptography;
using System.Text.Json;
using MKERP.Licensing;

if (args.Length < 3)
{
    Console.WriteLine("사용법: MKERP.LicenseTool <private-key.pem> <customer-id> <machine-fingerprint> [days] [license-id]");
    Console.WriteLine("days를 생략하면 영구 라이선스입니다.");
    return 2;
}

var keyPath = args[0];
var customerId = args[1];
var machine = args[2];
var days = args.Length >= 4 && int.TryParse(args[3], out var d) ? d : 0;
var licenseId = args.Length >= 5 ? args[4] : Guid.NewGuid().ToString("N");

using var rsa = RSA.Create();
rsa.ImportFromPem(File.ReadAllText(keyPath));

var issued = DateTime.UtcNow;
var payload = new LicensePayload
{
    LicenseId = licenseId,
    CustomerId = customerId,
    Product = LicenseService.ProductName,
    MachineFingerprint = machine.ToUpperInvariant(),
    IssuedAtUtc = issued,
    ExpiresAtUtc = days > 0 ? issued.AddDays(days) : null
};

var document = new LicenseDocument
{
    Payload = payload,
    Signature = LicenseVerifier.Sign(payload, rsa)
};

var output = Path.Combine(Environment.CurrentDirectory, $"license-{licenseId}.json");
var json = JsonSerializer.Serialize(document, new JsonSerializerOptions { WriteIndented = true });
File.WriteAllText(output, json);
Console.WriteLine($"LICENSE_CREATED: {output}");
Console.WriteLine($"LICENSE_ID: {licenseId}");
return 0;