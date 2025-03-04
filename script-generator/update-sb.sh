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

        # echo "feature_path=>$feature_path"

        
        # สร้าง alias และ path configs
        alias_config+="    '@${feature_name}': path.resolve(__dirname, '../../../libs/${feature_path}'),"
        paths_config+="      \"@${feature_name}/*\": [\"../../libs/${feature_path}*\"],"
        # alias_config+="    '@${feature_name}': path.resolve(__dirname, '../../../libs/${feature_name}/${suffix_path}'),"
        # paths_config+="      \"@${feature_name}/*\": [\"../../libs/${feature_name}/${suffix_path}*\"],"
    done < <(find "$LIBS_PATH" -maxdepth 3 -type d  \( -name "feature-*"  -o -name "ui-*-lib" -o -name "ui-components" -o -name "ui-common" \) -not -path "*/dist/*" -not -path "*/node_modules/*")
  

  # check dup tsconfig paths with existing paths
    # Convert paths_config and existing_paths to arrays for comparison
    IFS=$'\n' read -d '' -r -a paths_config_array <<< "${paths_config//,/$'\n'}"
    IFS=$'\n' read -d '' -r -a existing_paths_array <<< "${existing_paths//,/$'\n'}"

    # Create a new array for filtered existing paths
    filtered_existing_paths=()

    # Check each existing path against new paths
    for existing_path in "${existing_paths_array[@]}"; do
        existing_key=$(echo "$existing_path" | grep -o '"@[^"]*"' | head -1)
        is_duplicate=false
        
        for new_path in "${paths_config_array[@]}"; do
            new_key=$(echo "$new_path" | grep -o '"@[^"]*"' | head -1)
            if [ "$existing_key" = "$new_key" ]; then
                is_duplicate=true
                break
            fi
        done
        
        if [ "$is_duplicate" = false ] && [ -n "$existing_path" ]; then
            if [[ "$existing_path" =~ [^,]$ ]]; then
                existing_path="${existing_path},"
            fi
            filtered_existing_paths+=("$existing_path")
        fi
    done
    # Reconstruct existing_paths from filtered array
    new_existing_paths=$(IFS=$'\n'; echo "${filtered_existing_paths[*]}")
    if [ -n "$existing_paths" ] && [ -n "$paths_config" ]; then
        existing_paths="${new_existing_paths}"
    fi
# ==========

# check dup aliases with existing aliases
# Convert alias_config and existing_aliases to arrays for comparison

IFS=$'\n' read -d '' -r -a alias_config_array <<< "${alias_config//),/$'\n'}"
IFS=$'\n' read -d '' -r -a existing_aliases_array <<< "${existing_aliases}"

# Create a new array for filtered existing aliases
filtered_existing_aliases=()

# Check each existing alias against new aliases
for existing_alias in "${existing_aliases_array[@]}"; do
    
    existing_key=$(echo "$existing_alias" | grep -o "[']@[^']*[']:" | head -1)
    is_duplicate=false
    
    for new_alias in "${alias_config_array[@]}"; do
       
        new_key=$(echo "$new_alias" | grep -o "[']@[^']*[']:" | head -1)
       
        if [ "$existing_key" = "$new_key" ]; then
            is_duplicate=true
            
            break
        fi
    done
    
    if [ "$is_duplicate" = false ] && [ -n "$existing_alias" ]; then
        if [[ "$existing_alias" =~ [^,]$ ]]; then
            existing_alias="${existing_alias},"
        fi
        filtered_existing_aliases+=("$existing_alias")
    fi
done

# Reconstruct existing_aliases from filtered array
new_existing_aliases=$(IFS=$'\n'; echo "${filtered_existing_aliases[*]}")
if [ -n "$existing_aliases" ] && [ -n "$alias_config" ]; then
    existing_aliases="${new_existing_aliases}"
fi

# ==========


    # If paths_config is not empty and existing_paths is not empty
    if [ -n "$paths_config" ] && [ -n "$existing_paths" ]; then
        # Add comma to existing_paths if it doesn't end with a comma
        if [[ ! "$existing_paths" =~ ,[[:space:]]*$ ]]; then
            existing_paths="${existing_paths},"
        fi
    else
        # If paths_config is empty, remove trailing comma from existing_paths
        existing_paths=$(echo "$existing_paths" | sed 's/,[[:space:]]*$//')
    fi
    # Remove trailing comma from paths_config if it exists
    paths_config=$(echo "$paths_config" | sed 's/,$//')


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
${existing_paths}
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
#end ubdate_config_files

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

npx prettier --write  $TSCONFIG_PATH
npx prettier --write  $STORYBOOK_MAIN_PATH
update_config_files