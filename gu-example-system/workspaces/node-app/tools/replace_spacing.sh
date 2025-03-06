#!/bin/bash

# Create a temporary file for sed operations
touch temp_replace.txt

# Function to generate sed commands for a specific property
generate_sed_commands() {
    local property=$1
    local values=(
        "0" "px" "0.5" "1"
        "2" "3" "4" "5" "6" "8"
        "10" "12" "16" "20" "24" "32"
        "40" "48" "64"
    )
    
    for value in "${values[@]}"; do
        # Handle special cases first
        if [ "$value" = "0" ]; then
            echo "s/${property}-0/${property}-b4-0/g"
        elif [ "$value" = "px" ]; then
            echo "s/${property}-px/${property}-b4-px/g"
        else
            echo "s/${property}-${value}/${property}-b4-${value}/g"
        fi
    done
}

# List of Tailwind spacing-related properties
properties=(
    "p" "px" "py" "pt" "pr" "pb" "pl"    # Padding
    "m" "mx" "my" "mt" "mr" "mb" "ml"    # Margin
    "gap" "gap-x" "gap-y"                # Gap
    "space-x" "space-y"                  # Space Between
    "w" "h"                              # Width and Height
    "max-w" "max-h"                      # Max Width and Height
    "min-w" "min-h"                      # Min Width and Height
)

# Generate all sed commands
for property in "${properties[@]}"; do
    generate_sed_commands "$property" >> temp_replace.txt
done

# Add commands for percentage and viewport-based values
echo "s/\([pmwh]\|gap\|space-[xy]\)-full/\1-b4-full/g" >> temp_replace.txt
echo "s/\([pmwh]\|gap\|space-[xy]\)-screen/\1-b4-screen/g" >> temp_replace.txt

# Find all TSX files recursively and apply the replacements
find . -name "*.tsx" -type f | while read -r file; do
    echo "Processing: $file"
    # Create a backup of the original file
    cp "$file" "${file}.bak"
    # Apply all replacements from the temporary file
    sed -i -f temp_replace.txt "$file"
done

# Cleanup
rm temp_replace.txt

echo "Replacement complete. Backup files have been created with .bak extension"

# Optional: Show a summary of changes
echo -e "\nFiles modified:"
find . -name "*.tsx.bak" | sed 's/\.bak$//'