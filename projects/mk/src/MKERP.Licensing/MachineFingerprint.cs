using System.Runtime.Versioning;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Win32;

namespace MKERP.Licensing;

[SupportedOSPlatform("windows")]
public static class MachineFingerprint
{
    public static string Get()
    {
        var values = new[]
        {
            ReadRegistry(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography", "MachineGuid"),
            ReadRegistry(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductId"),
            Environment.OSVersion.VersionString,
            Environment.Is64BitOperatingSystem ? "x64" : "x86"
        };
        var raw = string.Join("|", values.Select(v => v ?? ""));
        var hash = SHA256.HashData(Encoding.UTF8.GetBytes(raw));
        return Convert.ToHexString(hash);
    }

    private static string? ReadRegistry(string path, string name)
    {
        try { return Registry.GetValue(path, name, null)?.ToString(); }
        catch { return null; }
    }
}