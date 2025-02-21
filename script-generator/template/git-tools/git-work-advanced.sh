#!/bin/bash

# ตรวจสอบว่าอยู่ในไดเรกทอรี Git หรือไม่
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "เกิดข้อผิดพลาด: ไม่ได้อยู่ในไดเรกทอรี Git"
  exit 1
fi

# ตรวจสอบว่ามี branch 'main' หรือไม่
if ! git show-ref --verify --quiet refs/heads/main; then
  # ตรวจสอบว่ามี branch 'master' หรือไม่ (สำหรับ repository เก่า)
  if git show-ref --verify --quiet refs/heads/master; then
    MAIN_BRANCH="master"
  else
    echo "เกิดข้อผิดพลาด: ไม่พบ branch 'main' หรือ 'master'"
    exit 1
  fi
else
  MAIN_BRANCH="main"
fi

# วันที่เริ่มต้น (ใช้วันเริ่มต้นของ repository ถ้าไม่ได้ระบุ)
if [ -n "$1" ]; then
  START_DATE="$1"
else
  # ใช้วันที่ของ commit แรกในโปรเจค
  START_DATE=$(git log --reverse --format=%ad --date=short | head -1)
fi

# วันที่สิ้นสุด (ใช้วันปัจจุบันถ้าไม่ได้ระบุ)
if [ -n "$2" ]; then
  END_DATE="$2"
else
  END_DATE=$(date +%Y-%m-%d)
fi

# สร้างฟังก์ชันแปลงวันที่เป็น timestamp (ทำงานได้ทั้ง Linux และ macOS)
date_to_seconds() {
  local date_str="$1"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD date)
    date -j -f "%Y-%m-%d" "$date_str" "+%s" 2>/dev/null
  else
    # Linux (GNU date)
    date -d "$date_str" +%s 2>/dev/null
  fi
}

echo "คำนวณเวลาการทำงานอย่างละเอียดของ programmer แต่ละคนบน branch '$MAIN_BRANCH'"
echo "จากวันที่: $START_DATE ถึง: $END_DATE"
echo "----------------------------------------------------------------"

# ดึงรายชื่อ programmer ทั้งหมดที่มีการ commit
PROGRAMMERS_FILE=$(mktemp)
git log --pretty=format:"%an" --since="$START_DATE" --until="$END_DATE" $MAIN_BRANCH | sort | uniq > "$PROGRAMMERS_FILE"

# สร้างไฟล์ชั่วคราวสำหรับเก็บข้อมูล
TEMP_FILE=$(mktemp)

echo "ชื่อ,จำนวน Commit,บรรทัดที่เพิ่ม,บรรทัดที่ลบ,ไฟล์ที่เปลี่ยนแปลง,วันทำงาน,ชั่วโมงโดยประมาณ" > "$TEMP_FILE"

