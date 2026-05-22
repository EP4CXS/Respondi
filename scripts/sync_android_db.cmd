@echo off
REM Copies the emulator database to your PC every 2 seconds.
REM Use CMD (not PowerShell) so the SQLite file stays binary-safe.
REM
REM If DB Browser has respondi.db open, sync writes to data\respondi_latest.db instead.
REM Best practice: open data\respondi_latest.db in DB Browser (stays updatable).

setlocal
set "ADB=%LOCALAPPDATA%\Android\sdk\platform-tools\adb.exe"
set "PKG=com.example.respondi"
set "DATA=%~dp0..\data"
set "TMP=%DATA%\.respondi_pull.tmp"
set "OUT=%DATA%\respondi.db"
set "LATEST=%DATA%\respondi_latest.db"

if not exist "%DATA%" mkdir "%DATA%"

if not exist "%ADB%" (
  echo Android platform-tools not found at:
  echo   %ADB%
  exit /b 1
)

echo Syncing %PKG% -^> data\  (Ctrl+C to stop)
echo   Primary:  data\respondi.db
echo   Fallback: data\respondi_latest.db  ^(use this if DB Browser locks respondi.db^)
echo.

:loop
"%ADB%" exec-out run-as %PKG% cat databases/respondi.db > "%TMP%" 2>nul
if errorlevel 1 (
  echo [%date% %time%] Pull failed — start emulator and run the app first.
  goto wait
)

copy /Y "%TMP%" "%LATEST%" >nul 2>&1

copy /Y "%TMP%" "%OUT%" >nul 2>&1
if errorlevel 1 (
  echo [%date% %time%] respondi.db locked — updated respondi_latest.db ^(close DB Browser to fix^)
) else (
  echo [%date% %time%] Updated respondi.db and respondi_latest.db
)

:wait
timeout /t 2 /nobreak >nul
goto loop
