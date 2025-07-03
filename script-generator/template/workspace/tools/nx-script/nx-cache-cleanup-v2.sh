#!/bin/bash
# nx-cache-cleanup-v2.sh
# Updated script based on actual database schema with configurable keep versions

set -e

# Parse arguments
KEEP_VERSIONS=""
AUTO_CONFIRM=false
FORCE_MODE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            AUTO_CONFIRM=true
            shift
            ;;
        -f|--force)
            FORCE_MODE=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [options] [keep_versions]"
            echo ""
            echo "Parameters:"
            echo "  keep_versions    Number of versions to keep per project:target (default: 3)"
            echo "                   Use 0 to delete ALL cache entries"
            echo ""
            echo "Options:"
            echo "  -y, --yes       Auto-confirm all prompts (for CI/CD)"
            echo "  -f, --force     Force mode - skip safety checks (use with caution)"
            echo "  -h, --help      Show this help"
            echo ""
            echo "Examples:"
            echo "  $0              # Keep 3 versions (default)"
            echo "  $0 5            # Keep 5 versions per project"
            echo "  $0 1 -y         # Keep 1 version, auto-confirm"
            echo "  $0 0 -f -y      # Delete ALL cache, force mode, auto-confirm"
            echo "  $0 --yes 0      # Delete ALL cache, auto-confirm"
            echo ""
            echo "CI/CD Usage:"
            echo "  $0 3 --yes      # Safe for CI - keep 3, auto-confirm"
            echo "  $0 0 -f -y      # Dangerous - delete all cache"
            echo ""
            exit 0
            ;;
        [0-9]*)
            KEEP_VERSIONS="$1"
            shift
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Set default if not specified
KEEP_VERSIONS="${KEEP_VERSIONS:-3}"

# Validate that KEEP_VERSIONS is a number
if ! [[ "$KEEP_VERSIONS" =~ ^[0-9]+$ ]]; then
    echo "❌ Invalid keep versions: $KEEP_VERSIONS"
    echo "Must be a number (0 to delete all, 1+ to keep versions)"
    exit 1
fi

