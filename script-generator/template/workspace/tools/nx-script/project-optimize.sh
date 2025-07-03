#!/bin/bash
# project-optimize.sh
# Comprehensive optimization for specific project

PROJECT="$1"
KEEP_VERSIONS="${2:-3}"

if [ -z "$PROJECT" ]; then
    echo "Usage: $0 <project> [keep-versions]"
    echo ""
    echo "Examples:"
    echo "  $0 my-app                  # Optimize my-app, keep 3 versions"
    echo "  $0 my-app 2               # Optimize my-app, keep 2 versions"
    echo "  $0 frontend-app 1         # Optimize frontend-app, keep 1 version"
    echo ""
    echo "What this does:"
    echo "  1. Clean old cache versions for the project"
    echo "  2. Clean orphaned files related to the project"
    echo "  3. Clean orphaned database entries for the project"
    echo "  4. Clean suspicious items (system-wide)"
    echo "  5. Optimize database"
    exit 1
fi

# Auto-detect .nx location
if [ -d ".nx" ]; then
    NX_DIR=".nx"
elif [ -d "../.nx" ]; then
    NX_DIR="../.nx"
    cd ..
elif [ -d "../../.nx" ]; then
    NX_DIR="../../.nx"
    cd ../..
else
    echo "❌ .nx directory not found"
    exit 1
fi

DB_FILE=$(find "${NX_DIR}/workspace-data" -name "*.db" 2>/dev/null | head -1)
CACHE_DIR="${NX_DIR}/cache"
SCRIPT_DIR="$(dirname "${BASH_SOURCE[0]}")"

echo "🎯 Project Optimization: $PROJECT"
echo "Keep versions: $KEEP_VERSIONS"
echo "Working directory: $(pwd)"
echo ""

# Check if project exists
if [ -f "$DB_FILE" ]; then
    PROJECT_EXISTS=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE project = '$PROJECT';" 2>/dev/null || echo "0")
    if [ "$PROJECT_EXISTS" -eq 0 ]; then
        echo "❌ Project '$PROJECT' not found in cache database"
        echo ""
        echo "📋 Available projects:"
        sqlite3 "$DB_FILE" "SELECT DISTINCT project FROM task_details ORDER BY project;" 2>/dev/null || echo "No projects found"
        exit 1
    fi
fi

# Backup database
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
BACKUP_FILE="${DB_FILE}.optimize-backup.$TIMESTAMP"
cp "$DB_FILE" "$BACKUP_FILE"
echo "📦 Database backed up to: $(basename "$BACKUP_FILE")"
echo ""

# Step 1: Clean project cache versions
echo "📊 Step 1/5: Cleaning project cache versions..."
if [ -f "$SCRIPT_DIR/project-cache-cleanup-v2.sh" ]; then
    "$SCRIPT_DIR/project-cache-cleanup-v2.sh" "$PROJECT" "$KEEP_VERSIONS"
elif [ -f "$SCRIPT_DIR/cache-utilities.sh" ]; then
    "$SCRIPT_DIR/cache-utilities.sh" clean-project "$PROJECT" "$KEEP_VERSIONS"
else
    echo "⚠️  Project cleanup script not found, skipping..."
fi

echo ""

# Step 2: Clean orphaned files related to project
echo "📁 Step 2/5: Cleaning orphaned files related to $PROJECT..."

# Find orphaned folders that might be related to this project
ORPHANED_PROJECT_FILES=0
if [ -d "$CACHE_DIR" ]; then
    # Check each hash folder
    find "$CACHE_DIR" -name '[0-9]*' -type d 2>/dev/null | while read dir; do
        hash=$(basename "$dir")
        
        # Check if this hash exists in current database
        current_exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE hash = '$hash';" 2>/dev/null || echo "0")
        
        if [ "$current_exists" -eq 0 ]; then
            # This is an orphaned folder - check if it might belong to our project
            # We can't be 100% sure, but we can check size/age patterns
            size=$(du -sh "$dir" 2>/dev/null | cut -f1)
            echo "  📁 Found orphaned folder: $hash ($size)"
            
            # For now, we'll let the user decide if they want to clean these
            # In a full implementation, we might keep a history table to track project associations
        fi
    done
    
    echo "  💡 Orphaned files found. Use 'cache:clean:files' to remove them."
else
    echo "  ✅ No cache directory or no orphaned files found"
fi

echo ""

# Step 3: Clean DB orphans related to project
echo "🗄️ Step 3/5: Cleaning DB orphans related to $PROJECT..."

