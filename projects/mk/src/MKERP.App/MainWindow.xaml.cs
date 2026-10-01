using System.IO;
using System.Windows;

namespace MKERP.App;

public partial class MainWindow : Window
{
    private readonly string _databasePath;

    public MainWindow()
    {
        InitializeComponent();
        _databasePath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "MKERP", "MKERP.db");
    }

    private void ItemManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new ItemManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }

    private void PartnerManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new PartnerManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }

    private void PartnerItemManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new PartnerItemManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }

    private void PriceManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new PriceManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }

    private void SalesOrderManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new SalesOrderManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }

    private void PurchaseOrderManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new PurchaseOrderManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }

    private void ProductionManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new ProductionManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }

    private void InOutManagement_Click(object sender, RoutedEventArgs e)
    {
        var window = new InOutManagementWindow(_databasePath) { Owner = this };
        window.ShowDialog();
    }
}
