using System.Globalization;
using System.Windows;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class InOutManagementWindow : Window
{
    private readonly ERPDbContext _db;
    private IReadOnlyList<Item> _items = [];
    public InOutManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        MovementDateBox.SelectedDate = DateTime.Today;
        Loaded += async (_, _) => await LoadAsync();
        Closed += (_, _) => _db.Dispose();
    }

    private async Task LoadAsync()
    {
        _items = await new ItemRepository(_db).GetActiveAsync();
        ItemBox.ItemsSource = _items;
        TypeBox.ItemsSource = await new CodeRepository(_db).GetActiveAsync("INOUT_TYPE");
        await NewAsync();
        await LoadMovementsAsync();
        await LoadInventoryAsync();
    }

    private async Task NewAsync()
    {
        DocumentNoText.Text = await new InOutRepository(_db).GetNextDocumentNoAsync(MovementDateBox.SelectedDate?.Date ?? DateTime.Today);
        TypeBox.SelectedIndex = -1;
        ItemBox.SelectedIndex = -1;
        QtyBox.Text = "1";
    }

    private async Task LoadMovementsAsync() => MovementGrid.ItemsSource = await new InOutRepository(_db).GetRecentAsync();
    private async Task LoadInventoryAsync() => InventoryGrid.ItemsSource =
        await new InOutRepository(_db).GetInventoryAsync(MovementDateBox.SelectedDate?.Date ?? DateTime.Today);

    private async void Date_Changed(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (IsLoaded) { DocumentNoText.Text = await new InOutRepository(_db).GetNextDocumentNoAsync(MovementDateBox.SelectedDate?.Date ?? DateTime.Today); await LoadInventoryAsync(); }
    }

    private async void New_Click(object sender, RoutedEventArgs e) => await NewAsync();

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (TypeBox.SelectedItem is not Code type || ItemBox.SelectedItem is not Item item)
        { MessageBox.Show("입출고 구분과 품목은 필수입니다."); return; }
        if (!decimal.TryParse(QtyBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var qty) || qty <= 0)
        { MessageBox.Show("수량을 올바르게 입력하세요."); return; }

        var status = (await new CodeRepository(_db).GetActiveAsync("DOCUMENT_STATUS")).FirstOrDefault(x => x.Key == "CONFIRMED");
        if (status is null) { MessageBox.Show("확정 상태 기준정보가 없습니다."); return; }

        var date = MovementDateBox.SelectedDate?.Date ?? DateTime.Today;
        if (type.Key is "OUT" or "LOSS")
        {
            var inventory = await new InOutRepository(_db).GetInventoryAsync(date);
            var current = inventory.FirstOrDefault(x => x.ItemId == item.Id);
            var available = current?.Ending ?? 0m;
            if (available < qty)
            {
                MessageBox.Show($"재고가 부족합니다. 현재 재고: {available:N2}, 출고 요청: {qty:N2}");
                return;
            }
        }

        await new InOutRepository(_db).AddAsync(
            new InOut { DocumentNo = DocumentNoText.Text, MovementDate = date, MovementTypeCode = type.Key,
                StatusCode = status.Key, CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow },
            new InOutDetail { ItemId = item.Id, Quantity = qty });
        await LoadMovementsAsync();
        await LoadInventoryAsync();
        await NewAsync();
    }

    private async void Inventory_Click(object sender, RoutedEventArgs e) => await LoadInventoryAsync();
}
