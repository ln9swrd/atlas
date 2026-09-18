#!/usr/bin/env python3
"""Desktop UI for selecting an attendance workbook and output folder."""

from __future__ import annotations

import threading
import tkinter as tk
from pathlib import Path
from tkinter import filedialog, messagebox, ttk

import xlrd

from generate_payroll_statement import (
    DEFAULT_HOURLY_WAGE,
    calculate_payroll_rows,
    parse_employee_cards,
    write_payroll_xlsx,
)


class PayrollApp(tk.Tk):
    def __init__(self) -> None:
        super().__init__()
        self.title("급여명세 생성기")
        self.geometry("700x430")
        self.minsize(620, 380)

        project_dir = Path(__file__).resolve().parent
        self.input_path = tk.StringVar(value=str(project_dir / "Input" / "001_2026_8_MON.XLS"))
        self.output_dir = tk.StringVar(value=str(project_dir / "Output"))
        self.hourly_rate = tk.StringVar(value=str(int(DEFAULT_HOURLY_WAGE)))
        self.status = tk.StringVar(value="입력 파일과 출력 폴더를 선택하세요.")
        self.progress = tk.DoubleVar(value=0)
        self.generate_button: ttk.Button | None = None

        self._build_ui()

    def _build_ui(self) -> None:
        self.columnconfigure(0, weight=1)
        self.rowconfigure(1, weight=1)

        title = ttk.Label(self, text="급여명세 생성기", font=("맑은 고딕", 18, "bold"))
        title.grid(row=0, column=0, padx=28, pady=(24, 12), sticky="w")

        content = ttk.Frame(self, padding=(28, 8, 28, 18))
        content.grid(row=1, column=0, sticky="nsew")
        content.columnconfigure(1, weight=1)

        self._add_path_row(content, 0, "입력 파일", self.input_path, self._choose_input)
        self._add_path_row(content, 1, "출력 폴더", self.output_dir, self._choose_output)

        ttk.Label(content, text="시급") .grid(row=2, column=0, padx=(0, 12), pady=12, sticky="w")
        rate_entry = ttk.Entry(content, textvariable=self.hourly_rate, width=18)
        rate_entry.grid(row=2, column=1, padx=(0, 12), pady=12, sticky="w")
        ttk.Label(content, text="원") .grid(row=2, column=2, pady=12, sticky="w")

        note = ttk.Label(
            content,
            text="직원 수는 입력 XLS의 직원 카드에서 자동으로 읽습니다. 직원이 늘거나 줄어도 별도 등록이 필요하지 않습니다.",
            wraplength=600,
        )
        note.grid(row=3, column=0, columnspan=3, pady=(18, 14), sticky="w")

        self.generate_button = ttk.Button(content, text="급여명세 생성", command=self._start_generation)
        self.generate_button.grid(row=4, column=0, columnspan=3, pady=(14, 8), ipadx=18, ipady=6)

        ttk.Progressbar(content, variable=self.progress, maximum=100).grid(
            row=5, column=0, columnspan=3, sticky="ew", pady=(8, 10)
        )
        ttk.Label(content, textvariable=self.status, wraplength=600).grid(
            row=6, column=0, columnspan=3, sticky="w"
        )

    @staticmethod
    def _add_path_row(parent: ttk.Frame, row: int, label: str, variable: tk.StringVar, command) -> None:
        ttk.Label(parent, text=label).grid(row=row, column=0, padx=(0, 12), pady=12, sticky="w")
        ttk.Entry(parent, textvariable=variable).grid(row=row, column=1, padx=(0, 8), pady=12, sticky="ew")
        ttk.Button(parent, text="찾아보기", command=command).grid(row=row, column=2, pady=12)

    def _choose_input(self) -> None:
        selected = filedialog.askopenfilename(
            title="근태 입력 파일 선택",
            filetypes=[("Excel 97-2003 파일", "*.xls"), ("모든 파일", "*.*")],
        )
        if selected:
            self.input_path.set(selected)

    def _choose_output(self) -> None:
        selected = filedialog.askdirectory(title="급여명세 저장 폴더 선택")
        if selected:
            self.output_dir.set(selected)

    def _start_generation(self) -> None:
        input_path = Path(self.input_path.get().strip())
        output_dir = Path(self.output_dir.get().strip())
        if not input_path.is_file():
            messagebox.showerror("입력 오류", "존재하는 XLS 입력 파일을 선택하세요.")
            return
        if not output_dir:
            messagebox.showerror("출력 오류", "출력 폴더를 선택하세요.")
            return
        try:
            hourly_rate = float(self.hourly_rate.get().replace(",", ""))
            if hourly_rate <= 0:
                raise ValueError
        except ValueError:
            messagebox.showerror("시급 오류", "시급은 0보다 큰 숫자여야 합니다.")
            return

        self.generate_button.configure(state="disabled")
        self.progress.set(15)
        self.status.set("근태 파일을 읽는 중입니다...")
        thread = threading.Thread(
            target=self._generate,
            args=(input_path, output_dir, hourly_rate),
            daemon=True,
        )
        thread.start()

    def _generate(self, input_path: Path, output_dir: Path, hourly_rate: float) -> None:
        try:
            workbook = xlrd.open_workbook(str(input_path))
            employee_rows = parse_employee_cards(workbook)
            project_rows = calculate_payroll_rows(employee_rows, hourly_rate, "project")
            self.after(0, self.progress.set, 65)
            output_path = output_dir / f"급여명세_{input_path.stem}.xlsx"
            write_payroll_xlsx(output_path, project_rows, [], hourly_rate, "project")
            self.after(0, self._generation_finished, output_path, len(employee_rows))
        except Exception as error:
            self.after(0, self._generation_failed, str(error))

    def _generation_finished(self, output_path: Path, employee_count: int) -> None:
        self.progress.set(100)
        self.status.set(f"완료: 직원 {employee_count}명, {output_path}")
        self.generate_button.configure(state="normal")
        messagebox.showinfo("생성 완료", f"급여명세를 생성했습니다.\n\n{output_path}")

    def _generation_failed(self, error: str) -> None:
        self.progress.set(0)
        self.status.set("생성에 실패했습니다.")
        self.generate_button.configure(state="normal")
        messagebox.showerror("생성 오류", error)


if __name__ == "__main__":
    PayrollApp().mainloop()
