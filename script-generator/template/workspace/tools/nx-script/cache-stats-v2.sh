#!/bin/bash
# cache-stats-v2.sh
# Cache statistics based on actual database schema - FIXED VERSION

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

echo "📊 Nx Cache Statistics"
echo "======================"

if [ ! -f "$DB_FILE" ]; then
    echo "❌ Database not found"
    exit 1
fi

# Database info
DB_SIZE=$(du -sh "$DB_FILE" | cut -f1)
echo "Database: $(basename "$DB_FILE") ($DB_SIZE)"

# Cache directory info
if [ -d "$CACHE_DIR" ]; then
    CACHE_SIZE=$(du -sh "$CACHE_DIR" | cut -f1)
    CACHE_FOLDERS=$(find "$CACHE_DIR" -maxdepth 1 -type d -name "[0-9]*" | wc -l | tr -d ' ')
    echo "Cache directory: $CACHE_SIZE ($CACHE_FOLDERS folders)"
fi

echo ""

# Table counts
echo "📋 Database summary:"
CACHE_ENTRIES=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM cache_outputs;")
TASK_ENTRIES=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details;")
echo "  Cache entries: $CACHE_ENTRIES"
echo "  Task entries: $TASK_ENTRIES"

echo ""

# Per-project breakdown
echo "📊 Per-project cache breakdown:"
sqlite3 "$DB_FILE" "
SELECT 
    td.project,
    td.target,
    COALESCE(td.configuration, '(default)') as config,
    COUNT(*) as versions,
    printf('%.2f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
    MAX(datetime(co.accessed_at)) as last_accessed
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
GROUP BY td.project, td.target, td.configuration
ORDER BY td.project, td.target, td.configuration;
"

echo ""

# Top 10 largest caches
echo "📈 Top 10 largest cache entries:"
sqlite3 "$DB_FILE" "
SELECT 
    td.project || ':' || td.target || 
    CASE WHEN td.configuration IS NOT NULL THEN ':' || td.configuration ELSE '' END as task,
    printf('%.2f MB', CAST(co.size AS REAL)/1024/1024) as size,
    td.hash,
    datetime(co.accessed_at) as accessed
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
ORDER BY co.size DESC
LIMIT 10;
"

echo ""

# Recent activity
echo "⏰ Recent cache activity (last 10):"
sqlite3 "$DB_FILE" "
SELECT 
    td.project || ':' || td.target || 
    CASE WHEN td.configuration IS NOT NULL THEN ':' || td.configuration ELSE '' END as task,
    td.hash,
    datetime(co.accessed_at) as accessed,
    printf('%.2f MB', CAST(co.size AS REAL)/1024/1024) as size
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
ORDER BY co.accessed_at DESC
LIMIT 10;
"

echo ""

# Orphaned analysis
echo "🔍 Orphaned cache analysis:"
ORPHANED_DB=$(sqlite3 "$DB_FILE" "
SELECT COUNT(*) FROM task_details td 
WHERE NOT EXISTS (SELECT 1 FROM cache_outputs co WHERE co.hash = td.hash);
")

ORPHANED_FS=0
if [ -d "$CACHE_DIR" ]; then
    ORPHANED_FS=$(find "$CACHE_DIR" -maxdepth 1 -type d -name "[0-9]*" | while read dir; do
        hash=$(basename "$dir")
        if ! sqlite3 "$DB_FILE" "SELECT 1 FROM task_details WHERE hash = '$hash';" | grep -q 1; then
            echo "$hash"
        fi
    done | wc -l | tr -d ' ')
fi

echo "  Database entries without cache files: $ORPHANED_DB"
echo "  Cache folders without database entries: $ORPHANED_FS"

# Cache age analysis
echo ""
echo "📅 Cache age analysis:"
sqlite3 "$DB_FILE" "
SELECT 
    CASE 
        WHEN julianday('now') - julianday(co.accessed_at) <= 1 THEN 'Last 24 hours'
        WHEN julianday('now') - julianday(co.accessed_at) <= 7 THEN 'Last week'
        WHEN julianday('now') - julianday(co.accessed_at) <= 30 THEN 'Last month'
        ELSE 'Older than month'
    END as age_group,
    COUNT(*) as count,
    printf('%.2f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size
FROM cache_outputs co
GROUP BY age_group
ORDER BY 
    CASE age_group
        WHEN 'Last 24 hours' THEN 1
        WHEN 'Last week' THEN 2
        WHEN 'Last month' THEN 3
        ELSE 4
    END;
"

echo ""

# Storage efficiency - FIXED VERSION
echo "💾 Storage efficiency:"

# Get database total size (from cache_outputs table)
TOTAL_DB_SIZE=$(sqlite3 "$DB_FILE" "SELECT COALESCE(SUM(size), 0) FROM cache_outputs;" 2>/dev/null || echo "0")

if [ -d "$CACHE_DIR" ]; then
    # Calculate hash folders only (exclude official folders)
    HASH_FOLDERS_SIZE=0
    OFFICIAL_FOLDERS_SIZE=0
    
    # Official Nx folders
    OFFICIAL_FOLDERS=("terminalOutputs" "cloud" "d")
    
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
            
            # Check if it's an official folder
            is_official=false
            for official in "${OFFICIAL_FOLDERS[@]}"; do
                if [ "$name" = "$official" ]; then
                    is_official=true
                    break
                fi
            done
            
            if [ "$is_official" = true ]; then
                OFFICIAL_FOLDERS_SIZE=$((OFFICIAL_FOLDERS_SIZE + size_bytes))
            elif [[ "$name" =~ ^[0-9]+$ ]]; then
                # Hash folder
                HASH_FOLDERS_SIZE=$((HASH_FOLDERS_SIZE + size_bytes))
            fi
        fi
    done < <(find "$CACHE_DIR" -maxdepth 1 -type d)
    
    TOTAL_FS_SIZE=$((HASH_FOLDERS_SIZE + OFFICIAL_FOLDERS_SIZE))
    
    # Convert to MB for display
    if [ "$TOTAL_DB_SIZE" != "0" ] && [ "$TOTAL_DB_SIZE" != "NULL" ] && [ -n "$TOTAL_DB_SIZE" ]; then
        DB_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_DB_SIZE / 1024 / 1024}")
        echo "  Database size: ${DB_SIZE_MB}MB"
    else
        echo "  Database size: 0MB"
    fi
    
    if [ "$HASH_FOLDERS_SIZE" -gt 0 ]; then
        HASH_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $HASH_FOLDERS_SIZE / 1024 / 1024}")
        echo "  Hash folders size: ${HASH_SIZE_MB}MB"
    else
        echo "  Hash folders size: 0MB"
    fi
    
    if [ "$OFFICIAL_FOLDERS_SIZE" -gt 0 ]; then
        OFFICIAL_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $OFFICIAL_FOLDERS_SIZE / 1024 / 1024}")
        echo "  Official folders size: ${OFFICIAL_SIZE_MB}MB"
    fi
    
    if [ "$TOTAL_FS_SIZE" -gt 0 ]; then
        TOTAL_FS_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $TOTAL_FS_SIZE / 1024 / 1024}")
        echo "  Total filesystem: ${TOTAL_FS_SIZE_MB}MB"
    else
        echo "  Total filesystem: 0MB"
    fi
    
    # Calculate efficiency (compare database vs hash folders only)
    if [ "$HASH_FOLDERS_SIZE" -gt 0 ] && [ "$TOTAL_DB_SIZE" -gt 0 ] && [ "$TOTAL_DB_SIZE" != "NULL" ]; then
        EFFICIENCY=$(awk "BEGIN {printf \"%.1f\", $TOTAL_DB_SIZE * 100 / $HASH_FOLDERS_SIZE}")
        echo "  Cache efficiency: ${EFFICIENCY}%"
        
        if [ "${EFFICIENCY%.*}" -ge 95 ] && [ "${EFFICIENCY%.*}" -le 105 ]; then
            echo "  Status: ✅ Excellent efficiency"
        elif [ "${EFFICIENCY%.*}" -ge 85 ] && [ "${EFFICIENCY%.*}" -le 115 ]; then
            echo "  Status: ✅ Good efficiency"
        else
            echo "  Status: ⚠️ Efficiency issue detected"
        fi
    else
        echo "  Status: ⚠️ Unable to calculate efficiency"
    fi
else
    echo "  Status: ❌ Cache directory not found"
fi