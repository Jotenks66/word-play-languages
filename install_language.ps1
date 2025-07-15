# Word Play Language Mod Installer for Windows
# Works on all Windows systems by default (PowerShell comes pre-installed)
# Usage: .\install_language.ps1 <language_name>

[CmdletBinding()]
param(
    [Parameter(Position=0)]
    [string]$LanguageName,
    
    [switch]$List,
    [switch]$Help
)

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"
$Cyan = "Cyan"

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "Word Play Language Mod Installer" $Blue
    Write-Host "Windows PowerShell script - no dependencies required"
    Write-Host ""
    Write-Host "Usage:"
    Write-Host "  .\install_language.ps1                    Interactive language selection"
    Write-Host "  .\install_language.ps1 <language_name>    Install a specific language mod"
    Write-Host "  .\install_language.ps1 --list             List available language mods"
    Write-Host "  .\install_language.ps1 --help             Show this help message"
    Write-Host ""
    Write-Host "Example:"
    Write-Host "  .\install_language.ps1 catalan"
    Write-Host ""
    Write-Host "Requirements:"
    Write-Host "  - Windows PowerShell (comes pre-installed on Windows 10/11)"
    Write-Host "  - Word Play game installed and run at least once"
}

function Get-SaveGamePath {
    # Windows save game path
    if ($IsWindows -or $env:OS -eq "Windows_NT") {
        $userProfile = $env:USERPROFILE
        return Join-Path $userProfile "AppData\LocalLow\Game Maker's Toolkit\Word Play"
    } else {
        # Cross-platform fallback (for testing on macOS/Linux)
        $userProfile = $env:HOME
        return Join-Path $userProfile "Library/Application Support/com.GMTK.WordPlay"
    }
}

function Get-AvailableLanguagesList {
    $languages = @()
    # Add English as the first option
    $languages += "English (remove custom files)"
    
    Get-ChildItem -Directory | ForEach-Object {
        $langName = $_.Name
        $dictFile = Join-Path $_.FullName "customdictionary.txt"
        $bagFile = Join-Path $_.FullName "customletterbag.txt"
        
        if ((Test-Path $dictFile) -and (Test-Path $bagFile)) {
            $languages += $langName
        }
    }
    
    return $languages
}

function Show-InteractiveSelection {
    Write-ColorOutput "Word Play Language Mod Installer" $Blue
    Write-ColorOutput "Select a language to install:" $Cyan
    Write-Host ""
    
    $languages = Get-AvailableLanguagesList
    $count = $languages.Count
    
    if ($count -eq 1) {
        Write-ColorOutput "No additional language mods found." $Yellow
        Write-Host "Each language directory should contain:"
        Write-Host "  - customdictionary.txt"
        Write-Host "  - customletterbag.txt"
    }
    
    # Display numbered options
    for ($i = 0; $i -lt $count; $i++) {
        $num = $i + 1
        if ($i -eq 0) {
            Write-ColorOutput "  $num. $($languages[$i])" $Cyan
        } else {
            Write-ColorOutput "  $num. $($languages[$i])" $Green
        }
    }
    
    Write-Host ""
    
    # Get user selection
    while ($true) {
        Write-Host "Enter the number of your choice (1-$count): " -NoNewline -ForegroundColor $Cyan
        $selection = Read-Host
        
        # Check if input is a number
        if ($selection -match '^\d+$') {
            $num = [int]$selection
            if ($num -ge 1 -and $num -le $count) {
                return $languages[$num - 1]
            } else {
                Write-ColorOutput "Please enter a number between 1 and $count." $Red
            }
        } else {
            Write-ColorOutput "Please enter a valid number." $Red
        }
    }
}

function Get-AvailableLanguages {
    Write-ColorOutput "Available language mods:" $Blue
    $foundLanguages = $false
    
    # Always show English option
    Write-ColorOutput "  ✓ English (remove custom files)" $Cyan
    
    Get-ChildItem -Directory | ForEach-Object {
        $langName = $_.Name
        $dictFile = Join-Path $_.FullName "customdictionary.txt"
        $bagFile = Join-Path $_.FullName "customletterbag.txt"
        
        if ((Test-Path $dictFile) -and (Test-Path $bagFile)) {
            Write-ColorOutput "  ✓ $langName" $Green
            $foundLanguages = $true
        } else {
            Write-ColorOutput "  ⚠ $langName (missing files)" $Yellow
        }
    }
    
    if (-not $foundLanguages) {
        Write-ColorOutput "No additional language mods found." $Yellow
        Write-Host "Each language directory should contain:"
        Write-Host "  - customdictionary.txt"
        Write-Host "  - customletterbag.txt"
    }
}

