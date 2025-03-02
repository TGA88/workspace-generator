
# ตำแหน่งปัจจุบัน
current_dir=$(pwd)
# ค้นหา nx.json
search_dir="$current_dir"
while [[ "$search_dir" != "/" ]]; do
  if [[ -f "$search_dir/nx.json" ]]; then
    nx_dir="$search_dir"
    break
  fi
  search_dir=$(dirname "$search_dir")
done

if [[ -z "$nx_dir" ]]; then
  echo "nx.json not found"
  exit 1
fi

# คำนวณ relative path
relative_path=""
temp_dir="$current_dir"
while [[ "$temp_dir" != "$nx_dir" && "$temp_dir" != "/" ]]; do
  relative_path="../$relative_path"
  temp_dir=$(dirname "$temp_dir")
done

echo "Relative path to nx.json: $relative_path"


# Check if tsconfig.json exists
if [[  -f "tsconfig.json" ]]; then
    # echo "tsconfig.json not found in current directory"
 
    # # update extends ใน tsconfig.json
    # tsconfig_path="${relative_path}tsconfig.features.base.json"

    # # แทนที่ค่า extends ใน tsconfig.json
    # sed -i.bak 's|"extends": "[^"]*"|"extends": "'"$tsconfig_path"'"|' tsconfig.json

    # echo "Updated extends in tsconfig.json to: $tsconfig_path"
    # แทนที่เส้นทางไฟล์ที่อ้างอิงถึง root-eslint.config.mjs
    sed -i.bak "s|\(\.\./\)*tsconfig\.*|${relative_path}tsconfig.|g" tsconfig.json

    echo "Updated all paths to tsconfig.json with relative_path in tsconfig.json"
fi

if [[  -f "tsconfig.build.json" ]]; then
    sed -i.bak "s|\(\.\./\)*tsconfig\.*|${relative_path}tsconfig.|g" tsconfig.build.json

    echo "Updated all paths to tsconfig.build.json with relative_path in tsconfig.json"
fi


# ==========
# eslint
if [[  -f "eslint.config.mjs" ]]; then
    # แทนที่เส้นทางไฟล์ที่อ้างอิงถึง root-eslint.config.mjs
    sed -i.bak "s|\(\.\./\)*root-eslint\.config\.mjs|${relative_path}root-eslint.config.mjs|g" eslint.config.mjs

    echo "Updated all paths to root-eslint.config.mjs with relative_path in eslint.config.mjs"
fi
# ==========

# jest
if [[  -f "jest.config.ts" ]]; then
    # แทนที่เส้นทางไฟล์ที่อ้างอิงถึง jest.config.ts
    sed -i.bak "s|\(\.\./\)*jest\.config\.*|${relative_path}jest.config.|g" jest.config.ts

    echo "Updated all paths to jest.config.ts with relative_path in jest.config.ts"
fi

# package.json
if [[  -f "package.json" ]]; then
    # แทนที่เส้นทางไฟล์ที่อ้างอิงถึง jest.config.ts
    sed -i.bak "s|\(\.\./\)*tools*|${relative_path}tools|g" package.json
    sed -i.bak "s|\(\.\./\)*coverage/|${relative_path}coverage/|g" package.json

    echo "Updated all paths to package.json with relative_path in package.json"
fi