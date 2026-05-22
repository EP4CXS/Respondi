@echo off
REM Installs Visual Studio 2022 Community with "Desktop development with C++"
REM Required for: flutter run -d windows
REM Run this script as Administrator (right-click -> Run as administrator).

setlocal
set "INSTALLER=%TEMP%\vs_community.exe"
set "URL=https://aka.ms/vs/17/release/vs_community.exe"

echo.
echo RESPONDI - Visual Studio installer for Flutter Windows
echo ======================================================
echo.
echo This installs Visual Studio 2022 Community (~5-10 GB).
echo Workload: Desktop development with C++ (what Flutter needs)
echo.
echo Downloading installer...
powershell -NoProfile -Command ^
  "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; ^
   Invoke-WebRequest -Uri '%URL%' -OutFile '%INSTALLER%' -UseBasicParsing"

if not exist "%INSTALLER%" (
  echo Download failed. Install manually from:
  echo   https://visualstudio.microsoft.com/downloads/
  echo Select workload: "Desktop development with C++"
  exit /b 1
)

echo.
echo Starting install (passive — may take 20-60 minutes)...
echo You may see a UAC prompt — click Yes.
echo.

"%INSTALLER%" ^
  --passive ^
  --wait ^
  --add Microsoft.VisualStudio.Workload.NativeDesktop ^
  --includeRecommended

set ERR=%ERRORLEVEL%
echo.
if %ERR% equ 0 (
  echo Install finished. Run: flutter doctor
  echo Then: flutter run -d windows
) else (
  echo Install exited with code %ERR%.
  echo If it failed, open Visual Studio Installer and add workload:
  echo   Desktop development with C++
)
echo.
pause
exit /b %ERR%
