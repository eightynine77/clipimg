@echo off
:home
cls
title clipimg
echo ===============================
echo  clipimg - created by jebbidan
echo ===============================
echo press [1] key to start clipimg
echo press [2] key to stop clipimg
echo press [3] key to enable clipimg at startup
echo press [4] key to disable clipimg at startup
echo press [5] key to exit
CHOICE /C 12345 /N /M ">"
if errorlevel 5 exit
if errorlevel 4 goto disable_startup
if errorlevel 3 goto startup
if errorlevel 2 goto kill_clipimg 
if errorlevel 1 goto runclipimg
goto home

:runclipimg
echo.
echo.
echo starting clipimg...
echo.
echo please wait.
for /f %%A in ('powershell -NoProfile -Command "Start-Process 'powershell' -ArgumentList '-NoExit','-File','tray.ps1' -WindowStyle Hidden"') do rem
echo.
echo.
echo.
echo clipimg is now running.
echo.
echo press any key to go back...
pause >nul
goto home

:kill_clipimg
echo.
echo.
taskkill /f /im powershell.exe >nul
echo clipimg is now stopped running
echo.
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
powershell.exe -ExecutionPolicy Bypass -Command "$scriptPath = Join-Path '%~dp0' 'tray.ps1'; $wshShell = New-Object -ComObject WScript.Shell; $shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\clipimg.lnk'; $shortcut = $wshShell.CreateShortcut($shortcutPath); $shortcut.TargetPath = 'powershell.exe'; $shortcut.Arguments = \"-WindowStyle Hidden -ExecutionPolicy Bypass -File \"\"$scriptPath\"\" \"; $shortcut.WorkingDirectory = '%~dp0'; $shortcut.Save()"
echo windows startup shortcut is created!
echo.
echo now clipimg can run on startup.
echo.
echo.
echo.
echo press any key to clear this message...
pause >nul
goto home
)

:disable_startup
echo.
echo.
IF EXIST "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\clipimg.lnk" (
del "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\clipimg.lnk"
echo clipimg is now disabled on startup. which means clipimg won't run at startup.
echo.
echo.
echo.
echo press any key to clear this message...
pause >nul
goto home
) ELSE (
echo you haven't set clipimg to run at startup.
echo.
echo.
echo.
echo press any key to clear this message...
pause >nul
goto home
)
