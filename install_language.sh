#!/usr/bin/env bash

# Word Play Language Mod Installer - Mac Script
# Works on Mac

# Colors for output (works on most terminals)
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Function to get save game path
get_save_game_path() {
    local home_dir="$HOME"
    local macOS_dir="$home_dir/Library/Application Support/com.GMTK.WordPlay"
    case $OSTYPE in
        darwin*) echo $macOS_dir;;
        linux*) echo "$home_dir/.local/share/Steam/steamapps/compatdata/3586660/pfx/drive_c/users/steamuser/AppData/LocalLow/Game Maker's Toolkit/Word Play/";;
        *)
            echo -e "${RED}Unkown OS:${NC} falling back to macOS" >&2
            echo $macOS_dir
        ;;
    esac
}

# Function to get available languages as an array
get_available_languages() {
    local languages=()
    # Add English as the first option
    languages+=("English (remove custom files)")
    
    # Check directories
    for dir in */; do
        if [ -d "$dir" ]; then
            lang_name="${dir%/}"
            # Check for either customdictionary.txt or customdictionary.zip
            if [ -f "$dir/customletterbag.txt" ] && ([ -f "$dir/customdictionary.txt" ] || [ -f "$dir/customdictionary.zip" ]); then
                languages+=("$lang_name")
            fi
        fi
    done
    
    # Check zip files
    for zipfile in *.zip; do
        if [ -f "$zipfile" ]; then
            lang_name="${zipfile%.zip}"
            languages+=("$lang_name (zip)")
        fi
    done
    
    echo "${languages[@]}"
}

# Function to show interactive selection menu
show_interactive_selection() {
    echo -e "${BLUE}Word Play Language Mod Installer${NC}" >&2
    echo -e "${CYAN}Select a language to install:${NC}" >&2
    echo "" >&2
    
    # Build languages array directly
    local languages=()
    local count=0
    
    # Add English as the first option
    languages+=("English (remove custom files)")
    ((count++))
    
    # Check directories
    for dir in */; do
        if [ -d "$dir" ]; then
            lang_name="${dir%/}"
            # Check for either customdictionary.txt or customdictionary.zip
            if [ -f "$dir/customletterbag.txt" ] && ([ -f "$dir/customdictionary.txt" ] || [ -f "$dir/customdictionary.zip" ]); then
                languages+=("$lang_name")
                ((count++))
            fi
        fi
    done
    
    # Check zip files
    for zipfile in *.zip; do
        if [ -f "$zipfile" ]; then
            lang_name="${zipfile%.zip}"
            languages+=("$lang_name (zip)")
            ((count++))
        fi
    done
    
    if [ $count -eq 1 ]; then
        echo -e "${YELLOW}No additional language mods found.${NC}" >&2
        echo "Each language directory should contain:" >&2
        echo "  - customdictionary.txt OR customdictionary.zip" >&2
        echo "  - customletterbag.txt" >&2
        echo "Or provide a .zip file containing customdictionary.txt" >&2
    fi
    
    # Display numbered options
    for i in "${!languages[@]}"; do
        local num=$((i + 1))
        if [ $i -eq 0 ]; then
            echo -e "  ${GREEN}$num${NC}. ${CYAN}${languages[$i]}${NC}" >&2
        elif [[ "${languages[$i]}" == *"(zip)" ]]; then
            echo -e "  ${GREEN}$num${NC}. ${YELLOW}${languages[$i]}${NC}" >&2
        else
            echo -e "  ${GREEN}$num${NC}. ${languages[$i]}" >&2
        fi
    done
    
    echo "" >&2
    
    # Get user selection
    while true; do
        echo -n -e "${CYAN}Enter the number of your choice (1-$count): ${NC}" >&2
        read -r selection
        
        # Check if input is a number
        if [[ "$selection" =~ ^[0-9]+$ ]]; then
            local num=$((selection))
            if [ $num -ge 1 ] && [ $num -le $count ]; then
                echo "${languages[$((num - 1))]}"
                return 0
            else
                echo -e "${RED}Please enter a number between 1 and $count.${NC}" >&2
            fi
        else
            echo -e "${RED}Please enter a valid number.${NC}" >&2
        fi
    done
}

