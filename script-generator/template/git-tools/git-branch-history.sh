#!/bin/bash

# ตรวจสอบว่าอยู่ในไดเรกทอรี Git หรือไม่
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo "เกิดข้อผิดพลาด: ไม่ได้อยู่ในไดเรกทอรี Git"
  exit 1
fi

# กำหนดค่าเริ่มต้นและประมวลผลตัวเลือก
BRANCH=""
START_DATE=""
END_DATE=""
MAX_HOURS_PER_DAY=10
TIME_BETWEEN_COMMITS_MINUTES=30
MAX_COMMIT_INTERVAL_HOURS=4
WORK_START_HOUR=9
WORK_END_HOUR=18

# แสดงวิธีใช้งาน
show_usage() {
  echo "การใช้งาน: $0 [options]"
  echo "ตัวเลือก:"
  echo "  -b, --branch BRANCH_NAME    ระบุชื่อ branch ที่ต้องการวิเคราะห์ (ค่าเริ่มต้น: main หรือ master)"
  echo "  -s, --start-date DATE       วันที่เริ่มต้น (รูปแบบ YYYY-MM-DD)"
  echo "  -e, --end-date DATE         วันที่สิ้นสุด (รูปแบบ YYYY-MM-DD)"
  echo "  -m, --max-hours HOURS       จำนวนชั่วโมงสูงสุดต่อวัน (ค่าเริ่มต้น: 10)"
  echo "  -i, --interval MINUTES      เวลาทำงานโดยประมาณระหว่าง commit (ค่าเริ่มต้น: 30 นาที)"
  echo "  -h, --help                  แสดงวิธีใช้งาน"
  exit 1
}

# ประมวลผลตัวเลือก
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -b|--branch)
      BRANCH="$2"
      shift 2
      ;;
    -s|--start-date)
      START_DATE="$2"
      shift 2
      ;;
    -e|--end-date)
      END_DATE="$2"
      shift 2
      ;;
    -m|--max-hours)
      MAX_HOURS_PER_DAY="$2"
      shift 2
      ;;
    -i|--interval)
      TIME_BETWEEN_COMMITS_MINUTES="$2"
      shift 2
      ;;
    -h|--help)
      show_usage
      ;;
    *)
      # หากไม่ได้ระบุ flag แต่ให้พารามิเตอร์
      if [ -z "$BRANCH" ]; then
        BRANCH="$1"
      elif [ -z "$START_DATE" ]; then
        START_DATE="$1"
      elif [ -z "$END_DATE" ]; then
        END_DATE="$1"
      else
        echo "ตัวเลือกที่ไม่รู้จัก: $1"
        show_usage
      fi
      shift
      ;;
  esac
done

# ถ้าไม่ได้ระบุ branch ให้ใช้ main หรือ master
if [ -z "$BRANCH" ]; then
  if git show-ref --verify --quiet refs/heads/main; then
    BRANCH="main"
  elif git show-ref --verify --quiet refs/heads/master; then
    BRANCH="master"
  else
    echo "ไม่พบ branch main หรือ master โปรดระบุ branch ด้วยตัวเลือก -b"
    exit 1
  fi
fi

# ตรวจสอบว่า branch ที่ระบุมีอยู่จริงหรือไม่
if ! git show-ref --verify --quiet refs/heads/$BRANCH; then
  # ตรวจสอบ remote branch
  if ! git show-ref --verify --quiet refs/remotes/origin/$BRANCH; then
    echo "เกิดข้อผิดพลาด: ไม่พบ branch '$BRANCH'"
    exit 1
  else
    # ใช้ remote branch แทน
    BRANCH="origin/$BRANCH"
  fi
fi

# วันที่เริ่มต้น (ใช้วันเริ่มต้นของ branch ถ้าไม่ได้ระบุ)
if [ -z "$START_DATE" ]; then
  # ใช้วันที่ของ commit แรกใน branch
  START_DATE=$(git log --reverse --format=%ad --date=short $BRANCH | head -1)
fi

# วันที่สิ้นสุด (ใช้วันปัจจุบันถ้าไม่ได้ระบุ)
if [ -z "$END_DATE" ]; then
  END_DATE=$(date +%Y-%m-%d)
fi

# สร้างฟังก์ชันแปลงวันที่เป็น timestamp (ทำงานได้ทั้ง Linux และ macOS)
date_to_seconds() {
  local date_str="$1"
  if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS (BSD date)
    date -j -f "%Y-%m-%d %H:%M:%S" "$date_str" "+%s" 2>/dev/null || date -j -f "%Y-%m-%d" "$date_str" "+%s" 2>/dev/null
  else
    # Linux (GNU date)
    date -d "$date_str" +%s 2>/dev/null
  fi
}

