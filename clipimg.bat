@echo off
:home
cls
title clipimg
echo ===============================
echo  clipimg - created by jebbidan
echo ===============================
echo press [1] key to start clipimg
echo press [2] key to enable clipimg at startup
echo press [3] key to exit
CHOICE /C 123 /N /M ">"
if errorlevel 3 exit
if errorlevel 2 goto startup
if errorlevel 1 goto runclipimg
goto home

:runclipimg
echo.
echo.
start powershell -Command "write-host loading...; Start-Process 'powershell' -ArgumentList '-NoExit','-File','tray.ps1' -WindowStyle Hidden; write-host ''; write-host 'clipimg is now running.';write-host 'press any key to close this window...'; $null = $Host.UI.RawUI.ReadKey('NoEcho,IncludeKeyDown')"
echo press any key to go back...
pause >nul
goto home

:startup
echo.
echo.
IF EXIST "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\clipimg.lnk" (
    echo you already set clipimg to run at startup.
    echo.
    echo press any key to clear this message...
  pause >nul
  goto home
) ELSE (
  cls
  echo loading...
echo.
  powershell.exe -ExecutionPolicy Bypass -Command "$scriptPath = Join-Path '%~dp0' 'tray.ps1'; $wshShell = New-Object -ComObject WScript.Shell; $shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\clipimg.lnk'; $shortcut = $wshShell.CreateShortcut($shortcutPath); $shortcut.TargetPath = 'powershell.exe'; $shortcut.Arguments = \"-WindowStyle Hidden -ExecutionPolicy Bypass -File `\"`\"$scriptPath`\"`\" \"; $shortcut.WorkingDirectory = '%~dp0'; $shortcut.Save()"
echo windows startup shortcut created!
echo.
echo now clipimg can run on startup.
echo.
echo.
echo.
echo press any key to clear this message...
pause >nul
goto home
)