# วนลูปผ่านแต่ละ programmer
while IFS= read -r programmer; do
  # ดึงรายการ commit ของ programmer นี้
  COMMIT_DETAILS=$(mktemp)
  git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%H" $MAIN_BRANCH > "$COMMIT_DETAILS"
  
  TOTAL_ADDITIONS=0
  TOTAL_DELETIONS=0
  TOTAL_FILES_CHANGED=0
  
  # วนลูปผ่านแต่ละ commit เพื่อนับการเปลี่ยนแปลง
  while IFS= read -r commit_hash; do
    # ดึงสถิติการเปลี่ยนแปลง
    STATS=$(git show --stat --format="" "$commit_hash" | tail -n 1)
    
    # แยกข้อมูลการเปลี่ยนแปลง
    FILES_CHANGED=$(echo "$STATS" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo "0")
    INSERTIONS=$(echo "$STATS" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
    DELETIONS=$(echo "$STATS" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
    
    # รวมสถิติ
    TOTAL_FILES_CHANGED=$((TOTAL_FILES_CHANGED + FILES_CHANGED))
    TOTAL_ADDITIONS=$((TOTAL_ADDITIONS + INSERTIONS))
    TOTAL_DELETIONS=$((TOTAL_DELETIONS + DELETIONS))
  done < "$COMMIT_DETAILS"
  
  # นับจำนวน commit
  COMMIT_COUNT=$(wc -l < "$COMMIT_DETAILS")
  
  # หาจำนวนวันที่ทำงาน (วันที่ที่มีการ commit)
  WORK_DAYS=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $MAIN_BRANCH | sort | uniq | wc -l)
  
  # ใช้ค่าเริ่มต้น 1 วันหากไม่มีวันทำงานบันทึกไว้
  if [ "$WORK_DAYS" -lt 1 ]; then
    WORK_DAYS=1
  fi
  
  # คำนวณชั่วโมงการทำงานโดยประมาณตามการเปลี่ยนแปลง
  if [ "$COMMIT_COUNT" -gt 0 ]; then
    LINE_CHANGE_FACTOR=20  # จำนวนบรรทัดต่อชั่วโมง
    FILE_CHANGE_FACTOR=0.5  # ชั่วโมงต่อไฟล์
    
    TOTAL_CHANGES=$((TOTAL_ADDITIONS + TOTAL_DELETIONS))
    
    HOURS_FROM_LINES=$(echo "scale=2; $TOTAL_CHANGES / $LINE_CHANGE_FACTOR" | bc)
    HOURS_FROM_FILES=$(echo "scale=2; $TOTAL_FILES_CHANGED * $FILE_CHANGE_FACTOR" | bc)
    
    # คำนวณชั่วโมงรวม (ใช้ค่าสูงกว่าระหว่างการคำนวณจากบรรทัดหรือไฟล์)
    if (( $(echo "$HOURS_FROM_LINES > $HOURS_FROM_FILES" | bc -l) )); then
      ESTIMATED_HOURS=$HOURS_FROM_LINES
    else
      ESTIMATED_HOURS=$HOURS_FROM_FILES
    fi
    
    # ถ้าชั่วโมงที่คำนวณได้น้อยกว่าจำนวน commit ใช้จำนวน commit แทน
    # (สมมติว่า 1 commit ใช้เวลาอย่างน้อย 1 ชั่วโมง)
    if (( $(echo "$ESTIMATED_HOURS < $COMMIT_COUNT" | bc -l) )); then
      ESTIMATED_HOURS=$COMMIT_COUNT
    fi
    
    # บันทึกข้อมูลลงในไฟล์ชั่วคราว
    ESCAPED_NAME=$(echo "$programmer" | sed 's/"/""/g')
    echo "\"$ESCAPED_NAME\",$COMMIT_COUNT,$TOTAL_ADDITIONS,$TOTAL_DELETIONS,$TOTAL_FILES_CHANGED,$WORK_DAYS,$ESTIMATED_HOURS" >> "$TEMP_FILE"
  fi
  
  # ลบไฟล์ชั่วคราว
  rm "$COMMIT_DETAILS"
done < "$PROGRAMMERS_FILE"

# เรียงลำดับตามจำนวนชั่วโมงทำงาน (มากไปน้อย)
if command -v column > /dev/null; then
  # แสดงผลในรูปแบบตาราง (ถ้ามีคำสั่ง column)
  echo "รายงานเวลาการทำงานของ programmer แต่ละคน:"
  echo "----------------------------------------------------------------"
  (head -1 "$TEMP_FILE" && tail -n +2 "$TEMP_FILE" | sort -t',' -k7 -nr) | column -t -s','
else
  # แสดงผลในรูปแบบ CSV ถ้าไม่มีคำสั่ง column
  (head -1 "$TEMP_FILE" && tail -n +2 "$TEMP_FILE" | sort -t',' -k7 -nr)
fi

# แสดงข้อมูลเพิ่มเติม - เฉลี่ยต่อวัน
echo ""
echo "ประสิทธิภาพการทำงานโดยเฉลี่ยต่อวัน:"
echo "----------------------------------------------------------------"

while IFS="," read -r name commits additions deletions files days hours; do
  # ข้ามบรรทัดหัวตาราง
  if [[ "$name" == "ชื่อ" ]]; then
    continue
  fi
  
  # ลบเครื่องหมาย quotation จากชื่อ
  CLEAN_NAME=$(echo "$name" | sed 's/^"//;s/"$//')
  
  # คำนวณค่าเฉลี่ยต่อวัน
  if [ "$days" -gt 0 ]; then
    COMMITS_PER_DAY=$(echo "scale=2; ${commits} / ${days}" | bc)
    LINES_PER_DAY=$(echo "scale=2; (${additions} + ${deletions}) / ${days}" | bc)
    HOURS_PER_DAY=$(echo "scale=2; ${hours} / ${days}" | bc)
  else
    COMMITS_PER_DAY="${commits}"
    LINES_PER_DAY="$((additions + deletions))"
    HOURS_PER_DAY="${hours}"
  fi
  
  echo "$CLEAN_NAME: $COMMITS_PER_DAY commits/วัน, $LINES_PER_DAY บรรทัด/วัน, $HOURS_PER_DAY ชั่วโมง/วัน"
done < "$TEMP_FILE"

# แสดงข้อมูลแยกตามวันในสัปดาห์
echo ""
echo "รูปแบบการทำงานตามวันในสัปดาห์:"
echo "----------------------------------------------------------------"

# สร้าง temp file สำหรับเก็บข้อมูลวันในสัปดาห์
WEEKDAY_FILE=$(mktemp)
echo "ชื่อ,จันทร์,อังคาร,พุธ,พฤหัสบดี,ศุกร์,เสาร์,อาทิตย์,รวม" > "$WEEKDAY_FILE"

while IFS= read -r programmer; do
  # นับจำนวน commit ในแต่ละวัน
  MON_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%u" $MAIN_BRANCH | grep -c "^1$")
  TUE_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%u" $MAIN_BRANCH | grep -c "^2$")
  WED_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%u" $MAIN_BRANCH | grep -c "^3$")
  THU_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%u" $MAIN_BRANCH | grep -c "^4$")
  FRI_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%u" $MAIN_BRANCH | grep -c "^5$")
  SAT_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%u" $MAIN_BRANCH | grep -c "^6$")
  SUN_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%u" $MAIN_BRANCH | grep -c "^7$")
  
  TOTAL_COUNT=$((MON_COUNT + TUE_COUNT + WED_COUNT + THU_COUNT + FRI_COUNT + SAT_COUNT + SUN_COUNT))
  
  if [ "$TOTAL_COUNT" -gt 0 ]; then
    ESCAPED_NAME=$(echo "$programmer" | sed 's/"/""/g')
    echo "\"$ESCAPED_NAME\",$MON_COUNT,$TUE_COUNT,$WED_COUNT,$THU_COUNT,$FRI_COUNT,$SAT_COUNT,$SUN_COUNT,$TOTAL_COUNT" >> "$WEEKDAY_FILE"
  fi
done < "$PROGRAMMERS_FILE"

# แสดงผลในรูปแบบตาราง
if command -v column > /dev/null; then
  (head -1 "$WEEKDAY_FILE" && tail -n +2 "$WEEKDAY_FILE" | sort -t',' -k9 -nr) | column -t -s','
else
  (head -1 "$WEEKDAY_FILE" && tail -n +2 "$WEEKDAY_FILE" | sort -t',' -k9 -nr)
fi

# วิเคราะห์ช่วงเวลาที่มีการ commit มากที่สุด
echo ""
echo "ช่วงเวลาที่มีการ commit มากที่สุด:"
echo "----------------------------------------------------------------"

# สร้าง temp file สำหรับเก็บข้อมูลช่วงเวลา
HOUR_FILE=$(mktemp)
echo "ชื่อ,เช้า(6-12),บ่าย(12-18),เย็น(18-24),ดึก(0-6),รวม" > "$HOUR_FILE"

while IFS= read -r programmer; do
  # นับจำนวน commit ในแต่ละช่วงเวลา
  MORNING_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%H" $MAIN_BRANCH | awk '{ if ($1 >= 6 && $1 < 12) print $1 }' | wc -l)
  AFTERNOON_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%H" $MAIN_BRANCH | awk '{ if ($1 >= 12 && $1 < 18) print $1 }' | wc -l)
  EVENING_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%H" $MAIN_BRANCH | awk '{ if ($1 >= 18 && $1 < 24) print $1 }' | wc -l)
  NIGHT_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=format:"%H" $MAIN_BRANCH | awk '{ if ($1 >= 0 && $1 < 6) print $1 }' | wc -l)
  
  TOTAL_COUNT=$((MORNING_COUNT + AFTERNOON_COUNT + EVENING_COUNT + NIGHT_COUNT))
  
  if [ "$TOTAL_COUNT" -gt 0 ]; then
    ESCAPED_NAME=$(echo "$programmer" | sed 's/"/""/g')
    echo "\"$ESCAPED_NAME\",$MORNING_COUNT,$AFTERNOON_COUNT,$EVENING_COUNT,$NIGHT_COUNT,$TOTAL_COUNT" >> "$HOUR_FILE"
  fi
