# Word Play (by Game Maker's Toolkit) - Language Mods
Language mods for the Word Play game by Game Maker's Toolkit

## Quick Installation

Use our automated installation scripts for easy setup:

### Mac
```bash
chmod +x install_language.sh
./install_language.sh <language_name>

# List available languages
./install_language.sh --list

# Show help
./install_language.sh --help
```

### Windows
```powershell
.\install_language.ps1 <language_name>

# List available languages
.\install_language.ps1 --list

# Show help
.\install_language.ps1 --help
```

### Example
```bash
# Install Catalan language mod
./install_language.sh catalan
```

## Manual Installation

If you prefer to install manually, you'll need to find the folder with your save game in it:

### Mac
`~/Library/Application Support/com.GMTK.WordPlay`

### Windows
`%USERPROFILE%\AppData\LocalLow\Game Maker's Toolkit\Word Play`

You may need to show hidden files or folders to get here!

Then simply add the `customdictionary.txt` and `customletterbag.txt` of the desired language.

The game should show "Custom Dictionary" in the bottom left corner.

<img width="1920" height="1080" alt="image" src="https://github.com/user-attachments/assets/cc5920eb-3ab3-43f5-b79b-8efcab7e2079" />

## Contribute

### Standard Language Contribution
Simply make a Pull Request with a new folder with the language (or edit existing one) with both a `customdictionary.txt` and `customletterbag.txt`

### Large Dictionary Support
For languages with large dictionaries that exceed GitHub's file size limits, you can compress only the dictionary file:

**Mixed Setup (Recommended)**
- Create a language folder (e.g., `german/`)
- Add `customdictionary.zip` (containing `customdictionary.txt`)
- Add `customletterbag.txt` (uncompressed)
- The installer will automatically extract and install both files

**File Structure Examples:**
```
# Standard setup
catalan/
├── customdictionary.txt
└── customletterbag.txt

# Mixed setup (for large dictionaries)
german/
├── customdictionary.zip  # Contains customdictionary.txt
└── customletterbag.txt   # Always uncompressed
```

**Creating a compressed dictionary:**
```bash
# Create zip file from existing dictionary
zip customdictionary.zip customdictionary.txt

# Or compress an existing dictionary
zip -r customdictionary.zip customdictionary.txt
```

**Important:** Only compress `customdictionary.txt` to `customdictionary.zip`. The `customletterbag.txt` file should always remain uncompressed.

The installation scripts automatically detect and handle all these formats!

## Steam Link
https://store.steampowered.com/app/3586660/Word_Play/?curator_clanid=44902603

## Custom Language Explainer
https://store.steampowered.com/news/app/3586660/view/521970822705840562?l=english

## Known limitations
- Single letters only (some languages require tiles with several letters)
- Perks etc.. don't adapt to the language
