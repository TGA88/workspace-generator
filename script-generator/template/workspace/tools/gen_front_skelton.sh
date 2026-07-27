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

# โครงตาม developer-handbook: frontend-structure §3 (pages/ + logic/ — เทมเพลตเดิมเรียก containers/ + functions/)
# stories อยู่ __stories__/ ข้างของที่มัน demo · tests อยู่ __test__/ ข้างของที่มันเทส

# components — FEATURE-LEVEL: ใช้ข้ามหน้า (page-private อยู่ pages/<page>/components/)
mkdir -p "$base_folder/components/sample/__stories__"
touch "$base_folder/components/sample/sample.tsx"
touch "$base_folder/components/sample/sample.type.ts"
touch "$base_folder/components/sample/__stories__/sample.stories.tsx"

# hooks — 1 hook = สมองของ component ที่มี state (ไฟล์แบน hook-*.ts)
mkdir -p "$base_folder/hooks/__test__"
touch "$base_folder/hooks/hook-sample.ts"
touch "$base_folder/hooks/__test__/hook-sample.test.tsx"

# logic — pure function ระดับ feature (เดิมซ่อนอยู่ hooks/*/functions/)
mkdir -p "$base_folder/logic/__test__"
touch "$base_folder/logic/sample-fn.ts"
touch "$base_folder/logic/__test__/sample-fn.test.ts"

mkdir -p "$base_folder/types"
touch "$base_folder/types/index.ts"

if [ "$frontend_type" = "feature" ]; then
    # pages — entry-point ของ feature (host เอาไป mount เป็น 1 หน้า)
    mkdir -p "$base_folder/pages/sample/__stories__"
    mkdir -p "$base_folder/pages/sample/components"
    touch "$base_folder/pages/sample/sample.page.tsx"
    touch "$base_folder/pages/sample/__stories__/sample.page.stories.tsx"

    # mocks — MSW 3 ไฟล์ต่อ feature (storybook-testing §0)
    mkdir -p "$base_folder/mocks"
    touch "$base_folder/mocks/handlers.ts"
    touch "$base_folder/mocks/browser.ts"
    touch "$base_folder/mocks/server.ts"
fi

# main.ts — public surface ของ folder นี้ (feature: export เฉพาะ page + type)
touch "$base_folder/main.ts"


echo "Skeleton structure created successfully in $base_name/"
echo ""
echo "ขั้นต่อไป (อย่าลืม):"
echo "  1. เพิ่ม exports entry './$base_name/*' ใน package.json ของ lib — หรือรัน: pnpm gen:exports"
echo "  2. รัน: pnpm update:alias-paths && pnpm update:config  (ทุกครั้งที่เพิ่ม/ลบ sub-module)"