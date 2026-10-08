using System.Runtime.InteropServices;
using System.Security.Cryptography;
using System.Text;
using System.Text.Json;

namespace MKERP.Licensing;

public static class DeviceIdentity
{
    private static readonly string IdentityDirectory = Path.Combine(
        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "MKERP");
    private static readonly string PrivateKeyPath = Path.Combine(IdentityDirectory, "device-key.bin");

    public static string GetOrCreatePublicKey()
    {
        using var rsa = LoadOrCreate();
        return rsa.ExportRSAPublicKeyPem();
    }

    public static string SignRequest(LicenseActivationRequestUnsigned request)
    {
        using var rsa = LoadOrCreate();
        var data = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(request));
        return Convert.ToBase64String(rsa.SignData(data, HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1));
    }

    public static bool VerifyRequest(LicenseActivationRequestUnsigned request, string signature, string publicKeyPem)
    {
        try
        {
            using var rsa = RSA.Create();
            rsa.ImportFromPem(publicKeyPem);
            var data = Encoding.UTF8.GetBytes(JsonSerializer.Serialize(request));
            return rsa.VerifyData(data, Convert.FromBase64String(signature), HashAlgorithmName.SHA256, RSASignaturePadding.Pkcs1);
        }
        catch { return false; }
    }

    public static bool MatchesInstalledIdentity(string publicKeyPem)
    {
        try
        {
            using var rsa = LoadExisting();
            if (rsa is null) return false;
            return string.Equals(NormalizePem(rsa.ExportRSAPublicKeyPem()), NormalizePem(publicKeyPem), StringComparison.Ordinal);
        }
        catch { return false; }
    }

    private static RSA LoadOrCreate()
    {
        Directory.CreateDirectory(IdentityDirectory);
        var existing = LoadExisting();
        if (existing is not null) return existing;

        var rsa = RSA.Create(2048);
        var privateKey = rsa.ExportPkcs8PrivateKey();
        try
        {
            File.WriteAllBytes(PrivateKeyPath, Dpapi.Protect(privateKey));
        }
        finally
        {
            CryptographicOperations.ZeroMemory(privateKey);
        }
        return rsa;
    }

    private static RSA? LoadExisting()
    {
        if (!File.Exists(PrivateKeyPath)) return null;
        var protectedKey = File.ReadAllBytes(PrivateKeyPath);
        var privateKey = Dpapi.Unprotect(protectedKey);
        try
        {
            var rsa = RSA.Create();
            rsa.ImportPkcs8PrivateKey(privateKey, out _);
            return rsa;
        }
        finally
        {
            CryptographicOperations.ZeroMemory(privateKey);
        }
    }

    private static string NormalizePem(string value)
        => value.Replace("\r", "").Replace("\n", "").Trim();
}

internal static class Dpapi
{
    [StructLayout(LayoutKind.Sequential)]
    private struct DataBlob
    {
        public int cbData;
        public IntPtr pbData;
    }

    [DllImport("crypt32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    private static extern bool CryptProtectData(
        ref DataBlob pDataIn, string? szDataDescr, IntPtr pOptionalEntropy,
        IntPtr pvReserved, IntPtr pPromptStruct, int dwFlags, ref DataBlob pDataOut);

    [DllImport("crypt32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
    private static extern bool CryptUnprotectData(
        ref DataBlob pDataIn, IntPtr ppszDataDescr, IntPtr pOptionalEntropy,
        IntPtr pvReserved, IntPtr pPromptStruct, int dwFlags, ref DataBlob pDataOut);

    public static byte[] Protect(byte[] data) => Transform(data, ProtectCore);
    public static byte[] Unprotect(byte[] data) => Transform(data, UnprotectCore);

    private static bool ProtectCore(ref DataBlob input, IntPtr description, IntPtr entropy, IntPtr reserved, IntPtr prompt, int flags, ref DataBlob output)
        => CryptProtectData(ref input, null, entropy, reserved, prompt, flags, ref output);

    private static bool UnprotectCore(ref DataBlob input, IntPtr description, IntPtr entropy, IntPtr reserved, IntPtr prompt, int flags, ref DataBlob output)
        => CryptUnprotectData(ref input, IntPtr.Zero, entropy, reserved, prompt, flags, ref output);

    private delegate bool TransformDelegate(
        ref DataBlob input, IntPtr description, IntPtr entropy, IntPtr reserved,
        IntPtr prompt, int flags, ref DataBlob output);

    private static byte[] Transform(byte[] data, TransformDelegate transform)
    {
        var inputPtr = Marshal.AllocHGlobal(data.Length);
        try
        {
            Marshal.Copy(data, 0, inputPtr, data.Length);
            var input = new DataBlob { cbData = data.Length, pbData = inputPtr };
            var output = new DataBlob();
            if (!transform(ref input, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, IntPtr.Zero, 0, ref output))
                throw new CryptographicException(Marshal.GetLastWin32Error());

            try
            {
                var result = new byte[output.cbData];
                Marshal.Copy(output.pbData, result, 0, output.cbData);
                return result;
            }
            finally
            {
                if (output.pbData != IntPtr.Zero) Marshal.FreeHGlobal(output.pbData);
            }
        }
        finally
        {
            Marshal.FreeHGlobal(inputPtr);
        }
    }
}
