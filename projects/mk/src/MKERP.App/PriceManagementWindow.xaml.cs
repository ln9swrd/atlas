using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class PriceManagementWindow : UserControl
{
    private readonly ERPDbContext _db;
    private IReadOnlyList<Partner> _partners = [];
    private IReadOnlyList<Item> _items = [];
    private IReadOnlyList<Price> _prices = [];
    private Price? _selected;

    public PriceManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        EffectiveFromBox.SelectedDate = DateTime.Today;
        Loaded += async (_, _) => await LoadAsync();
        Unloaded += (_, _) => _db.Dispose();
    }

    private async Task LoadAsync()
    {
        _partners = await new PartnerRepository(_db).GetActiveAsync();
        _items = await new ItemRepository(_db).GetActiveAsync();
        PartnerBox.ItemsSource = _partners;
        ItemBox.ItemsSource = _items;
        await LoadGridAsync();
    }

    private async Task LoadGridAsync()
    {
        _prices = await new PriceRepository(_db).GetActiveAsync();
        Grid.ItemsSource = _prices.Select(x => new PriceRow
        {
            Id = x.Id,
            PartnerName = _partners.FirstOrDefault(p => p.Id == x.PartnerId)?.Name ?? x.PartnerId.ToString(),
            ItemName = _items.FirstOrDefault(i => i.Id == x.ItemId)?.Name ?? x.ItemId.ToString(),
            UnitPrice = x.UnitPrice,
            EffectiveFrom = x.EffectiveFrom,
            Priority = x.Priority,
            PartnerId = x.PartnerId,
            ItemId = x.ItemId
        }).ToList();
    }

    private async void Search_Click(object sender, RoutedEventArgs e) => await LoadGridAsync();

    private void New_Click(object sender, RoutedEventArgs e)
    {
        _selected = null;
        PartnerBox.SelectedIndex = -1;
        ItemBox.SelectedIndex = -1;
        EffectiveFromBox.SelectedDate = DateTime.Today;
        PriorityBox.Text = "0";
        UnitPriceBox.Clear();
    }

    private void Grid_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (Grid.SelectedItem is not PriceRow row) return;
        _selected = _prices.FirstOrDefault(x => x.Id == row.Id);
        PartnerBox.SelectedValue = row.PartnerId;
        ItemBox.SelectedValue = row.ItemId;
        EffectiveFromBox.SelectedDate = row.EffectiveFrom;
        PriorityBox.Text = row.Priority.ToString(CultureInfo.InvariantCulture);
    }

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (PartnerBox.SelectedItem is not Partner partner || ItemBox.SelectedItem is not Item item)
        {
            MessageBox.Show("거래처와 MK 품목은 필수입니다.");
            return;
        }

        if (!decimal.TryParse(UnitPriceBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var unitPrice)
            || unitPrice < 0)
        {
            MessageBox.Show("단가를 올바르게 입력하세요.");
            return;
        }

        if (!int.TryParse(PriorityBox.Text, out var priority))
        {
            MessageBox.Show("우선순위를 정수로 입력하세요.");
            return;
        }

        var effectiveFrom = EffectiveFromBox.SelectedDate?.Date ?? DateTime.Today;
        await new PriceRepository(_db).AddAsync(new Price
        {
            PartnerId = partner.Id,
            ItemId = item.Id,
            UnitPrice = unitPrice,
            EffectiveFrom = effectiveFrom,
            Priority = priority,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        });
        await LoadGridAsync();
        New_Click(sender, e);
    }

    private async void Deactivate_Click(object sender, RoutedEventArgs e)
    {
        if (_selected is null) return;
        if (MessageBox.Show("단가 이력을 비활성화하시겠습니까? 실제 삭제는 하지 않습니다.", "확인",
            MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;
        await new PriceRepository(_db).DeactivateAsync(_selected.Id);
        await LoadGridAsync();
        New_Click(sender, e);
    }

    private void Excel_Click(object sender, RoutedEventArgs e) => ExcelExportHelper.Export(Grid, $"단가_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx", "단가");
    private void Print_Click(object sender, RoutedEventArgs e) => PrintHelper.Print(Grid, "단가관리");

    private sealed class PriceRow
    {
        public long Id { get; init; }
        public long PartnerId { get; init; }
        public long ItemId { get; init; }
        public string PartnerName { get; init; } = string.Empty;
        public string ItemName { get; init; } = string.Empty;
        public decimal UnitPrice { get; init; }
        public DateTime EffectiveFrom { get; init; }
        public int Priority { get; init; }
    }
}