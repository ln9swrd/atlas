using System.Reflection;
using System.Windows.Controls;
using Microsoft.Win32;
using MKERP.Reporting;

namespace MKERP.App;

internal static class ExcelExportHelper
{
    public static void Export(DataGrid grid, string defaultName, string sheetName)
    {
        if (grid.ItemsSource is not System.Collections.IEnumerable source)
        {
            System.Windows.MessageBox.Show("내보낼 데이터가 없습니다.");
            return;
        }

        var columns = grid.Columns.OfType<DataGridBoundColumn>()
            .Select(column => (Header: Convert.ToString(column.Header) ?? string.Empty,
                Path: (column.Binding as System.Windows.Data.Binding)?.Path?.Path))
            .Where(x => !string.IsNullOrWhiteSpace(x.Path))
            .ToList();
        if (columns.Count == 0)
        {
            System.Windows.MessageBox.Show("내보낼 열이 없습니다.");
            return;
        }

        var rows = source.Cast<object>().ToList();
        var dialog = new SaveFileDialog { Filter = "Excel 통합 문서 (*.xlsx)|*.xlsx", FileName = defaultName };
        if (dialog.ShowDialog() != true) return;

        var data = rows.Select(row => columns.Select(column => (column.Header, Value: GetValue(row, column.Path!))).ToArray()).ToList();
        var headers = columns.Select(x => x.Header).ToArray();
        var cells = data.Select(row => row.Select(x => x.Value).ToArray()).ToList();
        ExcelExporter.Export(cells, headers.Select((header, index) => (header, (Func<object?[], object?>)(row => row[index]))).ToArray(), dialog.FileName, sheetName);
        System.Windows.MessageBox.Show("Excel 파일로 저장되었습니다.");
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
