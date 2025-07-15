# Word Play Language Mod Installer for Windows
# Works on all Windows systems by default (PowerShell comes pre-installed)
# Usage: .\install_language.ps1 <language_name>

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
    Write-Host "  .\install_language.ps1 <language_name>     Install a language mod"
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
    $userProfile = $env:USERPROFILE
    return Join-Path $userProfile "AppData\LocalLow\Game Maker's Toolkit\Word Play"
}

function Get-AvailableLanguages {
    Write-ColorOutput "Available language mods:" $Blue
    $foundLanguages = $false
    
    Get-ChildItem -Directory | ForEach-Object {
        $langName = $_.Name
        $dictFile = Join-Path $_.FullName "customdictionary.txt"
        $bagFile = Join-Path $_.FullName "customletterbag.txt"
        
        if (Test-Path $dictFile -and Test-Path $bagFile) {
            Write-ColorOutput "  ✓ $langName" $Green
            $foundLanguages = $true
        } else {
            Write-ColorOutput "  ⚠ $langName (missing files)" $Yellow
        }
    }
    
    if (-not $foundLanguages) {
        Write-ColorOutput "No complete language mods found." $Yellow
        Write-Host "Each language directory should contain:"
        Write-Host "  - customdictionary.txt"
        Write-Host "  - customletterbag.txt"
    }
}

function Install-LanguageMod {
    param([string]$LanguageName)
    
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
if ($Help -or $args.Count -eq 0) {
    Show-Help
    exit 0
}

if ($List) {
    Get-AvailableLanguages
    exit 0
}

if ($LanguageName) {
    Install-LanguageMod $LanguageName
    exit $LASTEXITCODE
}

# If we get here, show help
Show-Help
exit 1 