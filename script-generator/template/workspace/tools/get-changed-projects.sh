#!/bin/bash

# Cross-platform script for macOS and Ubuntu
# Usage: ./get-changed-projects.sh [--debug] [base_commit] [head_commit]

set -e

# Handle debug flag first
DEBUG=false
if [ "$1" = "--debug" ] || [ "$1" = "-d" ]; then
    DEBUG=true
    shift
fi

# Handle help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    cat << EOF
Usage: $0 [--debug] [base_commit] [head_commit]

Find project names from package.json files that changed between two commits.

Options:
    --debug, -d        Enable debug mode to see detailed search process
    --help, -h         Show this help

Arguments:
    base_commit        Base commit for comparison (default: HEAD~1)
    head_commit        Head commit for comparison (default: HEAD)

Examples:
    $0                          # Compare HEAD~1 with HEAD
    $0 --debug HEAD~3 HEAD      # Debug mode: Compare HEAD~3 with HEAD
    $0 main feature-branch      # Compare main with feature-branch

Requirements:
    - git
    - sed
    - jq (optional, fallback available)
EOF
    exit 0
fi

BASE_COMMIT=${1:-"HEAD~1"}
HEAD_COMMIT=${2:-"HEAD"}

# Detect OS for compatibility
OS="$(uname -s)"
case "${OS}" in
    Linux*)     MACHINE=Linux;;
    Darwin*)    MACHINE=Mac;;
    *)          MACHINE="UNKNOWN:${OS}"
esac

# Colors for output
if [ -t 1 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    NC='\033[0m'
else
    RED=''
    GREEN=''
    YELLOW=''
    NC=''
fi

# Check if jq is available
JQ_AVAILABLE=false
if command -v jq >/dev/null 2>&1; then
    JQ_AVAILABLE=true
fi

# Function to check dependencies
check_dependencies() {
    local missing_deps=""
    
    if ! command -v git >/dev/null 2>&1; then
        missing_deps="$missing_deps git"
    fi
    
    if ! command -v sed >/dev/null 2>&1; then
        missing_deps="$missing_deps sed"
    fi
    
    if [ -n "$missing_deps" ]; then
        printf "${RED}Error: Missing required dependencies:%s${NC}\n" "$missing_deps"
        exit 1
    fi
}

# Function to extract project name from package.json
extract_project_name() {
    local package_file="$1"
    
    if [ ! -f "$package_file" ]; then
        echo ""
        return
    fi
    
    if [ "$JQ_AVAILABLE" = true ]; then
        jq -r '.name // empty' "$package_file" 2>/dev/null || echo ""
    else
        sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$package_file" | head -1
    fi
}

printf "${YELLOW}Checking changed files between ${BASE_COMMIT} and ${HEAD_COMMIT}...${NC}\n"
printf "${YELLOW}Running on: ${MACHINE}${NC}\n"
if [ "$JQ_AVAILABLE" = false ]; then
    printf "${YELLOW}Note: jq not found, using fallback method to parse JSON${NC}\n"
fi
if [ "$DEBUG" = true ]; then
    printf "${YELLOW}🐛 Debug mode enabled${NC}\n"
fi
printf "\n"

# Check dependencies
check_dependencies

# Find git root directory
GIT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ $? -ne 0 ] || [ -z "$GIT_ROOT" ]; then
    printf "${RED}Error: Not in a git repository or unable to find git root${NC}\n"
    exit 1
fi

CURRENT_DIR=$(pwd)
printf "${YELLOW}Current directory: %s${NC}\n" "$CURRENT_DIR"
printf "${YELLOW}Git root directory: %s${NC}\n" "$GIT_ROOT"

# Change to git root directory for proper file path resolution
cd "$GIT_ROOT" || {
    printf "${RED}Error: Cannot change to git root directory${NC}\n"
    exit 1
}

# Get all changed files
CHANGED_FILES=$(git diff --name-only "$BASE_COMMIT" "$HEAD_COMMIT" 2>/dev/null)
git_exit_code=$?

if [ $git_exit_code -ne 0 ]; then
    printf "${RED}Error: Unable to get git diff between '$BASE_COMMIT' and '$HEAD_COMMIT'.${NC}\n"
    exit 1
fi

if [ -z "$CHANGED_FILES" ]; then
    printf "${YELLOW}No files changed between '$BASE_COMMIT' and '$HEAD_COMMIT'${NC}\n"
    exit 0
fi

printf "${GREEN}Changed files:${NC}\n"
printf "%s\n" "$CHANGED_FILES" | sed 's/^/  /'
printf "\n"

# Initialize arrays and temp files for cross-platform compatibility
PROJECT_NAMES=""
TEMP_PROJECTS=$(mktemp 2>/dev/null || echo "/tmp/projects_$")
TEMP_MAPPING=$(mktemp 2>/dev/null || echo "/tmp/mapping_$")
TEMP_CACHE=$(mktemp 2>/dev/null || echo "/tmp/cache_$")
rm -f "$TEMP_PROJECTS" "$TEMP_MAPPING" "$TEMP_CACHE"