done < "$PROGRAMMERS_FILE"

# แสดงผลในรูปแบบตาราง
if command -v column > /dev/null; then
  (head -1 "$HOUR_FILE" && tail -n +2 "$HOUR_FILE" | sort -t',' -k6 -nr) | column -t -s','
else
  (head -1 "$HOUR_FILE" && tail -n +2 "$HOUR_FILE" | sort -t',' -k6 -nr)
fi

# แสดงสรุปโครงการ
echo ""
echo "สรุปรวมโครงการ:"
echo "----------------------------------------------------------------"

TOTAL_COMMITS=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%H" $MAIN_BRANCH | wc -l)
TOTAL_AUTHORS=$(wc -l < "$PROGRAMMERS_FILE")

START_SECONDS=$(date_to_seconds "$START_DATE")
END_SECONDS=$(date_to_seconds "$END_DATE")

if [ -n "$START_SECONDS" ] && [ -n "$END_SECONDS" ]; then
  TOTAL_DAYS=$(( (END_SECONDS - START_SECONDS) / 86400 + 1 ))
else
  # ถ้าคำนวณไม่ได้ ใช้การนับจำนวนวันแทน
  TOTAL_DAYS=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $MAIN_BRANCH | sort | uniq | wc -l)
fi

ACTIVE_DAYS=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $MAIN_BRANCH | sort | uniq | wc -l)

