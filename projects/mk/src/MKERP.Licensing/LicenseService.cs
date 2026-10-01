using System.Security.Cryptography;
using System.Text.Json;

namespace MKERP.Licensing;

public sealed class LicenseService
{
    public const string ProductName = "MK ERP";
    private readonly RSA _publicKey;

    private const string PublicKeyPem = """
-----BEGIN PUBLIC KEY-----
MIIBojANBgkqhkiG9w0BAQEFAAOCAY8AMIIBigKCAYEAw4v8WuwHu4le/SEeriTs
WcJwO6IWB7/zT64fiBHu/JG0pr4pT+OCkRIiMWRDtf7lY1w04FiKZVqEOKV5DbcD
Z+2xi75le9K3xNPZP0QS38C+iPyoKdLx0isrGAj3knTY2Nwn7qrHMBQmd4KrFjzw
QXtahKYfABMBGU9i+Pn2+oJGROpxoKkLL4eIfwK/RWgtSCPpA2LcygsEH8FO0gE3
DIIJFVDYhYQQeNW/qa2mFnwSMmVVjysm7ZD3HN/pUqysNj9mVuKU0PZJNZ1tLaTb
4Vl5Cyope3j5JcwW9fKtCr1y3RM5e0kbgnHXQow+V/mOYoWrJY7KhTG/bjtfI2dm
tmcphF5TCyL98y1APsTPQK++v6tVbbYJJgBnb3faXawTKy+Eadvoohr1xUyTd3rW
IplDfqJAxHmjvOm3Ki30deqC6wRi3Z7sJ2/vjiiBn0wD/5XWoN6VBrAzlS4HCXlu
hMEVQCzmaxaIs+xySz/aY2/AZAE/HTfka+KmyqRFbO8hAgMBAAE=
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
        return new(true, "DEBUG 빌드: 라이선스 검사를 생략합니다.", null);
#else
        var candidates = new[]
        {
            Path.Combine(AppContext.BaseDirectory, "license.json"),
            Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "MKERP", "license.json")
        };

        foreach (var path in candidates.Distinct(StringComparer.OrdinalIgnoreCase))
        {
            if (!File.Exists(path)) continue;
            try
            {
                var document = JsonSerializer.Deserialize<LicenseDocument>(File.ReadAllText(path));
                if (document is null) continue;
                return LicenseVerifier.Validate(
                    document, _publicKey, ProductName,
                    MachineFingerprint.Get(), DateTime.UtcNow);
            }
            catch { }
        }

        return new(false, "설치된 라이선스 파일이 없습니다.", null);
#endif
    }

    public static string GetMachineFingerprint() => MachineFingerprint.Get();
}