# Cache functions for optimization
cache_get() {
    local dir="$1"
    if [ -f "$TEMP_CACHE" ]; then
        grep "^$dir|" "$TEMP_CACHE" | head -1 | cut -d'|' -f2-
    fi
}

cache_set() {
    local dir="$1"
    local project="$2"
    local path="$3"
    echo "$dir|$project|$path" >> "$TEMP_CACHE"
}

cache_check() {
    local dir="$1"
    if [ -f "$TEMP_CACHE" ]; then
        grep -q "^$dir|" "$TEMP_CACHE"
    else
        return 1
    fi
}

# Function to find project for a file
find_project_for_file() {
    local file="$1"
    local dir project_found search_levels current_dir package_path project_name
    local cached_result cached_project cached_path
    
    if [ "$DEBUG" = true ]; then
        echo "🔍 Processing file: $file"
    fi
    
    dir=$(dirname "$file")
    project_found=false
    search_levels=0
    
    # Check cache first - traverse up to find any cached directory
    current_dir="$dir"
    while [ "$current_dir" != "." ] && [ "$current_dir" != "/" ]; do
        if cache_check "$current_dir"; then
            cached_result=$(cache_get "$current_dir")
            cached_project=$(echo "$cached_result" | cut -d'|' -f1)
            cached_path=$(echo "$cached_result" | cut -d'|' -f2)
            
            if [ "$DEBUG" = true ]; then
                printf "  🚀 Cache hit! Found cached project: %s from %s\n" "$cached_project" "$cached_path"
            fi
            
            # Increment cache hit counter
            CACHE_HITS=$((CACHE_HITS + 1))
            
            # Store results using cached data
            echo "$cached_project" >> "$TEMP_PROJECTS"
            echo "$file|$cached_project|$cached_path" >> "$TEMP_MAPPING"
            project_found=true
            break
        fi
        current_dir=$(dirname "$current_dir")
    done
    
    # If not found in cache, do the normal search
    if [ "$project_found" = false ]; then
        if [ "$DEBUG" = true ]; then
            printf "  📂 Starting search from directory: %s\n" "$dir"
        fi
        
        current_dir="$dir"
        while [ "$current_dir" != "." ] && [ "$current_dir" != "/" ] && [ $search_levels -lt 15 ]; do
            package_path="$current_dir/package.json"
            
            if [ "$DEBUG" = true ]; then
                printf "  🔎 Level %d - Checking: %s" "$search_levels" "$package_path"
            fi
            
            if [ -f "$package_path" ]; then
                if [ "$DEBUG" = true ]; then
                    printf " ✅ Found!\n"
                fi
                
                project_name=$(extract_project_name "$package_path")
                
                if [ "$DEBUG" = true ]; then
                    printf "    📦 Extracted name: '%s'\n" "$project_name"
                fi
                
                if [ -n "$project_name" ] && [ "$project_name" != "null" ]; then
                    if [ "$DEBUG" = true ]; then
                        printf "    ✅ Successfully mapped: %s → %s\n" "$(basename "$file")" "$project_name"
                        printf "    💾 Caching result for future files\n"
                    fi
                    
                    # Cache this result for future files
                    cache_set "$current_dir" "$project_name" "$current_dir"
                    
                    # Store results in temp files
                    echo "$project_name" >> "$TEMP_PROJECTS"
                    echo "$file|$project_name|$current_dir" >> "$TEMP_MAPPING"
                    project_found=true
                else
                    if [ "$DEBUG" = true ]; then
                        printf "    ❌ No valid name found in package.json\n"
                    fi
                fi
                break
            else
                if [ "$DEBUG" = true ]; then
                    printf " ❌ Not found\n"
                fi
            fi
            
            current_dir=$(dirname "$current_dir")
            search_levels=$((search_levels + 1))
        done
    fi
    
    if [ "$project_found" = false ]; then
        if [ "$DEBUG" = true ]; then
            echo "  🚫 No package.json found after searching $search_levels levels"
        fi
        echo "$file|unknown|." >> "$TEMP_MAPPING"
    fi
    
    if [ "$DEBUG" = true ]; then
        echo ""
    fi
}

# Process each file
while IFS= read -r file; do
    if [ -n "$file" ]; then
        find_project_for_file "$file"
    fi
done << EOF
$CHANGED_FILES
EOF

# Process results
UNIQUE_PROJECTS=""
if [ -f "$TEMP_PROJECTS" ]; then
    UNIQUE_PROJECTS=$(sort "$TEMP_PROJECTS" | uniq)
fi

# Return to original directory
cd "$CURRENT_DIR" || true

# Show results
if [ ! -f "$TEMP_PROJECTS" ] || [ -z "$UNIQUE_PROJECTS" ]; then
    printf "${YELLOW}No projects with package.json found in changed files.${NC}\n"
    rm -f "$TEMP_PROJECTS" "$TEMP_MAPPING"
    exit 0
