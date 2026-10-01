using System.Windows;
using MKERP.Domain;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class PartnerManagementWindow : Window
{
    private readonly ERPDbContext _db;
    private Partner? _selected;

    public PartnerManagementWindow(string databasePath)
    {
        InitializeComponent();
        _db = DbContextFactory.Create(databasePath);
        Loaded += async (_, _) => await LoadAsync();
        Closed += (_, _) => _db.Dispose();
    }

    private async Task LoadAsync()
    {
        TypeBox.ItemsSource = await new CodeRepository(_db).GetActiveAsync("PARTNER_TYPE");
        PartnerGrid.ItemsSource = await new PartnerRepository(_db).GetActiveAsync();
    }

    private async void Search_Click(object sender, RoutedEventArgs e) => await LoadAsync();

    private void New_Click(object sender, RoutedEventArgs e)
    {
        _selected = null;
        CodeBox.Clear();
        NameBox.Clear();
        TypeBox.SelectedIndex = -1;
        CodeBox.Focus();
    }

    private void PartnerGrid_SelectionChanged(object sender, System.Windows.Controls.SelectionChangedEventArgs e)
    {
        _selected = PartnerGrid.SelectedItem as Partner;
        if (_selected is null) return;
        CodeBox.Text = _selected.Code;
        NameBox.Text = _selected.Name;
        TypeBox.SelectedValue = _selected.TypeCode;
    }

    private async void Save_Click(object sender, RoutedEventArgs e)
    {
        if (string.IsNullOrWhiteSpace(CodeBox.Text) || string.IsNullOrWhiteSpace(NameBox.Text) ||
            TypeBox.SelectedItem is not Code type)
        {
            MessageBox.Show("거래처코드, 거래처명, 구분은 필수입니다.");
            return;
        }

        var repo = new PartnerRepository(_db);
        if (_selected is null)
        {
            await repo.AddAsync(new Partner
            {
                Code = CodeBox.Text.Trim(), Name = NameBox.Text.Trim(), TypeCode = type.Key,
                CreatedAt = DateTime.UtcNow, UpdatedAt = DateTime.UtcNow
            });
        }
        else
        {
            _selected.Code = CodeBox.Text.Trim();
            _selected.Name = NameBox.Text.Trim();
            _selected.TypeCode = type.Key;
            _selected.UpdatedAt = DateTime.UtcNow;
            await repo.UpdateAsync(_selected);
        }
        await LoadAsync();
        New_Click(sender, e);
    }

    private async void Deactivate_Click(object sender, RoutedEventArgs e)
    {
        if (_selected is null) return;
        if (MessageBox.Show("거래처를 비활성화하시겠습니까? 실제 삭제는 하지 않습니다.", "확인", MessageBoxButton.YesNo) != MessageBoxResult.Yes) return;
        await new PartnerRepository(_db).DeactivateAsync(_selected.Id);
        await LoadAsync();
        New_Click(sender, e);
    }
}
