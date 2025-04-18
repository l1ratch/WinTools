@echo off
setlocal EnableDelayedExpansion

:: === Logging setup ===
set timestamp=%DATE:/=-%_%TIME::=-%
set timestamp=%timestamp: =_%
set logfile=log_cleanup_!timestamp!.txt
echo [START] Cleanup started at !timestamp! > "!logfile!"

:: === Mode selection menu ===
cls
echo ============================================
echo        Windows Cleaner v1.0 [.bat]
echo    https://github.com/l1ratch/WinTools
echo ============================================
echo.
echo 1. Basic Cleanup (safe)
echo 2. Enhanced Cleanup (deeper + network reset)
echo 3. Full Cleanup (manual confirmations)
echo.
set /p choice="Select a mode (1-3): "

if "%choice%"=="1" goto BASIC
if "%choice%"=="2" goto ENHANCED
if "%choice%"=="3" goto FULL
goto END

:BASIC
echo [INFO] Mode selected: Basic >> "!logfile!"
echo Cleaning temp files...
del /s /f /q %TEMP%\* >> "!logfile!" 2>&1
del /s /f /q C:\Windows\Temp\* >> "!logfile!" 2>&1
del /s /f /q C:\Windows\Prefetch\* >> "!logfile!" 2>&1
del /s /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >> "!logfile!" 2>&1
echo Done.

set /p delbin="Empty Recycle Bin? (y/n): "
if /i "!delbin!"=="y" (
    echo Emptying Recycle Bin...
    PowerShell.exe -Command "Clear-RecycleBin -Force" >> "!logfile!" 2>&1
    echo [INFO] Recycle Bin emptied >> "!logfile!"
) else (
    echo [INFO] Recycle Bin was not emptied >> "!logfile!"
)
goto END

:ENHANCED
echo [INFO] Mode selected: Enhanced >> "!logfile!"
call :BASIC_ACTIONS

:: Network reset
ipconfig /flushdns >> "!logfile!" 2>&1
netsh winsock reset >> "!logfile!" 2>&1
netsh int ip reset >> "!logfile!" 2>&1
echo [INFO] Network reset done >> "!logfile!"

goto END

:FULL
echo [INFO] Mode selected: Full >> "!logfile!"

set /p delbin="Empty Recycle Bin? (y/n): "
if /i "!delbin!"=="y" (
    PowerShell.exe -Command "Clear-RecycleBin -Force" >> "!logfile!" 2>&1
    echo [INFO] Recycle Bin emptied >> "!logfile!"
)

set /p deltemp="Delete TEMP, Prefetch, Recent? (y/n): "
if /i "!deltemp!"=="y" call :BASIC_ACTIONS

set /p resetnet="Reset network settings (DNS/Winsock/IP)? (y/n): "
if /i "!resetnet!"=="y" (
    ipconfig /flushdns >> "!logfile!" 2>&1
    netsh winsock reset >> "!logfile!" 2>&1
    netsh int ip reset >> "!logfile!" 2>&1
    echo [INFO] Network reset done >> "!logfile!"
)

set /p clearlogs="Clear Event Logs? (y/n): "
if /i "!clearlogs!"=="y" (
    for /f %%x in ('wevtutil el') do wevtutil cl "%%x" >> "!logfile!" 2>&1
    echo [INFO] Event Logs cleared >> "!logfile!"
)

goto END

:BASIC_ACTIONS
echo Cleaning temporary folders...
del /s /f /q %TEMP%\* >> "!logfile!" 2>&1
del /s /f /q C:\Windows\Temp\* >> "!logfile!" 2>&1
del /s /f /q C:\Windows\Prefetch\* >> "!logfile!" 2>&1
del /s /f /q "%APPDATA%\Microsoft\Windows\Recent\*" >> "!logfile!" 2>&1
echo [INFO] Temp folders cleaned >> "!logfile!"
goto :eof

:END
echo [END] Cleanup completed >> "!logfile!"
echo Done. Log saved to: !logfile!
pause
exit
