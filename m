relative_path= '../../'
tsconfig_path="${relative_path}tsconfig.features.base.json"

# แทนที่ค่า extends ใน tsconfig.json
sed -i.bak 's|"extends": "[^"]*"|"extends": "'"$tsconfig_path"'"|' tsconfig.json

echo "Updated extends in tsconfig.json to: $tsconfig_path"


# แทนที่ค่า paths ใน tsconfig.json
relative_path= '../../'

sed -i.bak 's|"@/\*": \[[^]]*\]|"@/\*": \["'"$relative_path"'\*"\]|g' tsconfig.json

echo "Updated '@/*' paths value to ['$relative_path*'] in tsconfig.json"

# eslint
relative_path='../../'

# แทนที่เส้นทางไฟล์ที่อ้างอิงถึง root-eslint.config.mjs
sed -i.bak "s|\(\.\./\)*root-eslint\.config\.mjs|${relative_path}root-eslint.config.mjs|g" eslint.config.mjs

echo "Updated all paths to root-eslint.config.mjs with relative_path in eslint.config.mjs"

# =====

# jest.config.ts
relative_path='../../'

# แทนที่เส้นทางไฟล์ที่อ้างอิงถึง jest.config.ts
sed -i.bak "s|\(\.\./\)*jest\.config\.*|${relative_path}jest.config.|g" jest.config.ts

echo "Updated all paths to jest.config.ts with relative_path in jest.config.ts"


# สร้าง alias ใน tsconfig.features.base.json

# สร้าง JSON สำหรับ paths ใหม่
lib_folder="lib"
paths_json="{\n"
first=true

# เพิ่ม alias สำหรับโฟลเดอร์ใน lib
for folder in "$lib_folder"/*; do
  if [ -d "$folder" ]; then
  
    # เพิ่ม comma ถ้าไม่ใช่รายการแรก
    if [ "$first" = true ]; then
      first=false
    else
      paths_json="$paths_json,"
    fi
    folder_name=$(basename "$folder")
    paths_json="$paths_json\n  \"@$folder_name/*\": [\"./lib/$folder_name/*\"]"
  fi
done

# ปิด JSON object
paths_json="$paths_json\n}"

echo $paths_json


# อัปเดต tsconfig.json

echo "use sed"
  # ใช้ sed ถ้าไม่มี jq
#   sed -i.bak "s|\"paths\": {[^}]*}|\"paths\": $(echo -e "$paths_json" | sed 's/\//\\\//g')|g" tsconfig.json
  sed -i.bak "s|\"paths\": {[^}]*}|\"paths\": $(echo -e "$paths_json" | sed 's/\//\\\//g')|g" tsconfig.json

echo "Updated paths in tsconfig.json with lib folder aliases"


# วิธีที่ 2 ใช้ variable expansion ใน bash เนื่องจาก วิธีแรกมีปัญหาเรื่อง new line กับ sed

# กำหนดตำแหน่งของโฟลเดอร์ lib
lib_folder="./lib"

# ตรวจสอบว่าโฟลเดอร์ lib มีอยู่จริง
if [ ! -d "$lib_folder" ]; then
  echo "Error: lib folder not found at $lib_folder"
  exit 1
fi

# สร้าง paths JSON
paths_json="{"
first=true

# หาโฟลเดอร์ใน lib
for folder in "$lib_folder"/*; do
  if [ -d "$folder" ]; then
    folder_name=$(basename "$folder")
    
    # เพิ่ม comma ถ้าไม่ใช่รายการแรก
    if [ "$first" = true ]; then
      first=false
    else
      paths_json="$paths_json,"
    fi
    
    # เพิ่ม alias path (single line)
    paths_json="$paths_json \"@$folder_name/*\": [\"./lib/$folder_name/*\"]"
  fi
done

# ปิด JSON object
paths_json="$paths_json }"


echo $paths_json

# สร้าง backup file
cp tsconfig.json tsconfig.json.bak


# สร้าง sed script แยกและบันทึกลงไฟล์
cat > sed_script.txt << EOF
/[[:space:]]*"paths"[[:space:]]*:/ {
  c\\
  "paths": $paths_json,
  :loop
  n
  /[[:space:]]*}/!{
    d
    b loop
  }
}
EOF



# รัน sed ด้วย script ไฟล์ (ซึ่งสามารถรองรับ multi-line ได้)
sed -f sed_script.txt tsconfig.json > tsconfig.temp.json
# mv tsconfig.temp.json tsconfig.json
# rm sed_script.txt

echo "Updated paths in tsconfig.json with only lib folder aliases"

# # สร้าง sed script แยกและบันทึกลงไฟล์
# cat > sed_script.txt << EOF
# /[[:space:]]*"paths"[[:space:]]*:/ {
#   c\\
#   "paths": $paths_json,
#   :a
#   n
#   /[[:space:]]*}/!ba
# }
# EOF