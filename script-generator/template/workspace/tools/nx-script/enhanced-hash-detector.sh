#!/bin/bash
# enhanced-hash-detector-fixed.sh
# Detect current hash for a project and target - FIXED VERSION

PROJECT="$1"
TARGET="${2:-build}"

if [ -z "$PROJECT" ]; then
    echo "Usage: $0 <project> [target]"
    echo "Example: $0 my-app build"
    exit 1
fi

# Auto-detect .nx location and ensure we're in the right directory
if [ -d ".nx" ]; then
    NX_ROOT="$(pwd)"
elif [ -d "../.nx" ]; then
    NX_ROOT="$(cd .. && pwd)"
    cd "$NX_ROOT"
elif [ -d "../../.nx" ]; then
    NX_ROOT="$(cd ../.. && pwd)"  
    cd "$NX_ROOT"
else
    echo "❌ .nx directory not found"
    exit 1
fi

echo "🔍 Enhanced Hash Detection for: $PROJECT:$TARGET"
echo "================================================"
echo "🔧 Working from: $NX_ROOT"
echo ""

# Method 1: Dry run with multiple pattern attempts
echo "📊 Method 1: Dry run analysis"
OUTPUT1=$(NX_VERBOSE_LOGGING=true npx nx "$TARGET" "$PROJECT" --dry-run 2>&1)

# Try multiple hash patterns for different Nx versions
HASH_1=""
# Pattern 1: "Hash: abc123"
HASH_1=$(echo "$OUTPUT1" | grep -o "Hash: [a-f0-9]*" | head -1 | cut -d' ' -f2)
if [ -z "$HASH_1" ]; then
    # Pattern 2: "hash: abc123" 
    HASH_1=$(echo "$OUTPUT1" | grep -o "hash: [a-f0-9]*" | head -1 | cut -d' ' -f2)
fi
if [ -z "$HASH_1" ]; then
    # Pattern 3: "task hash abc123"
    HASH_1=$(echo "$OUTPUT1" | grep -o "task hash [a-f0-9]*" | head -1 | awk '{print $3}')
fi
if [ -z "$HASH_1" ]; then
    # Pattern 4: Numbers only pattern (common in newer versions)
    HASH_1=$(echo "$OUTPUT1" | grep -o "\b[0-9]\{15,20\}\b" | head -1)
fi

echo "Dry run hash: ${HASH_1:-'Not detected'}"

# Debug: Show relevant lines from dry run output
echo ""
echo "📝 Dry run debug (lines containing 'hash' or numbers):"
echo "$OUTPUT1" | grep -i -E "(hash|[0-9]{15,20})" | head -5 || echo "  No relevant lines found"

# Method 2: Actual run
echo ""
echo "📊 Method 2: Actual run"
OUTPUT2=$(npx nx "$TARGET" "$PROJECT" 2>&1)

# Try same patterns for actual run
HASH_2=""
HASH_2=$(echo "$OUTPUT2" | grep -o "Hash: [a-f0-9]*" | head -1 | cut -d' ' -f2)
if [ -z "$HASH_2" ]; then
    HASH_2=$(echo "$OUTPUT2" | grep -o "hash: [a-f0-9]*" | head -1 | cut -d' ' -f2)
fi
if [ -z "$HASH_2" ]; then
    HASH_2=$(echo "$OUTPUT2" | grep -o "task hash [a-f0-9]*" | head -1 | awk '{print $3}')
fi
if [ -z "$HASH_2" ]; then
    HASH_2=$(echo "$OUTPUT2" | grep -o "\b[0-9]\{15,20\}\b" | head -1)
fi

# Check if it was cache hit or miss
if echo "$OUTPUT2" | grep -q -i "cache"; then
    echo "✅ Cache HIT"
    CACHE_STATUS="HIT"
else
    echo "🔄 Cache MISS (new build)"
    CACHE_STATUS="MISS"
fi

echo "Actual run hash: ${HASH_2:-'Not detected'}"

# Debug: Show relevant lines from actual run output  
echo ""
echo "📝 Actual run debug (lines containing 'hash', 'cache', or numbers):"
echo "$OUTPUT2" | grep -i -E "(hash|cache|[0-9]{15,20})" | head -5 || echo "  No relevant lines found"

