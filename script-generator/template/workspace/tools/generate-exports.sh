#!/bin/bash
SOURCE_PATH=$1
# PACKAGE_PATH=$2

ESM_EXT=$2
COMMONJS_EXT=$3

# Set default value for ESM_EXT if not provided
ESM_EXT=${ESM_EXT:-mjs}
echo "ESM_EXT=> $ESM_EXT"
# Set default value for COMMONJS_EXT if not provided
COMMONJS_EXT=${COMMONJS_EXT:-js}
echo "COMMONJS_EXT=> $COMMONJS_EXT"

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check jq installation and provide installation instructions
check_jq() {
    if ! command_exists jq; then
        echo "Error: jq is not installed"
        echo "Please install jq first:"
        
        # Detect OS
        if [[ "$OSTYPE" == "darwin"* ]]; then
            echo "For macOS, run:"
            echo "  brew install jq"
            echo "If you don't have brew installed, install it first with:"
            echo "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        else
            # Assume Linux
            echo "For Ubuntu/Debian, run:"
            echo "  sudo apt-get update && sudo apt-get install jq"
            echo "For CentOS/RHEL, run:"
            echo "  sudo yum install jq"
            echo "For Fedora, run:"
            echo "  sudo dnf install jq"
        fi
        exit 1
    fi
}

# Check for jq installation
check_jq

# Function to generate export entry for a given path
generate_export_entry() {
    local filepath=$1
    local sourcepath=$2
    local sourcedir=$(basename "$sourcepath")
    local dir=$(dirname "$filepath")
    # Remove src/ from the beginning of the path if it exists
    local clean_path=${dir#$sourcedir/}
    
    # If the path is exactly "src", replace it with "."
    if [ "$clean_path" = $sourcedir ]; then
        clean_path="."
    else
        clean_path="./${clean_path}"
    fi
    
    # Function to clean up path (remove extra dots and slashes)
    clean_dist_path() {
        local path=$1
        # Replace multiple slashes with single slash and remove unnecessary dots
        echo "$path" | sed 's/\/\.\//\//g; s/\/\+/\//g'
    }

    # Generate paths
    local types_path=$(clean_dist_path "./dist/${clean_path}/index.d.ts")
    local import_path=$(clean_dist_path "./dist/${clean_path}/index.${ESM_EXT}")
    local require_path=$(clean_dist_path "./dist/${clean_path}/index.${COMMONJS_EXT}")

    # Generate the export entry
    cat << EOF
    "${clean_path}": {
      "types": "${types_path}",
      "import": "${import_path}",
      "require": "${require_path}"
    }
EOF
}
# echo "PWD=> $(pwd)"

# Create temporary file for the new exports
temp_exports=$(mktemp package-temp.XXXXXX)

# Generate the exports content
echo "{" > "$temp_exports"
echo "  \"exports\": {" >> "$temp_exports"

# First, check if 'src/index.ts' exists and if so, add the root export first
 rootindex=$(basename "$SOURCE_PATH")
 first=true
if [ -f "${rootindex}/index.ts" ]; then
    # Generate root export entry (".")
    generate_export_entry "${rootindex}/index.ts" "$SOURCE_PATH" >> "$temp_exports"
    if [ "$first" = true ]; then
        first=false
    fi
fi

# Find all index.ts files, excluding node_modules

while IFS= read -r file; do
    # Skip the root index.ts as it's already handled
    if [ "$file" = "${rootindex}/index.ts" ]; then
        continue
    fi

    if [ "$first" = true ]; then
        first=false
    else
        echo "," >> "$temp_exports"
    fi
    generate_export_entry "$file" "$SOURCE_PATH" >> "$temp_exports"
done < <(find $SOURCE_PATH -name "index.ts" -not -path "*/node_modules/*" | sort)

# Close the exports object
echo "  }" >> "$temp_exports"
echo "}" >> "$temp_exports"

# Check if package.json exists
if [ ! -f "package.json" ]; then
    echo "Error: package.json not found"
    rm "$temp_exports"
    exit 1
fi

# Create temporary file for the merged content
temp_merged=$(mktemp package-new.XXXXXX)

# Use jq to merge the files
# This will replace existing exports or add new ones if they don't exist
jq -s '
    .[0] as $original |
    .[1] as $new |
    $original + $new
' package.json "$temp_exports" > "$temp_merged"

# Check if jq command was successful
if [ $? -eq 0 ]; then
    # Backup original package.json
    cp package.json package.json.backup
    
    # Move merged content to package.json
    mv "$temp_merged" package.json
    
    echo "Successfully updated package.json (backup saved as package.json.backup)"
else
    echo "Error: Failed to update package.json"
fi


# Cleanup temporary files
if [ -f "$temp_exports" ]; then
    rm "$temp_exports" || echo "Warning: Failed to remove $temp_exports"
fi

if [ -f "$temp_merged" ]; then
    rm "$temp_merged" || echo "Warning: Failed to remove $temp_merged"
fi
if [ -f "package.json.backup" ]; then
    rm "package.json.backup" || echo "Warning: Failed to remove package.json.backup"
fi