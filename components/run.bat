@echo off
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
"%IMGPATH%"
timeout /t 1 /nobreak >nul
del "%IMGPATH%"
exit /b 0