#!/bin/bash
# cache-validation.sh
# Cache validation utility for CI/CD

set -e

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

CACHE_DIR="${NX_DIR}/cache"
DB_FILE=$(find "${NX_DIR}/workspace-data" -name "*.db" 2>/dev/null | head -1)

# Default thresholds - CONFIGURABLE
MAX_CACHE_ENTRIES=${NX_CACHE_MAX_ENTRIES:-1000}
MAX_CACHE_SIZE_MB=${NX_CACHE_MAX_SIZE_MB:-1024}  # 1GB
MAX_ORPHANED_ENTRIES=${NX_CACHE_MAX_ORPHANED:-50}

# Project-specific overrides (uncomment and modify as needed)
# MAX_CACHE_ENTRIES=500    # For smaller projects
# MAX_CACHE_SIZE_MB=2048   # For projects with large assets
# MAX_ORPHANED_ENTRIES=100 # For high-activity projects

# Parse command line arguments
COMMAND="${1:-validate}"

show_help() {
    echo "🔍 Cache Validation Utility"
    echo "=========================="
    echo ""
    echo "Usage: $0 [command] [options]"
    echo ""
    echo "Commands:"
    echo "  validate          - Run all validations (default)"
    echo "  count             - Count cache entries"
    echo "  size              - Check cache size"
    echo "  orphaned          - Check for orphaned entries"
    echo "  health            - Full health check"
    echo "  validate-ci       - CI-friendly validation (exit codes)"
    echo ""
    echo "Options:"
    echo "  --max-entries N   - Set max cache entries (default: $MAX_CACHE_ENTRIES)"
    echo "  --max-size N      - Set max cache size in MB (default: $MAX_CACHE_SIZE_MB)"
    echo "  --max-orphaned N  - Set max orphaned entries (default: $MAX_ORPHANED_ENTRIES)"
    echo ""
    echo "Examples:"
    echo "  $0                           # Basic validation"
    echo "  $0 validate-ci               # CI validation with exit codes"
    echo "  $0 count                     # Just count entries"
    echo "  $0 validate --max-entries 500"
    echo ""
}

# Function to count cache entries
count_cache_entries() {
    if [ -d "$CACHE_DIR" ]; then
        find "$CACHE_DIR" -name '[0-9]*' -type d 2>/dev/null | wc -l | tr -d ' '
    else
        echo "0"
    fi
}

