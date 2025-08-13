try {
    try {
        $IrfanPath = $env:IRFANVIEW_PATH
        if (-not $IrfanPath) {
            $commonPaths = @(
                "D:\Program Files\IrfanView\i_view64.exe",
                "C:\Program Files\IrfanView\i_view64.exe",
                "C:\Program Files (x86)\IrfanView\i_view64.exe",
                "C:\Program Files\IrfanView\i_view32.exe",
                "C:\Program Files (x86)\IrfanView\i_view32.exe"
            )
            $IrfanPath = $commonPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
        }
        if (-not $IrfanPath) {
            throw "IrfanView not found. Set the IRFANVIEW_PATH environment variable or edit this script to add the correct path. you can download Irfanview here: https://www.irfanview.com/main_download_engl.htm"
        }
        
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        if (-not [Windows.Forms.Clipboard]::ContainsImage()) {
            throw "Clipboard does not contain an image. Copy an image first (e.g., use PrintScreen)."
        }
        $img = [Windows.Forms.Clipboard]::GetImage()
        if (-not $img) {
            throw "Failed to retrieve a valid image from the clipboard."
        }

        $tempFile = Join-Path $env:TEMP ("clipboard_image_{0}.png" -f ([guid]::NewGuid().ToString()))
        $img.Save($tempFile, [System.Drawing.Imaging.ImageFormat]::Png)

        $irfanProc = Start-Process -FilePath $IrfanPath -ArgumentList $tempFile -PassThru
        
        try {
            $irfanProc.WaitForExit()
        } finally {
            if (Test-Path $tempFile) {
                Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
            }
        }
        
        Write-Host "[DONE] Image was opened in IrfanView and the temp file was removed." -ForegroundColor Green

    } catch {
        Write-Host "[ERROR]" -ForegroundColor Red
        Write-Host $_.Exception.Message -ForegroundColor Red
    }

} finally {
    Write-Host "`nPress ENTER to close this window..." -ForegroundColor Yellow
    Read-Host | Out-Null

}
