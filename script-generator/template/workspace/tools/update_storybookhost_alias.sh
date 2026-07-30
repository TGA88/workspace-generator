#!/bin/bash

# update_storybookhost_alias.sh <workspace-root> <storybook-host-name>
#
# เขียน alias ของ sub-module (feature-* · ui-*) ลง `.storybook/main.ts` + `tsconfig.json` ของ host
#
# v1.7.1 — **scope ตาม `stories` glob ของ host เอง** (เดิมสแกน `libs/` ทั้งก้อน ไม่สน `$2`)
#   ของเดิม: `find "$LIBS_PATH" …` ⇒ host ของ base ใหม่ได้ alias ของ base เก่าติดมาทุกครั้งที่รัน
#   เมื่อคู่กับ `stories` glob ที่ scaffold ออกมาเป็น `libs/**` = storybook เขียวด้วย story ของ base อื่น
#   (false signal — auth-portal เจอจริงที่ P-PW.5d-1: `libs/admin-portal-lib` ว่างแต่ test-storybook เขียว)
#
#   ตัวใหม่ derive "จะสแกน lib ไหน" จาก **`stories` ของ host เอง** — ไม่ใช่ convention ชื่อ (proxy)
#   เพราะ `stories` คือที่ที่ host ประกาศอยู่แล้วว่า "ฉันครอบ lib ไหน" ⇒ 2 กลไกอ่านจากที่เดียวกัน
#   แก้ glob ที่เดียว alias ตามทันที · host เก่าที่ยังเป็น `libs/**` ได้พฤติกรรมเดิมเป๊ะ (backward-compatible)
#
# fail-closed: ไม่มี `stories` glob ที่ชี้เข้า `libs/` เลย = abort ไม่แตะไฟล์
# (root ที่ประกาศไว้แต่ยังไม่มีจริง = ปกติของ host ที่เพิ่ง scaffold → เตือนแล้วไปต่อด้วย alias ว่าง)
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

# SCAN_ROOTS/SCAN_DEPTHS = คู่ขนาน (root ตัวที่ i ใช้ maxdepth ตัวที่ i)
SCAN_ROOTS=()
SCAN_DEPTHS=()
LIBS_ABS=""