# Function to list available languages
list_available_languages() {
    echo -e "${BLUE}Available language mods:${NC}"
    local found_languages=false
    
    # Always show English option
    echo -e "  ${CYAN}✓${NC} English (default)"
    
    # Check directories
    for dir in */; do
        if [ -d "$dir" ]; then
            lang_name="${dir%/}"
            if [ -f "$dir/customletterbag.txt" ] && ([ -f "$dir/customdictionary.txt" ] || [ -f "$dir/customdictionary.zip" ]); then
                if [ -f "$dir/customdictionary.zip" ]; then
                    echo -e "  ${GREEN}✓${NC} $lang_name"
                else
                    echo -e "  ${GREEN}✓${NC} $lang_name"
                fi
                found_languages=true
            else
                echo -e "  ${YELLOW}⚠${NC} $lang_name (missing files)"
            fi
        fi
    done
    
    # Check zip files
    for zipfile in *.zip; do
        if [ -f "$zipfile" ]; then
            lang_name="${zipfile%.zip}"
            echo -e "  ${YELLOW}📦${NC} $lang_name (custom dictionary only)"
            found_languages=true
        fi
    done
    
    if [ "$found_languages" = false ]; then
        echo -e "${YELLOW}No additional language mods found.${NC}"
        echo "Each language directory should contain:"
        echo "  - customdictionary.txt OR customdictionary.zip"
        echo "  - customletterbag.txt"
    fi
}

verify_save_game_path_exists() {
    if [ ! -d "$1" ]; then
        echo -e "${RED}Error: Word Play save game directory not found at:${NC}"
        echo "  $1"
        echo ""
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo "1. Make sure Word Play is installed"
        echo "2. Run Word Play at least once to create the save directory"
        echo "3. Check that the game has proper permissions"
        [[ "$OSTYPE" == linux* ]] && echo '4. Check if the game was installed in the default steam library, i.e. `~/.local/share/Steam/steamapps/` this is the only supported configuration currently'
            
        return 1
    fi
}

# Function to remove custom files (English option)
remove_custom_files() {
    local save_game_path=$(get_save_game_path)
    
    # Check if save game directory exists
    if ! verify_save_game_path_exists "$save_game_path"; then
        return 1
    fi
    
    echo -e "${BLUE}Removing custom language files...${NC}"
    echo "Location: $save_game_path"
    echo ""
    
    local removed_count=0
    
    # Remove custom dictionary if it exists
    if [ -f "$save_game_path/customdictionary.txt" ]; then
        if rm "$save_game_path/customdictionary.txt"; then
            echo -e "${GREEN}✓${NC} Removed customdictionary.txt"
            ((removed_count++))
        else
            echo -e "${RED}✗${NC} Failed to remove customdictionary.txt"
        fi
    else
        echo -e "${YELLOW}⚠${NC} No customdictionary.txt found to remove"
    fi
    
    # Remove custom letter bag if it exists
    if [ -f "$save_game_path/customletterbag.txt" ]; then
        if rm "$save_game_path/customletterbag.txt"; then
            echo -e "${GREEN}✓${NC} Removed customletterbag.txt"
            ((removed_count++))
        else
            echo -e "${RED}✗${NC} Failed to remove customletterbag.txt"
        fi
    else
        echo -e "${YELLOW}⚠${NC} No customletterbag.txt found to remove"
    fi
    
    echo ""
    if [ $removed_count -gt 0 ]; then
        echo -e "${GREEN}Successfully restored default English language!${NC}"
        echo "The game will now use the default English dictionary and letter bag."
        return 0
    else
        echo -e "${YELLOW}No custom files were found to remove.${NC}"
        echo "The game is already using the default English language."
        return 0
    fi
}

