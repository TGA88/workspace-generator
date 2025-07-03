#!/bin/bash
# project-cache-details.sh
# Show detailed cache information for each project with project and target filtering

# Auto-detect database
DB_FILE=$(ls .nx/workspace-data/*.db 2>/dev/null | head -1)

if [ ! -f "$DB_FILE" ]; then
    echo "❌ Database file not found"
    exit 1
fi

PROJECT_FILTER="${1:-}"
TARGET_FILTER="${2:-}"

# Help function
show_help() {
    echo "Usage: $0 [project_pattern] [target_pattern]"
    echo ""
    echo "Examples:"
    echo "  $0                                  # Show all projects"
    echo "  $0 my-app                          # Filter by project name"
    echo "  $0 my-app build                    # Filter by project and target"
    echo "  $0 \"\" build                        # Filter by target only"
    echo "  $0 web-nextjs test                 # Filter web-nextjs projects with test target"
    echo ""
    exit 0
}

# Check for help flag
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]]; then
    show_help
fi

echo "📊 Project Cache Details Report"
echo "==============================="
echo "Database: $(basename "$DB_FILE")"
if [ -n "$PROJECT_FILTER" ] || [ -n "$TARGET_FILTER" ]; then
    echo "Filters:"
    [ -n "$PROJECT_FILTER" ] && echo "  Project: *$PROJECT_FILTER*"
    [ -n "$TARGET_FILTER" ] && echo "  Target: *$TARGET_FILTER*"
fi
echo ""

# Build WHERE clause safely
build_where_clause() {
    local conditions=""
    
    if [ -n "$PROJECT_FILTER" ] && [ -n "$TARGET_FILTER" ]; then
        conditions="WHERE td.project LIKE '%$PROJECT_FILTER%' AND td.target LIKE '%$TARGET_FILTER%'"
    elif [ -n "$PROJECT_FILTER" ]; then
        conditions="WHERE td.project LIKE '%$PROJECT_FILTER%'"
    elif [ -n "$TARGET_FILTER" ]; then
        conditions="WHERE td.target LIKE '%$TARGET_FILTER%'"
    else
        conditions=""
    fi
    
    echo "$conditions"
}

WHERE_CLAUSE=$(build_where_clause)

# Debug: Show the WHERE clause
if [ -n "$WHERE_CLAUSE" ]; then
    echo "🔍 SQL Filter: $WHERE_CLAUSE"
    echo ""
fi

# Query 1: Project summary with version counts
echo "📋 Project Version Summary:"
echo "$(printf '%-35s %-15s %-10s %-10s %-20s' 'PROJECT:TARGET' 'CONFIG' 'VERSIONS' 'SIZE' 'LAST_ACCESS')"
echo "$(printf '%.0s-' {1..90})"

sqlite3 "$DB_FILE" "
SELECT 
    td.project || ':' || td.target as project_target,
    COALESCE(td.configuration, '(default)') as config,
    COUNT(*) as versions,
    printf('%.1f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size,
    MAX(datetime(co.accessed_at)) as last_accessed
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
$WHERE_CLAUSE
GROUP BY td.project, td.target, td.configuration
ORDER BY td.project, td.target, td.configuration;
" | while IFS='|' read project_target config versions size last_accessed; do
    printf "%-35s %-15s %-10s %-10s %-20s\n" \
        "${project_target:0:34}" \
        "${config:0:14}" \
        "$versions" \
        "$size" \
        "${last_accessed:0:19}"
done

echo ""

# Query 2: Detailed hash information for filtered results
if [ -n "$PROJECT_FILTER" ] || [ -n "$TARGET_FILTER" ]; then
    FILTER_DESC=""
    [ -n "$PROJECT_FILTER" ] && FILTER_DESC="$PROJECT_FILTER"
    [ -n "$TARGET_FILTER" ] && FILTER_DESC="$FILTER_DESC:$TARGET_FILTER"
    
    echo "🔍 Detailed Cache Entries for: $FILTER_DESC"
    echo "$(printf '%-20s %-15s %-15s %-25s %-20s %-20s %-10s' 'HASH' 'PROJECT' 'TARGET' 'CONFIG' 'CREATED' 'ACCESSED' 'SIZE')"
    echo "$(printf '%.0s-' {1..130})"
    
    sqlite3 "$DB_FILE" "
    SELECT 
        substr(td.hash, 1, 18) || '...' as hash_short,
        substr(td.project, 1, 12) || '...' as project_short,
        td.target,
        COALESCE(td.configuration, '(default)') as config,
        datetime(co.created_at) as created,
        datetime(co.accessed_at) as accessed,
        printf('%.1f MB', CAST(co.size AS REAL)/1024/1024) as size
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    $WHERE_CLAUSE
    ORDER BY co.accessed_at DESC;
    " | while IFS='|' read hash project target config created accessed size; do
        printf "%-20s %-15s %-15s %-25s %-20s %-20s %-10s\n" \
            "$hash" \
            "${project:0:14}" \
            "${target:0:14}" \
            "${config:0:24}" \
            "${created:0:19}" \
            "${accessed:0:19}" \
            "$size"
    done
    
    echo ""
    
    # Full hash list for copying
    echo "📋 Full Hash List for $FILTER_DESC:"
    sqlite3 "$DB_FILE" "
    SELECT 
        td.hash,
        td.project || ':' || td.target || ':' || COALESCE(td.configuration, 'default') as full_task,
        datetime(co.accessed_at) as accessed
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    $WHERE_CLAUSE
    ORDER BY co.accessed_at DESC;
    " | while IFS='|' read hash full_task accessed; do
        echo "  $hash ($full_task) - $accessed"
    done
    
    echo ""
fi

# Query 3: Cache age distribution (only if no specific filters)
if [ -z "$PROJECT_FILTER" ] && [ -z "$TARGET_FILTER" ]; then
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
        printf('%.1f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as total_size
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
    echo ""
fi

# Summary statistics for filtered results
if [ -n "$PROJECT_FILTER" ] || [ -n "$TARGET_FILTER" ]; then
    echo "📊 Summary Statistics:"
    
    sqlite3 "$DB_FILE" "
    SELECT 
        'Total Entries: ' || COUNT(*) as stat
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    $WHERE_CLAUSE
    UNION ALL
    SELECT 
        'Total Size: ' || printf('%.1f MB', SUM(CAST(co.size AS REAL)/1024/1024)) as stat
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    $WHERE_CLAUSE
    UNION ALL
    SELECT 
        'Average Size: ' || printf('%.1f MB', AVG(CAST(co.size AS REAL)/1024/1024)) as stat
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    $WHERE_CLAUSE;
    " | while read stat; do
        echo "  $stat"
    done
    
    echo ""
fi

echo "💡 Usage Examples:"
echo "  Show all projects: $0"
echo "  Filter by project: $0 my-app"
echo "  Filter by target: $0 \"\" build"
echo "  Filter both: $0 my-app build"
echo "  Pattern matching: $0 web-nextjs test"
echo ""
echo "🎯 Available Targets in Database:"
sqlite3 "$DB_FILE" "SELECT DISTINCT target FROM task_details ORDER BY target;" | while read target; do
    echo "  • $target"
done

echo ""
echo "🏗️ Available Projects in Database:"
sqlite3 "$DB_FILE" "SELECT DISTINCT project FROM task_details ORDER BY project;" | while read project; do
    echo "  • $project"
done