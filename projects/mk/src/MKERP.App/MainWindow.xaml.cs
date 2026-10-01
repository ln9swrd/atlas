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
}
