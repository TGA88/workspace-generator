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

echo "คำนวณเวลาการทำงานของ programmer แต่ละคนบน branch '$MAIN_BRANCH'"
echo "จากวันที่: $START_DATE ถึง: $END_DATE"
echo "----------------------------------------------------------------"

# ดึงรายชื่อ programmer ทั้งหมดที่มีการ commit
PROGRAMMERS_FILE=$(mktemp)
git log --pretty=format:"%an" --since="$START_DATE" --until="$END_DATE" $MAIN_BRANCH | sort | uniq > "$PROGRAMMERS_FILE"

# สร้างไฟล์ชั่วคราวสำหรับเก็บข้อมูล
TEMP_FILE=$(mktemp)

echo "ชื่อ,จำนวน Commit,วันแรกที่ Commit,วันล่าสุดที่ Commit,ช่วงเวลาทำงาน (วัน),เวลาเฉลี่ยระหว่าง Commit (ชั่วโมง)" > "$TEMP_FILE"

# วนลูปผ่านแต่ละ programmer
while IFS= read -r programmer; do
  # นับจำนวน commit
  COMMIT_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%h" $MAIN_BRANCH | wc -l)
  
  # หาวันแรกที่ commit
  FIRST_COMMIT_DATE=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --reverse --pretty=format:"%ad" --date=short $MAIN_BRANCH | head -1)
  
  # หาวันล่าสุดที่ commit
  LAST_COMMIT_DATE=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $MAIN_BRANCH | head -1)
  
  # คำนวณช่วงเวลาทำงาน (วัน)
  if [ -n "$FIRST_COMMIT_DATE" ] && [ -n "$LAST_COMMIT_DATE" ]; then
    FIRST_COMMIT_SECONDS=$(date_to_seconds "$FIRST_COMMIT_DATE")
    LAST_COMMIT_SECONDS=$(date_to_seconds "$LAST_COMMIT_DATE")
    
    if [ -n "$FIRST_COMMIT_SECONDS" ] && [ -n "$LAST_COMMIT_SECONDS" ]; then
      WORK_PERIOD_DAYS=$(( (LAST_COMMIT_SECONDS - FIRST_COMMIT_SECONDS) / 86400 ))
      
      # ป้องกันค่าติดลบ
      if [ "$WORK_PERIOD_DAYS" -lt 0 ]; then
        WORK_PERIOD_DAYS=0
      fi
    else
      WORK_PERIOD_DAYS=0
    fi
  else
    WORK_PERIOD_DAYS=0
  fi
  
  # หาเวลาเฉลี่ยระหว่าง commit (ชั่วโมง)
  if [ "$COMMIT_COUNT" -gt 1 ]; then
    # ดึงรายการ timestamp ของ commit ทั้งหมด
    COMMIT_TIMESTAMPS_FILE=$(mktemp)
    git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%at" $MAIN_BRANCH > "$COMMIT_TIMESTAMPS_FILE"
    
    # คำนวณเวลาเฉลี่ยระหว่าง commit
    TOTAL_DIFF=0
    PREV_TIMESTAMP=""
    COUNT=0
    
    while IFS= read -r timestamp; do
      if [ -n "$PREV_TIMESTAMP" ]; then
        DIFF=$((PREV_TIMESTAMP - timestamp))
        # เพิ่มค่าต่างเฉพาะกรณีที่ห่างกันไม่เกิน 24 ชั่วโมง (86400 วินาที)
        if [ "$DIFF" -gt 0 ] && [ "$DIFF" -lt 86400 ]; then
          TOTAL_DIFF=$((TOTAL_DIFF + DIFF))
          COUNT=$((COUNT + 1))
        fi
      fi
      PREV_TIMESTAMP=$timestamp
    done < "$COMMIT_TIMESTAMPS_FILE"
    
    rm "$COMMIT_TIMESTAMPS_FILE"
    
    if [ "$COUNT" -gt 0 ]; then
      AVG_HOURS=$(echo "scale=2; $TOTAL_DIFF / $COUNT / 3600" | bc)
    else
      AVG_HOURS="N/A"
    fi
  else
    AVG_HOURS="N/A"
  fi
  
  # บันทึกข้อมูลลงในไฟล์ชั่วคราว
  ESCAPED_NAME=$(echo "$programmer" | sed 's/"/""/g')
  echo "\"$ESCAPED_NAME\",$COMMIT_COUNT,$FIRST_COMMIT_DATE,$LAST_COMMIT_DATE,$WORK_PERIOD_DAYS,$AVG_HOURS" >> "$TEMP_FILE"
done < "$PROGRAMMERS_FILE"

