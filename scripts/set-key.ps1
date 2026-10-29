# Stores API keys as user environment variables on Windows. Keys are never shown on screen
# or written to the repo. Which keys exist is defined in scripts\keys.conf.
#
# Close your AI agent first, then double-click scripts\set-key.cmd, or run:
#   powershell -ExecutionPolicy Bypass -File scripts\set-key.ps1
# Open a NEW terminal afterwards so the keys are visible.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$keys = @()
foreach ($line in Get-Content (Join-Path $PSScriptRoot "keys.conf")) {
    $line = $line.Trim()
    if (-not $line -or $line.StartsWith("#")) { continue }
    $parts = $line -split "\s+"
    $keys += @{
        Var   = $parts[0]
        Label = if ($parts.Count -gt 1) { $parts[1] } else { $parts[0] }
        Url   = if ($parts.Count -gt 2) { $parts[2] } else { $null }
    }
}

if ($keys.Count -eq 0) {
    Write-Host "No keys listed in scripts\keys.conf yet. Ask your agent to add them." -ForegroundColor Yellow
    exit
}

while ($true) {
    Write-Host ""
    Write-Host "Which key do you want to set?" -ForegroundColor Cyan
    for ($i = 0; $i -lt $keys.Count; $i++) {
        $k = $keys[$i]
        $state = if ([Environment]::GetEnvironmentVariable($k.Var, "User")) { "set" } else { "missing" }
        Write-Host ("  {0}. {1,-14} {2,-26} ({3})" -f ($i + 1), $k.Label, $k.Var, $state)
    }
    Write-Host "  0. Quit"

    $choice = Read-Host "Choose"
    if ($choice -eq "" -or $choice -eq "0") { break }
    $n = 0
    if (-not [int]::TryParse($choice, [ref]$n) -or $n -lt 1 -or $n -gt $keys.Count) {
        Write-Host "Invalid choice." -ForegroundColor Red
        continue
    }
    $k = $keys[$n - 1]

    $s = Read-Host "Paste the $($k.Label) key (it will not be shown)" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($s)
    $v = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr).Trim()
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
    if (-not $v) {
        Write-Host "Nothing entered, skipped." -ForegroundColor Yellow
        continue
    }

    if ($k.Url) {
        try {
            $r = Invoke-WebRequest -UseBasicParsing -TimeoutSec 15 -Headers @{ Authorization = "Bearer $v" } $k.Url
            Write-Host "Verified (HTTP $($r.StatusCode))." -ForegroundColor Green
        } catch {
            Write-Host "Verification failed: $($_.Exception.Message)" -ForegroundColor Red
            if ((Read-Host "Save anyway? (y/n)") -ne "y") { $v = $null; continue }
        }
    } else {
        Write-Host "No verify URL for this key, saving without a check." -ForegroundColor Yellow
    }

    [Environment]::SetEnvironmentVariable($k.Var, $v, "User")
    $v = $null
    Write-Host "Saved: $($k.Var)" -ForegroundColor Green
}

Write-Host ""
Write-Host "Keys are only visible in NEW terminals. Open a new one before starting your agent." -ForegroundColor Cyan
