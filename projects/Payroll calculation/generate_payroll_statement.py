#!/usr/bin/env python3
"""Generate project-rule and legal-rule payroll statements from an attendance XLS."""

from __future__ import annotations

import argparse
import json
import re
from datetime import date
from pathlib import Path
from typing import Any, Dict, Iterable, List
from urllib.error import URLError
from urllib.request import urlopen

import xlrd
from openpyxl import Workbook
from openpyxl.styles import Alignment, Font, PatternFill

DEFAULT_HOURLY_WAGE = 10320.0
STANDARD_WORK_DAY_MINUTES = 8 * 60


def parse_hm(value: Any) -> int | None:
    if not isinstance(value, str) or ":" not in value:
        return None
    try:
        hour, minute = (int(part) for part in value.strip().split(":", 1))
    except ValueError:
        return None
    return hour * 60 + minute


def parse_month_day_label(label: Any) -> int | None:
    if not isinstance(label, str):
        return None
    digits = "".join(ch for ch in label if ch.isdigit())
    return int(digits[:2]) if digits else None


def _is_valid_employee_name(value: Any) -> bool:
    if not isinstance(value, str):
        return False
    return value.strip() not in {"", "이름", "부서", "사원번호", "번호", "일자", "일자/주"}


def infer_workbook_year_month(workbook: xlrd.Book) -> tuple[int, int]:
    for sheet in workbook.sheets():
        for row in sheet.get_rows():
            for cell in row:
                if isinstance(cell.value, str):
                    match = re.search(r"(20\d{2})\s*/\s*(\d{1,2})", cell.value)
                    if match:
                        return int(match.group(1)), int(match.group(2))
    return 2026, 8


def legal_public_holidays(year: int, month: int) -> set[date]:
    fixed_holidays = {
        date(year, 1, 1),
        date(year, 3, 1),
        date(year, 5, 5),
        date(year, 6, 6),
        date(year, 8, 15),
        date(year, 10, 3),
        date(year, 10, 9),
        date(year, 12, 25),
    }
    url = f"https://date.nager.at/api/v3/PublicHolidays/{year}/KR"
    try:
        with urlopen(url, timeout=10) as response:
            holidays = json.load(response)
    except (OSError, URLError, json.JSONDecodeError) as error:
        raise RuntimeError(f"{year}년 법정공휴일 정보를 인터넷에서 가져오지 못했습니다: {error}") from error

    api_holidays = {
        date.fromisoformat(item["date"])
        for item in holidays
        if item.get("types") and "Public" in item["types"]
    }
    return {
        holiday for holiday in fixed_holidays | api_holidays
        if holiday.year == year and holiday.month == month
    }


def _new_stats() -> Dict[str, float]:
    return {
        "work_minutes": 0.0,
        "holiday_minutes": 0.0,
        "special_minutes": 0.0,
        "overtime_minutes": 0.0,
        "night_minutes": 0.0,
        "worked_days": 0,
    }


def parse_employee_cards(workbook: xlrd.Book) -> List[Dict[str, Any]]:
    year, month = infer_workbook_year_month(workbook)
    holidays = legal_public_holidays(year, month)
    employee_rows: Dict[str, Dict[str, float]] = {}

    sheet_names = [
        sheet_name for sheet_name in workbook.sheet_names()
        if re.fullmatch(r"\d+(?:\.\d+)*", sheet_name)
    ]
    for sheet_name in sheet_names:
        sheet = workbook.sheet_by_name(sheet_name)
        for block_start in (0, 15, 30):
            name = sheet.cell_value(2, block_start + 9)
            if not _is_valid_employee_name(name):
                continue
            name = name.strip()
            stats = employee_rows.setdefault(name, _new_stats())

            for row_index in range(11, sheet.nrows):
                day_number = parse_month_day_label(sheet.cell_value(row_index, block_start))
                start = parse_hm(sheet.cell_value(row_index, block_start + 1))
                end = parse_hm(sheet.cell_value(row_index, block_start + 3))
                if day_number is None or start is None or end is None:
                    continue
                if end < start:
                    end += 24 * 60
                worked = end - start
                if worked == 0:
                    continue

                work_day = date(year, month, day_number)
                stats["work_minutes"] += worked
                stats["worked_days"] += 1
                is_holiday = work_day in holidays
                if is_holiday:
                    stats["holiday_minutes"] += worked
                if is_holiday or work_day.weekday() >= 5:
                    stats["special_minutes"] += worked
                if worked > STANDARD_WORK_DAY_MINUTES:
                    stats["overtime_minutes"] += worked - STANDARD_WORK_DAY_MINUTES
                if end > 22 * 60:
                    stats["night_minutes"] += end - max(start, 22 * 60)
                if start < 6 * 60:
                    stats["night_minutes"] += min(end, 6 * 60) - start

    summary_sheet = workbook.sheet_by_name("출퇴근기록표")
    for row_index in range(4, summary_sheet.nrows):
        employee_name = summary_sheet.cell_value(row_index, 1)
        if not _is_valid_employee_name(employee_name):
            continue
        try:
            actual_hours = float(summary_sheet.cell_value(row_index, 4))
        except (TypeError, ValueError):
            continue
        stats = employee_rows.setdefault(employee_name.strip(), _new_stats())
        if stats["work_minutes"] == 0:
            stats["work_minutes"] = actual_hours * 60

    result = []
    for name, stats in employee_rows.items():
        work_hours = stats["work_minutes"] / 60
        result.append({
            "name": name,
            "work_hours": round(work_hours, 2),
            "holiday_hours": round(stats["holiday_minutes"] / 60, 2),
            "special_hours": round(stats["special_minutes"] / 60, 2),
            "overtime_hours": round(stats["overtime_minutes"] / 60, 2),
            "night_hours": round(stats["night_minutes"] / 60, 2),
            "weekly_rest_hours": round(work_hours / 4, 2),
            "legal_weekly_rest_hours": 8.0,
            "worked_days": int(stats["worked_days"]),
        })
    return sorted(result, key=lambda item: item["name"])


