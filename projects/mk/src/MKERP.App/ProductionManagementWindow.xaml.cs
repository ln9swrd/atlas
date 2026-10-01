using System.Globalization;
using System.Windows;
using System.Windows.Controls;
using Microsoft.EntityFrameworkCore;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class ProductionManagementWindow : UserControl
{
    private readonly ERPDbContext _db;
    private IReadOnlyList<Item> _items = [];

    public ProductionManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        ProductionDateBox.SelectedDate = DateTime.Today;
        Loaded += async (_, _) => await LoadAsync();
        Unloaded += (_, _) => _db.Dispose();
    }

    private async Task LoadAsync()
    {
        _items = await new ItemRepository(_db).GetActiveAsync();
        ItemBox.ItemsSource = _items;
        await NewAsync();
        await LoadGridAsync();
    }

    private async Task NewAsync()
    {
        var date = ProductionDateBox.SelectedDate?.Date ?? DateTime.Today;
        DocumentNoText.Text = await new ProductionRepository(_db).GetNextDocumentNoAsync(date);
        ItemBox.SelectedIndex = -1;
        ProductionQtyBox.Text = "1";
        DefectQtyBox.Text = "0";
        MkLotBox.Text = string.Empty;
    }

    private async Task LoadGridAsync()
    {
        Grid.ItemsSource = await _db.Productions.AsNoTracking().OrderByDescending(x => x.ProductionDate).ThenByDescending(x => x.Id).Take(100).ToListAsync();
    }

    private async void New_Click(object sender, RoutedEventArgs e) => await NewAsync();

    private async void Date_Changed(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        if (IsLoaded)
            DocumentNoText.Text = await new ProductionRepository(_db).GetNextDocumentNoAsync(ProductionDateBox.SelectedDate?.Date ?? DateTime.Today);
    }

    private async void Cancel_Click(object sender, RoutedEventArgs e)
    {
        if (Grid.SelectedItem is not Production production)
        {
            MessageBox.Show("취소할 생산 문서를 선택하세요.");
            return;
        }
        var result = MessageBox.Show($"{production.DocumentNo} 생산을 취소하시겠습니까? 기존 입출고는 CANCELLED로 보존되고 역거래가 생성됩니다.", "생산 취소", MessageBoxButton.YesNo, MessageBoxImage.Question);
        if (result != MessageBoxResult.Yes)
            return;
        try
        {
            await new ProductionRepository(_db).CancelAsync(production.Id);
            await LoadGridAsync();
            MessageBox.Show("생산 취소가 완료되었습니다. 기존 입출고는 보존되고 역거래가 생성되었습니다.");
        }
        catch (InvalidOperationException ex)
        {
            MessageBox.Show(ex.Message);
        }
    }

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (ItemBox.SelectedItem is not Item item)
        {
            MessageBox.Show("품목은 필수입니다.");
            return;
        }

        if (!decimal.TryParse(ProductionQtyBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var productionQty) || productionQty <= 0)
        {
            MessageBox.Show("생산수량을 올바르게 입력하세요.");
            return;
        }

        if (!decimal.TryParse(DefectQtyBox.Text, NumberStyles.Number, CultureInfo.CurrentCulture, out var defectQty) || defectQty < 0 || defectQty > productionQty)
        {
            MessageBox.Show("불량수량은 0 이상 생산수량 이하로 입력하세요.");
            return;
        }

        if (string.IsNullOrWhiteSpace(MkLotBox.Text))
        {
            MessageBox.Show("MK Lot No???꾩닔?낅땲??");
            return;
        }

        var statusCodes = await new CodeRepository(_db).GetActiveAsync("DOCUMENT_STATUS");
        if (statusCodes.All(x => x.Key != "CONFIRMED"))
        {
            MessageBox.Show("문서상태 기준정보에 확정 코드가 없습니다.");
            return;
        }

        var date = ProductionDateBox.SelectedDate?.Date ?? DateTime.Today;
        var production = new Production
        {
            DocumentNo = DocumentNoText.Text,
            ProductionDate = date,
            StatusId = statusCodes.First(x => x.Key == "CONFIRMED").Id,
            CreatedAt = DateTime.UtcNow,
            UpdatedAt = DateTime.UtcNow
        };
        var detail = new ProductionDetail { ItemId = item.Id, ProductionQty = productionQty, DefectQty = defectQty };

        await new ProductionRepository(_db).CompleteAsync(production, detail, MkLotBox.Text.Trim());
        await LoadGridAsync();
        await NewAsync();
        MessageBox.Show("생산 완료 처리되었습니다. 생산수량은 전량 입고되고 불량수량은 LOSS 출고 처리되었습니다.");
    }

    private void Excel_Click(object sender, RoutedEventArgs e) => ExcelExportHelper.Export(Grid, $"생산_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx", "생산");
    private void Print_Click(object sender, RoutedEventArgs e) => PrintHelper.Print(Grid, "생산관리");
}
