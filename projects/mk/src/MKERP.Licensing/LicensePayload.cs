using System.Text.Json.Serialization;

namespace MKERP.Licensing;

public sealed class LicenseActivationRequest
{
    public string Product { get; init; } = "MK ERP";
    public string MachineFingerprint { get; init; } = "";
    public DateTime CreatedAtUtc { get; init; }
    public string DevicePublicKey { get; init; } = "";
    public string RequestSignature { get; init; } = "";
}

public sealed class LicenseActivationRequestUnsigned
{
    public string Product { get; init; } = "MK ERP";
    public string MachineFingerprint { get; init; } = "";
    public DateTime CreatedAtUtc { get; init; }
    public string DevicePublicKey { get; init; } = "";
}

public sealed class LicensePayload
{
    [JsonPropertyOrder(0)] public string LicenseId { get; init; } = "";
    [JsonPropertyOrder(1)] public string CustomerId { get; init; } = "";
    [JsonPropertyOrder(2)] public string Product { get; init; } = "MK ERP";
    [JsonPropertyOrder(3)] public string MachineFingerprint { get; init; } = "";
    [JsonPropertyOrder(4)] public DateTime IssuedAtUtc { get; init; }
    [JsonPropertyOrder(5)] public DateTime? ExpiresAtUtc { get; init; }
    [JsonPropertyOrder(6)] public string DevicePublicKey { get; init; } = "";
}

public sealed class LicenseDocument
{
    public LicensePayload Payload { get; init; } = new();
    public string Signature { get; init; } = "";
}