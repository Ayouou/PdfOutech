<#
.SYNOPSIS
  Add (or remove, with -Unlink) PdfOutech's MCP server in the Claude desktop app's config.

.DESCRIPTION
  Writes mcpServers.pdfoutech = { command: <install folder>\pdfoutech-cli.exe, args: ["mcp"] }
  into claude_desktop_config.json, in both places the Claude app keeps it (the classic installer and
  the Store/MSIX package). The file is backed up next to itself first. Restart Claude afterwards.
#>
param(
  [string] $Cli = (Join-Path $PSScriptRoot 'pdfoutech-cli.exe'),
  [switch] $Unlink,
  [switch] $Quiet
)
$ErrorActionPreference = 'Stop'

# Connector name -> arguments of pdfoutech-cli.
$Servers = [ordered]@{ 'pdfoutech' = @('mcp') }

$configs = @(Join-Path $env:APPDATA 'Claude\claude_desktop_config.json')
$packages = Join-Path $env:LOCALAPPDATA 'Packages'
if (Test-Path $packages) {
  Get-ChildItem $packages -Directory -Filter 'Claude_*' | ForEach-Object {
    $configs += Join-Path $_.FullName 'LocalCache\Roaming\Claude\claude_desktop_config.json'
  }
}

$done = @()
foreach ($path in $configs) {
  $dir = Split-Path $path
  # Only where Claude is installed: its folder exists even before the config file does.
  if (-not (Test-Path $dir)) { continue }
  $config = New-Object PSObject
  if (Test-Path $path) {
    $text = [IO.File]::ReadAllText($path)
    if ($text.Trim()) { $config = $text | ConvertFrom-Json }
    Copy-Item $path "$path.pdfoutech.bak" -Force
  } elseif ($Unlink) { continue }

  if (-not $config.PSObject.Properties['mcpServers']) {
    $config | Add-Member -NotePropertyName mcpServers -NotePropertyValue (New-Object PSObject)
  }
  $entries = $config.mcpServers
  foreach ($name in $Servers.Keys) {
    if ($entries.PSObject.Properties[$name]) { $entries.PSObject.Properties.Remove($name) }
    if (-not $Unlink) {
      $entries | Add-Member -NotePropertyName $name -NotePropertyValue ([pscustomobject]@{ command = $Cli; args = @($Servers[$name]) })
    }
  }
  # No BOM: Claude reads the file as plain UTF-8 JSON.
  [IO.File]::WriteAllText($path, ($config | ConvertTo-Json -Depth 32), (New-Object Text.UTF8Encoding $false))
  $done += $path
}

if (-not $Quiet) {
  if ($done.Count -eq 0) { Write-Output 'Claude desktop app not found: nothing changed.' }
  elseif ($Unlink) { Write-Output "PdfOutech removed from Claude:`n$($done -join "`n")" }
  else { Write-Output "PdfOutech linked to Claude (restart Claude to see it):`n$($done -join "`n")" }
}
