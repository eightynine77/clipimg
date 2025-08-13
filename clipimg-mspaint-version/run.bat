@echo off
setlocal

:: ============================================================================
:: CONFIGURATION
::
set "psScript=clipimg.ps1"
::
:: This file will store the path to pwsh.exe if you enter it manually.
set "configFile=pwsh_path.cfg"
:: ============================================================================

set "PWSH_EXE_PATH="

echo Searching for PowerShell Core (pwsh.exe)...

:: --- DETECTION PHASE ---

:: 1. PRIORITY CHECK: Look for a user-saved path first.
:: This makes subsequent runs instant if the path was entered manually before.
if exist "%configFile%" (
    set /p PWSH_SAVED_PATH=<"%configFile%"
    if exist "%PWSH_SAVED_PATH%\pwsh.exe" (
        echo [+] Found saved path from a previous run.
        set "PWSH_EXE_PATH=%PWSH_SAVED_PATH%\pwsh.exe"
        goto :ExecuteScript
    ) else (
        echo [!] Invalid path found in '%configFile%'. Deleting it and re-scanning.
        del "%configFile%"
    )
)

:: 2. AUTOMATED SEARCH: Check system PATH.
where /q pwsh.exe
if %errorlevel% equ 0 (
    echo [+] Found pwsh.exe in the system PATH.
    set "PWSH_EXE_PATH=pwsh.exe"
    goto :ExecuteScript
)

echo [-] pwsh.exe not found in PATH. Checking common installation directories...

:: 3. AUTOMATED SEARCH: Check known installation folders.
for %%D in (
    "%ProgramFiles%\PowerShell",
    "%LOCALAPPDATA%\Microsoft\PowerShell",
    "%USERPROFILE%\.dotnet\tools"
) do (
    if exist "%%~D\pwsh.exe" (
        echo [+] Found pwsh.exe in: "%%~D"
        set "PWSH_EXE_PATH=%%~D\pwsh.exe"
        goto :ExecuteScript
    )
    if exist "%%~D\" (
        for /d %%S in ("%%~D\*") do (
            if exist "%%~S\pwsh.exe" (
                echo [+] Found pwsh.exe in: "%%~S"
                set "PWSH_EXE_PATH=%%~S\pwsh.exe"
                goto :ExecuteScript
            )
        )
    )
)

:: 4. AUTOMATED SEARCH: Check for Microsoft Store installation.
set "StorePath=%LOCALAPPDATA%\Microsoft\WindowsApps\Microsoft.PowerShell_8wekyb3d8bbwe\pwsh.exe"
if exist "%StorePath%" (
    echo [+] Found pwsh.exe in Microsoft Store path.
    set "PWSH_EXE_PATH=%StorePath%"
    goto :ExecuteScript
)

:: If we reach here, all automatic checks have failed.
goto :ManualInput

:: --- MANUAL INPUT & SAVE ---

:ManualInput
echo.
echo [ERROR] PowerShell Core (pwsh.exe) could not be found automatically.
echo.
powershell -NoProfile -Command ^
     "Write-Host 'Note: If you installed PowerShell Core (pwsh.exe) in a custom directory, ' -ForegroundColor Yellow -NoNewline; " ^
     "Write-Host 'you can enter the full path to its FOLDER below.' -ForegroundColor Yellow; " ^
     "Write-Host ''; " ^
     "Write-Host 'Example: C:\MyPortableApps\PowerShell' -ForegroundColor Cyan; " ^
     "Write-Host ''; " ^
     "Write-Host 'If you don''t want to, you can close this window and run the script manually.' -ForegroundColor Red"

echo.
set /p "userInputPath=Enter the directory path: "

:: Validate the user's input
if "%userInputPath%"=="" (
    echo.
    echo No path was entered. Exiting.
    echo.
    pause
    exit /b
)

:: Remove quotes from input, in case the user pasted them
set "userInputPath=%userInputPath:"=%"

if not exist "%userInputPath%\pwsh.exe" (
    echo.
    echo [FATAL] The path you entered is incorrect.
    echo pwsh.exe was NOT found in: "%userInputPath%"
    echo.
    pause
    exit /b
)

:: If the path is valid, save it to the config file for next time.
echo.
echo [+] Path is valid! Saving it to '%configFile%' for future use.
(echo %userInputPath%)>"%configFile%"

:: Set the executable path and proceed to run the script.
set "PWSH_EXE_PATH=%userInputPath%\pwsh.exe"
goto :ExecuteScript


:: --- EXECUTION PHASE ---

:ExecuteScript
echo.
echo --- Executing '%psScript%' with PowerShell Core ---
echo Location: %PWSH_EXE_PATH%
echo.

if not exist "%~dp0%psScript%" (
    echo [ERROR] The target PowerShell script '%psScript%' was not found.
    echo Make sure it is in the same directory as this batch file.
    pause
    goto :End
)

"%PWSH_EXE_PATH%" -NoProfile -ExecutionPolicy Bypass -File "%~dp0%psScript%"

echo.
echo --- Script execution finished. ---
goto :End

:End
echo.
endlocal