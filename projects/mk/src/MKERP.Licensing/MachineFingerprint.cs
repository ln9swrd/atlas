using System.Management;
using System.Runtime.Versioning;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Win32;

namespace MKERP.Licensing;

[SupportedOSPlatform("windows")]
public static class MachineFingerprint
{
    private static readonly string[] Names =
    {
        "MachineGuid", "SmbiosUuid", "BaseBoardSerial", "BiosSerial", "SystemDiskSerial"
    };

    public static string Get() => BuildV2(Collect());

    public static IReadOnlyDictionary<string, string> Collect()
        => new Dictionary<string, string>(StringComparer.Ordinal)
        {
            ["MachineGuid"] = Hash(ReadRegistry(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography", "MachineGuid")),
            ["SmbiosUuid"] = Hash(QueryWmi("Win32_ComputerSystemProduct", "UUID")),
            ["BaseBoardSerial"] = Hash(QueryWmi("Win32_BaseBoard", "SerialNumber")),
            ["BiosSerial"] = Hash(QueryWmi("Win32_BIOS", "SerialNumber")),
            ["SystemDiskSerial"] = Hash(QuerySystemDiskSerial())
        };

    public static bool IsV2(string value) => value.StartsWith("v2|", StringComparison.Ordinal);

    public static bool Matches(string licensed, string current, int requiredMatches = 3)
    {
        if (!IsV2(licensed) || !IsV2(current)) return false;
        var left = Parse(licensed);
        var right = Parse(current);
        var matches = Names.Count(name =>
            left.TryGetValue(name, out var a) &&
            right.TryGetValue(name, out var b) &&
            !string.IsNullOrWhiteSpace(a) &&
            a == b);
        return matches >= requiredMatches;
    }

    public static string GetLegacy()
    {
        var values = new[]
        {
            ReadRegistry(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography", "MachineGuid"),
            ReadRegistry(@"HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows NT\CurrentVersion", "ProductId"),
            Environment.OSVersion.VersionString,
            Environment.Is64BitOperatingSystem ? "x64" : "x86"
        };
        return Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(string.Join("|", values.Select(v => v ?? "")))));
    }

    private static string BuildV2(IReadOnlyDictionary<string, string> values)
        => "v2|" + string.Join("|", Names.Select(name => $"{name}={values.GetValueOrDefault(name, "")}"));

    private static Dictionary<string, string> Parse(string value)
        => value.Split('|', StringSplitOptions.RemoveEmptyEntries)
            .Skip(1)
            .Select(x => x.Split('=', 2))
            .Where(x => x.Length == 2)
            .ToDictionary(x => x[0], x => x[1], StringComparer.Ordinal);

    private static string Hash(string? value)
    {
        var normalized = (value ?? "").Trim().ToUpperInvariant();
        return string.IsNullOrWhiteSpace(normalized) ? "" :
            Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(normalized)));
    }

    private static string? QueryWmi(string className, string propertyName)
    {
        try
        {
            using var searcher = new ManagementObjectSearcher($"SELECT {propertyName} FROM {className}");
            foreach (ManagementObject item in searcher.Get())
                return item[propertyName]?.ToString();
        }
        catch { }
        return null;
    }

    private static string? QuerySystemDiskSerial()
    {
        try
        {
            var drive = Path.GetPathRoot(Environment.SystemDirectory)?.TrimEnd('\\') ?? "C:";
            using var partitionSearcher = new ManagementObjectSearcher(
                $"ASSOCIATORS OF {{Win32_LogicalDisk.DeviceID='{drive}'}} WHERE AssocClass=Win32_LogicalDiskToPartition");

            foreach (ManagementObject partition in partitionSearcher.Get())
            {
                using var diskSearcher = new ManagementObjectSearcher(
                    $"ASSOCIATORS OF {{Win32_DiskPartition.DeviceID='{partition["DeviceID"]}'}} WHERE AssocClass=Win32_DiskDriveToDiskPartition");

                foreach (ManagementObject disk in diskSearcher.Get())
                    return disk["SerialNumber"]?.ToString();
            }
        }
        catch { }
        return null;
    }

    private static string? ReadRegistry(string path, string name)
    {
        try { return Registry.GetValue(path, name, null)?.ToString(); }
        catch { return null; }
    }
}
