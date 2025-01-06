#!/bin/bash

LOCATION=$1


# find $LOCATION -name "lcov.info"
echo "pwd=> $(pwd)"

ResultList=$(find $LOCATION -name "lcov.info")

# รวมไฟล์ coverage1.xml และ coverage2.xml เข้าด้วยกันเป็น coverage.db
result_string=""
# for (( i=0; i<${#ResultList[@]}; i++ )); do
#     P=$((i+1))
#     result_string="$result_string package$P=${ResultList[$i]}"
# done

for file in $ResultList; do
  # ทำอะไรบางอย่างกับไฟล์แต่ละไฟล์
  echo "Processing file: $file"

  # ${file#*coverage/} จะตัดทุกอักษรจากจุดเริ่มต้นจนถึง "coverage/" ออก
  name=${file#*coverage/}
  echo "name:$name"
  
  loc=$(echo $name | sed 's/lcov.info//')
  echo "loc:$loc"

  tmp_loc=$(echo $file | sed 's/lcov.info/lcov.tmp/')
   old_value="^SF:"
   new_value="SF:"$loc
   echo "new_value:$new_value"
   new_val=$(echo $new_value | sed -E 's/\//\\\//g')
   echo "var new_val = $new_val"

   echo "echo sed 's/$old_value/$new_val/g' $file > $tmp_loc"
   sed "s/$old_value/$new_val/g" $file > $tmp_loc
   echo "mv $tmp_loc $file"
   mv $tmp_loc $file

done



echo "$result_string"

# ขึ้นตอนใช้ script 
# run test ทุกตัว ใน workspace
#  cd fos-psc-system
#  run pnpm test:all
# bash ../build-script/gen_lcov_path.sh coverage
# ได้ผลลัพใน terminal แล้ว ลบ , ตัวสุดท้ายออกด้วย