PACKAGE_NAME=$1
lib_folder="./lib"

# ตรวจสอบว่าโฟลเดอร์ lib มีอยู่จริง
if [ ! -d "$lib_folder" ]; then
  echo "Error: lib folder not found at $lib_folder"
  exit 1
fi



# สร้าง paths JSON
paths_json="{ \"@$PACKAGE_NAME/*\": [\"./lib/*\"]"
first=false


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
cat > sed_remove.txt << EOF
/[[:space:]]*"paths"[[:space:]]*:[[:space:]]*{/,/}/ {
  c\\

}
EOF

cat > sed_replace.txt << EOF
/[[:space:]]*"compilerOptions"[[:space:]]*:/ {
  c\\
  "compilerOptions": {\\
    "paths": $paths_json,
}
EOF





# รัน sed ด้วย script ไฟล์ (ซึ่งสามารถรองรับ multi-line ได้)
sed -f sed_remove.txt tsconfig.json > tsconfig.temp.json
sed -f sed_replace.txt tsconfig.temp.json > tsconfig.temp2.json
mv tsconfig.temp2.json tsconfig.json
rm tsconfig.temp.json
# rm sed_remove.txt
rm sed_remove.txt
rm sed_replace.txt

echo "Updated paths in tsconfig.json with only lib folder aliases"
