namespace MKERP.Domain;

public sealed class PartnerItem
{
    public long Id { get; set; }
    public long PartnerId { get; set; }
    public long ItemId { get; set; }
    public string? PartnerItemCode { get; set; }
    public string? PartnerItemName { get; set; }
    public bool IsActive { get; set; } = true;
}
