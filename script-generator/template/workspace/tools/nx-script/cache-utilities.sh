#!/bin/bash
# cache-utilities.sh
# Collection of utility functions for Nx cache management - COMPLETE VERSION

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

DB_FILE=$(find "${NX_DIR}/workspace-data" -name "*.db" 2>/dev/null | head -1)
CACHE_DIR="${NX_DIR}/cache"

# Official Nx cache items (not orphaned)
OFFICIAL_ITEMS=("terminalOutputs" "cloud" "d" "run.json")

# Function to check if item is official Nx item
is_official_item() {
    local item_name="$1"
    for official in "${OFFICIAL_ITEMS[@]}"; do
        if [ "$item_name" = "$official" ]; then
            return 0  # is official
        fi
    done
    return 1  # not official
}

# Function to show all projects
show_projects() {
    echo "📋 Available Projects:"
    if [ -f "$DB_FILE" ]; then
        sqlite3 "$DB_FILE" "
            SELECT DISTINCT project 
            FROM task_details 
            ORDER BY project;
        "
    else
        echo "❌ Database not found at: $DB_FILE"
    fi
}

# Function to show targets for a project
show_targets() {
    local project="$1"
    if [ -z "$project" ]; then
        echo "Usage: show_targets <project>"
        return 1
    fi
    
    echo "🎯 Targets for project '$project':"
    sqlite3 "$DB_FILE" "
        SELECT DISTINCT target 
        FROM task_details 
        WHERE project = '$project'
        ORDER BY target;
    "
}

# Helper function to generate cache analysis
generate_cache_analysis() {
    if [ ! -d "$CACHE_DIR" ]; then
        echo "❌ Cache directory not found: $CACHE_DIR"
        return 1
    fi
    
    # Analyze all items in cache directory
    find "$CACHE_DIR" -maxdepth 1 | while read item; do
        if [ "$item" != "$CACHE_DIR" ]; then
            name=$(basename "$item")
            
            if [ -d "$item" ]; then
                size=$(du -sh "$item" 2>/dev/null | cut -f1)
                size_bytes=$(du -sb "$item" 2>/dev/null | cut -f1)
            elif [ -f "$item" ]; then
                size=$(du -sh "$item" 2>/dev/null | cut -f1)
                size_bytes=$(du -sb "$item" 2>/dev/null | cut -f1)
            else
                continue
            fi
            
            if [ -z "$size_bytes" ]; then
                size_bytes=0
            fi
            
            # Categorize the item
            if is_official_item "$name"; then
                # Official Nx item - not orphaned
                echo "OFFICIAL:$name:$size:$size_bytes"
            elif [[ "$name" =~ ^[0-9]+$ ]]; then
                # Hash folder - check if exists in database
                exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE hash = '$name';" 2>/dev/null || echo "0")
                if [ "$exists" -eq 0 ]; then
                    echo "ORPHANED:$name:$size:$size_bytes"
                else
                    echo "VALID:$name:$size:$size_bytes"
                fi
            else
                # Suspicious item (not hash, not official)
                echo "SUSPICIOUS:$name:$size:$size_bytes"
            fi
        fi
    done > /tmp/cache_analysis.txt
}

