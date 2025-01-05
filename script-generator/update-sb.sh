#!/bin/bash

# script-generator/update-sb-config.sh
WORKSPACE_DIR=$1
PROJECT_NAME=$2
PROJECT_LAYER='storybook-host'
SYSTEM_DIR='node-app'

# กำหนด path ที่จะใช้
WORKSPACE_PATH="$WORKSPACE_DIR/workspaces/$SYSTEM_DIR"
LIBS_PATH="$WORKSPACE_PATH/libs"
STORYBOOK_MAIN_PATH="$WORKSPACE_PATH/$PROJECT_LAYER/$PROJECT_NAME/.storybook/main.ts"
TSCONFIG_PATH="$WORKSPACE_PATH/$PROJECT_LAYER/$PROJECT_NAME/tsconfig.json"
PROJECT_PATH="$WORKSPACE_PATH/$PROJECT_LAYER/$PROJECT_NAME"

update_config_files() {
    local feature_dirs=()
    local alias_config=""
    local paths_config=""

    echo "Scaning features libs ..."
    # เก็บค่า non-feature configs เดิม
    local existing_aliases=$(sed -n '/resolve: {/,/}/p' "$STORYBOOK_MAIN_PATH" | grep '@' | grep -v "feature-")
    local existing_paths=$(sed -n '/"paths": {/,/}/p' "$TSCONFIG_PATH" | grep '@' | grep -v "feature-")

    # สร้าง configs ใหม่จาก features ใน libs
    while IFS= read -r dir; do
        feature_name=$(basename "$dir")
        feature_dirs+=("$feature_name")
        feature_path=${dir#*libs/}
        
        if [ -f "$dir/package.json" ]; then
        # ถ้าเป็น feature_name project level ให้อ้างถึง folder lib 
            feature_path=${feature_path}/'lib/'
        else    
        # ถ้าเป็น feature_name subfolder ของ project ให้อ้างถึง folder ตัวเอง
            feature_path=${feature_path}/
        fi

        echo "feature_path=>$feature_path"

        
        # สร้าง alias และ path configs
        alias_config+="    '@${feature_name}': path.resolve(__dirname, '../../../libs/${feature_path}'),"
        paths_config+="      \"@${feature_name}/*\": [\"../../libs/${feature_path}*\"],"
        # alias_config+="    '@${feature_name}': path.resolve(__dirname, '../../../libs/${feature_name}/${suffix_path}'),"
        # paths_config+="      \"@${feature_name}/*\": [\"../../libs/${feature_name}/${suffix_path}*\"],"
    done < <(find "$LIBS_PATH" -maxdepth 3 -type d  \( -name "feature-*" -o -name "ui-components" -o -name "ui-common" \) -not -path "*/dist/*" -not -path "*/node_modules/*")
  # กำหนด path สำหรับ temporary files
    local temp_main="$PROJECT_PATH/temp_main.ts"
    local temp_tsconfig="$PROJECT_PATH/temp_tsconfig.json"


    # สร้าง temporary files
    cat > "$temp_main" << EOF
      alias: {
      ${existing_aliases}
      ${alias_config}
      }
EOF

    cat > "$temp_tsconfig" << EOF
    "paths": {
${existing_paths},
${paths_config}
    },
EOF


    # Update files
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # MacOS
        sed -i '' -e "/alias: {/,/}/{
            /alias: {/r $temp_main
            /alias: {/,/})/d
        }" "$STORYBOOK_MAIN_PATH"

        sed -i '' -e "/\"paths\": {/,/}/{
            /\"paths\": {/r $temp_tsconfig
            /\"paths\": {/,/}/d
        }" "$TSCONFIG_PATH"
    else
        # Linux
        sed -i -e "/alias: {/,/}/{ /alias: {/r $temp_main; /alias: {/,/}/d; }" "$STORYBOOK_MAIN_PATH"
       
        sed -i -e "/\"paths\": {/,/}/{
            /\"paths\": {/r $temp_tsconfig
            /\"paths\": {/,/}/d
        }" "$TSCONFIG_PATH"
    fi





  
    # Clean up temporary files
    rm "$temp_main" "$temp_tsconfig"

    echo "features is added to storybook"

    # Format files with prettier
    echo "Formatting updated files..."
    npx prettier --write "$STORYBOOK_MAIN_PATH" "$TSCONFIG_PATH"

    echo "Updated and formatted configuration files."
    echo "Current feature directories:"
    printf '%s\n' "${feature_dirs[@]}"
}

# ตรวจสอบว่า prettier ถูกติดตั้งหรือไม่
if ! command -v npx &> /dev/null; then
    echo "Error: npx is not installed. Please install Node.js and npm first."
    exit 1
fi

# ตรวจสอบ paths
if [ ! -d "$LIBS_PATH" ]; then
    echo "Error: Libs directory not found at $LIBS_PATH"
    exit 1
fi

if [ ! -f "$STORYBOOK_MAIN_PATH" ]; then
    echo "Error: Storybook main.ts not found at $STORYBOOK_MAIN_PATH"
    exit 1
fi

if [ ! -f "$TSCONFIG_PATH" ]; then
    echo "Error: tsconfig.json not found at $TSCONFIG_PATH"
    exit 1
fi

update_config_files