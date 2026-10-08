using System.Runtime.Versioning;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace MKERP.Licensing;

public sealed record LicenseValidationResult(bool IsValid, string Message, LicensePayload? Payload);

[SupportedOSPlatform("windows")]
public static class LicenseVerifier
{
    public static string SerializePayload(LicensePayload payload)
        => JsonSerializer.Serialize(payload);

    public static string Sign(LicensePayload payload, RSA privateKey)
    {
        var data = Encoding.UTF8.GetBytes(SerializePayload(payload));
        return Convert.ToBase64String(privateKey.SignData(data, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1));
    }

    public static bool Verify(LicenseDocument document, RSA publicKey)
    {
        try
        {
            var data = Encoding.UTF8.GetBytes(SerializePayload(document.Payload));
            var signature = Convert.FromBase64String(document.Signature);
            return publicKey.VerifyData(data, signature, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        }
        catch { return false; }
    }

    public static LicenseValidationResult Validate(
        LicenseDocument document,
        RSA publicKey,
        string expectedProduct,
        string currentMachineFingerprint,
        DateTime nowUtc)
    {
        if (!Verify(document, publicKey))
            return new(false, "라이선스 서명이 올바르지 않습니다.", null);

        var p = document.Payload;
        if (!string.Equals(p.Product, expectedProduct, StringComparison.Ordinal))
            return new(false, "다른 제품의 라이선스입니다.", p);

        var bindingValid = MachineFingerprint.IsV2(p.MachineFingerprint)
            ? MachineFingerprint.Matches(p.MachineFingerprint, currentMachineFingerprint, 4)
            : string.Equals(p.MachineFingerprint, MachineFingerprint.GetLegacy(), StringComparison.OrdinalIgnoreCase);

        if (!bindingValid)
            return new(false, "이 PC에 등록된 라이선스가 아닙니다.", p);

        if (!string.IsNullOrWhiteSpace(p.DevicePublicKey) && !DeviceIdentity.MatchesInstalledIdentity(p.DevicePublicKey))
            return new(false, "이 PC의 등록된 장치 식별 키와 라이선스가 일치하지 않습니다.", p);

        if (p.IssuedAtUtc > nowUtc.AddMinutes(5))
            return new(false, "라이선스 발급 시간이 유효하지 않습니다.", p);

        if (p.ExpiresAtUtc is not null && p.ExpiresAtUtc.Value < nowUtc)
            return new(false, "라이선스가 만료되었습니다.", p);

        return new(true, "라이선스가 유효합니다.", p);
    }
}
