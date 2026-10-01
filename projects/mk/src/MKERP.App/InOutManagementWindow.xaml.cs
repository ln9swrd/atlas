using System.Collections.ObjectModel;
using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class InOutManagementWindow : UserControl
{
    private readonly ERPDbContext _db;
    private IReadOnlyList<Item> _items = [];
    private IReadOnlyList<Partner> _partners = [];
    private readonly ObservableCollection<EntryRow> _entries = [];

    public InOutManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        EntryGrid.ItemsSource = _entries;
        MovementDateBox.SelectedDate = DateTime.Today;
        Loaded += async (_, _) => await LoadAsync();
        Unloaded += (_, _) => _db.Dispose();
    }

    private async Task LoadAsync()
    {
        _items = await new ItemRepository(_db).GetActiveAsync();
        _partners = await new PartnerRepository(_db).GetActiveAsync();
        ItemBox.ItemsSource = _items;
        PartnerBox.ItemsSource = _partners;
        TypeBox.ItemsSource = await new CodeRepository(_db).GetActiveAsync("INOUT_TYPE");
        await NewAsync();
        await LoadResultsAsync();
    }

    private async Task NewAsync()
    {
        DocumentNoText.Text = await new InOutRepository(_db).GetNextDocumentNoAsync(MovementDateBox.SelectedDate?.Date ?? DateTime.Today);
        TypeBox.SelectedIndex = -1;
        PartnerBox.SelectedIndex = -1;
        ItemBox.SelectedIndex = -1;
        _entries.Clear();
    }

    private async Task LoadResultsAsync()
    {
        var repository = new InOutRepository(_db);
        MovementGrid.ItemsSource = await repository.GetRecentAsync();
        LotMovementGrid.ItemsSource = await repository.GetRecentLotDetailsAsync();
        InventoryGrid.ItemsSource = await repository.GetInventoryAsync(MovementDateBox.SelectedDate?.Date ?? DateTime.Today);
        LotInventoryGrid.ItemsSource = await repository.GetLotInventoryAsync(MovementDateBox.SelectedDate?.Date ?? DateTime.Today);
    }

    private async void Date_Changed(object sender, SelectionChangedEventArgs e)
    {
        if (IsLoaded)
        {
            DocumentNoText.Text = await new InOutRepository(_db).GetNextDocumentNoAsync(MovementDateBox.SelectedDate?.Date ?? DateTime.Today);
            await LoadResultsAsync();
        }
    }

    private async void New_Click(object sender, RoutedEventArgs e) => await NewAsync();

    private void AddLine_Click(object sender, RoutedEventArgs e)
    {
        if (ItemBox.SelectedItem is not Item item)
        {
            MessageBox.Show("품목을 선택하세요.");
            return;
        }

        _entries.Add(new EntryRow { ItemId = item.Id, ItemCode = item.Code, ItemName = item.Name, Quantity = 1m });
    }

    private void RemoveLine_Click(object sender, RoutedEventArgs e)
    {
        if (EntryGrid.SelectedItem is EntryRow row)
            _entries.Remove(row);
    }

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (TypeBox.SelectedItem is not Code type || PartnerBox.SelectedItem is not Partner partner)
        {
            MessageBox.Show("입출고 구분과 거래처는 필수입니다.");
            return;
        }
        if (_entries.Count == 0)
        {
            MessageBox.Show("입출고 상세행을 하나 이상 추가하세요.");
            return;
        }

        var status = (await new CodeRepository(_db).GetActiveAsync("DOCUMENT_STATUS"))
            .FirstOrDefault(x => x.Key == "CONFIRMED");
        if (status is null)
        {
            MessageBox.Show("확정 상태 기준정보가 없습니다.");
            return;
        }

        var date = MovementDateBox.SelectedDate?.Date ?? DateTime.Today;
        var details = new List<InOutDetail>();
        foreach (var row in _entries)
        {
            if (string.IsNullOrWhiteSpace(row.MkLotNo) || string.IsNullOrWhiteSpace(row.PartnerLotNo))
            {
                MessageBox.Show("모든 상세행에 MK Lot No와 거래처 Lot No를 입력하세요.");
                return;
            }
            if (row.Quantity <= 0)
            {
                MessageBox.Show("수량은 0보다 커야 합니다.");
                return;
            }

            details.Add(new InOutDetail { ItemId = row.ItemId, Quantity = row.Quantity });
        }

        if (type.Key is "OUT" or "LOSS")
        {
            var inventory = await new InOutRepository(_db).GetInventoryAsync(date);
            foreach (var group in details.GroupBy(x => x.ItemId))
            {
                var available = inventory.FirstOrDefault(x => x.ItemId == group.Key)?.Ending ?? 0m;
                var requested = group.Sum(x => x.Quantity);
                if (available < requested)
                {
                    MessageBox.Show($"재고가 부족합니다. 현재 재고: {available:N2}, 출고 요청: {requested:N2}");
                    return;
                }
            }
        }

        for (var index = 0; index < details.Count; index++)
        {
            var row = _entries[index];
            var lots = await new InOutRepository(_db).EnsureLotsAsync(partner.Id, row.MkLotNo.Trim(), row.PartnerLotNo.Trim());
            details[index].LotId = lots.LotId;
            details[index].PartnerLotId = lots.PartnerLotId;
        }

        await new InOutRepository(_db).AddAsync(
            new InOut
            {
                DocumentNo = DocumentNoText.Text,
                MovementDate = date,
                MovementTypeId = type.Key,
                PartnerId = partner.Id,
                StatusId = status.Key,
                CreatedAt = DateTime.UtcNow,
                UpdatedAt = DateTime.UtcNow
            }, details);

        await LoadResultsAsync();
        await NewAsync();
    }

    private async void Inventory_Click(object sender, RoutedEventArgs e) => await LoadResultsAsync();

    private void Excel_Click(object sender, RoutedEventArgs e)
    {
        var selected = ResultsTabs.SelectedContent as DataGrid ?? MovementGrid;
        var title = selected == InventoryGrid ? "재고현황" : selected == LotMovementGrid ? "Lot별내역" : "입출고내역";
        ExcelExportHelper.Export(selected, $"입출고재고_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx", title);
    }

    private void Print_Click(object sender, RoutedEventArgs e)
    {
        var selected = ResultsTabs.SelectedContent as DataGrid ?? MovementGrid;
        var title = selected == InventoryGrid ? "재고현황" : selected == LotMovementGrid ? "Lot별내역" : "입출고내역";
        PrintHelper.Print(selected, title);
    }

    private sealed class EntryRow
    {
        public long ItemId { get; init; }
        public string ItemCode { get; init; } = string.Empty;
        public string ItemName { get; init; } = string.Empty;
        public string MkLotNo { get; set; } = string.Empty;
        public string PartnerLotNo { get; set; } = string.Empty;
        public decimal Quantity { get; set; }
    }
}
