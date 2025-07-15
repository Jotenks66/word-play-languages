#!/bin/bash

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
    echo "$home_dir/Library/Application Support/com.GMTK.WordPlay"
}

# Function to show interactive selection menu
show_interactive_selection() {
    echo -e "${BLUE}Word Play Language Mod Installer${NC}" >&2
    echo -e "${CYAN}Select a language to install:${NC}" >&2
    echo "" >&2
    
    # Build languages array directly
    local languages=()
    local count=0
    
    for dir in */; do
        if [ -d "$dir" ]; then
            lang_name="${dir%/}"
            if [ -f "$dir/customdictionary.txt" ] && [ -f "$dir/customletterbag.txt" ]; then
                languages+=("$lang_name")
                ((count++))
            fi
        fi
    done
    
    if [ $count -eq 0 ]; then
        echo -e "${YELLOW}No complete language mods found.${NC}" >&2
        echo "Each language directory should contain:" >&2
        echo "  - customdictionary.txt" >&2
        echo "  - customletterbag.txt" >&2
        return 1
    fi
    
    # Display numbered options
    for i in "${!languages[@]}"; do
        local num=$((i + 1))
        echo -e "  ${GREEN}$num${NC}. ${languages[$i]}" >&2
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
    
    for dir in */; do
        if [ -d "$dir" ]; then
            lang_name="${dir%/}"
            if [ -f "$dir/customdictionary.txt" ] && [ -f "$dir/customletterbag.txt" ]; then
                echo -e "  ${GREEN}✓${NC} $lang_name"
                found_languages=true
            else
                echo -e "  ${YELLOW}⚠${NC} $lang_name (missing files)"
            fi
        fi
    done
    
    if [ "$found_languages" = false ]; then
        echo -e "${YELLOW}No complete language mods found.${NC}"
        echo "Each language directory should contain:"
        echo "  - customdictionary.txt"
        echo "  - customletterbag.txt"
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
    echo "  - Bash shell (comes pre-installed on Mac)"
    echo "  - Word Play game installed and run at least once"
}

# Main installation function
install_language_mod() {
    local language_name="$1"
    local save_game_path=$(get_save_game_path)
    
    # Check if language directory exists
    if [ ! -d "$language_name" ]; then
        echo -e "${RED}Error: Language directory '$language_name' not found!${NC}"
        echo "Use '$0 --list' to see available languages."
        return 1
    fi
    
    # Check if save game directory exists
    if [ ! -d "$save_game_path" ]; then
        echo -e "${RED}Error: Word Play save game directory not found at:${NC}"
        echo "  $save_game_path"
        echo ""
        echo -e "${YELLOW}Troubleshooting:${NC}"
        echo "1. Make sure Word Play is installed"
        echo "2. Run Word Play at least once to create the save directory"
        echo "3. Check that the game has proper permissions"
        return 1
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