# Method 3: Find latest cache entry
echo ""
echo "📊 Method 3: Latest cache analysis"
LATEST_CACHE=$(ls -t .nx/cache/ 2>/dev/null | grep "^[0-9]" | head -1)
echo "Latest cache entry: ${LATEST_CACHE:-'None found'}"

# Method 4: Database query
echo ""
echo "📊 Method 4: Database analysis"
DB_FILE=$(ls .nx/workspace-data/*.db 2>/dev/null | head -1)
if [ -n "$DB_FILE" ]; then
    echo "Database: $(basename "$DB_FILE")"
    
    # Find latest entry for this project
    LATEST_DB_HASH=$(sqlite3 "$DB_FILE" "
        SELECT td.hash FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project = '$PROJECT' AND td.target = '$TARGET'
        ORDER BY co.accessed_at DESC, co.created_at DESC 
        LIMIT 1;
    " 2>/dev/null)
    echo "Latest DB hash: ${LATEST_DB_HASH:-'Not found'}"
    
    # Show all hashes for this project:target
    echo ""
    echo "📋 All cache entries for $PROJECT:$TARGET:"
    sqlite3 "$DB_FILE" "
        SELECT 
            td.hash,
            COALESCE(td.configuration, '(default)') as config,
            datetime(co.accessed_at) as accessed,
            printf('%.2f MB', CAST(co.size AS REAL)/1024/1024) as size
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.project = '$PROJECT' AND td.target = '$TARGET'
        ORDER BY co.accessed_at DESC;
    " 2>/dev/null
fi

# Method 5: Try alternative Nx commands
echo ""
echo "📊 Method 5: Alternative detection methods"

# Try nx show command if available (newer Nx versions)
if command -v npx >/dev/null 2>&1; then
    SHOW_OUTPUT=$(npx nx show project "$PROJECT" 2>/dev/null || echo "")
    if [ -n "$SHOW_OUTPUT" ]; then
        echo "✅ Project info available via 'nx show'"
        # Look for any hash-like patterns in project info
        ALT_HASH=$(echo "$SHOW_OUTPUT" | grep -o "\b[0-9]\{15,20\}\b" | head -1)
        if [ -n "$ALT_HASH" ]; then
            echo "Alternative hash found: $ALT_HASH"
        fi
    fi
fi

# Try to get hash from recent build outputs/logs
if [ -d ".nx" ]; then
    RECENT_HASH=$(find .nx -name "*.log" -exec grep -l "$PROJECT" {} \; 2>/dev/null | head -1 | xargs grep -o "\b[0-9]\{15,20\}\b" 2>/dev/null | head -1)
    if [ -n "$RECENT_HASH" ]; then
        echo "Hash from recent logs: $RECENT_HASH"
    fi
fi

# Summary
echo ""
echo "📋 SUMMARY"
echo "=========="
echo "Project: $PROJECT"
echo "Target: $TARGET"
echo "Git Commit: $(git rev-parse --short HEAD 2>/dev/null || echo 'N/A')"
echo "Git Branch: $(git branch --show-current 2>/dev/null || echo 'N/A')"
echo ""

# Determine the authoritative hash with fallback logic
CURRENT_HASH=""

# Priority: 1. Dry run and actual run match, 2. Actual run, 3. Dry run, 4. Latest DB, 5. Latest cache
if [ -n "$HASH_1" ] && [ -n "$HASH_2" ] && [ "$HASH_1" = "$HASH_2" ]; then
    CURRENT_HASH="$HASH_1"
    echo "✅ Consistent Hash from runs: $CURRENT_HASH"
elif [ -n "$HASH_2" ]; then
    CURRENT_HASH="$HASH_2"
    echo "✅ Hash from actual run: $CURRENT_HASH"
elif [ -n "$HASH_1" ]; then
    CURRENT_HASH="$HASH_1"
    echo "✅ Hash from dry run: $CURRENT_HASH"
elif [ -n "$LATEST_DB_HASH" ]; then
    CURRENT_HASH="$LATEST_DB_HASH"
    echo "🔄 Hash from database (latest): $CURRENT_HASH"
    CACHE_STATUS="DATABASE"
elif [ -n "$LATEST_CACHE" ]; then
    CURRENT_HASH="$LATEST_CACHE"
    echo "📁 Hash from latest cache folder: $CURRENT_HASH"
    CACHE_STATUS="FILESYSTEM"
else
    echo "❌ Unable to determine current hash"
    CACHE_STATUS="UNKNOWN"
fi

echo ""
echo "🎯 CURRENT HASH: ${CURRENT_HASH:-'UNKNOWN'}"
echo "Cache Status: ${CACHE_STATUS:-'UNKNOWN'}"

# Cache directory info
if [ -n "$CURRENT_HASH" ] && [ -d ".nx/cache/$CURRENT_HASH" ]; then
    echo ""
    echo "📁 Cache Directory: .nx/cache/$CURRENT_HASH"
    CACHE_SIZE=$(du -sh ".nx/cache/$CURRENT_HASH" | cut -f1)
    echo "Cache Size: $CACHE_SIZE"
    
    # Count files in cache
    FILE_COUNT=$(find ".nx/cache/$CURRENT_HASH" -type f | wc -l | tr -d ' ')
    echo "Cache Files: $FILE_COUNT files"
    
    # Show sample files (first 5)
    echo "Sample files:"
    find ".nx/cache/$CURRENT_HASH" -type f | head -5 | while read file; do
        echo "  $(basename "$file")"
    done
    
elif [ -n "$CURRENT_HASH" ]; then
    echo ""
    echo "❌ Cache directory not found: .nx/cache/$CURRENT_HASH"
fi

# Database record info
if [ -n "$CURRENT_HASH" ] && [ -n "$DB_FILE" ]; then
    echo ""
    echo "🗄️  Database Record:"
    sqlite3 "$DB_FILE" "
        SELECT 
            'Hash: ' || td.hash,
            'Project: ' || td.project,
            'Target: ' || td.target,
            'Config: ' || COALESCE(td.configuration, '(default)'),
            'Size: ' || printf('%.2f MB', CAST(co.size AS REAL)/1024/1024),
            'Created: ' || datetime(co.created_at),
            'Accessed: ' || datetime(co.accessed_at)
        FROM task_details td
        LEFT JOIN cache_outputs co ON td.hash = co.hash
        WHERE td.hash = '$CURRENT_HASH';
    " 2>/dev/null | while read line; do
        echo "  $line"
    done
fi

# Export for other scripts
echo ""
echo "📤 Export Commands:"
echo "export CURRENT_HASH='${CURRENT_HASH:-}'"
echo "export CACHE_STATUS='${CACHE_STATUS:-UNKNOWN}'"
echo "export PROJECT_NAME='$PROJECT'"
echo "export TARGET_NAME='$TARGET'"

# Validation
if [ -n "$CURRENT_HASH" ]; then
    echo ""
    echo "🔍 Validation:"
    
    # Check if hash exists in database
    if [ -n "$DB_FILE" ]; then
        DB_EXISTS=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details WHERE hash = '$CURRENT_HASH';" 2>/dev/null || echo "0")
        if [ "$DB_EXISTS" -gt 0 ]; then
            echo "  ✅ Hash exists in database"
        else
            echo "  ❌ Hash not found in database"
        fi
    fi
    
    # Check if cache folder exists
    if [ -d ".nx/cache/$CURRENT_HASH" ]; then
        echo "  ✅ Cache folder exists"
    else
        echo "  ❌ Cache folder missing"
    fi
    
    # Check if cache is recent
    if [ -n "$DB_FILE" ]; then
        AGE_HOURS=$(sqlite3 "$DB_FILE" "
            SELECT CAST((julianday('now') - julianday(co.accessed_at)) * 24 AS INTEGER)
            FROM cache_outputs co
            WHERE co.hash = '$CURRENT_HASH';
        " 2>/dev/null || echo "unknown")
        
        if [ "$AGE_HOURS" != "unknown" ] && [ "$AGE_HOURS" != "" ]; then
            if [ "$AGE_HOURS" -lt 24 ]; then
                echo "  ✅ Cache is recent (${AGE_HOURS}h old)"
            elif [ "$AGE_HOURS" -lt 168 ]; then  # 7 days
                echo "  ⚠️  Cache is ${AGE_HOURS}h old"
            else
                echo "  🔶 Cache is old (${AGE_HOURS}h old)"
            fi
        fi
    fi
fi

# Debugging tips
echo ""
echo "🛠️  Debugging Tips:"
echo "  If hash detection fails:"
echo "  1. Check Nx version: npx nx --version"
echo "  2. Try verbose: NX_VERBOSE_LOGGING=true npx nx $TARGET $PROJECT --dry-run"
echo "  3. Check output format manually"