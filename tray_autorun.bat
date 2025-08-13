@echo off
powershell.exe -ExecutionPolicy Bypass -Command "$scriptPath = Join-Path '%~dp0' 'tray.ps1'; $wshShell = New-Object -ComObject WScript.Shell; $shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\clipboard image viewer.lnk'; $shortcut = $wshShell.CreateShortcut($shortcutPath); $shortcut.TargetPath = 'powershell.exe'; $shortcut.Arguments = \"-WindowStyle Hidden -ExecutionPolicy Bypass -File `\"`\"$scriptPath`\"`\" \"; $shortcut.WorkingDirectory = '%~dp0'; $shortcut.Save()"

echo windows startup shortcut created!
echo.
echo now clipimg can run on startup.
echo.
echo.
echo.
echo press any key to close this script...
pause >nul
exit /b