# Function to get cache size in MB
get_cache_size_mb() {
    if [ -d "$CACHE_DIR" ]; then
        local size_bytes
        if [[ "$OSTYPE" == "darwin"* ]]; then
            size_bytes=$(find "$CACHE_DIR" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
        else
            size_bytes=$(du -sb "$CACHE_DIR" 2>/dev/null | cut -f1 || echo "0")
        fi
        
        if [ -z "$size_bytes" ] || [ "$size_bytes" = "0" ]; then
            echo "0"
        else
            echo $(awk "BEGIN {printf \"%.0f\", $size_bytes / 1024 / 1024}")
        fi
    else
        echo "0"
    fi
}

# Function to count orphaned entries
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
    
    # Count database orphans (DB entries without folders)
    if [ -f "$DB_FILE" ]; then
        local db_orphans=$(sqlite3 "$DB_FILE" "
            SELECT COUNT(*) 
            FROM task_details td 
            WHERE NOT EXISTS (SELECT 1 FROM cache_outputs co WHERE co.hash = td.hash);
        " 2>/dev/null || echo "0")
        orphaned_count=$((orphaned_count + db_orphans))
    fi
    
    echo "$orphaned_count"
}

# Function to validate cache
validate_cache() {
    local exit_on_fail=${1:-false}
    local issues=0
    
    echo "🔍 Cache Validation Report"
    echo "========================="
    echo "Cache Directory: $CACHE_DIR"
    echo "Database: ${DB_FILE:-'Not found'}"
    echo ""
    
    # Check cache entries
    local cache_count=$(count_cache_entries)
    echo "📊 Cache Entries: $cache_count"
    if [ "$cache_count" -ge "$MAX_CACHE_ENTRIES" ]; then
        echo "  ❌ Too many cache entries (>= $MAX_CACHE_ENTRIES)"
        issues=$((issues + 1))
    else
        echo "  ✅ Cache entries within limit"
    fi
    
    # Check cache size
    local cache_size=$(get_cache_size_mb)
    echo "💾 Cache Size: ${cache_size}MB"
    if [ "$cache_size" -ge "$MAX_CACHE_SIZE_MB" ]; then
        echo "  ❌ Cache size too large (>= ${MAX_CACHE_SIZE_MB}MB)"
        issues=$((issues + 1))
    else
        echo "  ✅ Cache size within limit"
    fi
    
    # Check orphaned entries
    local orphaned_count=$(count_orphaned_entries)
    echo "🔍 Orphaned Entries: $orphaned_count"
    if [ "$orphaned_count" -ge "$MAX_ORPHANED_ENTRIES" ]; then
        echo "  ⚠️  High number of orphaned entries (>= $MAX_ORPHANED_ENTRIES)"
        issues=$((issues + 1))
    else
        echo "  ✅ Orphaned entries within acceptable range"
    fi
    
    # Check database health
    if [ -f "$DB_FILE" ]; then
        local db_integrity=$(sqlite3 "$DB_FILE" "PRAGMA integrity_check;" 2>/dev/null | head -1)
        echo "🗄️  Database Health: $db_integrity"
        if [ "$db_integrity" != "ok" ]; then
            echo "  ❌ Database integrity issues detected"
            issues=$((issues + 1))
        else
            echo "  ✅ Database integrity OK"
        fi
        
        # Check table counts
        local task_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details;" 2>/dev/null || echo "0")
        local cache_output_count=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM cache_outputs;" 2>/dev/null || echo "0")
        echo "📋 Database Records: $task_count tasks, $cache_output_count cache outputs"
        
        if [ "$task_count" -ne "$cache_output_count" ]; then
            echo "  ⚠️  Task/cache count mismatch (may indicate orphaned entries)"
        else
            echo "  ✅ Task/cache counts match"
        fi
    else
        echo "🗄️  Database: Not found"
        echo "  ⚠️  No database found - cache tracking unavailable"
    fi
    
    echo ""
    echo "📊 Summary:"
    if [ "$issues" -eq 0 ]; then
        echo "  ✅ All validations passed!"
        echo "  🎯 Cache is healthy and optimized"
    elif [ "$issues" -le 2 ]; then
        echo "  ⚠️  Minor issues detected ($issues)"
        echo "  💡 Consider running: pnpm cache:optimize"
    else
        echo "  ❌ Multiple issues detected ($issues)"
        echo "  🚨 Immediate attention required"
        echo "  💡 Run: pnpm cache:full-cleanup"
    fi
    
    # Exit with appropriate code if in CI mode
    if [ "$exit_on_fail" = true ] && [ "$issues" -gt 2 ]; then
        echo ""
        echo "❌ Validation failed - too many issues for CI"
        exit 1
    elif [ "$exit_on_fail" = true ] && [ "$issues" -gt 0 ]; then
        echo ""
        echo "⚠️  Validation passed with warnings"
        exit 0
    fi
    
    return "$issues"
}

# Parse additional arguments
while [[ $# -gt 1 ]]; do
    case $2 in
        --max-entries)
            MAX_CACHE_ENTRIES="$3"
            shift 2
            ;;
        --max-size)
            MAX_CACHE_SIZE_MB="$3"
            shift 2
            ;;
        --max-orphaned)
            MAX_ORPHANED_ENTRIES="$3"
            shift 2
            ;;
        *)
            shift
            ;;
    esac
done

# Execute command
case "$COMMAND" in
    "validate")
        validate_cache false
        ;;
    "validate-ci")
        validate_cache true
        ;;
    "count")
        count=$(count_cache_entries)
        echo "Cache entries: $count"
        if [ "$count" -ge "$MAX_CACHE_ENTRIES" ]; then
            echo "❌ Exceeds limit of $MAX_CACHE_ENTRIES"
            exit 1
        fi
        ;;
    "size")
        size=$(get_cache_size_mb)
        echo "Cache size: ${size}MB"
        if [ "$size" -ge "$MAX_CACHE_SIZE_MB" ]; then
            echo "❌ Exceeds limit of ${MAX_CACHE_SIZE_MB}MB"
            exit 1
        fi
        ;;
    "orphaned")
        orphaned=$(count_orphaned_entries)
        echo "Orphaned entries: $orphaned"
        if [ "$orphaned" -ge "$MAX_ORPHANED_ENTRIES" ]; then
            echo "⚠️  High number of orphaned entries"
            exit 1
        fi
        ;;
    "health")
        validate_cache false
        echo ""
        echo "💡 Recommendations:"
        echo "  • Run 'pnpm cache:cleanup' weekly"
        echo "  • Use 'pnpm cache:clean-orphaned' monthly"
        echo "  • Monitor with 'pnpm cache:stats'"
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo "❌ Unknown command: $COMMAND"
        echo "Use '$0 help' for usage information"
        exit 1
        ;;
esac