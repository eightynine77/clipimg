Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$batchPath = Join-Path $PSScriptRoot '\clipimg-mspaint-version\run.bat'   
$iconFile  = Join-Path $PSScriptRoot '\icon.ico' 

if (-not (Test-Path $batchPath)) {
    Write-host "Batch file not found: $batchPath" -foreground red
    exit 1
}

$escapedPath = $batchPath -replace "'", "''"

$notify = New-Object System.Windows.Forms.NotifyIcon
try {
    if (Test-Path $iconFile) {
        $notify.Icon = New-Object System.Drawing.Icon($iconFile)
    } else {
        $notify.Icon = [System.Drawing.SystemIcons]::Application
    }
} catch {
    $notify.Icon = [System.Drawing.SystemIcons]::Application
}
$notify.Text = "clipboard image viewer"
$notify.Visible = $true

$cms = New-Object System.Windows.Forms.ContextMenuStrip

$cmdScriptText = @"
param(`$sender, `$e)
Start-Job -ArgumentList '$escapedPath' -ScriptBlock {
    param(`$bp)
    Start-Process -FilePath `$bp -WorkingDirectory (Split-Path `$bp)
} | Out-Null
"@
$itemCommand = New-Object System.Windows.Forms.ToolStripMenuItem("view clipboard image")
$itemCommand.add_Click([ScriptBlock]::Create($cmdScriptText))

$exitScriptText = @"
param(`$sender, `$e)
[System.Windows.Forms.Application]::Exit()
taskkill /f /im powershell.exe
taskkill /f /im pwsh.exe
"@
$itemExit = New-Object System.Windows.Forms.ToolStripMenuItem("Exit")
$itemExit.add_Click([ScriptBlock]::Create($exitScriptText))

$cms.Items.Add($itemCommand) | Out-Null
$cms.Items.Add($itemExit)    | Out-Null

$notify.ContextMenuStrip = $cms

$leftClickScriptText = @"
param(`$sender, `$e)
if (`$e.Button -eq [System.Windows.Forms.MouseButtons]::Left) {
    Start-Job -ArgumentList '$escapedPath' -ScriptBlock {
        param(`$bp)
        Start-Process -FilePath `$bp -WorkingDirectory (Split-Path `$bp)
    } | Out-Null
}
"@
$notify.add_MouseClick([ScriptBlock]::Create($leftClickScriptText))

Register-ObjectEvent -InputObject ([System.AppDomain]::CurrentDomain) -EventName ProcessExit -Action {
    try {
        if ($notify) {
            $notify.Visible = $false
            $notify.Dispose()
        }
    } catch {}
} | Out-Null

[System.Windows.Forms.Application]::EnableVisualStyles()

[System.Windows.Forms.Application]::Run()