# Find database entries for this project that have no corresponding cache folder
ORPHANED_DB_COUNT=0
if [ -f "$DB_FILE" ]; then
    # Create temporary file for project's orphaned DB entries
    TEMP_ORPHANS="/tmp/project_orphans_$$"
    
    sqlite3 "$DB_FILE" "
        SELECT 
            td.hash,
            td.target,
            COALESCE(td.configuration, '(default)') as config,
            COALESCE(co.size, 0) as size
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project = '$PROJECT';
    " 2>/dev/null | while IFS='|' read hash target config size; do
        if [ -n "$hash" ] && [ ! -d "$CACHE_DIR/$hash" ]; then
            echo "$hash|$target|$config|$size" >> "$TEMP_ORPHANS"
        fi
    done
    
    # Process orphaned entries
    if [ -f "$TEMP_ORPHANS" ] && [ -s "$TEMP_ORPHANS" ]; then
        ORPHANED_DB_COUNT=$(wc -l < "$TEMP_ORPHANS" | tr -d ' ')
        echo "  🗄️ Found $ORPHANED_DB_COUNT orphaned DB entries for $PROJECT:"
        
        while IFS='|' read hash target config size; do
            size_mb=$(awk "BEGIN {printf \"%.1f\", $size / 1024 / 1024}")
            echo "    🗄️ $hash (${size_mb}MB) - $PROJECT:$target:$config"
        done < "$TEMP_ORPHANS"
        
        echo ""
        read -p "🤔 Delete these orphaned DB entries for $PROJECT? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            while IFS='|' read hash target config size; do
                sqlite3 "$DB_FILE" "
                    DELETE FROM cache_outputs WHERE hash = '$hash';
                    DELETE FROM task_details WHERE hash = '$hash';
                "
                size_mb=$(awk "BEGIN {printf \"%.1f\", $size / 1024 / 1024}")
                echo "    ✅ Deleted: $hash (${size_mb}MB) - $PROJECT:$target:$config"
            done < "$TEMP_ORPHANS"
        else
            echo "    ⏭️ Skipped orphaned DB cleanup"
        fi
        
        rm -f "$TEMP_ORPHANS"
    else
        echo "  ✅ No orphaned database entries found for $PROJECT"
    fi
else
    echo "  ❌ Database not accessible"
fi

echo ""

# Step 4: Clean suspicious items (system-wide)
echo "🚨 Step 4/5: Cleaning suspicious items (system-wide)..."
if [ -f "$SCRIPT_DIR/cache-utilities.sh" ]; then
    "$SCRIPT_DIR/cache-utilities.sh" clean-suspicious
else
    echo "  ⚠️ Cache utilities script not found, skipping..."
fi

echo ""

# Step 5: Optimize database
echo "🔄 Step 5/5: Optimizing database..."
if [ -f "$DB_FILE" ]; then
    sqlite3 "$DB_FILE" "VACUUM;" 2>/dev/null && echo "  ✅ Database optimized" || echo "  ⚠️ Database optimization failed"
else
    echo "  ❌ Database not accessible"
fi

echo ""

# Final status
echo "✅ Project optimization completed for: $PROJECT"
echo "📊 Summary:"
echo "  - Project: $PROJECT"
echo "  - Versions kept: $KEEP_VERSIONS per target"
echo "  - Orphaned DB entries for project: $ORPHANED_DB_COUNT (processed)"
echo "  - Database backup: $(basename "$BACKUP_FILE")"

echo ""
echo "📋 Final project status:"
if [ -f "$SCRIPT_DIR/project-cache-details.sh" ]; then
    "$SCRIPT_DIR/project-cache-details.sh" "$PROJECT"
elif [ -f "$SCRIPT_DIR/cache-utilities.sh" ]; then
    echo "Project cache entries:"
    sqlite3 "$DB_FILE" "
        SELECT 
            td.target,
            COALESCE(td.configuration, '(default)') as config,
            COUNT(*) as versions,
            printf('%.1f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
            MAX(datetime(co.accessed_at)) as last_accessed
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project = '$PROJECT'
        GROUP BY td.target, td.configuration
        ORDER BY td.target, td.configuration;
    " 2>/dev/null || echo "Unable to show project status"
else
    echo "Unable to show detailed project status"
fi

echo ""
echo "💡 Next steps:"
echo "  - Check overall cache health: pnpm cache:check"
echo "  - View project details: pnpm cache:project:info $PROJECT"
echo "  - Clean system orphans: pnpm cache:clean:files && pnpm cache:clean:db"