@echo off
REM One-time pull after sign-up. Close DB Browser first for best results.

setlocal
set "ADB=%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe"
set "PKG=com.example.respondi"
set "DATA=%~dp0..\data"
set "TMP=%DATA%\.respondi_pull.tmp"
set "OUT=%DATA%\respondi.db"
set "LATEST=%DATA%\respondi_latest.db"

if not exist "%DATA%" mkdir "%DATA%"

"%ADB%" exec-out run-as %PKG% cat databases/respondi.db > "%TMP%" 2>nul
if errorlevel 1 (
  echo Failed. Is the emulator running with the app installed?
  exit /b 1
)

copy /Y "%TMP%" "%LATEST%" >nul
copy /Y "%TMP%" "%OUT%" >nul 2>&1
if errorlevel 1 (
  echo Done. respondi.db was locked — open data\respondi_latest.db in DB Browser.
) else (
  echo Done. Open data\respondi.db in DB Browser.
)
pause
