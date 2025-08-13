@echo off

powershell -WindowStyle Hidden -Command "Start-Process 'powershell' -ArgumentList '-NoExit','-File','tray.ps1' -WindowStyle Hidden"