# Function to find orphaned cache folders - COMPREHENSIVE VERSION
find_orphaned_folders() {
    echo "🔍 Finding orphaned cache folders..."
    
    # Generate filesystem analysis
    generate_cache_analysis
    
    if [ ! -f "/tmp/cache_analysis.txt" ]; then
        echo "❌ Unable to analyze cache structure"
        return 1
    fi
    
    echo ""
    echo "📁 Analysis Results:"
    
    # Process filesystem results
    echo ""
    echo "📊 Official Nx items:"
    while IFS=':' read type name size size_bytes; do
        if [ "$type" = "OFFICIAL" ]; then
            echo "  ✅ $name ($size)"
        fi
    done < /tmp/cache_analysis.txt
    
    echo ""
    echo "📁 Orphaned hash folders (exist in filesystem but not in database):"
    local found_orphaned_fs=false
    local orphaned_fs_count=0
    local total_orphaned_fs_size=0
    while IFS=':' read type name size size_bytes; do
        if [ "$type" = "ORPHANED" ]; then
            echo "  📁 $name ($size)"
            orphaned_fs_count=$((orphaned_fs_count + 1))
            total_orphaned_fs_size=$((total_orphaned_fs_size + size_bytes))
            found_orphaned_fs=true
        fi
    done < /tmp/cache_analysis.txt
    
    if [ "$found_orphaned_fs" = false ]; then
        echo "  ✅ No orphaned filesystem folders found"
    fi
    
    echo ""
    echo "🗄️  Orphaned database entries (exist in database but not in filesystem):"
    local orphaned_db_count=0
    local total_orphaned_db_size=0
    local found_orphaned_db=false
    
    # Create temporary file for database orphans
    local temp_db_orphans="/tmp/orphaned_db_entries.txt"
    > "$temp_db_orphans"  # Clear the file
    
    # Check database entries that don't have corresponding folders
    sqlite3 "$DB_FILE" "
        SELECT 
            td.hash,
            printf('%.2f', CAST(co.size AS REAL)/1024/1024) as size_mb,
            co.size,
            td.project || ':' || td.target as task,
            strftime('%Y-%m-%d %H:%M', co.accessed_at) as last_accessed
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        ORDER BY co.accessed_at DESC;
    " 2>/dev/null | while IFS='|' read hash size_mb size_bytes task last_accessed; do
        if [ -n "$hash" ] && [ ! -d "$CACHE_DIR/$hash" ]; then
            echo "$hash|$size_mb|$size_bytes|$task|$last_accessed" >> "$temp_db_orphans"
        fi
    done
    
    # Process database orphans safely
    if [ -s "$temp_db_orphans" ]; then
        while IFS='|' read hash size_mb size_bytes task last_accessed; do
            echo "  🗄️  $hash (${size_mb}MB) - $task [${last_accessed:-'unknown'}]"
            orphaned_db_count=$((orphaned_db_count + 1))
            if [ -n "$size_bytes" ] && [ "$size_bytes" -ne 0 ] 2>/dev/null; then
                total_orphaned_db_size=$((total_orphaned_db_size + size_bytes))
            fi
            found_orphaned_db=true
        done < "$temp_db_orphans"
    else
        echo "  ✅ No orphaned database entries found"
    fi
    
    echo ""
    echo "🚨 Suspicious items (not standard Nx cache structure):"
    local found_suspicious=false
    local suspicious_count=0
    local total_suspicious_size=0
    while IFS=':' read type name size size_bytes; do
        if [ "$type" = "SUSPICIOUS" ]; then
            echo "  🚨 $name ($size) ← Should not be here!"
            suspicious_count=$((suspicious_count + 1))
            total_suspicious_size=$((total_suspicious_size + size_bytes))
            found_suspicious=true
        fi
    done < /tmp/cache_analysis.txt
    
    if [ "$found_suspicious" = false ]; then
        echo "  ✅ No suspicious items found"
    fi
    
    # Comprehensive Summary
    echo ""
    echo "📊 Comprehensive Summary:"
    if [ "$orphaned_fs_count" -gt 0 ]; then
        orphaned_fs_size_mb=$(awk "BEGIN {printf \"%.1f\", $total_orphaned_fs_size / 1024 / 1024}")
        echo "  📁 Orphaned filesystem folders: $orphaned_fs_count (${orphaned_fs_size_mb}MB)"
    fi
    
    if [ "$orphaned_db_count" -gt 0 ]; then
        orphaned_db_size_mb=$(awk "BEGIN {printf \"%.1f\", $total_orphaned_db_size / 1024 / 1024}")
        echo "  🗄️  Orphaned database entries: $orphaned_db_count (${orphaned_db_size_mb}MB recorded)"
    fi
    
    if [ "$suspicious_count" -gt 0 ]; then
        suspicious_size_mb=$(awk "BEGIN {printf \"%.1f\", $total_suspicious_size / 1024 / 1024}")
        echo "  🚨 Suspicious items: $suspicious_count (${suspicious_size_mb}MB)"
    fi
    
    # Overall status
    if [ "$orphaned_fs_count" -eq 0 ] && [ "$orphaned_db_count" -eq 0 ] && [ "$suspicious_count" -eq 0 ]; then
        echo "  ✅ Cache structure is perfectly clean!"
    else
        echo ""
        echo "💡 Recommended actions:"
        if [ "$orphaned_fs_count" -gt 0 ]; then
            echo "  • Use 'clean-orphaned' to remove filesystem orphans"
        fi
        if [ "$orphaned_db_count" -gt 0 ]; then
            echo "  • Use 'clean-db-orphans' to remove database orphans"
        fi
        if [ "$suspicious_count" -gt 0 ]; then
            echo "  • Use 'clean-suspicious' to remove suspicious items"
        fi
    fi
    
    # Cleanup temp files
    rm -f /tmp/cache_analysis.txt /tmp/orphaned_db.txt
}

# Function to clean orphaned folders - FIXED VERSION
clean_orphaned_folders() {
    echo "🧹 Cleaning orphaned cache folders..."
    
    # Generate analysis
    generate_cache_analysis
    
    if [ ! -f "/tmp/cache_analysis.txt" ]; then
        echo "❌ Unable to analyze cache structure"
        return 1
    fi
    
    # Count orphaned items
    ORPHANED_COUNT=$(grep "^ORPHANED:" /tmp/cache_analysis.txt | wc -l | tr -d ' ')
    
    if [ "$ORPHANED_COUNT" -eq 0 ]; then
        echo "✅ No orphaned hash folders found"
        rm -f /tmp/cache_analysis.txt
        return 0
    fi
    
    echo ""
    echo "📁 Found orphaned hash folders:"
    local total_size=0
    while IFS=':' read type name size size_bytes; do
        if [ "$type" = "ORPHANED" ]; then
            echo "  📁 $name ($size)"
            total_size=$((total_size + size_bytes))
        fi
    done < /tmp/cache_analysis.txt
    
    total_size_mb=$(awk "BEGIN {printf \"%.1f\", $total_size / 1024 / 1024}")
    echo ""
    echo "Total to delete: ${total_size_mb}MB"
    
    read -p "🤔 Delete orphaned hash folders? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        rm -f /tmp/cache_analysis.txt
        return 0
    fi
    
    # Delete orphaned folders
    local deleted_count=0
    while IFS=':' read type name size size_bytes; do
        if [ "$type" = "ORPHANED" ]; then
            if [ -d "$CACHE_DIR/$name" ]; then
                rm -rf "$CACHE_DIR/$name"
                echo "  ✅ Deleted: $name"
                deleted_count=$((deleted_count + 1))
            fi
        fi
    done < /tmp/cache_analysis.txt
    
    echo ""
    echo "✅ Cleanup completed!"
    echo "  Deleted folders: $deleted_count"
    echo "  Freed space: ${total_size_mb}MB"
    
    rm -f /tmp/cache_analysis.txt
}

