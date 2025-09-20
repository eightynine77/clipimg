@echo off
set colort=components\text\gecho.exe
:home
cls
title clipimg
echo ===============================
echo  clipimg - created by jebbidan
echo ===============================
%colort% "press <green>[1]</> number key to <cyan>start</> clipimg"
%colort% "press <green>[2]</> number key to <yellow>enable</> clipimg at startup"
%colort% "press <green>[3]</> number key to <red>disable</> clipimg at startup"
%colort% "press <green>[4]</> number key to exit"
CHOICE /C 12345 /N /M ">"
if errorlevel 4 exit
if errorlevel 3 goto disable_startup
if errorlevel 2 goto startup
if errorlevel 1 goto runclipimg
goto home

:runclipimg
echo.
echo.
echo starting clipimg...
echo.
echo please wait.
start components\tray.exe
echo.
echo.
echo.
echo clipimg is now running.
echo.
echo press any key to go back...
pause >nul
goto home

:startup
echo.
echo.
IF EXIST "%appdata%\Microsoft\Windows\Start Menu\Programs\Startup\clipimg.lnk" (
%colort% "<red>you already set clipimg to run at startup."
    echo.
    echo press any key to clear this message...
  pause >nul
  goto home
) ELSE (
  echo loading...
echo.
powershell.exe -ExecutionPolicy Bypass -Command "$exePath = Join-Path '%~dp0components' 'tray.exe'; $wsh = New-Object -ComObject WScript.Shell; $shortcutPath = Join-Path $env:APPDATA 'Microsoft\Windows\Start Menu\Programs\Startup\clipimg.lnk'; $shortcut = $wsh.CreateShortcut($shortcutPath); $shortcut.TargetPath = $exePath; $shortcut.WorkingDirectory = '%~dp0'; $shortcut.Save()"
%colort% "<yellow>windows startup shortcut is created!<nl><nl>now clipimg can run on startup."
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
%colort% "<yellow>clipimg is now disabled on startup. which means clipimg won't run at startup."
echo.
echo.
echo.
echo press any key to clear this message...
pause >nul
goto home
) ELSE (
%colort% "<red>you haven't set clipimg to run at startup."
echo.
echo.
echo.
echo press any key to clear this message...
pause >nul
goto home
)