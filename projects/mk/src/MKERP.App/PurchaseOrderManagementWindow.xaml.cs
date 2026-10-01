using System.Globalization;
using System.Windows;
using Microsoft.EntityFrameworkCore;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class PurchaseOrderManagementWindow : Window
{
    private readonly ERPDbContext _db;
    private IReadOnlyList<Partner> _partners = [];
    private IReadOnlyList<Item> _items = [];
    private Price? _applicablePrice;
    private bool _loading;

    public PurchaseOrderManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        OrderDateBox.SelectedDate = DateTime.Today;
        Loaded += async (_, _) => await LoadAsync();
        Closed += (_, _) => _db.Dispose();
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
        DocumentNoText.Text = await new PurchaseOrderRepository(_db)
            .GetNextDocumentNoAsync(OrderDateBox.SelectedDate?.Date ?? DateTime.Today);
        PartnerBox.SelectedIndex = -1;
        ItemBox.SelectedIndex = -1;
        QtyBox.Text = "1";
        DueDateBox.SelectedDate = null;
        AppliedPriceBox.Text = string.Empty;
        _applicablePrice = null;
    }

    private async Task LoadGridAsync()
    {
        Grid.ItemsSource = await new PurchaseOrderRepository(_db).GetRecentAsync();
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
            DocumentNoText.Text = await new PurchaseOrderRepository(_db)
                .GetNextDocumentNoAsync(OrderDateBox.SelectedDate?.Date ?? DateTime.Today);
            await UpdateAppliedPriceAsync();
        }
    }

    private async void New_Click(object sender, RoutedEventArgs e) => await NewAsync();

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (PartnerBox.SelectedItem is not Partner partner || ItemBox.SelectedItem is not Item item)
        {
            MessageBox.Show("거래처와 품목은 필수입니다.");
            return;
        }

        if (_applicablePrice is null)
        {
            MessageBox.Show("발주일 기준 적용 단가가 없습니다. 단가관리에서 먼저 등록하세요.");
            return;
        }

        if (!decimal.TryParse(QtyBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var qty) || qty <= 0)
        {
            MessageBox.Show("수량을 올바르게 입력하세요.");
            return;
        }

        if (!decimal.TryParse(AppliedPriceBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var appliedPrice) || appliedPrice < 0)
        {
            MessageBox.Show("적용단가를 올바르게 입력하세요.");
            return;
        }

        var statusCodes = await new CodeRepository(_db).GetActiveAsync("DOCUMENT_STATUS");
        var draftCode = statusCodes.FirstOrDefault(x => x.Key == "DRAFT");
        if (draftCode is null)
        {
            MessageBox.Show("문서상태 기준정보에 작성중 코드가 없습니다.");
            return;
        }

        var partnerItemId = await _db.PartnerItems.AsNoTracking()
            .Where(x => x.IsActive && x.PartnerId == partner.Id && x.ItemId == item.Id)
            .Select(x => (long?)x.Id)
            .FirstOrDefaultAsync();

        var orderDate = OrderDateBox.SelectedDate?.Date ?? DateTime.Today;
        var unitPrice = appliedPrice;
        var order = new PurchaseOrder
        {
            DocumentNo = DocumentNoText.Text,
            OrderDate = orderDate,
            PartnerId = partner.Id,
            DueDate = DueDateBox.SelectedDate?.Date,
            StatusCode = draftCode.Key,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        var detail = new PurchaseOrderDetail
        {
            ItemId = item.Id,
            PriceId = _applicablePrice.Id,
            OrderQty = qty,
            AppliedUnitPrice = unitPrice,
            Amount = qty * unitPrice,
            DueDate = DueDateBox.SelectedDate?.Date
        };

        await new PurchaseOrderRepository(_db).AddAsync(order, detail);
        await LoadGridAsync();
        await NewAsync();
    }

    private async void Confirm_Click(object sender, RoutedEventArgs e)
    {
        if (Grid.SelectedItem is not PurchaseOrder order)
        {
            MessageBox.Show("확정할 발주를 목록에서 선택하세요.");
            return;
        }

        try
        {
            await new PurchaseOrderRepository(_db).ConfirmAsync(order.Id);
            await LoadGridAsync();
            MessageBox.Show("발주가 확정되고 입고(IN)가 재고에 반영되었습니다.");
        }
        catch (InvalidOperationException ex)
        {
            MessageBox.Show(ex.Message);
        }
    }

    private async void Cancel_Click(object sender, RoutedEventArgs e)
    {
        if (Grid.SelectedItem is not PurchaseOrder order) { MessageBox.Show("취소할 발주를 목록에서 선택하세요."); return; }
        try { await new PurchaseOrderRepository(_db).CancelAsync(order.Id); await LoadGridAsync(); MessageBox.Show("발주가 취소되고 재고가 복원되었습니다."); }
        catch (InvalidOperationException ex) { MessageBox.Show(ex.Message); }
    }

    private void Excel_Click(object sender, RoutedEventArgs e) => ExcelExportHelper.Export(Grid, $"발주_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx", "발주");
    private void Print_Click(object sender, RoutedEventArgs e) => PrintHelper.Print(Grid, "발주관리");
}