# Function to clean suspicious items - FIXED VERSION
clean_suspicious_items() {
    echo "🧹 Cleaning suspicious cache items..."
    
    # Generate analysis
    generate_cache_analysis
    
    if [ ! -f "/tmp/cache_analysis.txt" ]; then
        echo "❌ Unable to analyze cache structure"
        return 1
    fi
    
    # Count suspicious items
    SUSPICIOUS_COUNT=$(grep "^SUSPICIOUS:" /tmp/cache_analysis.txt | wc -l | tr -d ' ')
    
    if [ "$SUSPICIOUS_COUNT" -eq 0 ]; then
        echo "✅ No suspicious items found"
        rm -f /tmp/cache_analysis.txt
        return 0
    fi
    
    echo ""
    echo "🚨 Found suspicious items:"
    local total_size=0
    while IFS=':' read type name size size_bytes; do
        if [ "$type" = "SUSPICIOUS" ]; then
            echo "  🚨 $name ($size) ← Not standard Nx cache structure"
            total_size=$((total_size + size_bytes))
        fi
    done < /tmp/cache_analysis.txt
    
    total_size_mb=$(awk "BEGIN {printf \"%.1f\", $total_size / 1024 / 1024}")
    echo ""
    echo "Total to delete: ${total_size_mb}MB"
    echo ""
    echo "⚠️  WARNING: These items are not part of standard Nx cache structure"
    echo "   They might be created by mistake or other tools"
    
    read -p "🤔 Delete suspicious items? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        rm -f /tmp/cache_analysis.txt
        return 0
    fi
    
    # Delete suspicious items
    local deleted_count=0
    while IFS=':' read type name size size_bytes; do
        if [ "$type" = "SUSPICIOUS" ]; then
            if [ -d "$CACHE_DIR/$name" ]; then
                rm -rf "$CACHE_DIR/$name"
                echo "  ✅ Deleted folder: $name"
                deleted_count=$((deleted_count + 1))
            elif [ -f "$CACHE_DIR/$name" ]; then
                rm -f "$CACHE_DIR/$name"
                echo "  ✅ Deleted file: $name"
                deleted_count=$((deleted_count + 1))
            fi
        fi
    done < /tmp/cache_analysis.txt
    
    echo ""
    echo "✅ Cleanup completed!"
    echo "  Deleted items: $deleted_count"
    echo "  Freed space: ${total_size_mb}MB"
    
    rm -f /tmp/cache_analysis.txt
}

