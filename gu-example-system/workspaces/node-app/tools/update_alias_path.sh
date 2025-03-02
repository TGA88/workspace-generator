PACKAGE_NAME=$1
lib_folder="./lib"

# ตรวจสอบว่าโฟลเดอร์ lib มีอยู่จริง
if [ ! -d "$lib_folder" ]; then
  echo "Error: lib folder not found at $lib_folder"
  exit 1
fi



# สร้าง paths JSON
paths_json="{ \"@$PACKAGE_NAME/*\": [\"./lib/*\"]"
jest_paths_json=" '^@$PACKAGE_NAME/(.*)$': '<rootDir>/lib/\$1'"
vite_paths_json=" '@$PACKAGE_NAME':  resolve(__dirname, './lib') "
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
      jest_paths_json="$jest_paths_json,"
      vite_paths_json="$vite_paths_json,"
    fi
    
    # เพิ่ม alias path (single line)
    paths_json="$paths_json \"@$folder_name/*\": [\"./lib/$folder_name/*\"]"
    jest_paths_json="$jest_paths_json '^@$folder_name/(.*)$': '<rootDir>/lib/$folder_name/\$1'"
    vite_paths_json="$vite_paths_json '@$folder_name': resolve(__dirname, './lib/$folder_name') "
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

 npx prettier --write tsconfig.json
echo "Updated paths in tsconfig.json with only lib folder aliases"


# jest

echo $jest_paths_json

# สร้าง backup file
cp jest.config.ts jest.config.ts.bak


# สร้าง sed script แยกและบันทึกลงไฟล์
cat > sed_jest_remove.txt << EOF
/[[:space:]]*[\'"]\\^@*:*/  {
  c\\

}
EOF

cat > sed_jest_replace.txt << EOF
/[[:space:]]*moduleNameMapper:*/ {
  c\\
  moduleNameMapper: {\\
   $jest_paths_json,
}
EOF





# รัน sed ด้วย script ไฟล์ (ซึ่งสามารถรองรับ multi-line ได้)
npx prettier --write jest.config.ts
sed -f sed_jest_remove.txt jest.config.ts > jest.config.temp.ts.bak
sed -f sed_jest_replace.txt jest.config.temp.ts.bak > jest.config.temp2.ts.bak
mv jest.config.temp2.ts.bak jest.config.ts
rm jest.config.temp2.ts.bak
rm jest.config.temp.ts.bak


rm sed_jest_remove.txt
rm sed_jest_replace.txt

 npx prettier --write jest.config.ts
echo "Updated paths in jest.config.ts with only lib folder moduleNameMapper"

# ==========

# vite

echo $vite_paths_json

# สร้าง backup file
cp vite.config.ts vite.config.ts.bak


# สร้าง sed script แยกและบันทึกลงไฟล์
cat > sed_vite_remove.txt << EOF
/[[:space:]]*['"]@[^'"]*['"]:[[:space:]]*/  {
  c\\

}
EOF

cat > sed_vite_replace.txt << EOF
/[[:space:]]*alias:*/ {
  c\\
  alias: {\\
   $vite_paths_json,
}
EOF





# รัน sed ด้วย script ไฟล์ (ซึ่งสามารถรองรับ multi-line ได้)
npx prettier --write vite.config.ts
sed -f sed_vite_remove.txt vite.config.ts > vite.config.temp.ts.bak
sed -f sed_vite_replace.txt vite.config.temp.ts.bak > vite.config.temp2.ts.bak
mv vite.config.temp2.ts.bak vite.config.ts
rm vite.config.temp2.ts.bak
rm vite.config.temp.ts.bak


rm sed_vite_remove.txt
rm sed_vite_replace.txt

 npx prettier --write vite.config.ts
echo "Updated paths in vite.config.ts with only lib folder alias"
