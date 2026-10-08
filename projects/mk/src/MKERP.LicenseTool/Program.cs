using System.Security.Cryptography;
using System.Text.Json;
using System.Security.Cryptography.X509Certificates;
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
    var signatureValid = LicenseVerifier.Verify(verifyDocument, rsa);

    Console.WriteLine(signatureValid ? "VALID" : "INVALID");
    Console.WriteLine(signatureValid
        ? "?�이?�스 ?�명???�효?�니?? ?�드?�어 바인?��? ?�??PC?�서 ?�인?�야 ?�니??"
        : "?�이?�스 ?�명???�바르�? ?�습?�다.");
    return signatureValid ? 0 : 4;
}

if (args.Length == 3 && string.Equals(args[0], "verify-machine", StringComparison.OrdinalIgnoreCase))
{
    var verifyDocument = JsonSerializer.Deserialize<LicenseDocument>(File.ReadAllText(args[1]));
    if (verifyDocument is null) return 3;

    using var rsa = RSA.Create();
    var publicKey = File.ReadAllText(@"D:\Atlas\license-keys\mkerp\public-key.pem");
    rsa.ImportFromPem(publicKey);
    var result = LicenseVerifier.Validate(
        verifyDocument, rsa, LicenseService.ProductName,
        args[2], DateTime.UtcNow);
    Console.WriteLine(result.IsValid ? "VALID" : "INVALID");
    Console.WriteLine(result.Message);
    return result.IsValid ? 0 : 4;
}

if (args.Length >= 4 && string.Equals(args[0], "issue", StringComparison.OrdinalIgnoreCase))
{
    var requestPath = args[1];
    var requestCustomerId = args[2];
    var requestPrivateKeyPath = args[3];
    var requestLicenseDays = 0;
    if (args.Length >= 5 && !int.TryParse(args[4], out requestLicenseDays))
    {
        Console.WriteLine("INVALID_LICENSE_DAYS");
        return 6;
    }
    var requestLicenseId = args.Length >= 6 ? args[5] : Guid.NewGuid().ToString("N");

    try
    {
        if (requestLicenseDays < 0)
        {
            Console.WriteLine("INVALID_LICENSE_DAYS");
            return 6;
        }

        if (string.IsNullOrWhiteSpace(requestCustomerId))
        {
            Console.WriteLine("INVALID_CUSTOMER_ID");
            return 6;
        }

        var activationRequest = JsonSerializer.Deserialize<LicenseActivationRequest>(File.ReadAllText(requestPath));
        if (activationRequest is null ||
            !string.Equals(activationRequest.Product, LicenseService.ProductName, StringComparison.Ordinal) ||
            !MachineFingerprint.IsV2(activationRequest.MachineFingerprint) ||
            string.IsNullOrWhiteSpace(activationRequest.MachineFingerprint) ||
            string.IsNullOrWhiteSpace(activationRequest.DevicePublicKey) ||
            string.IsNullOrWhiteSpace(activationRequest.RequestSignature))
        {
            Console.WriteLine("INVALID_LICENSE_REQUEST");
            return 6;
        }

        var unsignedRequest = new LicenseActivationRequestUnsigned
        {
            Product = activationRequest.Product,
            MachineFingerprint = activationRequest.MachineFingerprint,
            CreatedAtUtc = activationRequest.CreatedAtUtc,
            DevicePublicKey = activationRequest.DevicePublicKey
        };
        if (!DeviceIdentity.VerifyRequest(unsignedRequest, activationRequest.RequestSignature, activationRequest.DevicePublicKey))
        {
            Console.WriteLine("INVALID_LICENSE_REQUEST_SIGNATURE");
            return 6;
        }

        RSA requestPrivateKey;
        if (requestPrivateKeyPath.StartsWith("cert:", StringComparison.OrdinalIgnoreCase))
        {
            var thumbprint = requestPrivateKeyPath[5..].Replace(" ", "");
            using var store = new X509Store(StoreName.My, StoreLocation.CurrentUser);
            store.Open(OpenFlags.ReadOnly);
            var cert = store.Certificates.Cast<X509Certificate2>().FirstOrDefault(c => string.Equals(c.Thumbprint?.Replace(" ", ""), thumbprint, StringComparison.OrdinalIgnoreCase));
            if (cert is null) throw new InvalidOperationException("서명용 인증서를 찾을 수 없습니다.");
            requestPrivateKey = cert.GetRSAPrivateKey() ?? throw new InvalidOperationException("인증서에 서명용 키가 없습니다.");
        }
        else
        {
            requestPrivateKey = RSA.Create();
            requestPrivateKey.ImportFromPem(File.ReadAllText(requestPrivateKeyPath));
        }
        using (requestPrivateKey)
        {

        var requestIssued = DateTime.UtcNow;
        var requestPayload = new LicensePayload
        {
            LicenseId = requestLicenseId,
            CustomerId = requestCustomerId,
            Product = LicenseService.ProductName,
            MachineFingerprint = activationRequest.MachineFingerprint,
            IssuedAtUtc = requestIssued,
            ExpiresAtUtc = requestLicenseDays > 0 ? requestIssued.AddDays(requestLicenseDays) : null,
            DevicePublicKey = activationRequest.DevicePublicKey
        };
        var requestDocument = new LicenseDocument
        {
            Payload = requestPayload,
            Signature = LicenseVerifier.Sign(requestPayload, requestPrivateKey)
        };

        var requestOutput = Path.Combine(Environment.CurrentDirectory, "license.json");
        var requestJson = JsonSerializer.Serialize(requestDocument, new JsonSerializerOptions { WriteIndented = true });
        File.WriteAllText(requestOutput, requestJson);
        Console.WriteLine($"LICENSE_CREATED: {requestOutput}");
        Console.WriteLine($"LICENSE_ID: {requestLicenseId}");
        return 0;
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"LICENSE_ISSUE_FAILED: {ex.Message}");
        return 7;
    }
}

if (args.Length < 3)
{
    Console.WriteLine("Usage: MKERP.LicenseTool machine");
    Console.WriteLine("Usage: MKERP.LicenseTool verify <license.json>");
    Console.WriteLine("Usage: MKERP.LicenseTool verify-machine <license.json> <machine-fingerprint>");
    Console.WriteLine("Usage: MKERP.LicenseTool issue <license-request.json> <customer-id> <key.pem|cert:THUMBPRINT> [days] [license-id]");
    Console.WriteLine("Usage: MKERP.LicenseTool <private-key.pem> <customer-id> <machine-fingerprint> [days] [license-id]");
    return 2;
}

var keyPath = args[0];
var customerId = args[1];
var machine = args[2];
if (!MachineFingerprint.IsV2(machine))
{
    Console.WriteLine("INVALID_MACHINE_FINGERPRINT: v2 hardware binding is required.");
    return 5;
}

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
    MachineFingerprint = machine,
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
