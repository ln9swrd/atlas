using System.Globalization;
using System.IO.Compression;
using System.Security;
using System.Text;

namespace MKERP.Reporting;

public static class ExcelExporter
{
    public static void Export<T>(IEnumerable<T> rows, IReadOnlyList<(string Header, Func<T, object?> Value)> columns, string filePath, string sheetName)
    {
        using var stream = File.Create(filePath);
        using var archive = new ZipArchive(stream, ZipArchiveMode.Create);
        AddEntry(archive, "[Content_Types].xml", ContentTypes());
        AddEntry(archive, "_rels/.rels", RootRels());
        AddEntry(archive, "xl/workbook.xml", Workbook(sheetName));
        AddEntry(archive, "xl/_rels/workbook.xml.rels", WorkbookRels());
        AddEntry(archive, "xl/worksheets/sheet1.xml", Sheet(rows, columns));
    }

    private static void AddEntry(ZipArchive archive, string name, string content)
    {
        var entry = archive.CreateEntry(name, CompressionLevel.Fastest);
        using var writer = new StreamWriter(entry.Open(), new UTF8Encoding(false));
        writer.Write(content);
    }

    private static string ContentTypes() => @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<Types xmlns=""http://schemas.openxmlformats.org/package/2006/content-types""><Default Extension=""rels"" ContentType=""application/vnd.openxmlformats-package.relationships+xml""/><Default Extension=""xml"" ContentType=""application/xml""/><Override PartName=""/xl/workbook.xml"" ContentType=""application/vnd.openxmlformats-officedocument.spreadsheetml.sheet.main+xml""/><Override PartName=""/xl/worksheets/sheet1.xml"" ContentType=""application/vnd.openxmlformats-officedocument.spreadsheetml.worksheet+xml""/></Types>";

    private static string RootRels() => @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<Relationships xmlns=""http://schemas.openxmlformats.org/package/2006/relationships""><Relationship Id=""rId1"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/officeDocument"" Target=""xl/workbook.xml""/></Relationships>";

    private static string Workbook(string sheetName) => $@"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<workbook xmlns=""http://schemas.openxmlformats.org/spreadsheetml/2006/main"" xmlns:r=""http://schemas.openxmlformats.org/officeDocument/2006/relationships""><sheets><sheet name=""{XmlEscape(sheetName)}"" sheetId=""1"" r:id=""rId1""/></sheets></workbook>";

    private static string WorkbookRels() => @"<?xml version=""1.0"" encoding=""UTF-8"" standalone=""yes""?>
<Relationships xmlns=""http://schemas.openxmlformats.org/package/2006/relationships""><Relationship Id=""rId1"" Type=""http://schemas.openxmlformats.org/officeDocument/2006/relationships/worksheet"" Target=""worksheets/sheet1.xml""/></Relationships>";

    private static string Sheet<T>(IEnumerable<T> rows, IReadOnlyList<(string Header, Func<T, object?> Value)> columns)
    {
        var sb = new StringBuilder("<worksheet xmlns='http://schemas.openxmlformats.org/spreadsheetml/2006/main'><sheetData>");
        sb.Append("<row r='1'>");
        for (var i = 0; i < columns.Count; i++) sb.Append(Cell(i + 1, 1, columns[i].Header));
        sb.Append("</row>");
        var rowNumber = 2;
        foreach (var row in rows)
        {
            sb.Append($"<row r='{rowNumber}'>");
            for (var i = 0; i < columns.Count; i++) sb.Append(Cell(i + 1, rowNumber, columns[i].Value(row)));
            sb.Append("</row>");
            rowNumber++;
        }
        sb.Append("</sheetData></worksheet>");
        return sb.ToString();
    }

    private static string Cell(int column, int row, object? value)
    {
        var reference = ColumnName(column) + row.ToString(CultureInfo.InvariantCulture);
        if (value is null) return $"<c r='{reference}' t='inlineStr'><is><t></t></is></c>";
        if (value is bool b) return $"<c r='{reference}' t='b'><v>{(b ? 1 : 0)}</v></c>";
        if (value is byte or short or int or long or float or double or decimal)
            return $"<c r='{reference}'><v>{Convert.ToString(value, CultureInfo.InvariantCulture)}</v></c>";
        return $"<c r='{reference}' t='inlineStr'><is><t>{XmlEscape(Convert.ToString(value, CultureInfo.CurrentCulture) ?? string.Empty)}</t></is></c>";
    }

    private static string ColumnName(int column)
    {
        var result = string.Empty;
        while (column > 0) { column--; result = (char)('A' + column % 26) + result; column /= 26; }
        return result;
    }

    private static string XmlEscape(string value) => SecurityElement.Escape(value) ?? string.Empty;
}
