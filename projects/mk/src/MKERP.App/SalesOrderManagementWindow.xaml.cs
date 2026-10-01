using System.Collections.ObjectModel;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using Microsoft.EntityFrameworkCore;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class SalesOrderManagementWindow : UserControl
{
    private readonly ERPDbContext _db;
    private IReadOnlyList<Partner> _partners = [];
    private IReadOnlyList<Item> _items = [];
    private Price? _applicablePrice;
    private bool _loading;
    private readonly ObservableCollection<SalesDraftRow> _draftRows = [];
    private long? _editingOrderId;

    public SalesOrderManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        OrderDateBox.SelectedDate = DateTime.Today;
        DraftGrid.ItemsSource = _draftRows;
        Loaded += async (_, _) => await LoadAsync();
        Unloaded += (_, _) => _db.Dispose();
    }

    private async Task LoadAsync()
    {
        _loading = true;
        _partners = await new PartnerRepository(_db).GetActiveAsync();
        _items = await new ItemRepository(_db).GetActiveAsync();
        PartnerBox.ItemsSource = _partners;
        ItemBox.ItemsSource = _items;
        _loading = false;
        await NewAsync();
        await LoadGridAsync();
    }

    private async Task NewAsync()
    {
        DocumentNoText.Text = await new SalesOrderRepository(_db)
            .GetNextDocumentNoAsync(OrderDateBox.SelectedDate?.Date ?? DateTime.Today);
        PartnerBox.SelectedIndex = -1;
        ItemBox.SelectedIndex = -1;
        QtyBox.Text = "1";
        ProcessQtyBox.Text = "1";
        DueDateBox.SelectedDate = null;
        AppliedPriceBox.Text = string.Empty;
        _applicablePrice = null;
        _draftRows.Clear();
        _editingOrderId = null;
        DetailGrid.ItemsSource = null;
    }

    private void AddDetail_Click(object sender, RoutedEventArgs e)
    {
        if (ItemBox.SelectedItem is not Item item || _applicablePrice is null)
        {
            MessageBox.Show("품목과 적용단가를 먼저 선택하세요.");
            return;
        }
        if (!decimal.TryParse(QtyBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var qty) || qty <= 0)
        {
            MessageBox.Show("수량을 올바르게 입력하세요.");
            return;
        }
        if (!decimal.TryParse(AppliedPriceBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var price) || price < 0)
        {
            MessageBox.Show("적용단가를 올바르게 입력하세요.");
            return;
        }
        var partner = PartnerBox.SelectedItem as Partner;
        var partnerItemId = partner is null ? null : _db.PartnerItems.AsNoTracking()
            .Where(x => x.IsActive && x.PartnerId == partner.Id && x.ItemId == item.Id)
            .Select(x => (long?)x.Id).FirstOrDefault();
        _draftRows.Add(new SalesDraftRow(0, item.Id, item.Name, partnerItemId, _applicablePrice.Id, qty, price, DueDateBox.SelectedDate?.Date));
    }

    private void RemoveDetail_Click(object sender, RoutedEventArgs e)
    {
        if (DraftGrid.SelectedItem is SalesDraftRow row) _draftRows.Remove(row);
    }

    private async Task LoadGridAsync()
    {
        Grid.ItemsSource = await new SalesOrderRepository(_db).GetRecentAsync();
    }

    private async Task UpdateAppliedPriceAsync()
    {
        if (_loading || PartnerBox.SelectedItem is not Partner partner
            || ItemBox.SelectedItem is not Item item)
        {
            AppliedPriceBox.Text = string.Empty;
            _applicablePrice = null;
            return;
        }

        var orderDate = OrderDateBox.SelectedDate?.Date ?? DateTime.Today;
        _applicablePrice = await new PriceRepository(_db)
            .GetApplicableAsync(partner.Id, item.Id, orderDate);
        AppliedPriceBox.Text = _applicablePrice is null
            ? string.Empty
            : _applicablePrice.UnitPrice.ToString("N2", CultureInfo.CurrentCulture);
    }

    private async void Input_Changed(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
        => await UpdateAppliedPriceAsync();

    private async void OrderDate_Changed(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (IsLoaded)
        {
            DocumentNoText.Text = await new SalesOrderRepository(_db)
                .GetNextDocumentNoAsync(OrderDateBox.SelectedDate?.Date ?? DateTime.Today);
            await UpdateAppliedPriceAsync();
        }
    }

    private async void New_Click(object sender, RoutedEventArgs e) => await NewAsync();

    private async void Edit_Click(object sender, RoutedEventArgs e)
    {
        if (Grid.SelectedItem is not SalesOrder order || order.StatusId != "DRAFT") { MessageBox.Show("작성 상태의 수주만 수정할 수 있습니다."); return; }
        _editingOrderId = order.Id;
        DocumentNoText.Text = order.DocumentNo;
        OrderDateBox.SelectedDate = order.OrderDate;
        DueDateBox.SelectedDate = order.DueDate;
        PartnerBox.SelectedValue = order.PartnerId;
        _draftRows.Clear();
        var rows = await _db.SalesOrderDetails.AsNoTracking().Where(x => x.SalesOrderId == order.Id && x.IsActive).Join(_db.Items.AsNoTracking(), d => d.ItemId, i => i.Id, (d,i) => new { d, i }).ToListAsync();
        foreach (var x in rows) _draftRows.Add(new SalesDraftRow(x.d.Id, x.d.ItemId, x.i.Name, x.d.PartnerItemId, x.d.PriceId ?? 0, x.d.OrderQty, x.d.AppliedUnitPrice, x.d.DueDate));
    }

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (PartnerBox.SelectedItem is not Partner partner)
        {
            MessageBox.Show("거래처는 필수입니다.");
            return;
        }

        if (_draftRows.Count == 0)
        {
            MessageBox.Show("저장할 상세행을 하나 이상 추가하세요.");
            return;
        }

        if (_applicablePrice is null)
        {
            MessageBox.Show("수주일 기준 적용 단가가 없습니다. 단가관리에서 먼저 등록하세요.");
            return;
        }

        var statusCodes = await new CodeRepository(_db).GetActiveAsync("DOCUMENT_STATUS");
        var draftCode = statusCodes.FirstOrDefault(x => x.Key == "DRAFT");
        if (draftCode is null)
        {
            MessageBox.Show("문서상태 기준정보에 작성중 코드가 없습니다.");
            return;
        }

        var orderDate = OrderDateBox.SelectedDate?.Date ?? DateTime.Today;
        var order = new SalesOrder
        {
            DocumentNo = DocumentNoText.Text,
            OrderDate = orderDate,
            PartnerId = partner.Id,
            DueDate = DueDateBox.SelectedDate?.Date,
            StatusId = draftCode.Key,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        var details = _draftRows.Select(row => new SalesOrderDetail
        {
            Id = row.Id,
            ItemId = row.ItemId,
            PartnerItemId = row.PartnerItemId,
            PriceId = row.PriceId,
            OrderQty = row.Quantity,
            AppliedUnitPrice = row.UnitPrice,
            Amount = row.Quantity * row.UnitPrice,
            DueDate = row.DueDate
        }).ToList();

        var repo = new SalesOrderRepository(_db);
        if (_editingOrderId is long editingId)
        {
            order.Id = editingId;
            order.DocumentNo = DocumentNoText.Text;
            foreach (var d in details) if (d.Id == 0) { }
            await repo.UpdateAsync(order, details);
        }
        else await repo.AddAsync(order, details);
        await LoadGridAsync();
        await NewAsync();
    }

    private async void Order_SelectionChanged(object sender, SelectionChangedEventArgs e)
    {
        if (Grid.SelectedItem is not SalesOrder order) { DetailGrid.ItemsSource = null; return; }
        DetailGrid.ItemsSource = await _db.SalesOrderDetails.AsNoTracking()
             .Where(x => x.SalesOrderId == order.Id && x.IsActive)
            .Join(_db.Items.AsNoTracking(), d => d.ItemId, i => i.Id, (d, i) => new SalesDetailRow
            {
                Id = d.Id, ItemName = i.Name, OrderQty = d.OrderQty, ProcessedQty = d.ProcessedQty,
                RemainingQty = d.OrderQty - d.ProcessedQty
            }).ToListAsync();
    }

    private async void Process_Click(object sender, RoutedEventArgs e)
    {
        if (DetailGrid.SelectedItem is not SalesDetailRow detail) { MessageBox.Show("출고할 상세행을 선택하세요."); return; }
        if (!decimal.TryParse(ProcessQtyBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var qty) || qty <= 0) { MessageBox.Show("출고수량을 올바르게 입력하세요."); return; }
        try { await new SalesOrderRepository(_db).ProcessDetailAsync(detail.Id, qty, ProcessMkLotBox.Text.Trim(), ProcessPartnerLotBox.Text.Trim()); await LoadGridAsync(); MessageBox.Show($"출고 {qty:N2}가 재고에 반영되었습니다."); }
        catch (InvalidOperationException ex) { MessageBox.Show(ex.Message); }
    }

    private async void Confirm_Click(object sender, RoutedEventArgs e)
    {
        if (Grid.SelectedItem is not SalesOrder order)
        {
            MessageBox.Show("확정할 수주를 목록에서 선택하세요.");
            return;
        }

        try
        {
            await new SalesOrderRepository(_db).ConfirmAsync(order.Id);
            await LoadGridAsync();
            MessageBox.Show("수주가 확정되었습니다. 실제 출고는 출고 버튼으로 처리합니다.");
        }
        catch (InvalidOperationException ex)
        {
            MessageBox.Show(ex.Message);
        }
    }

    private async void Cancel_Click(object sender, RoutedEventArgs e)
    {
        if (Grid.SelectedItem is not SalesOrder order) { MessageBox.Show("취소할 수주를 목록에서 선택하세요."); return; }
        try { await new SalesOrderRepository(_db).CancelAsync(order.Id); await LoadGridAsync(); MessageBox.Show("수주가 취소되고 재고가 복원되었습니다."); }
        catch (InvalidOperationException ex) { MessageBox.Show(ex.Message); }
    }

    private void Excel_Click(object sender, RoutedEventArgs e) => ExcelExportHelper.Export(Grid, $"수주_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx", "수주");
    private void Print_Click(object sender, RoutedEventArgs e) => PrintHelper.Print(Grid, "수주관리");

    private sealed record SalesDraftRow(long Id, long ItemId, string ItemName, long? PartnerItemId, long PriceId, decimal Quantity, decimal UnitPrice, DateTime? DueDate);
    private sealed class SalesDetailRow
    {
        public long Id { get; init; }
        public string ItemName { get; init; } = string.Empty;
        public decimal OrderQty { get; init; }
        public decimal ProcessedQty { get; init; }
        public decimal RemainingQty { get; init; }
    }
}