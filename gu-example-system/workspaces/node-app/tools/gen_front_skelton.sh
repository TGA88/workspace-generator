#!/bin/bash
DEST_DIR=$1

# Validate input is not empty
if [ -z "$DEST_DIR" ]; then
   DEST_DIR='.'
fi

# Prompt user to select frontend_type
echo "Select frontend_type:"
echo "1) feature"
echo "2) ui"
read -p "Enter choice (1 or 2): " choice

case $choice in
    1)
        frontend_type="feature"
        ;;
    2)
        frontend_type="ui"
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2"
        exit 1
        ;;
esac

base_folder=$DEST_DIR
base_name=''
# Get base folder name based on frontend_type
if [ "$frontend_type" = "feature" ]; then
    read -p "Enter feature name: " feature_name
    base_name="feature-$feature_name"
elif [ "$frontend_type" = "ui" ]; then
    # Find the nearest directory containing package.json
    current_dir="$PWD"
    while [[ "$current_dir" != "/" ]]; do
        if [[ -f "$current_dir/package.json" ]]; then
            current_dir=$(basename "$current_dir")
            break
        fi
        current_dir=$(dirname "$current_dir")
    done

    if [[ "$current_dir" == "/" ]]; then
        echo "Error: No package.json found in parent directories"
        exit 1
    fi
    base_name="ui-$current_dir"
fi

# Output feature name if frontend_type is feature
if [ "$frontend_type" = "feature" ]; then
    echo "Feature name: $base_name"
fi
if [ "$frontend_type" = "ui" ]; then
    echo "UI name: $base_name"
fi

base_folder="$DEST_DIR/$base_name"



echo "Creating skeleton for frontend_type: $frontend_type"

# Create base directory structure
mkdir -p "$base_folder/components/sample"
touch "$base_folder/components/sample/index.ts"
touch "$base_folder/components/sample/sample.tsx"
touch "$base_folder/components/sample/sample.types.ts"
touch "$base_folder/components/sample/sample.stories.tsx"

# create container structure
mkdir -p "$base_folder/constainers/sample"
touch "$base_folder/constainers/sample/index.ts"
touch "$base_folder/constainers/sample/sample.tsx"
touch "$base_folder/constainers/sample/sample.types.ts"
touch "$base_folder/constainers/sample/sample.stories.tsx"

# create hooks structure
mkdir -p "$base_folder/hooks/sample"
touch "$base_folder/hooks/sample/use-sample.ts"

mkdir -p "$base_folder/hooks/sample/__test__"
touch "$base_folder/hooks/sample/__test__/use-sample.test.tsx"

mkdir -p "$base_folder/hooks/sample/functions"
touch "$base_folder/hooks/sample/functions/sample-reducer.logic.ts"
touch "$base_folder/hooks/sample/functions/simple-fn.logic.ts"

mkdir -p "$base_folder/hooks/sample/functions/__test__"
touch "$base_folder/hooks/sample/functions/__test__/sample-reducer.logic.test.ts"
touch "$base_folder/hooks/sample/functions/__test__/simple-fn.logic.test.ts"

mkdir -p "$base_folder/mocks"
touch "$base_folder/mocks/index.ts"

mkdir -p "$base_folder/types"
touch "$base_folder/types/index.ts"


echo "Skeleton structure created successfully in $base_name/"