def calculate_payroll_rows(employee_rows: Iterable[Dict[str, Any]], hourly_wage: float, mode: str) -> List[Dict[str, Any]]:
    rows = []
    for employee in employee_rows:
        weekly_rest_hours = employee["weekly_rest_hours"] if mode == "project" else employee["legal_weekly_rest_hours"]
        basic_pay = round(employee["work_hours"] * hourly_wage)
        weekly_rest_pay = round(weekly_rest_hours * hourly_wage)
        special_pay = round(employee["special_hours"] * hourly_wage * 1.5)
        overtime_pay = round(employee["overtime_hours"] * hourly_wage * 1.5)
        night_pay = round(employee["night_hours"] * hourly_wage * (2.0 if mode == "project" else 1.5))
        rows.append({
            **employee,
            "weekly_rest_hours": weekly_rest_hours,
            "basic_pay": basic_pay,
            "weekly_rest_pay": weekly_rest_pay,
            "holiday_pay": special_pay,
            "overtime_pay": overtime_pay,
            "night_pay": night_pay,
            "total_pay": basic_pay + weekly_rest_pay + special_pay + overtime_pay + night_pay,
        })
    return rows


HEADERS = ["사원명", "근무시간", "주휴시간", "법정공휴일근무시간", "연장시간", "연장수당", "특근수당", "잔업수당", "기본급", "주휴수당", "총급여", "시급"]


def _write_sheet(sheet: Any, rows: List[Dict[str, Any]], hourly_wage: float) -> None:
    sheet.append(HEADERS)
    for row in rows:
        sheet.append([
            row["name"], row["work_hours"], row["weekly_rest_hours"], row["holiday_hours"],
            row["overtime_hours"], row["overtime_pay"], row["holiday_pay"], row["night_pay"],
            row["basic_pay"], row["weekly_rest_pay"], row["total_pay"], hourly_wage,
        ])
    sheet.append([])
    sheet.append([
        "합계",
        *(round(sum(row[key] for row in rows), 2) for key in ["work_hours", "weekly_rest_hours", "holiday_hours", "overtime_hours"]),
        round(sum(row["overtime_pay"] for row in rows)),
        round(sum(row["holiday_pay"] for row in rows)),
        round(sum(row["night_pay"] for row in rows)),
        round(sum(row["basic_pay"] for row in rows)),
        round(sum(row["weekly_rest_pay"] for row in rows)),
        round(sum(row["total_pay"] for row in rows)),
        hourly_wage,
    ])
    for cell in sheet[1]:
        cell.fill = PatternFill("solid", fgColor="D9EAF7")
        cell.font = Font(bold=True)
        cell.alignment = Alignment(horizontal="center")
    for cell in sheet[sheet.max_row]:
        cell.fill = PatternFill("solid", fgColor="FFF2CC")
        cell.font = Font(bold=True)
    for row in sheet.iter_rows(min_row=2):
        for cell in row:
            if isinstance(cell.value, (int, float)):
                cell.number_format = "#,##0.00" if 2 <= cell.column <= 5 else "#,##0"
    for column in sheet.columns:
        width = max(len(str(cell.value or "")) for cell in column)
        sheet.column_dimensions[column[0].column_letter].width = max(12, min(width + 2, 20))


def write_payroll_xlsx(path: Path, project_rows: List[Dict[str, Any]], legal_rows: List[Dict[str, Any]], hourly_wage: float, mode: str) -> None:
    workbook = Workbook()
    if mode in {"project", "both"}:
        project_sheet = workbook.active
        project_sheet.title = "급여명세"
        _write_sheet(project_sheet, project_rows, hourly_wage)
    if mode in {"legal", "both"}:
        legal_sheet = workbook.create_sheet("법정기준") if mode == "both" else workbook.active
        legal_sheet.title = "법정기준"
        _write_sheet(legal_sheet, legal_rows, hourly_wage)
        if mode == "both":
            legal_sheet.sheet_state = "hidden"
    path.parent.mkdir(parents=True, exist_ok=True)
    workbook.save(path)


def main() -> None:
    project_dir = Path(__file__).resolve().parent
    parser = argparse.ArgumentParser()
    parser.add_argument("--input", type=Path, default=project_dir / "Input" / "001_2026_8_MON.XLS")
    parser.add_argument("--output", type=Path, default=project_dir / "Output" / "급여명세_2026_08.xlsx")
    parser.add_argument("--hourly-rate", type=float, default=DEFAULT_HOURLY_WAGE)
    parser.add_argument("--mode", choices=["project", "legal", "both"], default="both")
    args = parser.parse_args()

    workbook = xlrd.open_workbook(str(args.input))
    employee_rows = parse_employee_cards(workbook)
    project_rows = calculate_payroll_rows(employee_rows, args.hourly_rate, "project")
    legal_rows = calculate_payroll_rows(employee_rows, args.hourly_rate, "legal")
    write_payroll_xlsx(args.output, project_rows, legal_rows, args.hourly_rate, args.mode)
    print(f"Generated {args.output} with {len(project_rows)} employee records.")


if __name__ == "__main__":
    main()