DB_FILE=$(ls .nx/workspace-data/*.db 2>/dev/null | head -1)
CACHE_DIR=".nx/cache"

if [ ! -f "$DB_FILE" ]; then
    echo "❌ Database file not found"
    exit 1
fi

echo "🧹 Nx Cache Cleanup (Configurable)"
echo "=================================="
echo "Database: $(basename "$DB_FILE")"
echo "Cache Directory: $CACHE_DIR"

if [ "$KEEP_VERSIONS" -eq 0 ]; then
    echo "Mode: 🚨 DELETE ALL CACHE"
    echo "Keep Versions: 0 (DELETE EVERYTHING)"
    if [ "$FORCE_MODE" = false ]; then
        echo "⚠️  WARNING: This will delete ALL cache entries!"
    fi
else
    echo "Mode: 🧹 Selective cleanup"
    echo "Keep Versions: $KEEP_VERSIONS per project"
fi

if [ "$AUTO_CONFIRM" = true ]; then
    echo "Auto-confirm: ✅ Enabled (CI mode)"
fi

if [ "$FORCE_MODE" = true ]; then
    echo "Force mode: ⚡ Enabled"
fi

echo ""

# Backup database
BACKUP_FILE="${DB_FILE}.backup.$(date +%Y%m%d-%H%M%S)"
cp "$DB_FILE" "$BACKUP_FILE"
echo "📦 Database backup: $(basename "$BACKUP_FILE")"

# Show current status
echo ""
echo "📊 Current cache status:"
sqlite3 "$DB_FILE" "
SELECT 
    project,
    target,
    configuration,
    COUNT(*) as total_versions
FROM task_details
GROUP BY project, target, configuration
ORDER BY project, target, configuration;
"

# Find hashes to delete
echo ""
if [ "$KEEP_VERSIONS" -eq 0 ]; then
    echo "🔍 Analyzing ALL cache entries for deletion..."
    
    # For delete all mode, get all hashes
    ALL_HASHES=$(sqlite3 "$DB_FILE" "SELECT hash FROM task_details ORDER BY hash;")
    TOTAL_ENTRIES=$(echo "$ALL_HASHES" | wc -l | tr -d ' ')
    
    echo "📋 DELETE ALL MODE:"
    echo "  Total cache entries: $TOTAL_ENTRIES"
    echo "  All entries will be deleted!"
    
    if [ "$FORCE_MODE" = false ] && [ "$AUTO_CONFIRM" = false ]; then
        echo ""
        echo "⚠️  WARNING: This will delete ALL cache entries!"
        echo "⚠️  This action cannot be undone!"
        echo "💡 Consider using a specific number instead of 0"
        echo ""
    fi
    
    HASHES_TO_DELETE="$ALL_HASHES"
    
else
    echo "🔍 Analyzing hashes to delete (keeping $KEEP_VERSIONS versions)..."
    
    CLEANUP_ANALYSIS=$(sqlite3 "$DB_FILE" "
    WITH ranked_cache AS (
        SELECT 
            td.hash,
            td.project,
            td.target,
            td.configuration,
            co.created_at,
            co.accessed_at,
            co.size,
            ROW_NUMBER() OVER (
                PARTITION BY td.project, td.target, COALESCE(td.configuration, '') 
                ORDER BY co.accessed_at DESC, co.created_at DESC
            ) as rank
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
    )
    SELECT 
        project,
        target,
        configuration,
        COUNT(*) as total,
        COUNT(CASE WHEN rank <= $KEEP_VERSIONS THEN 1 END) as keep,
        COUNT(CASE WHEN rank > $KEEP_VERSIONS THEN 1 END) as delete_count
    FROM ranked_cache
    GROUP BY project, target, configuration
    HAVING delete_count > 0
    ORDER BY project, target;
    ")
    
    if [ -z "$CLEANUP_ANALYSIS" ]; then
        echo "✅ No cleanup needed - all projects have ≤ $KEEP_VERSIONS versions"
        rm "$BACKUP_FILE"
        exit 0
    fi
    
    echo "📋 Projects needing cleanup:"
    echo "$CLEANUP_ANALYSIS" | while IFS='|' read project target config total keep delete; do
        config_display=${config:-"(default)"}
        echo "  📦 $project:$target [$config_display] - Keep: $keep, Delete: $delete"
    done
    
    # Calculate totals
    TOTAL_TO_DELETE=$(echo "$CLEANUP_ANALYSIS" | awk -F'|' '{sum += $6} END {print sum+0}')
    TOTAL_PROJECTS=$(echo "$CLEANUP_ANALYSIS" | wc -l | tr -d ' ')
    
    echo ""
    echo "📊 Cleanup Summary:"
    echo "  Projects affected: $TOTAL_PROJECTS"
    echo "  Total entries to delete: $TOTAL_TO_DELETE"
    echo "  Keeping: $KEEP_VERSIONS versions per project:target"
    
    # Get hashes to delete
    HASHES_TO_DELETE=$(sqlite3 "$DB_FILE" "
    WITH ranked_cache AS (
        SELECT 
            td.hash,
            td.project,
            td.target,
            td.configuration,
            co.created_at,
            co.accessed_at,
            co.size,
            ROW_NUMBER() OVER (
                PARTITION BY td.project, td.target, COALESCE(td.configuration, '') 
                ORDER BY co.accessed_at DESC, co.created_at DESC
            ) as rank
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
    )
    SELECT hash 
    FROM ranked_cache 
    WHERE rank > $KEEP_VERSIONS
    ORDER BY accessed_at;
    ")
fi

# Show sample hashes (unless in delete-all mode with force)
if [ "$KEEP_VERSIONS" -ne 0 ] || [ "$FORCE_MODE" = false ]; then
    echo ""
    echo "🗑️  Sample hashes to delete (first 5):"
    echo "$HASHES_TO_DELETE" | head -5 | while read hash; do
        if [ -n "$hash" ]; then
            # Get details from database
            DETAILS=$(sqlite3 "$DB_FILE" "
                SELECT 
                    td.project || ':' || td.target || 
                    CASE WHEN td.configuration IS NOT NULL THEN ':' || td.configuration ELSE '' END as task,
                    co.size,
                    datetime(co.accessed_at) as last_accessed
                FROM task_details td
                LEFT JOIN cache_outputs co ON td.hash = co.hash
                WHERE td.hash = '$hash';
            ")
            
            SIZE_MB=$(echo "$DETAILS" | cut -d'|' -f2)
            TASK=$(echo "$DETAILS" | cut -d'|' -f1)
            ACCESSED=$(echo "$DETAILS" | cut -d'|' -f3)
            
            echo "  📁 $(echo $hash | cut -c1-20)... - $TASK"
            echo "     Last accessed: ${ACCESSED:-unknown}"
            
            # Check filesystem
            if [ -d "$CACHE_DIR/$hash" ]; then
                FS_SIZE=$(du -sh "$CACHE_DIR/$hash" 2>/dev/null | cut -f1)
                echo "     Folder size: $FS_SIZE"
            else
                echo "     (folder not found on filesystem)"
            fi
            echo ""
        fi
    done
    
    # Show total if more than 5
    TOTAL_HASHES=$(echo "$HASHES_TO_DELETE" | wc -l | tr -d ' ')
    if [ "$TOTAL_HASHES" -gt 5 ]; then
        echo "  ... and $((TOTAL_HASHES - 5)) more hashes"
    fi
fi

# Confirmation logic
PROCEED=false

if [ "$AUTO_CONFIRM" = true ]; then
    echo ""
    echo "🤖 Auto-confirm enabled - proceeding automatically"
    PROCEED=true
elif [ "$KEEP_VERSIONS" -eq 0 ] && [ "$FORCE_MODE" = false ]; then
    echo ""
    echo "🚨 DANGER: You are about to delete ALL cache entries!"
    echo "🚨 This will remove EVERY cached build, test, and task result!"
    echo "🚨 Type 'DELETE ALL CACHE' to confirm:"
    read -r CONFIRMATION
    if [ "$CONFIRMATION" = "DELETE ALL CACHE" ]; then
        PROCEED=true
    else
        echo "❌ Confirmation failed. Cleanup cancelled."
        rm "$BACKUP_FILE"
        exit 0
    fi
else
    read -p "🤔 Proceed with cleanup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        PROCEED=true
    fi
fi

if [ "$PROCEED" = false ]; then
    echo "❌ Cleanup cancelled"
    rm "$BACKUP_FILE"
    exit 0
fi

# Perform cleanup
echo ""
echo "🗄️  Cleaning database..."

DELETED_FOLDERS=0
TOTAL_FREED_SIZE=0

echo "$HASHES_TO_DELETE" | while read hash; do
    if [ -n "$hash" ]; then
        # Get size before deletion
        SIZE=$(sqlite3 "$DB_FILE" "SELECT size FROM cache_outputs WHERE hash = '$hash';" 2>/dev/null || echo "0")
        
        # Delete from cache_outputs
        sqlite3 "$DB_FILE" "DELETE FROM cache_outputs WHERE hash = '$hash';"
        
        # Delete from task_details
        sqlite3 "$DB_FILE" "DELETE FROM task_details WHERE hash = '$hash';"
        
        # Delete cache folder
        if [ -d "$CACHE_DIR/$hash" ]; then
            FOLDER_SIZE=$(du -sb "$CACHE_DIR/$hash" 2>/dev/null | cut -f1 || echo "0")
            rm -rf "$CACHE_DIR/$hash"
            echo "  ✅ Deleted: $(echo $hash | cut -c1-16)... ($(echo $FOLDER_SIZE | awk '{print int($1/1024/1024)"MB"}'))"
            DELETED_FOLDERS=$((DELETED_FOLDERS + 1))
            TOTAL_FREED_SIZE=$((TOTAL_FREED_SIZE + FOLDER_SIZE))
        fi
    fi
done

# Get actual deletion counts
FINAL_CACHE_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM cache_outputs;")
FINAL_TASK_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details;")

# VACUUM database
echo ""
echo "🔄 Optimizing database..."
sqlite3 "$DB_FILE" "VACUUM;"

echo ""
echo "✅ Cleanup completed!"
echo "📊 Summary:"
if [ "$KEEP_VERSIONS" -eq 0 ]; then
    echo "  - Mode: 🚨 DELETE ALL CACHE"
    echo "  - All cache entries deleted"
else
    echo "  - Mode: 🧹 Selective cleanup"
    echo "  - Keep versions setting: $KEEP_VERSIONS"
fi
echo "  - Deleted folders: $DELETED_FOLDERS"
echo "  - Freed space: $(echo $TOTAL_FREED_SIZE | awk '{print int($1/1024/1024)"MB"}')"
echo "  - Remaining cache entries: $FINAL_CACHE_COUNT"
echo "  - Remaining task entries: $FINAL_TASK_COUNT"
echo "  - Database backup: $(basename "$BACKUP_FILE")"

# Show final status only if there are remaining entries
if [ "$FINAL_CACHE_COUNT" -gt 0 ]; then
    echo ""
    echo "📈 Final cache status:"
    sqlite3 "$DB_FILE" "
    SELECT 
        project,
        target,
        COALESCE(configuration, '(default)') as config,
        COUNT(*) as versions,
        printf('%.2f MB', SUM(CAST(size AS REAL)/1024/1024)) as total_size
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    GROUP BY project, target, configuration
    ORDER BY project, target, configuration;
    "
else
    echo ""
    echo "🎯 Cache is now completely empty!"
    if [ "$KEEP_VERSIONS" -eq 0 ]; then
        echo "💡 Next builds will start fresh without any cached results"
    fi
fi