namespace MKERP.Domain;

public sealed class SystemSetting
{
    public string Key { get; set; } = string.Empty;
    public string Value { get; set; } = string.Empty;
    public string ValueType { get; set; } = string.Empty;
    public string? Description { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class CodeGroup
{
    public long Id { get; set; }
    public string Key { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public string? Description { get; set; }
    public bool IsActive { get; set; } = true;
}

public sealed class Code
{
    public long Id { get; set; }
    public long CodeGroupId { get; set; }
    public string Key { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public int SortOrder { get; set; }
    public bool IsActive { get; set; } = true;
    public string? Description { get; set; }
}

public sealed class Item
{
    public long Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public long CategoryId { get; set; }
    public long? GradeId { get; set; }
    public string UnitCode { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class ItemGrade
{
    public long Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public bool IsActive { get; set; } = true;
}

public sealed class AuditLog
{
    public long Id { get; set; }
    public string EntityName { get; set; } = string.Empty;
    public long? EntityId { get; set; }
    public long ActionId { get; set; }
    public string? Actor { get; set; }
    public DateTime OccurredAt { get; set; }
    public string? BeforeJson { get; set; }
    public string? AfterJson { get; set; }
    public string? Note { get; set; }
}

public sealed class Partner
{
    public long Id { get; set; }
    public string Code { get; set; } = string.Empty;
    public string Name { get; set; } = string.Empty;
    public long TypeId { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class Price
{
    public long Id { get; set; }
    public long PartnerId { get; set; }
    public long ItemId { get; set; }
    public decimal UnitPrice { get; set; }
    public DateTime EffectiveFrom { get; set; }
    public int Priority { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class PurchaseOrder
{
    public long Id { get; set; }
    public string DocumentNo { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public long PartnerId { get; set; }
    public DateTime? DueDate { get; set; }
    public long StatusId { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class PurchaseOrderDetail
{
    public long Id { get; set; }
    public long PurchaseOrderId { get; set; }
    public long ItemId { get; set; }
    public long? PriceId { get; set; }
    public decimal OrderQty { get; set; }
    public decimal ProcessedQty { get; set; }
    public bool IsActive { get; set; } = true;
    public decimal AppliedUnitPrice { get; set; }
    public decimal Amount { get; set; }
    public DateTime? DueDate { get; set; }
    public string? Note { get; set; }
}

public sealed class SalesOrder
{
    public long Id { get; set; }
    public string DocumentNo { get; set; } = string.Empty;
    public DateTime OrderDate { get; set; }
    public long PartnerId { get; set; }
    public DateTime? DueDate { get; set; }
    public long StatusId { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class Production
{
    public long Id { get; set; }
    public string DocumentNo { get; set; } = string.Empty;
    public DateTime ProductionDate { get; set; }
    public long StatusId { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class ProductionDetail
{
    public long Id { get; set; }
    public long ProductionId { get; set; }
    public long ItemId { get; set; }
    public decimal ProductionQty { get; set; }
    public decimal DefectQty { get; set; }
}

public sealed class Lot
{
    public long Id { get; set; }
    public string MkLotNo { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class PartnerLot
{
    public long Id { get; set; }
    public long PartnerId { get; set; }
    public string PartnerLotNo { get; set; } = string.Empty;
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class LotPartnerLot
{
    public long LotId { get; set; }
    public long PartnerLotId { get; set; }
    public DateTime CreatedAt { get; set; }
}

public sealed class InOut
{
    public long Id { get; set; }
    public string DocumentNo { get; set; } = string.Empty;
    public DateTime MovementDate { get; set; }
    public long MovementTypeId { get; set; }
    public long? PartnerId { get; set; }
    public long? SourceTypeId { get; set; }
    public long? SourceId { get; set; }
    public long StatusId { get; set; }
    public string? Note { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
}

public sealed class InOutDetail
{
    public long Id { get; set; }
    public long InOutId { get; set; }
    public long ItemId { get; set; }
    public long? LotId { get; set; }
    public long? PartnerLotId { get; set; }
    public decimal Quantity { get; set; }
    public decimal? UnitPrice { get; set; }
    public decimal? Amount { get; set; }
}

public sealed class OrderProcessHistory
{
    public long Id { get; set; }
    public long SourceTypeId { get; set; }
    public long SourceDetailId { get; set; }
    public long InOutDetailId { get; set; }
    public decimal ProcessQty { get; set; }
    public long ActionId { get; set; }
    public long? ReversesHistoryId { get; set; }
    public DateTime CreatedAt { get; set; }
}

public sealed class SalesOrderDetail
{
    public long Id { get; set; }
    public long SalesOrderId { get; set; }
    public long ItemId { get; set; }
    public long? PartnerItemId { get; set; }
    public long? PriceId { get; set; }
    public decimal OrderQty { get; set; }
    public decimal ProcessedQty { get; set; }
    public bool IsActive { get; set; } = true;
    public decimal AppliedUnitPrice { get; set; }
    public decimal Amount { get; set; }
    public DateTime? DueDate { get; set; }
    public string? Note { get; set; }
}
