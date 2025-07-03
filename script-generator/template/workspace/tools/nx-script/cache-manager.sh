#!/bin/bash
# cache-manager.sh
# Universal wrapper script that auto-detects workspace structure
# Place this in tools/nx-script/ directory

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Auto-detect workspace structure and .nx location
detect_workspace() {
    local current_dir=$(pwd)
    local nx_dir=""
    local script_dir=""
    
    # Find .nx directory (can be at current level or parent levels)
    if [ -d ".nx" ]; then
        nx_dir="$(pwd)/.nx"
        script_dir="$(dirname "${BASH_SOURCE[0]}")"
    elif [ -d "../.nx" ]; then
        nx_dir="$(cd .. && pwd)/.nx"
        script_dir="$(dirname "${BASH_SOURCE[0]}")"
    elif [ -d "../../.nx" ]; then
        nx_dir="$(cd ../.. && pwd)/.nx"
        script_dir="$(dirname "${BASH_SOURCE[0]}")"
    else
        echo -e "${RED}❌ .nx directory not found${NC}"
        echo -e "${YELLOW}💡 Make sure you're running from a directory that has .nx nearby${NC}"
        exit 1
    fi
    
    # Get absolute paths
    NX_ROOT=$(dirname "$nx_dir")
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    
    echo "$NX_ROOT|$SCRIPT_DIR"
}

# Function to run script in correct context
run_script() {
    local script_name="$1"
    shift
    local args="$@"
    
    # Detect workspace
    local workspace_info=$(detect_workspace)
    local nx_root=$(echo "$workspace_info" | cut -d'|' -f1)
    local script_dir=$(echo "$workspace_info" | cut -d'|' -f2)
    
    local script_path="$script_dir/$script_name"
    
    if [ ! -f "$script_path" ]; then
        echo -e "${RED}❌ Script not found: $script_path${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}🔧 Workspace Detection:${NC}"
    echo -e "  Nx Root: ${GREEN}$nx_root${NC}"
    echo -e "  Script Dir: ${GREEN}$script_dir${NC}"
    echo -e "  Running: ${GREEN}$script_name $args${NC}"
    echo ""
    
    # Change to nx root and run script
    cd "$nx_root"
    chmod +x "$script_path"
    "$script_path" $args
    
    # Return to original directory
    cd - >/dev/null
}

# Function to show debug info
show_debug_info() {
    echo -e "${BLUE}🔍 Debug Information:${NC}"
    echo -e "  Current Directory: ${GREEN}$(pwd)${NC}"
    echo -e "  Script Location: ${GREEN}$(dirname "${BASH_SOURCE[0]}")${NC}"
    
    # Check for .nx at different levels
    if [ -d ".nx" ]; then
        echo -e "  .nx Location: ${GREEN}$(pwd)/.nx${NC}"
    elif [ -d "../.nx" ]; then
        echo -e "  .nx Location: ${GREEN}$(cd .. && pwd)/.nx${NC}"
    elif [ -d "../../.nx" ]; then
        echo -e "  .nx Location: ${GREEN}$(cd ../.. && pwd)/.nx${NC}"
    else
        echo -e "  .nx Location: ${RED}Not found${NC}"
    fi
    
    # Show available scripts
    local script_dir="$(dirname "${BASH_SOURCE[0]}")"
    echo -e "  Available Scripts:"
    for script in "$script_dir"/*.sh; do
        if [ -f "$script" ] && [ "$(basename "$script")" != "cache-manager.sh" ]; then
            echo -e "    ${GREEN}$(basename "$script")${NC}"
        fi
    done
}

# Main function
main() {
    local command="$1"
    
    case "$command" in
        "stats"|"s")
            run_script "cache-stats-v2.sh" "${@:2}"
            ;;
        "cleanup"|"c")
            run_script "nx-cache-cleanup-v2.sh" "${@:2}"
            ;;
        "project"|"p")
            if [ -z "$2" ]; then
                echo -e "${RED}Usage: $0 project <project-name> [keep-versions]${NC}"
                exit 1
            fi
            run_script "project-cache-cleanup-v2.sh" "${@:2}"
            ;;
        "hash"|"h")
            if [ -z "$2" ]; then
                echo -e "${RED}Usage: $0 hash <project> [target]${NC}"
                exit 1
            fi
            run_script "enhanced-hash-detector.sh" "${@:2}"
            ;;
        "utils"|"u")
            run_script "cache-utilities.sh" "${@:2}"
            ;;
        "projects")
            run_script "cache-utilities.sh" "projects"
            ;;
        "recent")
            run_script "cache-utilities.sh" "recent" "${2:-10}"
            ;;
        "search")
            if [ -z "$2" ]; then
                echo -e "${RED}Usage: $0 search <pattern>${NC}"
                exit 1
            fi
            run_script "cache-utilities.sh" "search" "$2"
            ;;
        "orphaned")
            run_script "cache-utilities.sh" "orphaned"
            ;;
        "clean-orphaned")
            run_script "cache-utilities.sh" "clean-orphaned"
            ;;
        "backup")
            run_script "cache-utilities.sh" "backup"
            ;;
        "age")
            run_script "cache-utilities.sh" "age"
            ;;
        "debug"|"d")
            show_debug_info
            ;;
        "help"|"")
            echo -e "${BLUE}🛠️  Nx Cache Manager${NC}"
            echo -e "${BLUE}===================${NC}"
            echo ""
            echo -e "${GREEN}Main Commands:${NC}"
            echo "  stats (s)                     - Show cache statistics"
            echo "  cleanup (c)                   - Clean old cache entries"
            echo "  project (p) <name> [keep]     - Clean specific project"
            echo "  hash (h) <project> [target]   - Get project hash"
            echo "  utils (u) <command>           - Cache utilities"
            echo ""
            echo -e "${GREEN}Quick Commands:${NC}"
            echo "  projects                      - List all projects"
            echo "  recent [limit]                - Show recent activity"
            echo "  search <pattern>              - Search cache"
            echo "  orphaned                      - Find orphaned folders"
            echo "  clean-orphaned                - Clean orphaned folders"
            echo "  backup                        - Backup database"
            echo "  age                           - Show age distribution"
            echo ""
            echo -e "${GREEN}Utilities:${NC}"
            echo "  debug (d)                     - Show debug information"
            echo "  help                          - Show this help"
            echo ""
            echo -e "${YELLOW}Examples:${NC}"
            echo "  $0 stats"
            echo "  $0 cleanup"
            echo "  $0 project my-app 3"
            echo "  $0 hash my-app build"
            echo "  $0 search my-app"
            ;;
        *)
            echo -e "${RED}❌ Unknown command: $command${NC}"
            echo -e "${YELLOW}Use '$0 help' for available commands${NC}"
            exit 1
            ;;
    esac
}

# Run main function
main "$@"