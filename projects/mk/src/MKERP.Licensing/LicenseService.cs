using System.Runtime.Versioning;
using System.Security.Cryptography;
using System.Text.Json;

namespace MKERP.Licensing;

[SupportedOSPlatform("windows")]
public sealed class LicenseService
{
    public const string ProductName = "MK ERP";
    private readonly RSA _publicKey;

    private const string PublicKeyPem = """
-----BEGIN PUBLIC KEY-----
MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAxIpSaEdcWp7KPFFob6rW
592dg/wt7F9W4F11Yu4kj8ZrPOotpSNHjM4JpR5GNOlU+BBZ/j/kVq746jyeX9Md
yQgZxjrc+EAJ0+l4RrcVb3WX0L6ZLXhwn/8RYKXRr5x2QinRWk+2q8w1FGte/yM4
pHGi4hjji5kbT5C26DAIKG8gzRzK4wLPpNkPKzmuauuDkFNCFXP+tuLneOnil8Hc
xOVUmeUQatBb9wdHQjjBn903zjTWpRvjrbRms1wrVOImTyH8OLbSTDRshd0wCADb
Z77A2t8QLkLbNXNVFJEXv2EDpRhBIT4rA5kjGvoVhATnrsw+EHJ50Z1sWBGJN+k9
TBUPy/CPAVzHZFaRt7WYUJSWPk0j2fwQKsAD3+POfo9JpZnG6b8BOCCqetPvzp3/
hKuhCk8jbyE6CPiyUvMnZoG+2h1gmppuNOlNEdCxTu5+XaT3JS3eHFanCR6sEIq3
+SHVjxyZTXiEZIqAsJgLAxJOoarjUnzOs5pv5i5VY645AgMBAAE=
-----END PUBLIC KEY-----
""";

    public LicenseService()
    {
        _publicKey = RSA.Create();
        _publicKey.ImportFromPem(PublicKeyPem);
    }

    public LicenseValidationResult ValidateInstalledLicense()
    {
#if DEBUG
        return new(true, "DEBUG 빌드: ?�이?�스 검?��? ?�략?�니??", null);
#else
        var candidates = new[]
        {
            Path.Combine(AppContext.BaseDirectory, "license.json"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "MKERP", "license.json")
        };

        LicenseValidationResult? lastInvalidResult = null;
        var foundLicenseFile = false;

        foreach (var path in candidates.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            if (!File.Exists(path)) continue;
            foundLicenseFile = true;

            try
            {
                var document = JsonSerializer.Deserialize<LicenseDocument>(File.ReadAllText(path));
                if (document is null)
                {
                    lastInvalidResult = new(false, "?�이?�스 ?�일 ?�식???�바르�? ?�습?�다.", null);
                    continue;
                }

                var result = LicenseVerifier.Validate(
                    document, _publicKey, ProductName,
                    MachineFingerprint.Get(), DateTime.UtcNow);

                if (result.IsValid) return result;
                lastInvalidResult = result;
            }
            catch
            {
                lastInvalidResult = new(false, "?�이?�스 ?�일???�을 ???�습?�다.", null);
            }
        }

        if (foundLicenseFile && lastInvalidResult is not null)
            return lastInvalidResult;

        return new(false, "?�치???�이?�스 ?�일???�습?�다.", null);
#endif
    }

    public static string GetMachineFingerprint() => MachineFingerprint.Get();
}