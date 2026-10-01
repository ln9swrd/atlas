using System.Security.Cryptography;
using System.Text.Json;
using MKERP.Licensing;

if (args.Length == 1 && string.Equals(args[0], "machine", StringComparison.OrdinalIgnoreCase))
{
    Console.WriteLine(LicenseService.GetMachineFingerprint());
    return 0;
}

if (args.Length == 2 && string.Equals(args[0], "verify", StringComparison.OrdinalIgnoreCase))
{
    var verifyDocument = JsonSerializer.Deserialize<LicenseDocument>(File.ReadAllText(args[1]));
    if (verifyDocument is null) return 3;
    using var rsa = RSA.Create();
    var publicKey = File.ReadAllText(@"D:\Atlas\license-keys\mkerp\public-key.pem");
    rsa.ImportFromPem(publicKey);
    var result = LicenseVerifier.Validate(
        verifyDocument, rsa, LicenseService.ProductName,
        LicenseService.GetMachineFingerprint(), DateTime.UtcNow);
    Console.WriteLine(result.IsValid ? "VALID" : "INVALID");
    Console.WriteLine(result.Message);
    return result.IsValid ? 0 : 4;
}

if (args.Length < 3)
{
    Console.WriteLine("?ъ슜踰? MKERP.LicenseTool machine");
    Console.WriteLine("?ъ슜踰? MKERP.LicenseTool verify <license.json>");
    Console.WriteLine("?ъ슜踰? MKERP.LicenseTool <private-key.pem> <customer-id> <machine-fingerprint> [days] [license-id]");
    return 2;
}

var keyPath = args[0];
var customerId = args[1];
var machine = args[2];
var days = args.Length >= 4 && int.TryParse(args[3], out var d) ? d : 0;
var licenseId = args.Length >= 5 ? args[4] : Guid.NewGuid().ToString("N");

using var privateKey = RSA.Create();
privateKey.ImportFromPem(File.ReadAllText(keyPath));

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
    Signature = LicenseVerifier.Sign(payload, privateKey)
};

var output = Path.Combine(Environment.CurrentDirectory, $"license-{licenseId}.json");
var json = JsonSerializer.Serialize(document, new JsonSerializerOptions { WriteIndented = true });
File.WriteAllText(output, json);
Console.WriteLine($"LICENSE_CREATED: {output}");
Console.WriteLine($"LICENSE_ID: {licenseId}");
return 0;
