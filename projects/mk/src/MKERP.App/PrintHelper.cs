using System.Reflection;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Documents;
using System.Windows.Media;
using System.Printing;

namespace MKERP.App;

internal static class PrintHelper
{
    public static void Print(DataGrid grid, string title)
    {
        if (grid.ItemsSource is not System.Collections.IEnumerable source)
        {
            MessageBox.Show("출력할 데이터가 없습니다.");
            return;
        }

        var columns = grid.Columns.OfType<DataGridBoundColumn>()
            .Select(column => (Header: Convert.ToString(column.Header) ?? string.Empty,
                Path: (column.Binding as System.Windows.Data.Binding)?.Path?.Path))
            .Where(x => !string.IsNullOrWhiteSpace(x.Path))
            .ToList();
        if (columns.Count == 0)
        {
            MessageBox.Show("출력할 열이 없습니다.");
            return;
        }

        var rows = source.Cast<object>().ToList();
        var document = new FlowDocument
        {
            FontFamily = new FontFamily("Malgun Gothic"),
            FontSize = 9,
            PagePadding = new Thickness(24)
        };
        document.Blocks.Add(new Paragraph(new Run(title))
        {
            FontSize = 16,
            FontWeight = FontWeights.Bold,
            Margin = new Thickness(0, 0, 0, 12)
        });

        var table = new Table { CellSpacing = 0 };
        foreach (var _ in columns) table.Columns.Add(new TableColumn { Width = new GridLength(1, GridUnitType.Star) });

        var header = new TableRow();
        foreach (var column in columns)
            header.Cells.Add(CreateCell(column.Header, true));
        table.RowGroups.Add(new TableRowGroup { Rows = { header } });

        var body = new TableRowGroup();
        foreach (var row in rows)
        {
            var tableRow = new TableRow();
            foreach (var column in columns)
                tableRow.Cells.Add(CreateCell(Convert.ToString(GetValue(row, column.Path!)) ?? string.Empty, false));
            body.Rows.Add(tableRow);
        }
        table.RowGroups.Add(body);
        document.Blocks.Add(table);

        var dialog = new PrintDialog { UserPageRangeEnabled = true };
        if (dialog.ShowDialog() != true) return;

        if (dialog.PrintTicket is not null)
            dialog.PrintTicket.PageOrientation = PageOrientation.Landscape;

        document.PageWidth = dialog.PrintableAreaWidth > 0 ? dialog.PrintableAreaWidth : 760;
        document.PageHeight = dialog.PrintableAreaHeight > 0 ? dialog.PrintableAreaHeight : 520;
        dialog.PrintDocument(((IDocumentPaginatorSource)document).DocumentPaginator, title);
    }

    private static TableCell CreateCell(string text, bool header)
    {
        return new TableCell(new Paragraph(new Run(text)))
        {
            Padding = new Thickness(4),
            BorderBrush = Brushes.Black,
            BorderThickness = new Thickness(0.5),
            Background = header ? Brushes.LightGray : Brushes.White,
            FontWeight = header ? FontWeights.Bold : FontWeights.Normal
        };
    }

    private static object? GetValue(object row, string path)
    {
        object? current = row;
        foreach (var part in path.Split('.'))
        {
            if (current is null) return null;
            var property = current.GetType().GetProperty(part, BindingFlags.Instance | BindingFlags.Public | BindingFlags.IgnoreCase);
            current = property?.GetValue(current);
        }
        return current;
    }
}