echo "ระยะเวลาโครงการ: $TOTAL_DAYS วัน (ทำงานจริง $ACTIVE_DAYS วัน)"
echo "จำนวน programmer: $TOTAL_AUTHORS คน"
echo "จำนวน commit ทั้งหมด: $TOTAL_COMMITS commits"
if [ "$ACTIVE_DAYS" -gt 0 ]; then
  echo "ค่าเฉลี่ย: $(echo "scale=2; $TOTAL_COMMITS / $ACTIVE_DAYS" | bc) commits/วัน"
fi

# สรุปเพิ่มเติมเกี่ยวกับภาพรวมรายบุคคล
echo ""
echo "สรุปร้อยละการมีส่วนร่วมในโครงการ (ตามจำนวน commit):"
echo "----------------------------------------------------------------"

# คำนวณเปอร์เซ็นต์การมีส่วนร่วมของแต่ละคน
CONTRIBUTION_FILE=$(mktemp)

while IFS= read -r programmer; do
  COMMIT_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%H" $MAIN_BRANCH | wc -l)
  
  if [ "$TOTAL_COMMITS" -gt 0 ] && [ "$COMMIT_COUNT" -gt 0 ]; then
    PERCENTAGE=$(echo "scale=2; ($COMMIT_COUNT * 100) / $TOTAL_COMMITS" | bc)
    echo "$programmer,$PERCENTAGE,$COMMIT_COUNT" >> "$CONTRIBUTION_FILE"
  fi
done < "$PROGRAMMERS_FILE"

# แสดงผลเรียงตามเปอร์เซ็นต์
if command -v column > /dev/null; then
  echo "ชื่อ                  เปอร์เซ็นต์  จำนวน Commit"
  echo "----------------------------------------------------------------"
  sort -t',' -k2 -nr "$CONTRIBUTION_FILE" | while IFS="," read -r name percentage commits; do
    printf "%-20s  %6s%%     %5s\n" "$name" "$percentage" "$commits"
  done
else
  echo "ชื่อ,เปอร์เซ็นต์,จำนวน Commit"
  sort -t',' -k2 -nr "$CONTRIBUTION_FILE" | while IFS="," read -r name percentage commits; do
    echo "$name,$percentage%,$commits"
  done
fi

# ลบไฟล์ชั่วคราว
rm "$TEMP_FILE"
rm "$PROGRAMMERS_FILE"
rm "$WEEKDAY_FILE"
rm "$HOUR_FILE"
rm "$CONTRIBUTION_FILE"

echo ""
echo "หมายเหตุ: การคำนวณนี้เป็นเพียงการประมาณการณ์เบื้องต้นโดยอ้างอิงจากการเปลี่ยนแปลงในแต่ละ commit"
echo "ตัวเลขนี้อาจคลาดเคลื่อนจากเวลาทำงานจริงขึ้นอยู่กับความซับซ้อนของโค้ด การทดสอบ และปัจจัยอื่นๆ"