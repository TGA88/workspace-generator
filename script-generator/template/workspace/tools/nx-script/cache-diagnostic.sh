#!/bin/bash
# cache-diagnostic-corrected.sh
# Comprehensive cache diagnostic script - Recognizes official Nx folders

# Auto-detect .nx location
if [ -d ".nx" ]; then
    NX_DIR=".nx"
elif [ -d "../.nx" ]; then
    NX_DIR="../.nx"
elif [ -d "../../.nx" ]; then
    NX_DIR="../../.nx"
else
    echo "❌ .nx directory not found"
    exit 1
fi

DB_FILE=$(ls ${NX_DIR}/workspace-data/*.db 2>/dev/null | head -1)
CACHE_DIR="${NX_DIR}/cache"

# Official Nx cache folders (not suspicious)
OFFICIAL_FOLDERS=("terminalOutputs" "cloud" "d")

echo "🔍 Nx Cache Diagnostic Report (Corrected)"
echo "=========================================="
echo ""

# Basic info
echo "📂 Paths:"
echo "  NX Directory: $NX_DIR"
echo "  Database: $DB_FILE"
echo "  Cache Directory: $CACHE_DIR"
echo ""

# Database existence and basic info
if [ ! -f "$DB_FILE" ]; then
    echo "❌ Database file not found!"
    exit 1
fi

echo "📊 Database Information:"
if command -v stat >/dev/null 2>&1; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        DB_SIZE_BYTES=$(stat -f%z "$DB_FILE" 2>/dev/null || echo "0")
    else
        # Linux
        DB_SIZE_BYTES=$(stat -c%s "$DB_FILE" 2>/dev/null || echo "0")
    fi
    DB_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $DB_SIZE_BYTES / 1024 / 1024}")
    echo "  File size: $DB_SIZE_MB MB ($DB_SIZE_BYTES bytes)"
else
    echo "  File size: Unable to determine"
fi

echo ""
echo "📋 Table Counts:"
TASK_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details;" 2>/dev/null || echo "0")
CACHE_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM cache_outputs;" 2>/dev/null || echo "0")
echo "  task_details: $TASK_COUNT rows"
echo "  cache_outputs: $CACHE_COUNT rows"

echo ""
echo "💾 Size Analysis:"

# Raw database size calculation
TOTAL_DB_SIZE_RAW=$(sqlite3 "$DB_FILE" "SELECT SUM(size) FROM cache_outputs;" 2>/dev/null || echo "0")
if [ "$TOTAL_DB_SIZE_RAW" = "NULL" ] || [ -z "$TOTAL_DB_SIZE_RAW" ]; then
    TOTAL_DB_SIZE_RAW=0
fi
TOTAL_DB_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_DB_SIZE_RAW / 1024 / 1024}")
echo "  Database recorded size: $TOTAL_DB_SIZE_MB MB ($TOTAL_DB_SIZE_RAW bytes)"

# Function to check if folder is official
is_official_folder() {
    local folder_name="$1"
    for official in "${OFFICIAL_FOLDERS[@]}"; do
        if [ "$folder_name" = "$official" ]; then
            return 0  # is official
        fi
    done
    return 1  # not official
}

# Filesystem analysis - separate official and hash folders
echo ""
echo "📁 Filesystem Analysis:"
if [ -d "$CACHE_DIR" ]; then
    
    # Calculate hash folders size only
    HASH_FOLDERS_SIZE=0
    HASH_FOLDER_COUNT=0
    
    # Calculate official folders size
    OFFICIAL_FOLDERS_SIZE=0
    OFFICIAL_FOLDER_LIST=()
    
    # Actual suspicious folders
    SUSPICIOUS_FOLDERS=()
    
    while read dir; do
        if [ "$dir" != "$CACHE_DIR" ]; then
            name=$(basename "$dir")
            
            # Get folder size
            if [[ "$OSTYPE" == "darwin"* ]]; then
                size_bytes=$(find "$dir" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
            else
                size_bytes=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")
            fi
            
            if [ -z "$size_bytes" ]; then
                size_bytes=0
            fi
            
            # Categorize folders
            if [[ "$name" =~ ^[0-9]+$ ]]; then
                # Hash folder (numbers only)
                HASH_FOLDERS_SIZE=$((HASH_FOLDERS_SIZE + size_bytes))
                HASH_FOLDER_COUNT=$((HASH_FOLDER_COUNT + 1))
            elif is_official_folder "$name"; then
                # Official Nx folder
                OFFICIAL_FOLDERS_SIZE=$((OFFICIAL_FOLDERS_SIZE + size_bytes))
                size_mb=$(awk "BEGIN {printf \"%.2f\", $size_bytes / 1024 / 1024}")
                OFFICIAL_FOLDER_LIST+=("$name:${size_mb}MB")
            else
                # Actually suspicious
                size_mb=$(awk "BEGIN {printf \"%.2f\", $size_bytes / 1024 / 1024}")
                SUSPICIOUS_FOLDERS+=("$name:${size_mb}MB")
            fi
        fi
    done < <(find "$CACHE_DIR" -maxdepth 1 -type d)
    
    # Calculate totals
    TOTAL_FS_SIZE=$((HASH_FOLDERS_SIZE + OFFICIAL_FOLDERS_SIZE))
    
    HASH_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $HASH_FOLDERS_SIZE / 1024 / 1024}")
    OFFICIAL_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $OFFICIAL_FOLDERS_SIZE / 1024 / 1024}")
    TOTAL_FS_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_FS_SIZE / 1024 / 1024}")
    
    echo "  📊 Hash folders: $HASH_FOLDER_COUNT folders, ${HASH_SIZE_MB}MB"
    echo "  📊 Official folders: ${#OFFICIAL_FOLDER_LIST[@]} folders, ${OFFICIAL_SIZE_MB}MB"
    echo "  📊 Total filesystem: ${TOTAL_FS_SIZE_MB}MB"
    
    echo ""
    echo "📂 Official Nx Folders:"
    if [ ${#OFFICIAL_FOLDER_LIST[@]} -gt 0 ]; then
        for folder_info in "${OFFICIAL_FOLDER_LIST[@]}"; do
            folder_name=$(echo "$folder_info" | cut -d':' -f1)
            folder_size=$(echo "$folder_info" | cut -d':' -f2)
            echo "  ✅ $folder_name: $folder_size"
        done
    else
        echo "  📭 No official folders found"
    fi
    
    # Show suspicious folders only if they exist
    if [ ${#SUSPICIOUS_FOLDERS[@]} -gt 0 ]; then
        echo ""
        echo "📂 Suspicious Folders:"
        for folder_info in "${SUSPICIOUS_FOLDERS[@]}"; do
            folder_name=$(echo "$folder_info" | cut -d':' -f1)
            folder_size=$(echo "$folder_info" | cut -d':' -f2)
            echo "  🚨 $folder_name: $folder_size"
        done
    fi
    
    # Sample hash folders
    echo ""
    echo "📂 Sample Hash Folders (first 5):"
    find "$CACHE_DIR" -maxdepth 1 -type d -name "[0-9]*" | head -5 | while read folder; do
        hash=$(basename "$folder")
        if [[ "$OSTYPE" == "darwin"* ]]; then
            size=$(du -sh "$folder" 2>/dev/null | cut -f1 || echo "unknown")
        else
            size=$(du -sh "$folder" 2>/dev/null | cut -f1 || echo "unknown")
        fi
        echo "  📁 $hash: $size"
    done
    
else
    echo "  ❌ Cache directory not found: $CACHE_DIR"
fi

# Orphaned analysis
echo ""
echo "🔍 Orphaned Analysis:"

# Database entries without cache files
echo "  Database entries without cache files:"
ORPHANED_TASK_LIST=$(sqlite3 "$DB_FILE" "
    SELECT td.hash, td.project, td.target 
    FROM task_details td 
    WHERE NOT EXISTS (
        SELECT 1 FROM cache_outputs co WHERE co.hash = td.hash
    )
    LIMIT 10;
" 2>/dev/null)

if [ -n "$ORPHANED_TASK_LIST" ]; then
    echo "$ORPHANED_TASK_LIST" | while read line; do
        echo "    📋 $line"
    done
else
    echo "    ✅ None found"
fi

# Hash folders without database entries (only check hash folders)
echo ""
echo "  Hash folders without database entries:"
FOUND_ORPHANED_FS=false
if [ -d "$CACHE_DIR" ]; then
    find "$CACHE_DIR" -maxdepth 1 -type d -name "[0-9]*" | head -10 | while read dir; do
        hash=$(basename "$dir")
        exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE hash = '$hash';" 2>/dev/null || echo "0")
        if [ "$exists" -eq 0 ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "unknown")
            else
                size=$(du -sh "$dir" 2>/dev/null | cut -f1 || echo "unknown")
            fi
            echo "    📁 $hash: $size"
            FOUND_ORPHANED_FS=true
        fi
    done
    
    if [ "$FOUND_ORPHANED_FS" = false ]; then
        echo "    ✅ None found"
    fi
fi

# Data consistency check
echo ""
echo "🔄 Data Consistency Check:"

ORPHANED_TASKS=$(sqlite3 "$DB_FILE" "
    SELECT COUNT(*) 
    FROM task_details td 
    WHERE NOT EXISTS (SELECT 1 FROM cache_outputs co WHERE co.hash = td.hash);
" 2>/dev/null || echo "0")

ORPHANED_CACHE=$(sqlite3 "$DB_FILE" "
    SELECT COUNT(*) 
    FROM cache_outputs co 
    WHERE NOT EXISTS (SELECT 1 FROM task_details td WHERE td.hash = co.hash);
" 2>/dev/null || echo "0")

echo "  task_details without cache_outputs: $ORPHANED_TASKS"
echo "  cache_outputs without task_details: $ORPHANED_CACHE"

# Storage efficiency comparison
echo ""
echo "💾 Storage Efficiency:"
echo "  Database recorded: ${TOTAL_DB_SIZE_MB}MB"
echo "  Hash folders actual: ${HASH_SIZE_MB}MB"
echo "  Official folders: ${OFFICIAL_SIZE_MB}MB"
echo "  Total filesystem: ${TOTAL_FS_SIZE_MB}MB"

if [ "$HASH_FOLDERS_SIZE" -gt 0 ] && [ "$TOTAL_DB_SIZE_RAW" -gt 0 ]; then
    EFFICIENCY=$(awk "BEGIN {printf \"%.1f\", $TOTAL_DB_SIZE_RAW * 100 / $HASH_FOLDERS_SIZE}")
    echo "  Hash folder efficiency: ${EFFICIENCY}%"
    
    if [ "${EFFICIENCY%.*}" -lt 90 ] || [ "${EFFICIENCY%.*}" -gt 110 ]; then
        echo "  ⚠️  Efficiency issue: Database and filesystem sizes don't match"
    fi
fi

# Recent activity
echo ""
echo "⏰ Recent Activity (last 5):"
sqlite3 "$DB_FILE" "
    SELECT 
        datetime(co.accessed_at) as accessed,
        td.project || ':' || td.target as task,
        printf('%.2f MB', CAST(co.size AS REAL)/1024/1024) as size,
        substr(td.hash, 1, 12) || '...' as hash_short
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    WHERE co.accessed_at IS NOT NULL
    ORDER BY co.accessed_at DESC
    LIMIT 5;
" 2>/dev/null | while read line; do
    echo "  $line"
done

# Recommendations
echo ""
echo "💡 Recommendations:"

if [ "$ORPHANED_TASKS" -gt 0 ]; then
    echo "  🔧 Clean $ORPHANED_TASKS orphaned task entries"
fi

if [ "$ORPHANED_CACHE" -gt 0 ]; then
    echo "  🔧 Clean $ORPHANED_CACHE orphaned cache entries"
fi

if [ ${#SUSPICIOUS_FOLDERS[@]} -gt 0 ]; then
    echo "  🚨 Review ${#SUSPICIOUS_FOLDERS[@]} non-standard folders"
fi

if [ "$TOTAL_FS_SIZE" -gt 1073741824 ]; then  # 1GB
    echo "  🧹 Consider cache cleanup: Total cache > 1GB"
fi

echo ""
echo "✅ Diagnostic completed!"
echo ""
echo "📝 Note: terminalOutputs/ and cloud/ are official Nx folders"