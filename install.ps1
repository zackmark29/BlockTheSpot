$PSDefaultParameterValues['Stop-Process:ErrorAction'] = 'SilentlyContinue'

write-host @'
***************** 
Author: @Nuzair46
Modified By: @Daksh777
***************** 
'@

$SpotifyDirectory = "$env:APPDATA\Spotify"
$SpotifyExecutable = "$SpotifyDirectory\Spotify.exe"

Write-Host 'Stopping Spotify...'`n
Stop-Process -Name Spotify
Stop-Process -Name SpotifyWebHelper

if ($PSVersionTable.PSVersion.Major -ge 7)
{
    Import-Module Appx -UseWindowsPowerShell
}

if (Get-AppxPackage -Name SpotifyAB.SpotifyMusic) {
  Write-Host @'
The Microsoft Store version of Spotify has been detected which is not supported.
'@`n
  $ch = Read-Host -Prompt "Uninstall Spotify Windows Store edition (Y/N) "
  if ($ch -eq 'y'){
     Write-Host @'
Uninstalling Spotify.
'@`n
     Get-AppxPackage -Name SpotifyAB.SpotifyMusic | Remove-AppxPackage
  } else{
     Write-Host @'
Exiting...
'@`n
     Pause 
     exit
    }
}

Push-Location -LiteralPath $env:TEMP
try {
  New-Item -Type Directory -Name "BlockTheSpot-$(Get-Date -UFormat '%Y-%m-%d_%H-%M-%S')" `
  | Convert-Path `
  | Set-Location
} catch {
  Write-Output $_
  Pause
  exit
}

Write-Host 'Downloading latest patch (chrome_elf.zip)...'`n
$webClient = New-Object -TypeName System.Net.WebClient
try {
  $webClient.DownloadFile(
    'https://github.com/mrpond/BlockTheSpot/releases/latest/download/chrome_elf.zip',
    "$PWD\chrome_elf.zip"
  )
} catch {
  Write-Output $_
  Start-Sleep
}

Expand-Archive -Force -LiteralPath "$PWD\chrome_elf.zip" -DestinationPath $PWD
Remove-Item -LiteralPath "$PWD\chrome_elf.zip"

$spotifyInstalled = (Test-Path -LiteralPath $SpotifyExecutable)
if (-not $spotifyInstalled) {
  Write-Host @'
Spotify installation was not detected.
Downloading Latest Spotify full setup, please wait...
'@
  try {
    $webClient.DownloadFile(
      'https://download.scdn.co/SpotifyFullSetup.exe',
      "$PWD\SpotifyFullSetup.exe"
    )
  } catch {
    Write-Output $_
    Pause
    exit
  }
  mkdir $SpotifyDirectory >$null 2>&1
  Write-Host 'Running installation...'
  Start-Process -FilePath "$PWD\SpotifyFullSetup.exe"
  Write-Host 'Stopping Spotify...Again'
  while ($null -eq (Get-Process -name Spotify -ErrorAction SilentlyContinue)){
     }
  Stop-Process -Name Spotify >$null 2>&1
  Stop-Process -Name SpotifyWebHelper >$null 2>&1
  Stop-Process -Name SpotifyFullSetup >$null 2>&1
}

if (!(test-path $SpotifyDirectory/chrome_elf_bak.dll)){
	move $SpotifyDirectory\chrome_elf.dll $SpotifyDirectory\chrome_elf_bak.dll >$null 2>&1
}

$ch = Read-Host -Prompt "Optional - Declutter Spotify?. (Y/N) "
if ($ch -eq 'y'){
  Start-Process http://github.com/Daksh777/SpotifyNoPremium
    Write-Host @'
Opened browser tab with the instructions. 
Didn't work? Visit https://github.com/Daksh777/SpotifyNoPremium
'@`n
} else{
     Write-Host @'
Action cancelled.
'@`n
}

Write-Host 'Patching Spotify...'
$patchFiles = "$PWD\chrome_elf.dll", "$PWD\config.ini"
Copy-Item -LiteralPath $patchFiles -Destination "$SpotifyDirectory"

$ch = Read-Host -Prompt "Optional - Remove ad placeholder and upgrade button. (Y/N) "
if ($ch -eq 'y') {
    $xpuiBundlePath = "$SpotifyApps\xpui.spa"
    $xpuiUnpackedPath = "$SpotifyApps\xpui\xpui.js"
    $fromZip = $false
    
    # Try to read xpui.js from xpui.spa for normal Spotify installations, or
    # directly from Apps/xpui/xpui.js in case Spicetify is installed.
    if (Test-Path $xpuiBundlePath) {
        Add-Type -Assembly 'System.IO.Compression.FileSystem'
        Copy-Item -Path $xpuiBundlePath -Destination "$xpuiBundlePath.bak"

        $zip = [System.IO.Compression.ZipFile]::Open($xpuiBundlePath, 'update')
        $entry = $zip.GetEntry('xpui.js')

        # Extract xpui.js from zip to memory
        $reader = New-Object System.IO.StreamReader($entry.Open())
        $xpuiContents = $reader.ReadToEnd()
        $reader.Close()

        $fromZip = $true
    } elseif (Test-Path $xpuiUnpackedPath) {
        Copy-Item -Path $xpuiUnpackedPath -Destination "$xpuiUnpackedPath.bak"
        $xpuiContents = Get-Content -Path $xpuiUnpackedPath -Raw

        Write-Host 'Spicetify detected - You may need to reinstall BTS after running "spicetify apply".';
    } else {
        Write-Host 'Could not find xpui.js, please open an issue on the BlockTheSpot repository.'
    }

    if ($xpuiContents) {
        # Replace ".ads.leaderboard.isEnabled" + separator - '}' or ')'
        # With ".ads.leaderboard.isEnabled&&false" + separator
        $xpuiContents = $xpuiContents -replace '(\.ads\.leaderboard\.isEnabled)(}|\))', '$1&&false$2'
    
        # Delete ".createElement(XX,{onClick:X,className:XX.X.UpgradeButton}),X()"
        $xpuiContents = $xpuiContents -replace '\.createElement\([^.,{]+,{onClick:[^.,]+,className:[^.]+\.[^.]+\.UpgradeButton}\),[^.(]+\(\)', ''
    
        if ($fromZip) {
            # Rewrite it to the zip
            $writer = New-Object System.IO.StreamWriter($entry.Open())
            $writer.BaseStream.SetLength(0)
            $writer.Write($xpuiContents)
            $writer.Close()

            $zip.Dispose()
        } else {
            Set-Content -Path $xpuiUnpackedPath -Value $xpuiContents
        }
    }
} else {
     Write-Host @'
Won't remove ad placeholder and upgrade button.
'@`n
}

$tempDirectory = $PWD
Pop-Location

Remove-Item -Recurse -LiteralPath $tempDirectory  

Write-Host 'Patching Complete, starting Spotify...'
Start-Process -WorkingDirectory $SpotifyDirectory -FilePath $SpotifyExecutable
Write-Host 'Done.'

exit