function Remove-CustomFiles {
    $saveGamePath = Get-SaveGamePath
    
    # Check if save game directory exists
    if (-not (Test-Path $saveGamePath -PathType Container)) {
        Write-ColorOutput "Error: Word Play save game directory not found at:" $Red
        Write-Host "  $saveGamePath"
        Write-Host ""
        Write-ColorOutput "Troubleshooting:" $Yellow
        Write-Host "1. Make sure Word Play is installed"
        Write-Host "2. Run Word Play at least once to create the save directory"
        Write-Host "3. Check that the game has proper permissions"
        return $false
    }
    
    Write-ColorOutput "Removing custom language files..." $Blue
    Write-Host "Location: $saveGamePath"
    Write-Host ""
    
    $removedCount = 0
    $requiredFiles = @("customdictionary.txt", "customletterbag.txt")
    
    foreach ($file in $requiredFiles) {
        $filePath = Join-Path $saveGamePath $file
        
        if (Test-Path $filePath) {
            try {
                Remove-Item $filePath -Force
                Write-ColorOutput "✓ Removed $file" $Green
                $removedCount++
            } catch {
                Write-ColorOutput "✗ Failed to remove $file" $Red
            }
        } else {
            Write-ColorOutput "⚠ No $file found to remove" $Yellow
        }
    }
    
    Write-Host ""
    if ($removedCount -gt 0) {
        Write-ColorOutput "Successfully restored default English language!" $Green
        Write-Host "The game will now use the default English dictionary and letter bag."
        return $true
    } else {
        Write-ColorOutput "No custom files were found to remove." $Yellow
        Write-Host "The game is already using the default English language."
        return $true
    }
}

function Install-LanguageMod {
    param([string]$LanguageName)
    
    # Check if this is the English option
    if ($LanguageName -eq "English (remove custom files)") {
        return Remove-CustomFiles
    }
    
    $saveGamePath = Get-SaveGamePath
    $sourceDir = Join-Path (Get-Location) $LanguageName
    
    Write-ColorOutput "Installing $LanguageName language mod..." $Blue
    
    # Check if language directory exists
    if (-not (Test-Path $sourceDir -PathType Container)) {
        Write-ColorOutput "Error: Language directory '$LanguageName' not found!" $Red
        Write-Host "Use '.\install_language.ps1 --list' to see available languages."
        return $false
    }
    
    # Check if save game directory exists
    if (-not (Test-Path $saveGamePath -PathType Container)) {
        Write-ColorOutput "Error: Word Play save game directory not found at:" $Red
        Write-Host "  $saveGamePath"
        Write-Host ""
        Write-ColorOutput "Troubleshooting:" $Yellow
        Write-Host "1. Make sure Word Play is installed"
        Write-Host "2. Run Word Play at least once to create the save directory"
        Write-Host "3. Check that the game has proper permissions"
        return $false
    }
    
    Write-Host "Source: $sourceDir"
    Write-Host "Destination: $saveGamePath"
    Write-Host ""
    
    # Copy files
    $successCount = 0
    $requiredFiles = @("customdictionary.txt", "customletterbag.txt")
    
    foreach ($file in $requiredFiles) {
        $sourceFile = Join-Path $sourceDir $file
        $destFile = Join-Path $saveGamePath $file
        
        if (Test-Path $sourceFile) {
            try {
                Copy-Item $sourceFile $destFile -Force
                Write-ColorOutput "✓ Copied $file" $Green
                $successCount++
            } catch {
                Write-ColorOutput "✗ Failed to copy $file" $Red
            }
        } else {
            Write-ColorOutput "⚠ $file not found in $LanguageName directory" $Yellow
        }
    }
    
    Write-Host ""
    if ($successCount -gt 0) {
        Write-ColorOutput "Successfully installed $LanguageName language mod!" $Green
        Write-Host "The game should show 'Custom Dictionary' and 'Custom Letter Bag' in the bottom left corner when starting a new game."
        return $true
    } else {
        Write-ColorOutput "No files were copied. Installation failed." $Red
        return $false
    }
}

# Main script logic
if ($Help) {
    Show-Help
    exit 0
}

if ($List) {
    Get-AvailableLanguages
    exit 0
}

if ($LanguageName -and $LanguageName -ne "") {
    Install-LanguageMod $LanguageName
    exit $LASTEXITCODE
}

# Interactive mode - no arguments provided
$selectedLanguage = Show-InteractiveSelection
if ($selectedLanguage) {
    $success = Install-LanguageMod $selectedLanguage
    if ($success) {
        exit 0
    } else {
        exit 1
    }
} else {
    exit 1
} 