# เรียงลำดับตามจำนวน commit (มากไปน้อย)
if command -v column > /dev/null; then
  # แสดงผลในรูปแบบตาราง (ถ้ามีคำสั่ง column)
  echo "รายงานเวลาการทำงานของ programmer แต่ละคน:"
  echo "----------------------------------------------------------------"
  (head -1 "$TEMP_FILE" && tail -n +2 "$TEMP_FILE" | sort -t',' -k2 -nr) | column -t -s','
else
  # แสดงผลในรูปแบบ CSV ถ้าไม่มีคำสั่ง column
  (head -1 "$TEMP_FILE" && tail -n +2 "$TEMP_FILE" | sort -t',' -k2 -nr)
fi

# แสดงข้อมูลเพิ่มเติม - จำนวน commit ต่อวัน
echo ""
echo "จำนวน commit ต่อวันของแต่ละ programmer:"
echo "----------------------------------------------------------------"

while IFS= read -r programmer; do
  COMMIT_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%h" $MAIN_BRANCH | wc -l)
  
  if [ "$COMMIT_COUNT" -gt 0 ]; then
    FIRST_COMMIT_DATE=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --reverse --pretty=format:"%ad" --date=short $MAIN_BRANCH | head -1)
    LAST_COMMIT_DATE=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $MAIN_BRANCH | head -1)
    
    # คำนวณช่วงเวลาทำงาน (วัน)
    if [ -n "$FIRST_COMMIT_DATE" ] && [ -n "$LAST_COMMIT_DATE" ]; then
      FIRST_COMMIT_SECONDS=$(date_to_seconds "$FIRST_COMMIT_DATE")
      LAST_COMMIT_SECONDS=$(date_to_seconds "$LAST_COMMIT_DATE")
      
      if [ -n "$FIRST_COMMIT_SECONDS" ] && [ -n "$LAST_COMMIT_SECONDS" ]; then
        WORK_PERIOD_DAYS=$(( (LAST_COMMIT_SECONDS - FIRST_COMMIT_SECONDS) / 86400 + 1 ))
        
        # ป้องกันค่าติดลบหรือศูนย์
        if [ "$WORK_PERIOD_DAYS" -lt 1 ]; then
          WORK_PERIOD_DAYS=1
        fi
      else
        WORK_PERIOD_DAYS=1
      fi
    else
      WORK_PERIOD_DAYS=1
    fi
    
    # คำนวณจำนวน commit ต่อวัน
    COMMITS_PER_DAY=$(echo "scale=2; $COMMIT_COUNT / $WORK_PERIOD_DAYS" | bc)
    
    echo "$programmer: $COMMITS_PER_DAY commits/วัน (รวม $COMMIT_COUNT commits ใน $WORK_PERIOD_DAYS วัน)"
  fi
done < "$PROGRAMMERS_FILE"

# สร้างรายงานชั่วโมงการทำงานโดยประมาณ
echo ""
echo "ชั่วโมงการทำงานโดยประมาณของแต่ละ programmer:"
echo "----------------------------------------------------------------"

while IFS= read -r programmer; do
  # นับจำนวน commit
  COMMIT_COUNT=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%h" $MAIN_BRANCH | wc -l)
  
  if [ "$COMMIT_COUNT" -gt 0 ]; then
    # หาวันที่ทำงาน (วันที่ที่มีการ commit)
    WORK_DAYS=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $MAIN_BRANCH | sort | uniq | wc -l)
    
    # คำนวณชั่วโมงการทำงานโดยประมาณ (สมมติว่า 1 commit = 1 ชั่วโมง และวันละไม่เกิน 8 ชั่วโมง)
    ESTIMATED_HOURS_PER_COMMIT=1
    TOTAL_HOURS=$((COMMIT_COUNT * ESTIMATED_HOURS_PER_COMMIT))
    
    echo "$programmer: ประมาณ $TOTAL_HOURS ชั่วโมง (จาก $COMMIT_COUNT commits ใน $WORK_DAYS วันทำงาน)"
  fi
done < "$PROGRAMMERS_FILE"

# สรุปโครงการ
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

# ลบไฟล์ชั่วคราว
rm "$TEMP_FILE"
rm "$PROGRAMMERS_FILE"

echo ""
echo "หมายเหตุ: การคำนวณนี้เป็นเพียงการประมาณการณ์เบื้องต้นโดยอ้างอิงจากประวัติการ commit เท่านั้น"
echo "เวลาจริงในการทำงานอาจแตกต่างกันไปขึ้นอยู่กับความซับซ้อนของงานและปัจจัยอื่นๆ"