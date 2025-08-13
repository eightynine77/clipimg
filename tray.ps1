# tray.ps1  -- for PowerShell Core (pwsh)
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ----- CONFIG -----
$batchPath = Join-Path $PSScriptRoot '\clipimg-mspaint-version\run.bat'   # adjust if needed
$iconFile  = Join-Path $PSScriptRoot '\icon.ico'          # optional
# ------------------

if (-not (Test-Path $batchPath)) {
    Write-Error "Batch file not found: $batchPath"
    exit 1
}

# Prepare an escaped single-quoted literal of the path for embedding
$escapedPath = $batchPath -replace "'", "''"

# Create NotifyIcon
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

# Build ContextMenuStrip
$cms = New-Object System.Windows.Forms.ContextMenuStrip

# Command item: uses Start-Job so it never tries to access outer variables in the event runspace
$cmdScriptText = @"
# param for mouse event handlers (unused here)
param(`$sender, `$e)
Start-Job -ArgumentList '$escapedPath' -ScriptBlock {
    param(`$bp)
    # launch the batch; change WindowStyle if you want hidden
    Start-Process -FilePath `$bp -WorkingDirectory (Split-Path `$bp)
} | Out-Null
"@
$itemCommand = New-Object System.Windows.Forms.ToolStripMenuItem("view clipboard image")
$itemCommand.add_Click([ScriptBlock]::Create($cmdScriptText))

# Exit item
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

# Left-click event: run same Start-Job script (we provide param signature for MouseClick)
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

# Cleanup on process exit (best-effort)
Register-ObjectEvent -InputObject ([System.AppDomain]::CurrentDomain) -EventName ProcessExit -Action {
    try {
        if ($notify) {
            $notify.Visible = $false
            $notify.Dispose()
        }
    } catch {}
} | Out-Null

# Visual styles + run loop
[System.Windows.Forms.Application]::EnableVisualStyles()

[System.Windows.Forms.Application]::Run()