fi

printf "${GREEN}Found Projects:${NC}\n"
if [ -f "$TEMP_PROJECTS" ] && [ -s "$TEMP_PROJECTS" ]; then
    sort "$TEMP_PROJECTS" | uniq | while IFS= read -r project; do
        if [ -n "$project" ]; then
            echo "  📦 $project"
        fi
    done
fi

if [ -f "$TEMP_MAPPING" ]; then
    printf "\n${GREEN}File to Project Mapping:${NC}\n"
    printf "${YELLOW}%-50s %-25s %s${NC}\n" "File" "Project Name" "Project Path"
    echo -e "${YELLOW}$(printf '%*s' 50 '' | tr ' ' '-') $(printf '%*s' 25 '' | tr ' ' '-') $(printf '%*s' 20 '' | tr ' ' '-')${NC}"
    
    while IFS='|' read -r file project_name project_path; do
        if [ -n "$file" ]; then
            short_file="$file"
            if [ ${#file} -gt 47 ]; then
                short_file="...$(basename "$file")"
            fi
            
            if [ "$project_name" = "unknown" ]; then
                echo -e "${RED}$(printf '%-50s %-25s %s' "$short_file" "$project_name" "$project_path")${NC}"
            else
                printf '%-50s %-25s %s\n' "$short_file" "$project_name" "$project_path"
            fi
        fi
    done < "$TEMP_MAPPING"
fi

# Output formats
printf "\n${GREEN}Output formats:${NC}\n"

# Space-separated
printf "${GREEN}Space-separated:${NC}\n"
if [ -f "$TEMP_PROJECTS" ] && [ -s "$TEMP_PROJECTS" ]; then
    cat "$TEMP_PROJECTS" | sort | uniq | tr '\n' ' '
fi
printf "\n"

# Comma-separated
printf "${GREEN}Comma-separated:${NC}\n"
if [ -f "$TEMP_PROJECTS" ] && [ -s "$TEMP_PROJECTS" ]; then
    cat "$TEMP_PROJECTS" | sort | uniq | paste -sd ',' - 2>/dev/null || (cat "$TEMP_PROJECTS" | sort | uniq | tr '\n' ',' | sed 's/,$//')
fi

# JSON array
printf "${GREEN}JSON array:${NC}\n"
printf '['
if [ -f "$TEMP_PROJECTS" ] && [ -s "$TEMP_PROJECTS" ]; then
    first=true
    cat "$TEMP_PROJECTS" | sort | uniq | while IFS= read -r project; do
        if [ -n "$project" ]; then
            if [ "$first" = true ]; then
                printf '"%s"' "$project"
                first=false
            else
                printf ',"%s"' "$project"
            fi
        fi
    done
fi
printf ']\n'

# Environment variable
printf "\n${GREEN}Environment variable format:${NC}\n"
if [ -f "$TEMP_PROJECTS" ] && [ -s "$TEMP_PROJECTS" ]; then
    PROJECTS_LIST=$(cat "$TEMP_PROJECTS" | sort | uniq | tr '\n' ' ' | sed 's/ $//')
    if [ -n "$PROJECTS_LIST" ]; then
        echo "CHANGED_PROJECTS=\"$PROJECTS_LIST\""
    else
        echo 'CHANGED_PROJECTS=""'
    fi
else
    echo 'CHANGED_PROJECTS=""'
fi

# Show optimization statistics in debug mode
if [ "$DEBUG" = true ]; then
    total_files=$(printf "%s\n" "$CHANGED_FILES" | wc -l)
    unique_projects=$(cat "$TEMP_PROJECTS" | sort | uniq | wc -l)
    
    printf "\n${YELLOW}📊 Performance Statistics:${NC}\n"
    printf "  • Files processed: %d\n" "$total_files"
    printf "  • Unique projects found: %d\n" "$unique_projects"
    printf "  • Cache hits: %d/%d\n" "$CACHE_HITS" "$total_files"
    
    if [ -f "$TEMP_CACHE" ]; then
        cache_entries=$(wc -l < "$TEMP_CACHE" 2>/dev/null || echo "0")
        printf "  • Cache entries created: %d\n" "$cache_entries"
        
        if [ "$CACHE_HITS" -gt 0 ]; then
            efficiency=$((CACHE_HITS * 100 / total_files))
            printf "  • Cache efficiency: %d%%\n" "$efficiency"
            printf "  • Optimization: Saved %d package.json lookups\n" "$CACHE_HITS"
        fi
        
        if [ "$cache_entries" -gt 0 ]; then
            printf "\n${YELLOW}📋 Cache Contents:${NC}\n"
            cat "$TEMP_CACHE" | while IFS='|' read -r dir project path; do
                if [ -n "$dir" ]; then
                    echo "    $dir → $project"
                fi
            done
        fi
    fi
fi

# Clean up
rm -f "$TEMP_PROJECTS" "$TEMP_MAPPING" "$TEMP_CACHE"