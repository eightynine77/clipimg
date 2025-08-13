@echo off
powershell -WindowStyle Hidden -Command "Start-Process 'pwsh' -ArgumentList '-NoExit','-File','tray.ps1' -WindowStyle Hidden"