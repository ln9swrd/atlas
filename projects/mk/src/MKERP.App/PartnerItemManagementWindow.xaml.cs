using System.Windows;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class PartnerItemManagementWindow : Window
{
    private readonly ERPDbContext _db;
    private PartnerItem? _selected;
    private IReadOnlyList<Partner> _partners = [];
    private IReadOnlyList<Item> _items = [];

    public PartnerItemManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        Loaded += async (_, _) => await LoadAsync();
        Closed += (_, _) => _db.Dispose();
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
        var partnerId = PartnerBox.SelectedValue as long?;
        Grid.ItemsSource = await new PartnerItemRepository(_db).GetActiveAsync(partnerId);
    }

    private async void Search_Click(object sender, RoutedEventArgs e) => await LoadGridAsync();

    private async void PartnerBox_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (IsLoaded) await LoadGridAsync();
    }

    private void New_Click(object sender, RoutedEventArgs e)
    {
        _selected = null;
        PartnerBox.SelectedIndex = -1;
        ItemBox.SelectedIndex = -1;
        PartnerItemCodeBox.Clear();
        PartnerItemCodeBox.Focus();
    }

    private void Grid_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        _selected = Grid.SelectedItem as PartnerItem;
        if (_selected is null) return;
        PartnerBox.SelectedValue = _selected.PartnerId;
        ItemBox.SelectedValue = _selected.ItemId;
        PartnerItemCodeBox.Text = _selected.PartnerItemCode;
    }

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (PartnerBox.SelectedItem is not Partner partner || ItemBox.SelectedItem is not Item item)
        {
            MessageBox.Show("거래처와 MK 품목은 필수입니다.");
            return;
        }

        var repo = new PartnerItemRepository(_db);
        var name = string.IsNullOrWhiteSpace(PartnerItemCodeBox.Text) ? item.Name : PartnerItemCodeBox.Text.Trim();
        if (_selected is null)
        {
            await repo.AddAsync(new PartnerItem
            {
                PartnerId = partner.Id, ItemId = item.Id,
                PartnerItemCode = string.IsNullOrWhiteSpace(PartnerItemCodeBox.Text) ? null : PartnerItemCodeBox.Text.Trim(),
                PartnerItemName = name
            });
        }
        else
        {
            _selected.PartnerId = partner.Id;
            _selected.ItemId = item.Id;
            _selected.PartnerItemCode = string.IsNullOrWhiteSpace(PartnerItemCodeBox.Text) ? null : PartnerItemCodeBox.Text.Trim();
            _selected.PartnerItemName = name;
            await repo.UpdateAsync(_selected);
        }
        await LoadGridAsync();
        New_Click(sender, e);
    }

    private async void Deactivate_Click(object sender, RoutedEventArgs e)
    {
        if (_selected is null) return;
        if (MessageBox.Show("거래처별 품목을 비활성화하시겠습니까? 실제 삭제는 하지 않습니다.", "확인", MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;
        await new PartnerItemRepository(_db).DeactivateAsync(_selected.Id);
        await LoadGridAsync();
        New_Click(sender, e);
    }
}
