using System.IO;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Input;
using Microsoft.Win32;
using MKERP.Infrastructure;

namespace MKERP.App;

public partial class MainWindow : Window
{
    private readonly string _databasePath;
    private double _cascadeX = 20;
    private double _cascadeY = 20;
    private int _zIndex;

    public MainWindow()
    {
        InitializeComponent();
        _databasePath = Path.Combine(
            Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
            "MKERP", "MKERP.db");
    }

    private void ItemManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("품목관리", () => new ItemManagementWindow(_databasePath), 900, 600);

    private void PartnerManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("거래처관리", () => new PartnerManagementWindow(_databasePath), 900, 600);

    private void PartnerItemManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("거래처별 품목관리", () => new PartnerItemManagementWindow(_databasePath), 1000, 650);

    private void PriceManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("단가관리", () => new PriceManagementWindow(_databasePath), 1050, 650);
    private void SalesOrderManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("수주관리", () => new SalesOrderManagementWindow(_databasePath), 1100, 700);

    private void PurchaseOrderManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("발주관리", () => new PurchaseOrderManagementWindow(_databasePath), 1100, 700);

    private void ProductionManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("생산관리", () => new ProductionManagementWindow(_databasePath), 1000, 650);

    private void InOutManagement_Click(object sender, RoutedEventArgs e)
        => OpenMdiChild("입출고 / 재고", () => new InOutManagementWindow(_databasePath), 1150, 720);