# Function to install from zip file
install_from_zip() {
    local zip_file="$1"
    local save_game_path=$(get_save_game_path)
    local temp_dir=$(mktemp -d)
    
    echo -e "${BLUE}Installing from zip file: $zip_file${NC}"
    echo "Source: $(pwd)/$zip_file"
    echo "Destination: $save_game_path"
    echo ""
    
    # Check if unzip is available
    if ! command -v unzip &> /dev/null; then
        echo -e "${RED}Error: 'unzip' command not found.${NC}"
        echo "Please install unzip to extract language files from zip archives."
        echo "On macOS: brew install unzip"
        echo "On Ubuntu/Debian: sudo apt-get install unzip"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extract zip file
    echo -e "${BLUE}Extracting zip file...${NC}"
    if ! unzip -q "$zip_file" -d "$temp_dir"; then
        echo -e "${RED}Error: Failed to extract zip file.${NC}"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Look for the customdictionary.txt file in the extracted content
    local dict_file=""
    
    # Search for the file recursively
    dict_file=$(find "$temp_dir" -name "customdictionary.txt" -type f | head -1)
    
    if [ -z "$dict_file" ]; then
        echo -e "${RED}Error: customdictionary.txt not found in zip archive.${NC}"
        echo "The zip file should contain customdictionary.txt"
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Found customdictionary.txt"
    echo ""
    
    # Copy only the dictionary file
    local success_count=0
    
    if cp "$dict_file" "$save_game_path/"; then
        echo -e "${GREEN}✓${NC} Copied customdictionary.txt"
        ((success_count++))
    else
        echo -e "${RED}✗${NC} Failed to copy customdictionary.txt"
    fi
    
    # Check if customletterbag.txt already exists in save directory
    if [ -f "$save_game_path/customletterbag.txt" ]; then
        echo -e "${YELLOW}⚠${NC} customletterbag.txt already exists in game directory (keeping existing)"
    else
        echo -e "${YELLOW}⚠${NC} No customletterbag.txt found - using default letter bag"
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    echo ""
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}Successfully installed custom dictionary from zip file!${NC}"
        echo "The game should show 'Custom Dictionary' in the bottom left corner when starting a new game."
        return 0
    else
        echo -e "${RED}No files were copied. Installation failed.${NC}"
        return 1
    fi
}

# Function to install from compressed dictionary
install_from_compressed_dict() {
    local language_dir="$1"
    local save_game_path=$(get_save_game_path)
    local temp_dir=$(mktemp -d)
    
    echo -e "${BLUE}Installing $language_dir language mod (with compressed dictionary)...${NC}"
    echo "Source: $(pwd)/$language_dir"
    echo "Destination: $save_game_path"
    echo ""
    
    # Check if unzip is available
    if ! command -v unzip &> /dev/null; then
        echo -e "${RED}Error: 'unzip' command not found.${NC}"
        echo "Please install unzip to extract language files from zip archives."
        echo "On macOS: brew install unzip"
        echo "On Ubuntu/Debian: sudo apt-get install unzip"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Extract the compressed dictionary
    echo -e "${BLUE}Extracting compressed dictionary...${NC}"
    if ! unzip -q "$language_dir/customdictionary.zip" -d "$temp_dir"; then
        echo -e "${RED}Error: Failed to extract compressed dictionary.${NC}"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Look for the customdictionary.txt file in the extracted content
    local dict_file=""
    dict_file=$(find "$temp_dir" -name "customdictionary.txt" -type f | head -1)
    
    if [ -z "$dict_file" ]; then
        echo -e "${RED}Error: customdictionary.txt not found in compressed dictionary.${NC}"
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo -e "${GREEN}✓${NC} Found customdictionary.txt"
    echo ""
    
    # Copy files
    local success_count=0
    
    # Copy the extracted dictionary
    if cp "$dict_file" "$save_game_path/"; then
        echo -e "${GREEN}✓${NC} Copied customdictionary.txt"
        ((success_count++))
    else
        echo -e "${RED}✗${NC} Failed to copy customdictionary.txt"
    fi
    
    # Copy the letter bag file
    if [ -f "$language_dir/customletterbag.txt" ]; then
        if cp "$language_dir/customletterbag.txt" "$save_game_path/"; then
            echo -e "${GREEN}✓${NC} Copied customletterbag.txt"
            ((success_count++))
        else
            echo -e "${RED}✗${NC} Failed to copy customletterbag.txt"
        fi
    else
        echo -e "${YELLOW}⚠${NC} customletterbag.txt not found in $language_dir directory"
    fi
    
    # Clean up
    rm -rf "$temp_dir"
    
    echo ""
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}Successfully installed $language_dir language mod!${NC}"
        echo "The game should show 'Custom Dictionary' and 'Custom Letter Bag' in the bottom left corner when starting a new game."
        return 0
    else
        echo -e "${RED}No files were copied. Installation failed.${NC}"
        return 1
    fi
}