echo "คำนวณเวลาการทำงานจริงของ programmer แต่ละคนบน branch '$BRANCH'"
echo "จากวันที่: $START_DATE ถึง: $END_DATE"
echo "----------------------------------------------------------------"

# ดึงรายชื่อ programmer ทั้งหมดที่มีการ commit
PROGRAMMERS_FILE=$(mktemp)
git log --pretty=format:"%an" --since="$START_DATE" --until="$END_DATE" $BRANCH | sort | uniq > "$PROGRAMMERS_FILE"

# สร้างไฟล์ชั่วคราวสำหรับเก็บข้อมูล
TEMP_FILE=$(mktemp)

echo "ชื่อ,จำนวน Commit,จำนวนวันทำงาน,ชั่วโมงทำงาน,ชั่วโมงเฉลี่ยต่อวัน,จำนวนบรรทัดที่เปลี่ยนแปลง,บรรทัดต่อชั่วโมง" > "$TEMP_FILE"

# วนลูปผ่านแต่ละ programmer
while IFS= read -r programmer; do
  COMMIT_TIMES_FILE=$(mktemp)
  
  # ดึงรายการเวลา commit ของ programmer นี้ (เรียงจากเก่าไปใหม่)
  git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --date=format:"%Y-%m-%d %H:%M:%S" --pretty=format:"%H|%ad" $BRANCH | sort -k2 > "$COMMIT_TIMES_FILE"
  
  # นับจำนวน commit
  COMMIT_COUNT=$(wc -l < "$COMMIT_TIMES_FILE")
  
  if [ "$COMMIT_COUNT" -gt 0 ]; then
    # หาวันที่ทำงาน (วันที่ที่มีการ commit)
    WORK_DAYS=$(git log --author="$programmer" --fixed-strings --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $BRANCH | sort | uniq | wc -l)
    
    # สร้างไฟล์สำหรับเก็บข้อมูลช่วงเวลาทำงาน
    WORK_SESSIONS_FILE=$(mktemp)
    
    # นับจำนวนบรรทัดที่เปลี่ยนแปลงทั้งหมด
    TOTAL_LINES_CHANGED=0
    
    # วนลูปผ่านแต่ละ commit เพื่อคำนวณเวลาทำงานและบรรทัดที่เปลี่ยนแปลง
    prev_hash=""
    prev_time=""
    TOTAL_WORK_MINUTES=0
    
    while IFS="|" read -r commit_hash commit_time; do
      # คำนวณบรรทัดที่เปลี่ยนแปลงใน commit นี้
      STATS=$(git show --stat --format="" "$commit_hash" | tail -n 1)
      INSERTIONS=$(echo "$STATS" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
      DELETIONS=$(echo "$STATS" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")
      LINES_CHANGED=$((INSERTIONS + DELETIONS))
      TOTAL_LINES_CHANGED=$((TOTAL_LINES_CHANGED + LINES_CHANGED))
      
      # หาวันของ commit
      COMMIT_DAY=$(echo "$commit_time" | cut -d' ' -f1)
      
      if [ -n "$prev_time" ]; then
        # แปลงเวลาให้เป็นวินาที
        CURR_SECONDS=$(date_to_seconds "$commit_time")
        PREV_SECONDS=$(date_to_seconds "$prev_time")
        
        if [ -n "$CURR_SECONDS" ] && [ -n "$PREV_SECONDS" ]; then
          # คำนวณความต่างของเวลาเป็นนาที
          TIME_DIFF_MINUTES=$(( (CURR_SECONDS - PREV_SECONDS) / 60 ))
          
          # ตรวจสอบว่าอยู่ในวันเดียวกันหรือไม่
          PREV_DAY=$(echo "$prev_time" | cut -d' ' -f1)
          
          if [ "$COMMIT_DAY" = "$PREV_DAY" ]; then
            # ถ้าช่วงเวลาห่างกันไม่เกิน MAX_COMMIT_INTERVAL_HOURS ชั่วโมง ถือว่าอยู่ในเซสชันเดียวกัน
            if [ "$TIME_DIFF_MINUTES" -le $((MAX_COMMIT_INTERVAL_HOURS * 60)) ]; then
              # คำนวณเวลาทำงานระหว่าง commit
              WORK_MINUTES=$TIME_BETWEEN_COMMITS_MINUTES
              
              # ถ้าเวลาระหว่าง commit น้อยกว่าเวลาทำงานที่กำหนด ใช้เวลาระหว่าง commit แทน
              if [ "$TIME_DIFF_MINUTES" -lt "$TIME_BETWEEN_COMMITS_MINUTES" ]; then
                WORK_MINUTES=$TIME_DIFF_MINUTES
              fi
              
              # เพิ่มเวลาทำงานสำหรับ commit ก่อนหน้า
              TOTAL_WORK_MINUTES=$((TOTAL_WORK_MINUTES + WORK_MINUTES))
              
              # บันทึกเซสชันการทำงาน
              echo "$prev_time -> $commit_time: $WORK_MINUTES นาที (ระยะห่าง: $TIME_DIFF_MINUTES นาที, บรรทัดที่เปลี่ยน: $LINES_CHANGED)" >> "$WORK_SESSIONS_FILE"
            else
              # หากเวลาห่างกันมาก ให้ถือว่าเป็นเซสชันแยกกัน
              # ให้เวลาทำงานสำหรับ commit ก่อนหน้า
              WORK_MINUTES=$TIME_BETWEEN_COMMITS_MINUTES
              TOTAL_WORK_MINUTES=$((TOTAL_WORK_MINUTES + WORK_MINUTES))
              
              # บันทึกเซสชันการทำงาน
              echo "$prev_time: $WORK_MINUTES นาที (เซสชันแยก, บรรทัดที่เปลี่ยน: ก่อนหน้า)" >> "$WORK_SESSIONS_FILE"
              
              # ให้เวลาทำงานสำหรับ commit ปัจจุบัน
              WORK_MINUTES=$TIME_BETWEEN_COMMITS_MINUTES
              TOTAL_WORK_MINUTES=$((TOTAL_WORK_MINUTES + WORK_MINUTES))
              
              # บันทึกเซสชันการทำงาน
              echo "$commit_time: $WORK_MINUTES นาที (เซสชันแยก, บรรทัดที่เปลี่ยน: $LINES_CHANGED)" >> "$WORK_SESSIONS_FILE"
            fi
          else
            # ถ้าเป็นคนละวัน ให้คิดเป็นเซสชันแยกกัน
            # ให้เวลาทำงานสำหรับ commit ก่อนหน้า
            WORK_MINUTES=$TIME_BETWEEN_COMMITS_MINUTES
            TOTAL_WORK_MINUTES=$((TOTAL_WORK_MINUTES + WORK_MINUTES))
            
            # บันทึกเซสชันการทำงาน
            echo "$prev_time: $WORK_MINUTES นาที (วันต่างกัน, บรรทัดที่เปลี่ยน: ก่อนหน้า)" >> "$WORK_SESSIONS_FILE"
            
            # ให้เวลาทำงานสำหรับ commit ปัจจุบัน
            WORK_MINUTES=$TIME_BETWEEN_COMMITS_MINUTES
            TOTAL_WORK_MINUTES=$((TOTAL_WORK_MINUTES + WORK_MINUTES))
            
            # บันทึกเซสชันการทำงาน
            echo "$commit_time: $WORK_MINUTES นาที (วันต่างกัน, บรรทัดที่เปลี่ยน: $LINES_CHANGED)" >> "$WORK_SESSIONS_FILE"
          fi
        fi
      else
        # commit แรก ให้เวลาทำงานเริ่มต้น
        WORK_MINUTES=$TIME_BETWEEN_COMMITS_MINUTES
        TOTAL_WORK_MINUTES=$((TOTAL_WORK_MINUTES + WORK_MINUTES))
        
        # บันทึกเซสชันการทำงาน
        echo "$commit_time: $WORK_MINUTES นาที (commit แรก, บรรทัดที่เปลี่ยน: $LINES_CHANGED)" >> "$WORK_SESSIONS_FILE"
      fi
      
      # บันทึกข้อมูลสำหรับการเปรียบเทียบในรอบถัดไป
      prev_hash=$commit_hash
      prev_time=$commit_time
    done < "$COMMIT_TIMES_FILE"
    
    # คำนวณเวลาทำงานทั้งหมดเป็นชั่วโมง
    TOTAL_WORK_HOURS=$(echo "scale=2; $TOTAL_WORK_MINUTES / 60" | bc)
    
    # คำนวณชั่วโมงเฉลี่ยต่อวัน
    if [ "$WORK_DAYS" -gt 0 ]; then
      AVG_HOURS_PER_DAY=$(echo "scale=2; $TOTAL_WORK_HOURS / $WORK_DAYS" | bc)
      
      # ตรวจสอบว่าชั่วโมงเฉลี่ยต่อวันเกินค่าสูงสุดหรือไม่
      if (( $(echo "$AVG_HOURS_PER_DAY > $MAX_HOURS_PER_DAY" | bc -l) )); then
        # ปรับชั่วโมงทำงานให้อยู่ในเกณฑ์ที่เหมาะสม
        TOTAL_WORK_HOURS=$(echo "scale=2; $MAX_HOURS_PER_DAY * $WORK_DAYS" | bc)
        AVG_HOURS_PER_DAY=$MAX_HOURS_PER_DAY
      fi
    else
      AVG_HOURS_PER_DAY=0
    fi
    
    # คำนวณบรรทัดต่อชั่วโมง
    if (( $(echo "$TOTAL_WORK_HOURS > 0" | bc -l) )); then
      LINES_PER_HOUR=$(echo "scale=2; $TOTAL_LINES_CHANGED / $TOTAL_WORK_HOURS" | bc)
    else
      LINES_PER_HOUR=0
    fi
    
    # บันทึกข้อมูลลงในไฟล์ชั่วคราว
    ESCAPED_NAME=$(echo "$programmer" | sed 's/"/""/g')
    echo "\"$ESCAPED_NAME\",$COMMIT_COUNT,$WORK_DAYS,$TOTAL_WORK_HOURS,$AVG_HOURS_PER_DAY,$TOTAL_LINES_CHANGED,$LINES_PER_HOUR" >> "$TEMP_FILE"
    
    # ลบไฟล์ชั่วคราว
    rm "$WORK_SESSIONS_FILE"
  fi
  
  # ลบไฟล์ชั่วคราว
  rm "$COMMIT_TIMES_FILE"
done < "$PROGRAMMERS_FILE"

# เรียงลำดับตามจำนวนชั่วโมงทำงาน (มากไปน้อย)
if command -v column > /dev/null; then
  # แสดงผลในรูปแบบตาราง (ถ้ามีคำสั่ง column)
  echo "รายงานเวลาทำงานจริง (คำนวณจากช่วงเวลา commit):"
  echo "----------------------------------------------------------------"
  (head -1 "$TEMP_FILE" && tail -n +2 "$TEMP_FILE" | sort -t',' -k4 -nr) | column -t -s','
else
  # แสดงผลในรูปแบบ CSV ถ้าไม่มีคำสั่ง column
  (head -1 "$TEMP_FILE" && tail -n +2 "$TEMP_FILE" | sort -t',' -k4 -nr)
fi

# แสดงสรุปโครงการ
echo ""
echo "สรุปรวมโครงการบน branch '$BRANCH':"
echo "----------------------------------------------------------------"

TOTAL_COMMITS=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%H" $BRANCH | wc -l)
TOTAL_AUTHORS=$(wc -l < "$PROGRAMMERS_FILE")

START_SECONDS=$(date_to_seconds "$START_DATE 00:00:00")
END_SECONDS=$(date_to_seconds "$END_DATE 23:59:59")

if [ -n "$START_SECONDS" ] && [ -n "$END_SECONDS" ]; then
  TOTAL_DAYS=$(( (END_SECONDS - START_SECONDS) / 86400 + 1 ))
else
  # ถ้าคำนวณไม่ได้ ใช้การนับจำนวนวันแทน
  TOTAL_DAYS=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $BRANCH | sort | uniq | wc -l)
fi

ACTIVE_DAYS=$(git log --since="$START_DATE" --until="$END_DATE" --pretty=format:"%ad" --date=short $BRANCH | sort | uniq | wc -l)

echo "ระยะเวลาโครงการ: $TOTAL_DAYS วัน (ทำงานจริง $ACTIVE_DAYS วัน)"
echo "จำนวน programmer: $TOTAL_AUTHORS คน"
echo "จำนวน commit ทั้งหมด: $TOTAL_COMMITS commits"
if [ "$ACTIVE_DAYS" -gt 0 ]; then
  echo "ค่าเฉลี่ย: $(echo "scale=2; $TOTAL_COMMITS / $ACTIVE_DAYS" | bc) commits/วัน"
fi

# คำนวณชั่วโมงทำงานรวมของทุกคน
TOTAL_WORK_HOURS=0
TOTAL_LINES_CHANGED=0
while IFS="," read -r name commits days hours avg_hours lines lines_per_hour; do
  # ข้ามบรรทัดหัวตาราง
  if [[ "$name" == "ชื่อ" ]]; then
    continue
  fi
  
  TOTAL_WORK_HOURS=$(echo "scale=2; $TOTAL_WORK_HOURS + $hours" | bc)
  TOTAL_LINES_CHANGED=$((TOTAL_LINES_CHANGED + lines))
done < "$TEMP_FILE"

echo "จำนวนชั่วโมงทำงานรวม: $TOTAL_WORK_HOURS ชั่วโมง"
if [ "$ACTIVE_DAYS" -gt 0 ]; then
  echo "ชั่วโมงทำงานเฉลี่ยต่อวัน: $(echo "scale=2; $TOTAL_WORK_HOURS / $ACTIVE_DAYS" | bc) ชั่วโมง"
fi
echo "จำนวนบรรทัดที่เปลี่ยนแปลงทั้งหมด: $TOTAL_LINES_CHANGED บรรทัด"
if (( $(echo "$TOTAL_WORK_HOURS > 0" | bc -l) )); then
  echo "ประสิทธิภาพเฉลี่ย: $(echo "scale=2; $TOTAL_LINES_CHANGED / $TOTAL_WORK_HOURS" | bc) บรรทัด/ชั่วโมง"
fi

# สรุปเพิ่มเติมเกี่ยวกับภาพรวมรายบุคคล
echo ""
echo "สรุปร้อยละการมีส่วนร่วมในโครงการ (ตามจำนวนชั่วโมง):"
echo "----------------------------------------------------------------"

# คำนวณเปอร์เซ็นต์การมีส่วนร่วมของแต่ละคน
CONTRIBUTION_FILE=$(mktemp)

while IFS="," read -r name commits days hours avg_hours lines lines_per_hour; do
  # ข้ามบรรทัดหัวตาราง
  if [[ "$name" == "ชื่อ" ]]; then
    continue
  fi
  
  if (( $(echo "$TOTAL_WORK_HOURS > 0" | bc -l) )); then
    PERCENTAGE=$(echo "scale=2; ($hours * 100) / $TOTAL_WORK_HOURS" | bc)
    echo "$name,$PERCENTAGE,$hours,$lines" >> "$CONTRIBUTION_FILE"
  fi
done < "$TEMP_FILE"

# แสดงผลเรียงตามเปอร์เซ็นต์
if command -v column > /dev/null; then
  echo "ชื่อ                  เปอร์เซ็นต์  ชั่วโมง   บรรทัดที่เปลี่ยน"
  echo "----------------------------------------------------------------"
  sort -t',' -k2 -nr "$CONTRIBUTION_FILE" | while IFS="," read -r name percentage hours lines; do
    CLEAN_NAME=$(echo "$name" | sed 's/^"//;s/"$//')
    printf "%-20s  %6s%%   %7s   %7s\n" "$CLEAN_NAME" "$percentage" "$hours" "$lines"
  done
else
  echo "ชื่อ,เปอร์เซ็นต์,ชั่วโมง,บรรทัดที่เปลี่ยน"
  sort -t',' -k2 -nr "$CONTRIBUTION_FILE" | while IFS="," read -r name percentage hours lines; do
    CLEAN_NAME=$(echo "$name" | sed 's/^"//;s/"$//')
    echo "$CLEAN_NAME,$percentage%,$hours,$lines"
  done
fi

# ลบไฟล์ชั่วคราว
rm "$TEMP_FILE"
rm "$PROGRAMMERS_FILE"
rm "$CONTRIBUTION_FILE"

echo ""
echo "หมายเหตุการคำนวณเวลาทำงานจริง:"
echo "----------------------------------------------------------------"
echo "1. แต่ละ commit มีเวลาทำงานพื้นฐาน $TIME_BETWEEN_COMMITS_MINUTES นาที"
echo "2. ถ้า commit อยู่ในวันเดียวกันและห่างกันไม่เกิน $MAX_COMMIT_INTERVAL_HOURS ชั่วโมง จะถือว่าอยู่ในเซสชันเดียวกัน"
echo "3. ชั่วโมงทำงานเฉลี่ยต่อวันไม่เกิน $MAX_HOURS_PER_DAY ชั่วโมง"
echo "4. ประสิทธิภาพวัดจากจำนวนบรรทัดที่เปลี่ยนแปลงต่อชั่วโมง"
echo ""
echo "ต้องการปรับแต่งพารามิเตอร์การคำนวณใช้ตัวเลือกต่อไปนี้:"
echo "  --max-hours HOURS       : จำนวนชั่วโมงสูงสุดต่อวัน (เริ่มต้น: $MAX_HOURS_PER_DAY)"
echo "  --interval MINUTES      : เวลาทำงานโดยประมาณระหว่าง commit (เริ่มต้น: $TIME_BETWEEN_COMMITS_MINUTES นาที)"