    private void OpenMdiChild(string title, Func<UserControl> factory, double width, double height)
    {
        var content = factory();
        var child = new Border
        {
            Width = width,
            Height = height,
            Background = System.Windows.Media.Brushes.White,
            BorderBrush = System.Windows.Media.Brushes.Gray,
            BorderThickness = new Thickness(1),
            CornerRadius = new CornerRadius(2)
        };

        var root = new Grid();
        root.RowDefinitions.Add(new RowDefinition { Height = GridLength.Auto });
        root.RowDefinitions.Add(new RowDefinition { Height = new GridLength(1, GridUnitType.Star) });

        var header = new Border
        {
            Background = System.Windows.Media.Brushes.LightGray,
            Padding = new Thickness(8, 5, 5, 5),
            Cursor = Cursors.SizeAll
        };
        var headerGrid = new Grid();
        headerGrid.ColumnDefinitions.Add(new ColumnDefinition());
        headerGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        headerGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        headerGrid.ColumnDefinitions.Add(new ColumnDefinition { Width = GridLength.Auto });
        headerGrid.Children.Add(new TextBlock { Text = title, FontWeight = FontWeights.SemiBold, VerticalAlignment = VerticalAlignment.Center });
        var minimize = new Button { Content = "—", Width = 28, Height = 24, Padding = new Thickness(0), FontSize = 14 };
        Grid.SetColumn(minimize, 1);
        headerGrid.Children.Add(minimize);
        var maximize = new Button { Content = "□", Width = 28, Height = 24, Padding = new Thickness(0), FontSize = 14 };
        Grid.SetColumn(maximize, 2);
        headerGrid.Children.Add(maximize);
        var close = new Button { Content = "×", Width = 28, Height = 24, Padding = new Thickness(0), FontSize = 16 };
        Grid.SetColumn(close, 3);
        headerGrid.Children.Add(close);
        header.Child = headerGrid;

        var presenter = new ContentPresenter { Content = content };
        Grid.SetRow(header, 0);
        Grid.SetRow(presenter, 1);
        root.Children.Add(header);
        root.Children.Add(presenter);
        child.Child = root;

        Canvas.SetLeft(child, _cascadeX);
        Canvas.SetTop(child, _cascadeY);
        Canvas.SetZIndex(child, ++_zIndex);
        _cascadeX += 25;
        _cascadeY += 25;
        if (_cascadeX > 160) _cascadeX = 20;
        if (_cascadeY > 160) _cascadeY = 20;

        var restoredLeft = _cascadeX;
        var restoredTop = _cascadeY;
        var restoredWidth = width;
        var restoredHeight = height;
        var isMaximized = false;

        var minimizedButton = new Button
        {
            Content = title,
            Padding = new Thickness(10, 3, 10, 3),
            Margin = new Thickness(2, 0, 2, 0),
            ToolTip = "복원"
        };
        minimizedButton.Click += (_, _) =>
        {
            child.Visibility = Visibility.Visible;
            minimizedButton.Visibility = Visibility.Collapsed;
            Canvas.SetZIndex(child, ++_zIndex);
        };

        close.Click += (_, _) =>
        {
            MdiCanvas.Children.Remove(child);
            MinimizedWindowsPanel.Children.Remove(minimizedButton);
        };

        minimize.Click += (_, _) =>
        {
            child.Visibility = Visibility.Collapsed;
            minimizedButton.Visibility = Visibility.Visible;
            if (!MinimizedWindowsPanel.Children.Contains(minimizedButton))
                MinimizedWindowsPanel.Children.Add(minimizedButton);
        };

        maximize.Click += (_, _) =>
        {
            if (!isMaximized)
            {
                restoredLeft = Canvas.GetLeft(child);
                restoredTop = Canvas.GetTop(child);
                restoredWidth = child.Width;
                restoredHeight = child.Height;

                Canvas.SetLeft(child, 0);
                Canvas.SetTop(child, 0);
                child.Width = Math.Max(0, MdiCanvas.ActualWidth);
                child.Height = Math.Max(0, MdiCanvas.ActualHeight);
                maximize.Content = "❐";
                isMaximized = true;
            }
            else
            {
                child.Width = restoredWidth;
                child.Height = restoredHeight;
                Canvas.SetLeft(child, restoredLeft);
                Canvas.SetTop(child, restoredTop);
                maximize.Content = "□";
                isMaximized = false;
            }

            Canvas.SetZIndex(child, ++_zIndex);
        };
        child.MouseLeftButtonDown += (_, _) => Canvas.SetZIndex(child, ++_zIndex);

        double startX = 0;
        double startY = 0;
        bool dragging = false;
        header.MouseLeftButtonDown += (_, e) =>
        {
            dragging = true;
            startX = e.GetPosition(MdiCanvas).X - Canvas.GetLeft(child);
            startY = e.GetPosition(MdiCanvas).Y - Canvas.GetTop(child);
            header.CaptureMouse();
            Canvas.SetZIndex(child, ++_zIndex);
        };
        header.MouseMove += (_, e) =>
        {
            if (!dragging) return;
            var p = e.GetPosition(MdiCanvas);
            Canvas.SetLeft(child, Math.Max(0, p.X - startX));
            Canvas.SetTop(child, Math.Max(0, p.Y - startY));
        };
        header.MouseLeftButtonUp += (_, _) =>
        {
            dragging = false;
            header.ReleaseMouseCapture();
        };

        MdiCanvas.Children.Add(child);
    }
    private async void RestoreDatabase_Click(object sender, RoutedEventArgs e)
    {
        var backupDirectory = Path.Combine(Path.GetDirectoryName(_databasePath)!, "backup");
        var dialog = new OpenFileDialog
        {
            Title = "Select backup to restore",
            Filter = "MK ERP backup (*.db)|*.db",
            InitialDirectory = Directory.Exists(backupDirectory) ? backupDirectory : Path.GetDirectoryName(_databasePath),
            CheckFileExists = true
        };
        if (dialog.ShowDialog() != true) return;
        var confirm = MessageBox.Show(
            "The current database will be backed up before replacement. The program will close after restore. Continue?",
            "Database Restore", MessageBoxButton.YesNo, MessageBoxImage.Warning);
        if (confirm != MessageBoxResult.Yes) return;
        try
        {
            await new BackupService(_databasePath).RestoreAsync(dialog.FileName);
            MessageBox.Show("Restore completed. Restart the program to use the restored data.", "Database Restore", MessageBoxButton.OK, MessageBoxImage.Information);
            System.Windows.Application.Current.Shutdown();
        }
        catch (Exception ex)
        {
            MessageBox.Show("Database restore failed."+Environment.NewLine+ex.Message, "Database Restore Error", MessageBoxButton.OK, MessageBoxImage.Error);
        }
    }
}