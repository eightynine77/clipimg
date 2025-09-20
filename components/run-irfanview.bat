@echo off
setlocal enabledelayedexpansion
set "textcolor=text\gecho.exe"
set "OUT="

for /f "usebackq delims=" %%p in (`"paste_image.exe" 2^>^&1`) do set "OUT=%%p"

if /i "%OUT%"=="pasting image from clipboard failed" (
  echo your clipboard does not contain an image/your currently copied thing is not an image
  echo.
  echo press any key to close this script...
  pause >nul
  exit /b 1
)

if "%OUT%"=="" (
  echo No output from clipboard tool.
  echo.
  echo press any key to close this script...
  pause >nul
  exit /b 1
)

set "IMGPATH=%OUT%"

set files="%ProgramFiles(x86)%\IrfanView\i_view32.exe" "%ProgramFiles%\IrfanView\i_view32.exe" "%ProgramFiles(x86)%\IrfanView\i_view64.exe" "%ProgramFiles%\IrfanView\i_view64.exe"
::==============================================
rem add your new line of custom irfanview installation directory above.

rem for example: 
REM "c:\your custom installation path\i_view64.exe" 
REM add the directory above to the "set files=" variable

rem or instaed of doing that, just modify the existing directories above

rem for exampel: modify this: "%ProgramFiles(x86)%\IrfanView\i_view64.exe"
rem into this: "c:\your custom installation path\i_view64.exe"
::==============================================

set "IV="
for %%F in (%files%) do (
    if exist %%~F (
        set "IV=%%~F"
        goto :found
    )
)

:missingfiles
%textcolor% "<red>ERROR: irfanview installation is not detected."
echo.
echo.
echo either you have not installed irfanview yet or you installed it in a custom path/folder
echo.
%textcolor% "<yellow>You can download IrfanView here:"
%textcolor% "<cyan>https://www.irfanview.com/main_download_engl.htm"
echo.
echo.
echo if it's the latter then you can modify this batch script by adding a new if else in the  
echo section of this batch file (%~nx0) that has this:
echo ::==============================================
%textcolor% "<green>this batch file's path location: %~dp0%~nx0"
echo.
echo.
echo press any key to close this script...
pause >nul
exit /b 1

:found
start "" "%IV%" "%IMGPATH%"
timeout /t 1 /nobreak >nul
del "%IMGPATH%" 
exit /b 0