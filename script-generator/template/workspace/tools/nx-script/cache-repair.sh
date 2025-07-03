#!/bin/bash
# cache-repair.sh (Enhanced)
# Repair cache database inconsistencies - respects official Nx structure
# Version: 2.1 with CI/CD support

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Global variables
NON_INTERACTIVE=false
VERBOSE=false
DRY_RUN=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -y|--yes)
            NON_INTERACTIVE=true
            shift
            ;;
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -d|--dry-run)
            DRY_RUN=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  -y, --yes       Auto-confirm all prompts (non-interactive mode)"
            echo "  -v, --verbose   Show detailed output during repair"
            echo "  -d, --dry-run   Show what would be done without making changes"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0              # Interactive mode (default)"
            echo "  $0 -y           # Non-interactive mode for CI/CD"
            echo "  $0 -y -v        # Non-interactive + verbose logging"
            echo "  $0 -d           # Dry run to see what would be repaired"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use -h or --help for usage information"
            exit 1
            ;;
    esac
done

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo -e "${CYAN}[VERBOSE]${NC} $1"
    fi
}

# Function to confirm actions
confirm_action() {
    local message="$1"
    local default_action="${2:-n}"  # Default to 'n' if not specified
    
    if [ "$DRY_RUN" = true ]; then
        log_info "🔍 DRY RUN: Would $message"
        return 0
    fi
    
    if [ "$NON_INTERACTIVE" = true ]; then
        if [ "$default_action" = "y" ]; then
            log_success "🤖 $message - proceeding automatically"
            return 0
        else
            log_warning "🤖 $message - skipping in non-interactive mode"
            return 1
        fi
    else
        read -p "$message (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Function to ask about individual items (used for suspicious folders)
confirm_individual_action() {
    local message="$1"
    
    if [ "$DRY_RUN" = true ]; then
        log_info "🔍 DRY RUN: Would ask: $message"
        return 1
    fi
    
    if [ "$NON_INTERACTIVE" = true ]; then
        log_warning "🤖 $message - skipping in non-interactive mode (safety)"
        return 1  # Skip individual items in non-interactive mode for safety
    else
        read -p "$message (y/N): " -n 1 -r
        echo
        [[ $REPLY =~ ^[Yy]$ ]]
    fi
}

# Auto-detect .nx location
if [ -d ".nx" ]; then
    NX_DIR=".nx"
elif [ -d "../.nx" ]; then
    NX_DIR="../.nx"
elif [ -d "../../.nx" ]; then
    NX_DIR="../../.nx"
else
    log_error ".nx directory not found"
    exit 1
fi

DB_FILE=$(ls ${NX_DIR}/workspace-data/*.db 2>/dev/null | head -1)
CACHE_DIR="${NX_DIR}/cache"

# Official Nx files/folders (don't touch these)
OFFICIAL_ITEMS=("terminalOutputs" "cloud" "d" "run.json")

echo -e "${BLUE}🔧 Cache Repair Tool (Enhanced with CI/CD Support)${NC}"
echo -e "${BLUE}==================================================${NC}"

if [ "$NON_INTERACTIVE" = true ]; then
    log_info "🤖 Running in non-interactive mode"
fi

if [ "$VERBOSE" = true ]; then
    log_info "📝 Verbose logging enabled"
fi

if [ "$DRY_RUN" = true ]; then
    log_info "🔍 Dry run mode - no changes will be made"
fi

echo ""

if [ ! -f "$DB_FILE" ]; then
    log_error "Database file not found!"
    exit 1
fi

log_verbose "Database file: $DB_FILE"
log_verbose "Cache directory: $CACHE_DIR"

# Function to check if item is official
is_official_item() {
    local item_name="$1"
    for official in "${OFFICIAL_ITEMS[@]}"; do
        if [ "$item_name" = "$official" ]; then
            return 0  # is official
        fi
    done
    return 1  # not official
}

# Show current issues
log_info "🔍 Analyzing current issues..."

# Check orphaned task entries
ORPHANED_TASKS=$(sqlite3 "$DB_FILE" "
    SELECT COUNT(*) 
    FROM task_details td 
    WHERE NOT EXISTS (SELECT 1 FROM cache_outputs co WHERE co.hash = td.hash);
" 2>/dev/null || echo "0")

log_verbose "Found $ORPHANED_TASKS orphaned task entries"

# Check size mismatch
DB_TOTAL_SIZE=$(sqlite3 "$DB_FILE" "SELECT SUM(size) FROM cache_outputs;" 2>/dev/null || echo "0")
if [ "$DB_TOTAL_SIZE" = "NULL" ] || [ -z "$DB_TOTAL_SIZE" ]; then
    DB_TOTAL_SIZE=0
fi

log_verbose "Database total size: $DB_TOTAL_SIZE bytes"

# Calculate actual hash folder sizes
ACTUAL_HASH_SIZE=0
MISSING_CACHE_ENTRIES=()

if [ -d "$CACHE_DIR" ]; then
    log_verbose "Analyzing cache directory vs database..."
    
    # Check each cache entry against filesystem
    sqlite3 "$DB_FILE" "SELECT hash, size FROM cache_outputs;" | while read line; do
        hash=$(echo "$line" | cut -d'|' -f1)
        recorded_size=$(echo "$line" | cut -d'|' -f2)
        
        if [ -d "$CACHE_DIR/$hash" ]; then
            # Folder exists - calculate actual size
            if [[ "$OSTYPE" == "darwin"* ]]; then
                actual_size=$(find "$CACHE_DIR/$hash" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
            else
                actual_size=$(du -sb "$CACHE_DIR/$hash" 2>/dev/null | cut -f1 || echo "0")
            fi
            
            if [ -z "$actual_size" ]; then
                actual_size=0
            fi
            
            log_verbose "Hash $(echo $hash | cut -c1-12)...: recorded=${recorded_size}B, actual=${actual_size}B"
            echo "$hash:$recorded_size:$actual_size:EXISTS"
        else
            # Folder missing
            log_verbose "Hash $(echo $hash | cut -c1-12)...: MISSING (recorded=${recorded_size}B)"
            echo "$hash:$recorded_size:0:MISSING"
        fi
    done > /tmp/cache_analysis.txt
    
    # Analyze results
    MISSING_COUNT=0
    MISSING_SIZE=0
    SIZE_MISMATCH_COUNT=0
    
    while IFS=':' read hash recorded_size actual_size status; do
        if [ "$status" = "MISSING" ]; then
            MISSING_COUNT=$((MISSING_COUNT + 1))
            MISSING_SIZE=$((MISSING_SIZE + recorded_size))
            log_verbose "Missing: $(echo $hash | cut -c1-12)... (${recorded_size}B)"
        elif [ "$status" = "EXISTS" ]; then
            if [ "$recorded_size" -ne "$actual_size" ]; then
                SIZE_MISMATCH_COUNT=$((SIZE_MISMATCH_COUNT + 1))
                log_verbose "Size mismatch: $(echo $hash | cut -c1-12)... (${recorded_size}B → ${actual_size}B)"
            fi
        fi
    done < /tmp/cache_analysis.txt
    
    MISSING_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $MISSING_SIZE / 1024 / 1024}")
    
    echo "  📋 Orphaned task entries: $ORPHANED_TASKS"
    echo "  📁 Missing cache folders: $MISSING_COUNT (${MISSING_SIZE_MB}MB recorded)"
    echo "  🔍 Size mismatches: $SIZE_MISMATCH_COUNT entries"
    
    # Check for non-hash folders (excluding official ones)
    SUSPICIOUS_FOLDERS=()
    if [ -d "$CACHE_DIR" ]; then
        log_verbose "Checking for suspicious folders..."
        while read item; do
            if [ "$item" != "$CACHE_DIR" ]; then
                name=$(basename "$item")
                # Skip official items and hash folders (64-char hex)
                if ! is_official_item "$name" && [[ ! "$name" =~ ^[a-f0-9]{64}$ ]] && [[ ! "$name" =~ ^[0-9]+$ ]]; then
                    if [ -d "$item" ]; then
                        size=$(du -sh "$item" 2>/dev/null | cut -f1 || echo "unknown")
                        SUSPICIOUS_FOLDERS+=("$name:$size")
                        log_verbose "Suspicious folder: $name ($size)"
                    fi
                fi
            fi
        done < <(find "$CACHE_DIR" -maxdepth 1)
    fi
    
    if [ ${#SUSPICIOUS_FOLDERS[@]} -gt 0 ]; then
        echo "  🚨 Suspicious items: ${#SUSPICIOUS_FOLDERS[@]}"
        for item in "${SUSPICIOUS_FOLDERS[@]}"; do
            echo "    - $(echo "$item" | tr ':' ' ')"
        done
    fi
    
else
    log_warning "Cache directory not found: $CACHE_DIR"
fi

echo ""

# Backup database first (skip in dry run unless explicitly requested)
if [ "$DRY_RUN" = false ]; then
    BACKUP_FILE="${DB_FILE}.repair-backup.$(date +%Y%m%d-%H%M%S)"
    log_verbose "Creating backup: $(basename "$BACKUP_FILE")"
    cp "$DB_FILE" "$BACKUP_FILE"
    log_success "📦 Database backed up to: $(basename "$BACKUP_FILE")"
    echo ""
fi

# Show repair plan
log_info "🤔 Repair Plan:"
echo "  1. Clean $ORPHANED_TASKS orphaned task entries"
if [ -f "/tmp/cache_analysis.txt" ]; then
    echo "  2. Remove $MISSING_COUNT missing cache entries from database"
    echo "  3. Update $SIZE_MISMATCH_COUNT size mismatches"
fi
if [ ${#SUSPICIOUS_FOLDERS[@]} -gt 0 ]; then
    echo "  4. Review ${#SUSPICIOUS_FOLDERS[@]} suspicious folders"
    if [ "$NON_INTERACTIVE" = true ]; then
        echo "     (will be skipped in non-interactive mode for safety)"
    else
        echo "     (will ask permission per item)"
    fi
fi
echo "  5. Optimize database"
echo ""

# Main confirmation
if ! confirm_action "Proceed with repair?" "y"; then
    log_warning "Repair cancelled"
    if [ -n "$BACKUP_FILE" ] && [ -f "$BACKUP_FILE" ]; then
        rm "$BACKUP_FILE"
    fi
    rm -f /tmp/cache_analysis.txt
    exit 0
fi

echo ""

# Step 1: Clean orphaned task entries
log_info "🧹 Step 1: Cleaning orphaned task entries..."
if [ "$ORPHANED_TASKS" -gt 0 ]; then
    echo "  Removing $ORPHANED_TASKS orphaned task entries..."
    
    # Show what will be deleted (if verbose or interactive)
    if [ "$VERBOSE" = true ] || [ "$NON_INTERACTIVE" = false ]; then
        echo "  Entries to be deleted:"
        sqlite3 "$DB_FILE" "
            SELECT '    - ' || project || ':' || target || ' (hash: ' || substr(hash, 1, 12) || '...)'
            FROM task_details td 
            WHERE NOT EXISTS (SELECT 1 FROM cache_outputs co WHERE co.hash = td.hash);
        " 2>/dev/null
    fi
    
    if [ "$DRY_RUN" = false ]; then
        # Delete orphaned tasks
        DELETED_TASKS=$(sqlite3 "$DB_FILE" "
            DELETE FROM task_details 
            WHERE hash NOT IN (SELECT hash FROM cache_outputs);
            SELECT changes();
        ")
        log_success "Deleted $DELETED_TASKS orphaned task entries"
    else
        log_info "DRY RUN: Would delete $ORPHANED_TASKS orphaned task entries"
    fi
else
    log_success "No orphaned task entries found"
fi

echo ""

# Step 2: Fix cache entries
log_info "🧹 Step 2: Fixing cache entries..."
if [ -f "/tmp/cache_analysis.txt" ]; then
    REMOVED_MISSING=0
    UPDATED_SIZES=0
    
    while IFS=':' read hash recorded_size actual_size status; do
        if [ "$status" = "MISSING" ]; then
            # Remove entries for missing cache folders
            recorded_mb=$(awk "BEGIN {printf \"%.2f\", $recorded_size / 1024 / 1024}")
            
            if [ "$DRY_RUN" = false ]; then
                sqlite3 "$DB_FILE" "
                    DELETE FROM cache_outputs WHERE hash = '$hash';
                    DELETE FROM task_details WHERE hash = '$hash';
                "
                echo "  🗑️  Removed missing: $(echo $hash | cut -c1-12)... (${recorded_mb}MB)"
            else
                echo "  🗑️  DRY RUN: Would remove missing: $(echo $hash | cut -c1-12)... (${recorded_mb}MB)"
            fi
            REMOVED_MISSING=$((REMOVED_MISSING + 1))
            
        elif [ "$status" = "EXISTS" ] && [ "$recorded_size" -ne "$actual_size" ]; then
            # Update size mismatches
            old_mb=$(awk "BEGIN {printf \"%.2f\", $recorded_size / 1024 / 1024}")
            new_mb=$(awk "BEGIN {printf \"%.2f\", $actual_size / 1024 / 1024}")
            
            if [ "$DRY_RUN" = false ]; then
                sqlite3 "$DB_FILE" "UPDATE cache_outputs SET size = $actual_size WHERE hash = '$hash';"
                echo "  🔄 Updated size: $(echo $hash | cut -c1-12)... (${old_mb}MB → ${new_mb}MB)"
            else
                echo "  🔄 DRY RUN: Would update size: $(echo $hash | cut -c1-12)... (${old_mb}MB → ${new_mb}MB)"
            fi
            UPDATED_SIZES=$((UPDATED_SIZES + 1))
        fi
    done < /tmp/cache_analysis.txt
    
    log_success "Processed $REMOVED_MISSING missing cache entries"
    log_success "Processed $UPDATED_SIZES size mismatches"
    
    rm -f /tmp/cache_analysis.txt
else
    log_success "No cache analysis data available"
fi

echo ""

# Step 3: Handle suspicious folders
log_info "🧹 Step 3: Reviewing suspicious folders..."
if [ ${#SUSPICIOUS_FOLDERS[@]} -gt 0 ]; then
    echo "  Found ${#SUSPICIOUS_FOLDERS[@]} suspicious folders..."
    
    DELETED_SUSPICIOUS=0
    for item in "${SUSPICIOUS_FOLDERS[@]}"; do
        folder_name=$(echo "$item" | cut -d':' -f1)
        folder_size=$(echo "$item" | cut -d':' -f2)
        
        echo "  🚨 Suspicious: $folder_name ($folder_size)"
        if confirm_individual_action "    Delete this folder?"; then
            if [ "$DRY_RUN" = false ]; then
                if [ -d "$CACHE_DIR/$folder_name" ]; then
                    rm -rf "$CACHE_DIR/$folder_name"
                    log_success "    Deleted: $folder_name"
                elif [ -f "$CACHE_DIR/$folder_name" ]; then
                    rm -f "$CACHE_DIR/$folder_name"
                    log_success "    Deleted: $folder_name"
                fi
            else
                log_info "    DRY RUN: Would delete: $folder_name"
            fi
            DELETED_SUSPICIOUS=$((DELETED_SUSPICIOUS + 1))
        else
            log_warning "    Skipped: $folder_name"
        fi
    done
    
    if [ "$DRY_RUN" = false ]; then
        log_success "Deleted $DELETED_SUSPICIOUS suspicious folders"
    else
        log_info "DRY RUN: Would delete $DELETED_SUSPICIOUS suspicious folders"
    fi
else
    log_success "No suspicious folders found"
fi

echo ""

# Step 4: Database optimization
log_info "🔄 Step 4: Optimizing database..."
if [ "$DRY_RUN" = false ]; then
    sqlite3 "$DB_FILE" "VACUUM;"
    sqlite3 "$DB_FILE" "ANALYZE;"
    log_success "Database optimized"
else
    log_info "DRY RUN: Would optimize database (VACUUM + ANALYZE)"
fi

echo ""

# Final verification
log_info "📊 Final Verification:"
FINAL_TASK_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM task_details;" 2>/dev/null || echo "0")
FINAL_CACHE_COUNT=$(sqlite3 "$DB_FILE" "SELECT COUNT(*) FROM cache_outputs;" 2>/dev/null || echo "0")
FINAL_DB_SIZE=$(sqlite3 "$DB_FILE" "SELECT COALESCE(SUM(size), 0) FROM cache_outputs;" 2>/dev/null || echo "0")
FINAL_DB_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $FINAL_DB_SIZE / 1024 / 1024}")

# Calculate actual filesystem size
if [ -d "$CACHE_DIR" ]; then
    FINAL_HASH_SIZE=0
    FINAL_HASH_COUNT=0
    
    while read dir; do
        if [ "$dir" != "$CACHE_DIR" ]; then
            name=$(basename "$dir")
            if [[ "$name" =~ ^[a-f0-9]{64}$ ]]; then
                FINAL_HASH_COUNT=$((FINAL_HASH_COUNT + 1))
                if [[ "$OSTYPE" == "darwin"* ]]; then
                    size_bytes=$(find "$dir" -type f -exec stat -f%z {} \; 2>/dev/null | awk '{sum += $1} END {print sum+0}')
                else
                    size_bytes=$(du -sb "$dir" 2>/dev/null | cut -f1 || echo "0")
                fi
                if [ -z "$size_bytes" ]; then
                    size_bytes=0
                fi
                FINAL_HASH_SIZE=$((FINAL_HASH_SIZE + size_bytes))
            fi
        fi
    done < <(find "$CACHE_DIR" -maxdepth 1 -type d)
    
    FINAL_HASH_SIZE_MB=$(awk "BEGIN {printf \"%.2f\", $FINAL_HASH_SIZE / 1024 / 1024}")
else
    FINAL_HASH_SIZE=0
    FINAL_HASH_SIZE_MB=0
    FINAL_HASH_COUNT=0
fi

echo "  📊 Cache entries: $FINAL_CACHE_COUNT"
echo "  📊 Total size: ${FINAL_DB_SIZE_MB}MB (database)"
echo "  📁 Hash folders: $FINAL_HASH_COUNT folders, ${FINAL_HASH_SIZE_MB}MB (filesystem)"

# Check final consistency
FINAL_ORPHANED_TASKS=$(sqlite3 "$DB_FILE" "
    SELECT COUNT(*) 
    FROM task_details td 
    WHERE NOT EXISTS (SELECT 1 FROM cache_outputs co WHERE co.hash = td.hash);
" 2>/dev/null || echo "0")

FINAL_ORPHANED_CACHE=$(sqlite3 "$DB_FILE" "
    SELECT COUNT(*) 
    FROM cache_outputs co 
    WHERE NOT EXISTS (SELECT 1 FROM task_details td WHERE td.hash = co.hash);
" 2>/dev/null || echo "0")

echo ""
log_info "🔍 Final Consistency Check:"
echo "  📋 Orphaned tasks: $FINAL_ORPHANED_TASKS"
echo "  💾 Orphaned cache entries: $FINAL_ORPHANED_CACHE"

# Calculate efficiency
if [ "$FINAL_HASH_SIZE" -gt 0 ] && [ "$FINAL_DB_SIZE" -gt 0 ]; then
    EFFICIENCY=$(awk "BEGIN {printf \"%.1f\", $FINAL_DB_SIZE * 100 / $FINAL_HASH_SIZE}")
    echo "  📊 Storage efficiency: ${EFFICIENCY}%"
    
    if [ "${EFFICIENCY%.*}" -ge 95 ] && [ "${EFFICIENCY%.*}" -le 105 ]; then
        log_success "Efficiency: EXCELLENT"
    elif [ "${EFFICIENCY%.*}" -ge 85 ] && [ "${EFFICIENCY%.*}" -le 115 ]; then
        log_success "Efficiency: GOOD"
    else
        log_warning "Efficiency: Some discrepancy remains"
    fi
fi

if [ "$FINAL_ORPHANED_TASKS" -eq 0 ] && [ "$FINAL_ORPHANED_CACHE" -eq 0 ]; then
    log_success "Database consistency: PERFECT"
else
    log_warning "Database consistency: Some issues remain"
fi

echo ""
if [ "$DRY_RUN" = true ]; then
    log_info "🔍 Dry run completed! No actual changes were made."
    echo ""
    echo "🎯 To apply these changes:"
    echo "  1. Run without -d flag: $0 $(echo "$@" | sed 's/-d//g' | sed 's/--dry-run//g')"
else
    log_success "🎉 Cache repair completed!"
    if [ -n "$BACKUP_FILE" ]; then
        echo "📦 Backup saved as: $(basename "$BACKUP_FILE")"
    fi
    echo ""
    echo "🎯 Next Steps:"
    echo "  1. Run: pnpm cache:stats"
    echo "  2. Verify efficiency is ~100%"
    if [ -n "$BACKUP_FILE" ]; then
        echo "  3. Delete backup if satisfied: rm '$BACKUP_FILE'"
    fi
fi

if [ "$NON_INTERACTIVE" = false ]; then
    echo ""
    echo "💡 Tips:"
    echo "  - Use '$0 -y' for CI/CD automation"
    echo "  - Use '$0 -y -v' for detailed logging"
    echo "  - Use '$0 -d' to preview changes"
fi