# normalize_path — ยุบ `.` / `..` แบบ lexical (ไม่ต้องมี dir จริง · ต่างจาก `cd && pwd`)
normalize_path() {
    local part out=()
    while IFS= read -r part; do
        case "$part" in
            ''|'.') ;;
            '..') [ ${#out[@]} -gt 0 ] && unset "out[$((${#out[@]}-1))]" ;;
            *) out+=("$part") ;;
        esac
    done < <(printf '%s\n' "$1" | tr '/' '\n')
    [ ${#out[@]} -eq 0 ] && { printf '/'; return; }
    printf '/%s' "${out[@]}"
}

# derive_scan_roots — อ่าน `stories: [...]` ของ host แล้วแปลงเป็น dir ที่จะ find
#   '../../../libs/portal-lib/**/feature-*/**/*.stories.@(…)'  →  <libs>/portal-lib   (maxdepth 2)
#   '../../../libs/**/feature-*/**/*.stories.@(…)'             →  <libs>              (maxdepth 3 = เดิม)
# maxdepth คิดจาก "ลึกจาก libs/ ได้ไม่เกิน 3" เท่าของเดิม → เซ็ต sub-module ที่จับได้ไม่เปลี่ยน
derive_scan_roots() {
    local sb_dir libs_abs raw g prefix part root rel depth d exists=0
    sb_dir="$(cd "$(dirname "$STORYBOOK_MAIN_PATH")" && pwd)"
    libs_abs="$(cd "$LIBS_PATH" && pwd)"
    LIBS_ABS="$libs_abs"

    # string literal ทุกตัวในบล็อก stories: [ … ]
    raw=$(awk '/stories[[:space:]]*:[[:space:]]*\[/{f=1} f{print} f&&/\]/{exit}' "$STORYBOOK_MAIN_PATH" \
          | grep -o "['\"][^'\"]*['\"]" | tr -d "\"'")

    while IFS= read -r g; do
        [ -z "$g" ] && continue
        # prefix = ส่วนหน้าสุดที่ยังไม่มี wildcard (ไม่แตะ IFS ระดับ shell — split ด้วย tr แทน)
        prefix=""
        while IFS= read -r part; do
            case "$part" in *[*?{@]*) break;; esac
            prefix="${prefix:+$prefix/}$part"
        done < <(printf '%s\n' "$g" | tr '/' '\n')
        [ -z "$prefix" ] && continue

        # normalize แบบ lexical ก่อน — ต้องตัดสิน "เล็งมาที่ libs/ ไหม" ให้ได้แม้ dir ยังไม่มีจริง
        # (ไม่งั้น glob ที่ชี้ออกนอก libs/ จะถูกนับเป็น 'ยังไม่ scaffold' แล้วรอดเส้น fail-closed ไป)
        root="$(normalize_path "$sb_dir/$prefix")"
        case "$root" in
            "$libs_abs"|"$libs_abs"/*) ;;
            *) continue;;   # glob ที่ไม่ได้ชี้เข้า libs/ (เช่น ../stories ของ host เอง) — ไม่เกี่ยวกับ alias
        esac
        exists=1            # เป็น glob ที่เล็ง libs/ จริง = host ประกาศ scope มาแล้ว
        if [ ! -d "$root" ]; then
            echo "  · stories ชี้ไปที่ '$prefix' ซึ่งยังไม่มีจริง (host เพิ่ง scaffold?) — ข้าม"
            continue
        fi

        # depth ที่เหลือ = 3 - (ระดับที่ root ลึกจาก libs/)
        rel="${root#"$libs_abs"}"; rel="${rel#/}"
        depth=3
        if [ -n "$rel" ]; then
            d=$(printf '%s' "$rel" | tr '/' '\n' | grep -c .)
            depth=$((3 - d))
        fi
        [ "$depth" -lt 1 ] && depth=1

        # dedup: ข้ามถ้ามี root เดิมที่ครอบตัวนี้อยู่แล้ว
        local seen=0 i
        for i in "${!SCAN_ROOTS[@]}"; do
            case "$root" in "${SCAN_ROOTS[$i]}"|"${SCAN_ROOTS[$i]}"/*) seen=1; break;; esac
        done
        [ "$seen" = 1 ] && continue

        SCAN_ROOTS+=("$root")
        SCAN_DEPTHS+=("$depth")
    done <<< "$raw"

    if [ "$exists" = 0 ]; then
        echo "Error: หา stories glob ที่ชี้เข้า libs/ ไม่เจอใน $STORYBOOK_MAIN_PATH" >&2
        echo "  host ต้องประกาศว่าครอบ lib ไหน เช่น:  '../../../libs/${PROJECT_NAME}-lib/**/feature-*/**/*.stories.@(js|jsx|ts|tsx)'" >&2
        echo "  (alias ถูก derive จาก stories เพื่อไม่ให้ 2 กลไกขัดกัน — ดูหัวไฟล์)" >&2
        exit 1
    fi
    echo "Scan roots (จาก stories ของ host): ${SCAN_ROOTS[*]:-(ยังไม่มี lib)}"
}

# scan_submodule_dirs — ไล่ทุก scan root (คนละ maxdepth) แล้วพ่น path ของ sub-module
scan_submodule_dirs() {
    local i
    for i in "${!SCAN_ROOTS[@]}"; do
        find "${SCAN_ROOTS[$i]}" -maxdepth "${SCAN_DEPTHS[$i]}" -type d \
            \( -name "feature-*" -o -name "ui-*" \) \
            -not -path "*/dist/*" -not -path "*/node_modules/*"
    done | sort -u
}

update_config_files() {
    local feature_dirs=()
    local alias_config=""
    local paths_config=""

    echo "Scaning features libs ..."
    # เก็บค่า config เดิมที่ "ไม่ใช่ sub-module" ไว้ (เช่น '@' · '@root' ที่ template ใส่มา)
    # ⚠️ v1.7.1: ต้องตัด **ทั้ง @feature-* และ @ui-*** ไม่ใช่แค่ feature-
    #   ของเดิมกรองแค่ "feature-" ⇒ `@ui-*` ของ base อื่นที่เคยถูกเขียนไว้จะถูกนับเป็น "ของเดิมที่ต้องเก็บ"
    #   แล้วรอดข้ามรอบไปตลอด (แม้ scan จะ scope ถูกแล้ว) — pollution ที่เขียนไปแล้วต้องล้างออกได้ด้วย
    local existing_aliases=$(sed -n '/resolve: {/,/}/p' "$STORYBOOK_MAIN_PATH" | grep '@' | grep -Ev "@(feature|ui)-")
    local existing_paths=$(sed -n '/"paths": {/,/}/p' "$TSCONFIG_PATH" | grep '@' | grep -Ev "@(feature|ui)-")





    # สร้าง configs ใหม่จาก features ใน libs
    while IFS= read -r dir; do
        feature_name=$(basename "$dir")
        feature_dirs+=("$feature_name")
        # ตัดด้วย $LIBS_ABS ที่รู้จริง ไม่ใช่ `#*libs/` (path เครื่องที่มีคำว่า libs/ อยู่ก่อนหน้าจะตัดผิด)
        feature_path=${dir#"$LIBS_ABS"/}
        
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
    # จับทุก sub-module ที่ขึ้นต้น feature- หรือ ui- (ครอบ ui-components, ui-functions, ui-state-<vendor>, ui-*-lib, ui-common)
    # ของเดิม list เฉพาะ ui-components/ui-common/ui-*-lib ทำให้ ui-functions, ui-state-redux ฯลฯ ไม่ได้ alias -> story ที่ import จากมันใน storybook พัง
    # v1.7.1: สแกนเฉพาะ root ที่ derive มาจาก `stories` ของ host (ไม่ใช่ `libs/` ทั้งก้อน) — ดูหัวไฟล์
    done < <(scan_submodule_dirs)
  

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
        echo "execute on Linux"
        # don't format or change line of code of sed command below
        sed -i -e "/alias: {/,/}/{
            /alias: {/r $temp_main
            /alias: {/,/})/d
        }" "$STORYBOOK_MAIN_PATH"
       
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
derive_scan_roots      # ต้องมาก่อน — update_config_files สแกนจาก SCAN_ROOTS ที่ตัวนี้ตั้ง
update_config_files