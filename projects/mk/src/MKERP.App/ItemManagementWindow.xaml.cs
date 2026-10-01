using System.Windows;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class ItemManagementWindow : Window
{
    private readonly string _databasePath;
    private readonly ERPDbContext _db;
    private Item? _selected;

    public ItemManagementWindow(string databasePath)
    {
        InitializeComponent();
        _databasePath = databasePath;
        _db = DbContextFactory.Create(databasePath);
        Loaded += async (_, _) => await LoadAsync();
        Closed += (_, _) => _db.Dispose();
    }

    private async Task LoadAsync()
    {
        CategoryBox.ItemsSource = await new CodeRepository(_db).GetActiveAsync("ITEM_CATEGORY");
        GradeBox.ItemsSource = await new ItemRepository(_db).GetGradesAsync();
        ItemGrid.ItemsSource = await new ItemRepository(_db).GetActiveAsync();
    }

    private async void Search_Click(object sender, RoutedEventArgs e) => await LoadAsync();

    private void New_Click(object sender, RoutedEventArgs e)
    {
        _selected = null;
        CodeBox.Clear();
        NameBox.Clear();
        UnitBox.Clear();
        CategoryBox.SelectedIndex = -1;
        GradeBox.SelectedIndex = -1;
        CodeBox.Focus();
    }

    private void ItemGrid_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        _selected = ItemGrid.SelectedItem as Item;
        if (_selected is null) return;
        CodeBox.Text = _selected.Code;
        NameBox.Text = _selected.Name;
        UnitBox.Text = _selected.UnitCode;
        CategoryBox.SelectedValue = _selected.CategoryCode;
        GradeBox.SelectedValue = _selected.GradeId;
    }

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(CodeBox.Text) || string.IsNullOrWhiteSpace(NameBox.Text) ||
            CategoryBox.SelectedItem is not Code category || string.IsNullOrWhiteSpace(UnitBox.Text))
        {
            MessageBox.Show("품목코드, 품목명, 구분, 단위는 필수입니다.");
            return;
        }

        var repo = new ItemRepository(_db);
        if (_selected is null)
        {
            await repo.AddAsync(new Item
            {
                Code = CodeBox.Text.Trim(), Name = NameBox.Text.Trim(),
                CategoryCode = category.Key, GradeId = (GradeBox.SelectedItem as ItemGrade)?.Id,
                UnitCode = UnitBox.Text.Trim(), CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
            });
        }
        else
        {
            _selected.Code = CodeBox.Text.Trim();
            _selected.Name = NameBox.Text.Trim();
            _selected.CategoryCode = category.Key;
            _selected.GradeId = (GradeBox.SelectedItem as ItemGrade)?.Id;
            _selected.UnitCode = UnitBox.Text.Trim();
            _selected.UpdatedAt = DateTime.UtcNow;
            await repo.UpdateAsync(_selected);
        }
        await LoadAsync();
        New_Click(sender, e);
    }

    private async void Deactivate_Click(object sender, RoutedEventArgs e)
    {
        if (_selected is null) return;
        if (MessageBox.Show("품목을 비활성화하시겠습니까? 실제 삭제는 하지 않습니다.", "확인", MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;
        await new ItemRepository(_db).DeactivateAsync(_selected.Id);
        await LoadAsync();
        New_Click(sender, e);
    }

    private void Excel_Click(object sender, RoutedEventArgs e) => ExcelExportHelper.Export(ItemGrid, $"품목_{DateTime.Now:yyyyMMdd_HHmmss}.xlsx", "품목");
    private void Print_Click(object sender, RoutedEventArgs e) => PrintHelper.Print(ItemGrid, "품목관리");
}
