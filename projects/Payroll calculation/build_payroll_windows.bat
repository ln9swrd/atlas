@echo off
setlocal
cd /d "%~dp0"
py -m pip install -r requirements-payroll.txt
py -m PyInstaller --noconfirm --clean --onefile --windowed --name PayrollStatement payroll_app.py
if errorlevel 1 exit /b %errorlevel%
echo Built: %cd%\dist\PayrollStatement.exe
