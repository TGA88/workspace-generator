#!/bin/bash
# project-cache-cleanup-v2.sh
# Project-specific cache cleanup based on actual database schema

PROJECT="$1"
KEEP_VERSIONS="${2:-3}"

if [ -z "$PROJECT" ]; then
    echo "Usage: $0 <project> [keep_versions]"
    echo "Example: $0 my-app 3"
    exit 1
fi

DB_FILE=$(ls .nx/workspace-data/*.db 2>/dev/null | head -1)

if [ ! -f "$DB_FILE" ]; then
    echo "❌ Database file not found"
    exit 1
fi

echo "🧹 Project Cache Cleanup: $PROJECT"
echo "Keep versions: $KEEP_VERSIONS"
echo ""

# Check if project exists
PROJECT_EXISTS=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE project = '$PROJECT';")
if [ "$PROJECT_EXISTS" -eq 0 ]; then
    echo "❌ Project '$PROJECT' not found in cache database"
    echo ""
    echo "📋 Available projects:"
    sqlite3 "$DB_FILE" "SELECT DISTINCT project FROM task_details ORDER BY project;"
    exit 1
fi

# Show current project status
echo "📊 Current $PROJECT cache status:"
sqlite3 "$DB_FILE" "
SELECT 
    td.target,
    COALESCE(td.configuration, '(default)') as config,
    td.hash,
    datetime(co.created_at) as created,
    datetime(co.accessed_at) as accessed,
    printf('%.2f MB', CAST(co.size AS REAL)/1024/1024) as size
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
WHERE td.project = '$PROJECT'
ORDER BY td.target, co.accessed_at DESC;
"

echo ""

# Show summary by target
echo "📋 Summary by target:"
sqlite3 "$DB_FILE" "
SELECT 
    td.target,
    COALESCE(td.configuration, '(default)') as config,
    COUNT(*) as versions,
    printf('%.2f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
    MAX(datetime(co.accessed_at)) as last_accessed
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
WHERE td.project = '$PROJECT'
GROUP BY td.target, td.configuration
ORDER BY td.target, td.configuration;
"

# Get project hashes to delete
HASHES_TO_DELETE=$(sqlite3 "$DB_FILE" "
WITH project_ranked AS (
    SELECT 
        td.hash,
        td.target,
        td.configuration,
        co.accessed_at,
        co.created_at,
        ROW_NUMBER() OVER (
            PARTITION BY td.target, COALESCE(td.configuration, '') 
            ORDER BY co.accessed_at DESC, co.created_at DESC
        ) as rank
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    WHERE td.project = '$PROJECT'
)
SELECT hash 
FROM project_ranked 
WHERE rank > $KEEP_VERSIONS;
")

if [ -z "$HASHES_TO_DELETE" ]; then
    echo ""
    echo "✅ No cleanup needed for $PROJECT"
    echo "All targets have ≤ $KEEP_VERSIONS versions"
    exit 0
fi

echo ""
echo "🗑️  Will delete these hashes:"
echo "$HASHES_TO_DELETE" | while read hash; do
    if [ -n "$hash" ]; then
        DETAILS=$(sqlite3 "$DB_FILE" "
            SELECT 
                td.target || CASE WHEN td.configuration IS NOT NULL THEN ':' || td.configuration ELSE '' END as task,
                printf('%.2f MB', CAST(co.size AS REAL)/1024/1024) as size,
                datetime(co.accessed_at) as accessed
            FROM task_details td
            LEFT JOIN cache_outputs co ON td.hash = co.hash
            WHERE td.hash = '$hash';
        ")
        echo "  📁 $hash ($DETAILS)"
    fi
done

echo ""
HASH_COUNT=$(echo "$HASHES_TO_DELETE" | wc -w)
echo "Total hashes to delete: $HASH_COUNT"

read -p "🤔 Proceed? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "❌ Cancelled"
    exit 0
fi

# Backup database
BACKUP_FILE="${DB_FILE}.backup.$(date +%Y%m%d-%H%M%S)"
cp "$DB_FILE" "$BACKUP_FILE"
echo "📦 Database backup: $(basename "$BACKUP_FILE")"

# Delete from database and filesystem
echo ""
echo "🗄️  Cleaning..."
DELETED_COUNT=0
TOTAL_FREED=0

for hash in $HASHES_TO_DELETE; do
    if [ -n "$hash" ]; then
        # Get size before deletion
        SIZE=$(sqlite3 "$DB_FILE" "SELECT COALESCE(size, 0) FROM cache_outputs WHERE hash = '$hash';" 2>/dev/null || echo "0")
        
        # Delete from database
        sqlite3 "$DB_FILE" "
            DELETE FROM cache_outputs WHERE hash = '$hash';
            DELETE FROM task_details WHERE hash = '$hash';
        "
        
        # Delete cache folder
        if [ -d ".nx/cache/$hash" ]; then
            FOLDER_SIZE=$(du -sb ".nx/cache/$hash" 2>/dev/null | cut -f1 || echo "0")
            rm -rf ".nx/cache/$hash"
            echo "  ✅ Deleted: $hash ($(echo $FOLDER_SIZE | awk '{print int($1/1024/1024)"MB"}'))"
            TOTAL_FREED=$((TOTAL_FREED + FOLDER_SIZE))
        else
            echo "  📁 Hash deleted from DB: $hash (folder not found)"
        fi
        
        DELETED_COUNT=$((DELETED_COUNT + 1))
    fi
done

# VACUUM database
echo ""
echo "🔄 Optimizing database..."
sqlite3 "$DB_FILE" "VACUUM;"

echo ""
echo "✅ Cleanup completed for $PROJECT!"
echo "📊 Summary:"
echo "  - Deleted hashes: $DELETED_COUNT"
echo "  - Freed space: $(echo $TOTAL_FREED | awk '{print int($1/1024/1024)"MB"}')"
echo "  - Database backup: $(basename "$BACKUP_FILE")"

# Show final status
echo ""
echo "📈 Remaining cache for $PROJECT:"
sqlite3 "$DB_FILE" "
SELECT 
    td.target,
    COALESCE(td.configuration, '(default)') as config,
    COUNT(*) as versions,
    printf('%.2f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
    MAX(datetime(co.accessed_at)) as last_accessed
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
WHERE td.project = '$PROJECT'
GROUP BY td.target, td.configuration
ORDER BY td.target, td.configuration;
"

if [ "$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE project = '$PROJECT';")" -eq 0 ]; then
    echo ""
    echo "🎯 Project '$PROJECT' has no remaining cache entries"
fi