# Function to show help
show_help() {
    echo -e "${BLUE}Word Play Language Mod Installer${NC}"
    echo "Mac shell script - no dependencies required"
    echo ""
    echo "Usage:"
    echo "  $0                    Interactive language selection"
    echo "  $0 <language_name>    Install a specific language mod"
    echo "  $0 --list             List available language mods"
    echo "  $0 --help             Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 catalan"
    echo ""
    echo "Requirements:"
    echo "  - Bash shell & unzip (comes pre-installed on Mac)"
    echo "  - Word Play game installed and run at least once"
}

# Main installation function
install_language_mod() {
    local language_name="$1"
    local save_game_path=$(get_save_game_path)
    
    # Check if this is the English option
    if [ "$language_name" = "English (remove custom files)" ]; then
        remove_custom_files
        return $?
    fi
    
    # Check if this is a zip file option
    if [[ "$language_name" == *"(zip)" ]]; then
        local zip_name="${language_name% (zip)}"
        local zip_file="${zip_name}.zip"
        
        if [ ! -f "$zip_file" ]; then
            echo -e "${RED}Error: Zip file '$zip_file' not found!${NC}"
            return 1
        fi
        
        install_from_zip "$zip_file"
        return $?
    fi
    
    # Check if language directory exists
    if [ ! -d "$language_name" ]; then
        echo -e "${RED}Error: Language directory '$language_name' not found!${NC}"
        echo "Use '$0 --list' to see available languages."
        return 1
    fi
    
    # Check if save game directory exists
    if ! verify_save_game_path_exists "$save_game_path"; then
        return 1
    fi
    
    # Check if this language uses a compressed dictionary
    if [ -f "$language_name/customdictionary.zip" ]; then
        install_from_compressed_dict "$language_name"
        return $?
    fi
    
    echo -e "${BLUE}Installing $language_name language mod...${NC}"
    echo "Source: $(pwd)/$language_name"
    echo "Destination: $save_game_path"
    echo ""
    
    # Copy files
    local success_count=0
    
    if [ -f "$language_name/customdictionary.txt" ]; then
        if cp "$language_name/customdictionary.txt" "$save_game_path/"; then
            echo -e "${GREEN}✓${NC} Copied customdictionary.txt"
            ((success_count++))
        else
            echo -e "${RED}✗${NC} Failed to copy customdictionary.txt"
        fi
    else
        echo -e "${YELLOW}⚠${NC} customdictionary.txt not found in $language_name directory"
    fi
    
    if [ -f "$language_name/customletterbag.txt" ]; then
        if cp "$language_name/customletterbag.txt" "$save_game_path/"; then
            echo -e "${GREEN}✓${NC} Copied customletterbag.txt"
            ((success_count++))
        else
            echo -e "${RED}✗${NC} Failed to copy customletterbag.txt"
        fi
    else
        echo -e "${YELLOW}⚠${NC} customletterbag.txt not found in $language_name directory"
    fi
    
    echo ""
    if [ $success_count -gt 0 ]; then
        echo -e "${GREEN}Successfully installed $language_name language mod!${NC}"
        echo "The game should show 'Custom Dictionary' and 'Custom Letter Bag' in the bottom left corner when starting a new game."
        return 0
    else
        echo -e "${RED}No files were copied. Installation failed.${NC}"
        return 1
    fi
}

# Main script logic
if [ $# -eq 0 ]; then
    # Interactive mode - show interactive selection menu
    selected_language=$(show_interactive_selection)
    if [ $? -ne 0 ]; then
        exit 1
    fi
    
    # Install the selected language
    install_language_mod "$selected_language"
    exit $?
fi

case "$1" in
    --help|-h)
        show_help
        exit 0
        ;;
    --list|-l)
        list_available_languages
        exit 0
        ;;
    *)
        install_language_mod "$1"
        exit $?
        ;;
esac 