# Function to clean orphaned database entries
clean_db_orphans() {
    echo "🧹 Cleaning orphaned database entries..."
    
    if [ ! -f "$DB_FILE" ]; then
        echo "❌ Database not found: $DB_FILE"
        return 1
    fi
    
    if [ ! -d "$CACHE_DIR" ]; then
        echo "❌ Cache directory not found: $CACHE_DIR"
        return 1
    fi
    
    # Create temporary file for database orphans
    local temp_db_orphans="/tmp/orphaned_db_entries.txt"
    > "$temp_db_orphans"  # Clear the file
    
    echo "🔍 Finding orphaned database entries..."
    
    # Check database entries that don't have corresponding folders
    sqlite3 "$DB_FILE" "
        SELECT 
            td.hash,
            printf('%.2f', CAST(co.size AS REAL)/1024/1024) as size_mb,
            co.size,
            td.project || ':' || td.target as task
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        ORDER BY co.accessed_at DESC;
    " 2>/dev/null | while IFS='|' read hash size_mb size_bytes task; do
        if [ -n "$hash" ] && [ ! -d "$CACHE_DIR/$hash" ]; then
            echo "$hash|$size_mb|$size_bytes|$task" >> "$temp_db_orphans"
        fi
    done
    
    # Count orphaned entries
    if [ ! -s "$temp_db_orphans" ]; then
        echo "✅ No orphaned database entries found"
        rm -f "$temp_db_orphans"
        return 0
    fi
    
    local orphaned_count=$(wc -l < "$temp_db_orphans" | tr -d ' ')
    local total_size=0
    
    echo ""
    echo "📋 Found orphaned database entries:"
    while IFS='|' read hash size_mb size_bytes task; do
        echo "  🗄️  $hash (${size_mb}MB) - $task"
        if [ -n "$size_bytes" ] && [ "$size_bytes" -ne 0 ] 2>/dev/null; then
            total_size=$((total_size + size_bytes))
        fi
    done < "$temp_db_orphans"
    
    local total_size_mb=$(awk "BEGIN {printf \"%.1f\", $total_size / 1024 / 1024}")
    
    echo ""
    echo "📊 Summary:"
    echo "  Orphaned database entries: $orphaned_count"
    echo "  Total recorded size: ${total_size_mb}MB"
    echo ""
    
    read -p "🤔 Delete these orphaned database entries? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Cancelled"
        rm -f "$temp_db_orphans"
        return 0
    fi
    
    # Backup database
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="${DB_FILE}.backup.$timestamp"
    cp "$DB_FILE" "$backup_file"
    echo "📦 Database backed up to: $(basename "$backup_file")"
    
    # Delete orphaned entries
    local deleted_count=0
    echo ""
    echo "🗄️  Cleaning database..."
    
    while IFS='|' read hash size_mb size_bytes task; do
        if [ -n "$hash" ]; then
            # Delete from both tables
            sqlite3 "$DB_FILE" "
                DELETE FROM cache_outputs WHERE hash = '$hash';
                DELETE FROM task_details WHERE hash = '$hash';
            "
            echo "  ✅ Deleted: $hash (${size_mb}MB) - $task"
            deleted_count=$((deleted_count + 1))
        fi
    done < "$temp_db_orphans"
    
    # Optimize database
    echo ""
    echo "🔄 Optimizing database..."
    sqlite3 "$DB_FILE" "VACUUM;"
    
    echo ""
    echo "✅ Cleanup completed!"
    echo "📊 Summary:"
    echo "  Deleted database entries: $deleted_count"
    echo "  Freed recorded space: ${total_size_mb}MB"
    echo "  Database backup: $(basename "$backup_file")"
    
    # Final verification
    local remaining_orphans=$(sqlite3 "$DB_FILE" "
        SELECT COUNT(*)
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE co.hash IS NULL;
    " 2>/dev/null || echo "0")
    
    echo "  Remaining orphaned task entries: $remaining_orphans"
    
    # Cleanup temp files
    rm -f "$temp_db_orphans"
}

# Function to show projects with many versions - FIXED VERSION
show_projects_with_many_versions() {
    local min_versions="${1:-3}"
    echo "📊 Projects with more than $min_versions cache versions:"
    
    if [ ! -f "$DB_FILE" ]; then
        echo "❌ Database not found: $DB_FILE"
        return 1
    fi
    
    echo ""
    echo "📋 Analysis Results:"
    
    # Query projects with many versions
    local query_result
    query_result=$(sqlite3 "$DB_FILE" "
        SELECT 
            td.project,
            td.target,
            COALESCE(td.configuration, '(default)') as config,
            COUNT(*) as version_count,
            printf('%.2f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
            MAX(datetime(co.accessed_at)) as last_accessed,
            MIN(datetime(co.accessed_at)) as first_accessed
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        GROUP BY td.project, td.target, td.configuration
        HAVING COUNT(*) > $min_versions
        ORDER BY COUNT(*) DESC, SUM(co.size) DESC;
    " 2>/dev/null)
    
    if [ -z "$query_result" ]; then
        echo "✅ No projects found with more than $min_versions versions"
        echo "💡 All projects are well-maintained!"
        return 0
    fi
    
    # Display header
    printf "%-35s %-15s %-12s %-10s %-20s %-20s\n" "PROJECT:TARGET" "CONFIG" "VERSIONS" "SIZE" "LAST_ACCESS" "FIRST_ACCESS"
    echo "$(printf '%.0s-' {1..120})"
    
    # Display results
    echo "$query_result" | while IFS='|' read project target config versions size last_accessed first_accessed; do
        project_target="${project}:${target}"
        printf "%-35s %-15s %-12s %-10s %-20s %-20s\n" \
            "${project_target:0:34}" \
            "${config:0:14}" \
            "$versions" \
            "$size" \
            "${last_accessed:0:19}" \
            "${first_accessed:0:19}"
    done
    
    echo ""
    
    # Summary statistics
    local total_projects
    local total_versions
    local total_size
    local potential_savings
    
    total_projects=$(echo "$query_result" | wc -l | tr -d ' ')
    total_versions=$(echo "$query_result" | awk -F'|' '{sum += $4} END {print sum+0}')
    
    total_size=$(sqlite3 "$DB_FILE" "
        WITH projects_with_many AS (
            SELECT td.project, td.target, td.configuration
            FROM task_details td
            GROUP BY td.project, td.target, td.configuration
            HAVING COUNT(*) > $min_versions
        )
        SELECT printf('%.2f MB', SUM(CAST(co.size AS REAL)/1024/1024))
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE (td.project, td.target, COALESCE(td.configuration, '')) IN (
            SELECT project, target, COALESCE(configuration, '') FROM projects_with_many
        );
    " 2>/dev/null)
    
    potential_savings=$(sqlite3 "$DB_FILE" "
        WITH ranked_versions AS (
            SELECT 
                td.project, td.target, td.configuration, co.size,
                ROW_NUMBER() OVER (
                    PARTITION BY td.project, td.target, COALESCE(td.configuration, '') 
                    ORDER BY co.accessed_at DESC, co.created_at DESC
                ) as rank
            FROM task_details td
            LEFT JOIN cache_outputs co ON td.hash = co.hash
        ),
        projects_with_many AS (
            SELECT td.project, td.target, td.configuration
            FROM task_details td
            GROUP BY td.project, td.target, td.configuration
            HAVING COUNT(*) > $min_versions
        )
        SELECT printf('%.2f MB', SUM(CAST(size AS REAL)/1024/1024))
        FROM ranked_versions rv
        WHERE rv.rank > $min_versions
        AND (rv.project, rv.target, COALESCE(rv.configuration, '')) IN (
            SELECT project, target, COALESCE(configuration, '') FROM projects_with_many
        );
    " 2>/dev/null)
    
    echo "📊 Summary:"
    echo "  🎯 Projects needing cleanup: $total_projects"
    echo "  📦 Total excess versions: $total_versions"
    echo "  💾 Total size involved: ${total_size:-0 MB}"
    echo "  💰 Potential savings: ${potential_savings:-0 MB} (if cleaned to $min_versions versions each)"
    
    echo ""
    echo "💡 Recommended actions:"
    echo "  1. Review projects with most versions first"
    echo "  2. Use: ./cache-utilities.sh clean-project <project> $min_versions"
    echo "  3. Or use: pnpm cache:project:clean <project> $min_versions"
}

# Function to show cache age distribution
show_cache_age_distribution() {
    echo "📅 Cache Age Distribution:"
    sqlite3 "$DB_FILE" "
        SELECT 
            CASE 
                WHEN julianday('now') - julianday(co.accessed_at) <= 1 THEN '📅 Last 24 hours'
                WHEN julianday('now') - julianday(co.accessed_at) <= 7 THEN '📅 Last week'
                WHEN julianday('now') - julianday(co.accessed_at) <= 30 THEN '📅 Last month'
                WHEN julianday('now') - julianday(co.accessed_at) <= 90 THEN '📅 Last 3 months'
                ELSE '📅 Older than 3 months'
            END as age_group,
            COUNT(*) as count,
            printf('%.1f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
            printf('%.1f%%', COUNT(*) * 100.0 / (SELECT COUNT(*) FROM cache_outputs)) as percentage
        FROM cache_outputs co
        GROUP BY age_group
        ORDER BY 
            CASE age_group
                WHEN '📅 Last 24 hours' THEN 1
                WHEN '📅 Last week' THEN 2
                WHEN '📅 Last month' THEN 3
                WHEN '📅 Last 3 months' THEN 4
                ELSE 5
            END;
    "
}

# Function to backup cache database
backup_database() {
    if [ ! -f "$DB_FILE" ]; then
        echo "❌ Database not found: $DB_FILE"
        return 1
    fi
    
    local timestamp=$(date +%Y%m%d-%H%M%S)
    local backup_file="${DB_FILE}.backup.$timestamp"
    
    cp "$DB_FILE" "$backup_file"
    echo "📦 Database backed up to: $(basename "$backup_file")"
    
    # Compress if large
    local size
    if [[ "$OSTYPE" == "darwin"* ]]; then
        size=$(stat -f%z "$backup_file" 2>/dev/null || echo "0")
    else
        size=$(stat -c%s "$backup_file" 2>/dev/null || echo "0")
    fi
    
    if [ "$size" -gt 10485760 ]; then  # 10MB
        gzip "$backup_file"
        echo "🗜️  Compressed backup: $(basename "$backup_file").gz"
    fi
}

# Function to show recent activity
show_recent_activity() {
    local limit="${1:-20}"
    echo "⏰ Recent Cache Activity (last $limit):"
    sqlite3 "$DB_FILE" "
        SELECT 
            datetime(co.accessed_at) as accessed,
            td.project || ':' || td.target || 
            CASE WHEN td.configuration IS NOT NULL THEN ':' || td.configuration ELSE '' END as task,
            substr(td.hash, 1, 8) || '...' as hash_short,
            printf('%.1f MB', CAST(co.size AS REAL)/1024/1024) as size
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        ORDER BY co.accessed_at DESC
        LIMIT $limit;
    "
}

# Function to search cache by pattern
search_cache() {
    local pattern="$1"
    if [ -z "$pattern" ]; then
        echo "Usage: search_cache <pattern>"
        echo "Example: search_cache 'my-app'"
        return 1
    fi
    
    echo "🔍 Searching cache for pattern: '$pattern'"
    sqlite3 "$DB_FILE" "
        SELECT 
            td.project,
            td.target,
            COALESCE(td.configuration, '(default)') as config,
            substr(td.hash, 1, 12) || '...' as hash_short,
            datetime(co.accessed_at) as last_accessed,
            printf('%.1f MB', CAST(co.size AS REAL)/1024/1024) as size
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project LIKE '%$pattern%' 
           OR td.target LIKE '%$pattern%'
           OR td.configuration LIKE '%$pattern%'
        ORDER BY co.accessed_at DESC;
    "
}

# Function to count orphaned entries (helper for health score)
count_orphaned_entries() {
    local orphaned_count=0
    
    if [ ! -f "$DB_FILE" ] || [ ! -d "$CACHE_DIR" ]; then
        echo "0"
        return
    fi
    
    # Count filesystem orphans (folders without DB entries)
    while read dir; do
        if [ "$dir" != "$CACHE_DIR" ]; then
            local name=$(basename "$dir")
            if [[ "$name" =~ ^[0-9]+$ ]]; then
                local exists=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE hash = '$name';" 2>/dev/null || echo "0")
                if [ "$exists" -eq 0 ]; then
                    orphaned_count=$((orphaned_count + 1))
                fi
            fi
        fi
    done < <(find "$CACHE_DIR" -maxdepth 1 -type d 2>/dev/null)
    
    echo "$orphaned_count"
}

# Function to validate cache size and provide detailed analysis
validate_cache_size() {
    echo "🔍 Detailed Cache Size Validation"
    echo "================================="
    echo ""
    
    if [ ! -d "$CACHE_DIR" ]; then
        echo "❌ Cache directory not found: $CACHE_DIR"
        return 1
    fi
    
    # Count entries
    local cache_count=$(find "$CACHE_DIR" -name '[0-9]*' -type d 2>/dev/null | wc -l | tr -d ' ')
    echo "📊 Cache Entries: $cache_count"
    
    # Calculate total cache size
    local cache_size_bytes
    if [[ "$OSTYPE" == "darwin"* ]]; then
        cache_size_bytes=$(find "$CACHE_DIR" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
    else
        cache_size_bytes=$(du -sb "$CACHE_DIR" 2>/dev/null | cut -f1 || echo "0")
    fi
    
    if [ -z "$cache_size_bytes" ]; then
        cache_size_bytes=0
    fi
    
    local cache_size_mb=$(awk "BEGIN {printf \"%.2f\", $cache_size_bytes / 1024 / 1024}")
    local cache_size_gb=$(awk "BEGIN {printf \"%.2f\", $cache_size_bytes / 1024 / 1024 / 1024}")
    
    echo "💾 Total Cache Size: ${cache_size_mb}MB (${cache_size_gb}GB)"
    
    # Size breakdown
    echo ""
    echo "📂 Size Breakdown:"
    
    # Official folders
    local official_size=0
    for folder in "terminalOutputs" "cloud" "d"; do
        if [ -d "$CACHE_DIR/$folder" ]; then
            if [[ "$OSTYPE" == "darwin"* ]]; then
                size=$(find "$CACHE_DIR/$folder" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
            else
                size=$(du -sb "$CACHE_DIR/$folder" 2>/dev/null | cut -f1 || echo "0")
            fi
            if [ -z "$size" ]; then
                size=0
            fi
            size_mb=$(awk "BEGIN {printf \"%.1f\", $size / 1024 / 1024}")
            echo "  📁 $folder: ${size_mb}MB"
            official_size=$((official_size + size))
        fi
    done
    
    local hash_size=$((cache_size_bytes - official_size))
    local hash_size_mb=$(awk "BEGIN {printf \"%.1f\", $hash_size / 1024 / 1024}")
    echo "  🏷️  Hash folders: ${hash_size_mb}MB"
    
    # Average size per entry
    if [ "$cache_count" -gt 0 ]; then
        local avg_size=$(awk "BEGIN {printf \"%.1f\", $hash_size / $cache_count / 1024 / 1024}")
        echo "  📊 Average per entry: ${avg_size}MB"
    fi
    
    # Database analysis
    if [ -f "$DB_FILE" ]; then
        echo ""
        echo "🗄️  Database Analysis:"
        local db_total_size=$(sqlite3 "$DB_FILE" "SELECT SUM(size) FROM cache_outputs;" 2>/dev/null || echo "0")
        if [ "$db_total_size" != "NULL" ] && [ -n "$db_total_size" ] && [ "$db_total_size" != "0" ]; then
            local db_size_mb=$(awk "BEGIN {printf \"%.2f\", $db_total_size / 1024 / 1024}")
            echo "  📋 Database recorded: ${db_size_mb}MB"
            
            # Efficiency calculation
            if [ "$hash_size" -gt 0 ]; then
                local efficiency=$(awk "BEGIN {printf \"%.1f\", $db_total_size * 100 / $hash_size}")
                echo "  📊 Accuracy: ${efficiency}%"
            fi
        else
            echo "  📋 No size data in database"
        fi
    fi
    
    # Recommendations
    echo ""
    echo "💡 Recommendations:"
    
    if [ "$cache_count" -gt 1000 ]; then
        echo "  🔧 High cache count ($cache_count) - consider cleanup"
        echo "      Run: pnpm cache:cleanup"
    elif [ "$cache_count" -gt 500 ]; then
        echo "  ⚠️  Moderate cache count ($cache_count) - monitor closely"
        echo "      Consider: pnpm cache:many-versions"
    else
        echo "  ✅ Cache count is healthy ($cache_count)"
    fi
    
    if [ "$cache_size_bytes" -gt 1073741824 ]; then  # > 1GB
        echo "  🔧 Large cache size (${cache_size_gb}GB) - consider cleanup"
        echo "      Run: pnpm cache:cleanup && pnpm cache:clean-orphaned"
    elif [ "$cache_size_bytes" -gt 536870912 ]; then  # > 512MB
        echo "  ⚠️  Moderate cache size (${cache_size_mb}MB) - monitor"
        echo "      Check: pnpm cache:orphaned"
    else
        echo "  ✅ Cache size is reasonable (${cache_size_mb}MB)"
    fi
    
    # Disk space check
    local available_space
    if [[ "$OSTYPE" == "darwin"* ]]; then
        available_space=$(df . | awk 'NR==2 {print $4}')
        available_space=$((available_space * 512))  # Convert to bytes
    else
        available_space=$(df . --output=avail | tail -1)
        available_space=$((available_space * 1024))  # Convert to bytes
    fi
    
    if [ "$available_space" -gt 0 ]; then
        local space_percentage=$(awk "BEGIN {printf \"%.1f\", $cache_size_bytes * 100 / $available_space}")
        local available_gb=$(awk "BEGIN {printf \"%.1f\", $available_space / 1024 / 1024 / 1024}")
        
        echo "  💽 Cache uses ${space_percentage}% of available disk space (${available_gb}GB free)"
        
        if [ "$(awk "BEGIN {print ($space_percentage > 10)}")" = "1" ]; then
            echo "      ⚠️  High disk usage - consider cleanup"
        fi
    fi
    
    echo ""
    echo "🎯 Quick Actions:"
    echo "  pnpm cache:cleanup        # Clean old entries"
    echo "  pnpm cache:clean-orphaned # Remove orphaned folders"
    echo "  pnpm cache:stats          # Detailed statistics"
    echo "  pnpm cache:largest        # Show largest entries"
    
    # Health score
    echo ""
    echo "🏥 Cache Health Score:"
    local health_score=100
    
    if [ "$cache_count" -gt 1000 ]; then
        health_score=$((health_score - 30))
    elif [ "$cache_count" -gt 500 ]; then
        health_score=$((health_score - 15))
    fi
    
    if [ "$cache_size_bytes" -gt 1073741824 ]; then  # > 1GB
        health_score=$((health_score - 25))
    elif [ "$cache_size_bytes" -gt 536870912 ]; then  # > 512MB
        health_score=$((health_score - 10))
    fi
    
    # Check orphaned entries
    local orphaned_count=$(count_orphaned_entries 2>/dev/null || echo "0")
    if [ "$orphaned_count" -gt 50 ]; then
        health_score=$((health_score - 20))
    elif [ "$orphaned_count" -gt 25 ]; then
        health_score=$((health_score - 10))
    fi
    
    if [ "$health_score" -ge 90 ]; then
        echo "  🎉 Excellent ($health_score/100)"
    elif [ "$health_score" -ge 75 ]; then
        echo "  ✅ Good ($health_score/100)"
    elif [ "$health_score" -ge 60 ]; then
        echo "  ⚠️  Fair ($health_score/100) - needs attention"
    else
        echo "  🚨 Poor ($health_score/100) - immediate action required"
    fi
}

# Function to show largest cache entries
show_largest_entries() {
    local limit="${1:-10}"
    echo "📈 Largest Cache Entries (top $limit):"
    
    if [ ! -d "$CACHE_DIR" ]; then
        echo "❌ Cache directory not found"
        return 1
    fi
    
    echo ""
    printf "%-20s %-10s %-25s %-25s\n" "HASH" "SIZE" "PROJECT:TARGET" "LAST_ACCESSED"
    echo "$(printf '%.0s-' {1..80})"
    
    # Create temporary file for size analysis
    local temp_file="/tmp/cache_sizes_$$"
    > "$temp_file"
    
    # Analyze each hash folder
    find "$CACHE_DIR" -name '[0-9]*' -type d 2>/dev/null | while read dir; do
        local hash=$(basename "$dir")
        local size
        if [[ "$OSTYPE" == "darwin"* ]]; then
            size=$(find "$dir" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
        else
            size=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")
        fi
        
        if [ -n "$size" ] && [ "$size" != "0" ]; then
            local size_mb=$(awk "BEGIN {printf \"%.1f\", $size / 1024 / 1024}")
            
            # Get project info from database if available
            local project_info=""
            local last_accessed=""
            if [ -f "$DB_FILE" ]; then
                project_info=$(sqlite3 "$DB_FILE" "
                    SELECT td.project || ':' || td.target
                    FROM task_details td 
                    WHERE td.hash = '$hash' 
                    LIMIT 1;
                " 2>/dev/null || echo "")
                
                last_accessed=$(sqlite3 "$DB_FILE" "
                    SELECT datetime(co.accessed_at)
                    FROM cache_outputs co 
                    WHERE co.hash = '$hash' 
                    LIMIT 1;
                " 2>/dev/null || echo "")
            fi
            
            if [ -z "$project_info" ]; then
                project_info="(orphaned)"
            fi
            if [ -z "$last_accessed" ]; then
                last_accessed="unknown"
            fi
            
            echo "$hash $size $size_mb $project_info $last_accessed" >> "$temp_file"
        fi
    done
    
    # Sort by size and display top entries
    if [ -f "$temp_file" ]; then
        sort -k2 -nr "$temp_file" | head -$limit | while read hash size size_mb project_info last_accessed; do
            printf "%-20s %-10s %-25s %-25s\n" \
                "${hash:0:18}..." \
                "${size_mb}MB" \
                "${project_info:0:24}" \
                "${last_accessed:0:24}"
        done
        
        # Summary
        echo ""
        local total_entries=$(wc -l < "$temp_file" | tr -d ' ')
        local total_size=$(awk '{sum += $2} END {print sum+0}' "$temp_file")
        local total_size_mb=$(awk "BEGIN {printf \"%.1f\", $total_size / 1024 / 1024}")
        local shown_size=$(sort -k2 -nr "$temp_file" | head -$limit | awk '{sum += $2} END {print sum+0}')
        local shown_size_mb=$(awk "BEGIN {printf \"%.1f\", $shown_size / 1024 / 1024}")
        
        echo "📊 Summary:"
        echo "  Total cache entries: $total_entries"
        echo "  Total cache size: ${total_size_mb}MB"
        echo "  Shown entries ($limit): ${shown_size_mb}MB"
        
        if [ "$total_entries" -gt "$limit" ]; then
            local percentage=$(awk "BEGIN {printf \"%.1f\", $shown_size * 100 / $total_size}")
            echo "  Top $limit represent: ${percentage}% of total size"
        fi
        
        rm -f "$temp_file"
    else
        echo "No cache entries found"
    fi
    
    echo ""
    echo "💡 Actions:"
    echo "  pnpm cache:project:clean <project> 2  # Clean specific project"
    echo "  pnpm cache:cleanup                    # Clean old entries globally"
    echo "  pnpm cache:clean-orphaned             # Remove orphaned entries"
}

# Function to clean specific project with version limit
clean_project_versions() {
    local project="$1"
    local keep_versions="${2:-3}"
    
    if [ -z "$project" ]; then
        echo "Usage: clean_project_versions <project> [keep_versions]"
        echo "Example: clean_project_versions 'my-app' 3"
        return 1
    fi
    
    echo "🧹 Cleaning project '$project' (keeping $keep_versions versions per target)..."
    
    # Use the existing project cleanup script if available
    local script_dir=$(dirname "${BASH_SOURCE[0]}")
    if [ -f "$script_dir/project-cache-cleanup-v2.sh" ]; then
        "$script_dir/project-cache-cleanup-v2.sh" "$project" "$keep_versions"
    else
        echo "❌ Project cleanup script not found"
        echo "💡 Please run: pnpm cache:project:clean $project $keep_versions"
    fi
}

# เพิ่มหลังจาก function clean_project_versions() 
# Function to find issues for specific project
issues_for_project() {
    local project="$1"
    if [ -z "$project" ]; then
        echo "Usage: issues_for_project <project>"
        echo "Example: issues_for_project my-app"
        return 1
    fi
    
    echo "🔍 Issues Analysis for Project: $project"
    echo "========================================"
    echo ""
    
    # Check if project exists
    if [ -f "$DB_FILE" ]; then
        PROJECT_EXISTS=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE project = '$project';" 2>/dev/null || echo "0")
        if [ "$PROJECT_EXISTS" -eq 0 ]; then
            echo "❌ Project '$project' not found in cache database"
            echo ""
            echo "📋 Available projects:"
            sqlite3 "$DB_FILE" "SELECT DISTINCT project FROM task_details ORDER BY project;" 2>/dev/null
            return 1
        fi
    fi
    
    # 1. Check for many versions in this project
    echo "📊 Cache Versions Analysis:"
    sqlite3 "$DB_FILE" "
        SELECT 
            td.target,
            COALESCE(td.configuration, '(default)') as config,
            COUNT(*) as version_count,
            printf('%.1f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
            MAX(datetime(co.accessed_at)) as last_accessed
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project = '$project'
        GROUP BY td.target, td.configuration
        ORDER BY COUNT(*) DESC;
    " 2>/dev/null | while IFS='|' read target config versions size last_accessed; do
        if [ "$versions" -gt 5 ]; then
            echo "  🚨 ${project}:${target}:${config} - $versions versions ($size) ← High"
        elif [ "$versions" -gt 3 ]; then
            echo "  ⚠️  ${project}:${target}:${config} - $versions versions ($size) ← Moderate"  
        elif [ "$versions" -gt 1 ]; then
            echo "  ✅ ${project}:${target}:${config} - $versions versions ($size) ← Normal"
        else
            echo "  ✅ ${project}:${target}:${config} - $versions version ($size) ← Good"
        fi
    done
    
    echo ""
    
    # 2. Find orphaned DB entries for this project
    echo "🗄️ Orphaned Database Entries for $project:"
    local orphaned_db_count=0
    local temp_orphans="/tmp/project_orphans_$$"
    > "$temp_orphans"
    
    sqlite3 "$DB_FILE" "
        SELECT 
            td.hash,
            td.target,
            COALESCE(td.configuration, '(default)') as config,
            COALESCE(co.size, 0) as size
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project = '$project';
    " 2>/dev/null | while IFS='|' read hash target config size; do
        if [ -n "$hash" ] && [ ! -d "$CACHE_DIR/$hash" ]; then
            echo "$hash|$target|$config|$size" >> "$temp_orphans"
        fi
    done
    
    if [ -s "$temp_orphans" ]; then
        while IFS='|' read hash target config size; do
            size_mb=$(awk "BEGIN {printf \"%.1f\", $size / 1024 / 1024}")
            echo "  🗄️ $hash (${size_mb}MB) - ${project}:${target}:${config}"
            orphaned_db_count=$((orphaned_db_count + 1))
        done < "$temp_orphans"
    else
        echo "  ✅ No orphaned database entries found for $project"
    fi
    
    rm -f "$temp_orphans"
    echo ""
    
    # 3. Summary and recommendations
    echo "📋 Summary for $project:"
    
    # Count high-version targets
    high_version_targets=$(sqlite3 "$DB_FILE" "
        SELECT COUNT(*)
        FROM (
            SELECT COUNT(*) as versions
            FROM task_details td
            WHERE td.project = '$project'
            GROUP BY td.target, td.configuration
            HAVING COUNT(*) > 3
        );
    " 2>/dev/null || echo "0")
    
    total_size=$(sqlite3 "$DB_FILE" "
        SELECT printf('%.1f MB', SUM(CAST(co.size AS REAL)/1024/1024))
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project = '$project';
    " 2>/dev/null || echo "0 MB")
    
    echo "  📊 Total cache size: $total_size"
    echo "  🚨 Targets with >3 versions: $high_version_targets"
    echo "  🗄️ Orphaned DB entries: $orphaned_db_count"
    echo ""
    
    # Recommendations
    echo "💡 Recommendations:"
    if [ "$high_version_targets" -gt 0 ]; then
        echo "  🔧 Clean project versions: pnpm cache:clean:project $project 2"
        echo "  🏆 Full project optimization: pnpm cache:optimize:project $project 2"
    else
        echo "  ✅ Project cache looks healthy!"
    fi
    
    if [ "$orphaned_db_count" -gt 0 ]; then
        echo "  🗄️ Clean orphaned DB entries: pnpm cache:clean:db"
    fi
    
    echo "  📊 View detailed project info: pnpm cache:project:info $project"
}

# Main function to handle command line arguments
main() {
    local command="$1"
    shift
    
    case "$command" in
        "projects"|"p")
            show_projects
            ;;
        "targets"|"t")
            show_targets "$@"
            ;;
        "orphaned"|"o")
            find_orphaned_folders
            ;;
        "clean-orphaned"|"co")
            clean_orphaned_folders
            ;;
        "clean-db-orphans"|"cdo")
            clean_db_orphans
            ;;
        "clean-suspicious"|"cs")
            clean_suspicious_items
            ;;
        "many-versions"|"mv")
            show_projects_with_many_versions "$@"
            ;;
        "clean-project"|"cp")
            clean_project_versions "$@"
            ;;
        "age"|"a")
            show_cache_age_distribution
            ;;
        "backup"|"b")
            backup_database
            ;;
        "recent"|"r")
            show_recent_activity "$@"
            ;;
        "search"|"s")
            search_cache "$@"
            ;;
        "validate-size"|"vs")
            validate_cache_size
            ;;
        "largest"|"l")
            show_largest_entries "$@"
            ;;
        "issues-for-project"|"ifp")
            issues_for_project "$@"
            ;;
        "help"|"h"|"")
            echo "🛠️  Nx Cache Utilities (Enhanced)"
            echo "================================"
            echo ""
            echo "Available commands:"
            echo "  projects (p)               - List all projects"
            echo "  targets (t) <project>      - List targets for project"
            echo "  orphaned (o)               - Find orphaned cache folders"
            echo "  clean-orphaned (co)        - Clean orphaned cache folders"
            echo "  clean-db-orphans (cdo)     - Clean orphaned database entries"
            echo "  clean-suspicious (cs)      - Clean suspicious items"
            echo "  many-versions (mv) [min]   - Show projects with many versions (default: >3)"
            echo "  clean-project (cp) <proj> [keep] - Clean specific project (keep N versions)"
            echo "  age (a)                    - Show cache age distribution"
            echo "  backup (b)                 - Backup database"
            echo "  recent (r) [limit]         - Show recent activity"
            echo "  search (s) <pattern>       - Search cache by pattern"
            echo "  validate-size (vs)         - Detailed cache size validation"
            echo "  largest (l) [limit]        - Show largest cache entries"
            echo "  issues-for-project (ifp) <proj> - Find project-specific issues"
            echo "  help (h)                   - Show this help"
            echo ""
            echo "Examples:"
            echo "  ./cache-utilities.sh many-versions 5      # Projects with >5 versions"
            echo "  ./cache-utilities.sh clean-project my-app 2  # Keep only 2 versions"
            echo "  ./cache-utilities.sh orphaned"
            echo "  ./cache-utilities.sh clean-db-orphans     # Clean orphaned DB entries"
            echo "  ./cache-utilities.sh clean-suspicious"
            echo "  ./cache-utilities.sh targets my-app"
            echo "  ./cache-utilities.sh recent 10"
            echo "  ./cache-utilities.sh search my-app"
            echo "  ./cache-utilities.sh validate-size        # Detailed size analysis"
            echo "  ./cache-utilities.sh largest 5            # Show 5 largest entries"
            echo ""
            echo "📝 Note: Official Nx folders (terminalOutputs, cloud, d) are preserved"
            ;;
        *)
            echo "❌ Unknown command: $command"
            echo "Use 'help' to see available commands"
            ;;
    esac
}

# Check if database exists
if [ ! -f "$DB_FILE" ]; then
    echo "❌ Database file not found: $DB_FILE"
    echo "💡 Current working directory: $(pwd)"
    echo "💡 Looking for .nx in: $NX_DIR"
    echo "💡 Workspace-data directory: ${NX_DIR}/workspace-data"
    exit 1
fi

# Run main function with all arguments
main "$@"