#!/bin/bash
# cache-helper.sh - NX Cache Management Helper (Fixed Version)
# Works with backup.sh for complete S3 backup solution

ACTION=$1
COMMIT_ID=$2
OUTPUT_PATH=$3

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }

# Default paths
NX_CACHE_DIR=".nx"
TMP_DIR="tmp"
UPLOAD_DIR="$TMP_DIR/upload"
DOWNLOAD_DIR="$TMP_DIR/download"

# Generate cache filename based on commit ID
generate_cache_filename() {
    local commit_id=${1:-$(get_commit_id)}
    echo "backup-${commit_id}.tar.gz"
}

# Generate commit ID
get_commit_id() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git rev-parse --short HEAD
    else
        date +%Y%m%d-%H%M%S
    fi
}

# Ensure temp directories exist
ensure_dirs() {
    mkdir -p "$UPLOAD_DIR" "$DOWNLOAD_DIR"
}

# Check if .nx directory exists
check_nx_cache() {
    if [ ! -d "$NX_CACHE_DIR" ]; then
        log_warning "NX cache directory not found: $NX_CACHE_DIR"
        log_info "This might be a new project or cache was already cleaned"
        return 1
    fi
    return 0
}

# Get cache size info
get_cache_info() {
    if [ -d "$NX_CACHE_DIR" ]; then
        local cache_size=$(du -sh "$NX_CACHE_DIR" 2>/dev/null | cut -f1 || echo "unknown")
        local file_count=$(find "$NX_CACHE_DIR" -type f 2>/dev/null | wc -l || echo "0")
        echo "📦 Cache: $cache_size ($file_count files)"
    fi
}

# 🔥 NEW: Check NX daemon status
check_nx_daemon() {
    if command -v nx >/dev/null 2>&1; then
        # Check if daemon is running using nx status
        if nx status >/dev/null 2>&1; then
            return 0  # Daemon is running
        else
            return 1  # Daemon is not running
        fi
    else
        log_warning "NX CLI not found"
        return 1
    fi
}

# 🔥 NEW: Stop NX daemon safely
stop_nx_daemon() {
    if check_nx_daemon; then
        log_info "Stopping NX daemon for safe backup..."
        
        # Stop daemon
        nx reset >/dev/null 2>&1
        
        # Wait for daemon to fully stop
        local timeout=10
        local count=0
        while check_nx_daemon && [ $count -lt $timeout ]; do
            sleep 1
            count=$((count + 1))
            echo -n "."
        done
        echo ""
        
        if check_nx_daemon; then
            log_warning "NX daemon still running after $timeout seconds"
            log_info "Continuing anyway, but backup might be inconsistent"
            return 1
        else
            log_success "NX daemon stopped successfully"
            return 0
        fi
    else
        log_info "NX daemon was not running"
        return 0
    fi
}

# 🔥 NEW: Check for SQLite WAL/SHM files
check_sqlite_files() {
    local has_active_sqlite=false
    
    # Check for .wal and .shm files in cache directory
    if [ -d "$NX_CACHE_DIR" ]; then
        local wal_files=$(find "$NX_CACHE_DIR" -name "*.wal" -type f 2>/dev/null | head -5)
        local shm_files=$(find "$NX_CACHE_DIR" -name "*.shm" -type f 2>/dev/null | head -5)
        
        if [ -n "$wal_files" ] || [ -n "$shm_files" ]; then
            has_active_sqlite=true
            log_warning "Active SQLite files found:"
            [ -n "$wal_files" ] && echo "$wal_files" | while read file; do echo "  📝 WAL: $(basename "$file")"; done
            [ -n "$shm_files" ] && echo "$shm_files" | while read file; do echo "  🔗 SHM: $(basename "$file")"; done
        fi
    fi
    
    return $( [ "$has_active_sqlite" = true ] && echo 0 || echo 1 )
}

# 🔥 NEW: Wait for SQLite files to close
wait_for_sqlite_close() {
    local timeout=15
    local count=0
    
    log_info "Waiting for SQLite files to close..."
    
    while check_sqlite_files && [ $count -lt $timeout ]; do
        sleep 1
        count=$((count + 1))
        echo -n "."
    done
    echo ""
    
    if check_sqlite_files; then
        log_warning "SQLite files still active after $timeout seconds"
        log_warning "Backup may be inconsistent - consider manual cleanup"
        return 1
    else
        log_success "SQLite files closed successfully"
        return 0
    fi
}

# 🔥 NEW: Cleanup temporary and problematic files before backup
cleanup_cache_files() {
    if [ ! -d "$NX_CACHE_DIR" ]; then
        return 0
    fi
    
    log_info "🧹 Cleaning up temporary files before backup..."
    
    local cleaned_count=0
    
    # Find and clean SQLite temporary files
    find "$NX_CACHE_DIR" -name "*.wal" -type f 2>/dev/null | while read file; do
        echo "  🗑️  Removing WAL: $(basename "$file")"
        rm -f "$file"
        cleaned_count=$((cleaned_count + 1))
    done
    
    find "$NX_CACHE_DIR" -name "*.shm" -type f 2>/dev/null | while read file; do
        echo "  🗑️  Removing SHM: $(basename "$file")"
        rm -f "$file"
        cleaned_count=$((cleaned_count + 1))
    done
    
    # Find and clean backup files (pattern: *.backup.*)
    find "$NX_CACHE_DIR" -name "*.backup.*" -type f 2>/dev/null | while read file; do
        echo "  🗑️  Removing backup: $(basename "$file")"
        rm -f "$file"
        cleaned_count=$((cleaned_count + 1))
    done
    
    # Find and clean temporary files
    find "$NX_CACHE_DIR" -name "*.tmp" -type f 2>/dev/null | while read file; do
        echo "  🗑️  Removing temp: $(basename "$file")"
        rm -f "$file"
        cleaned_count=$((cleaned_count + 1))
    done
    
    # Clean empty lock files
    find "$NX_CACHE_DIR" -name "*.lock" -size 0 -type f 2>/dev/null | while read file; do
        echo "  🗑️  Removing empty lock: $(basename "$file")"
        rm -f "$file"
        cleaned_count=$((cleaned_count + 1))
    done
    
    # Count actual cleaned files
    local actual_cleaned=$(find "$NX_CACHE_DIR" -name "*.wal" -o -name "*.shm" -o -name "*.backup.*" -o -name "*.tmp" -type f 2>/dev/null | wc -l)
    
    if [ "$actual_cleaned" -eq 0 ]; then
        log_success "Cache cleanup completed - no temporary files found"
    else
        log_warning "Some temporary files remain: $actual_cleaned files"
        echo "  💡 This might indicate active processes still using cache"
    fi
    
    return 0
}

# 🔥 NEW: SQLite checkpoint to commit WAL files before cleanup
sqlite_checkpoint() {
    if [ ! -d "$NX_CACHE_DIR" ]; then
        return 0
    fi
    
    # Look for SQLite database files
    local db_files=$(find "$NX_CACHE_DIR" -name "*.db" -type f 2>/dev/null)
    
    if [ -z "$db_files" ]; then
        return 0  # No SQLite databases found
    fi
    
    log_info "📊 Performing SQLite checkpoint for database consistency..."
    
    echo "$db_files" | while read db_file; do
        if [ -f "$db_file" ]; then
            local db_name=$(basename "$db_file")
            echo "  📊 Checkpointing: $db_name"
            
            # Try to checkpoint the database (commit WAL to main db)
            if command -v sqlite3 >/dev/null 2>&1; then
                sqlite3 "$db_file" "PRAGMA wal_checkpoint(TRUNCATE);" 2>/dev/null || {
                    echo "    ⚠️  Could not checkpoint $db_name (database may be locked)"
                }
            else
                echo "    💡 sqlite3 not available - skipping checkpoint"
            fi
        fi
    done
    
    log_success "SQLite checkpoint completed"
    return 0
}

# 🔥 NEW: Safe compression with daemon management
safe_compress() {
    local commit_id=$1
    local output_path=$2
    local cache_filename=$(generate_cache_filename "$commit_id")
    local restart_daemon=false
    
    log_info "🔒 Starting safe compression process..."
    echo "  🔗 Commit ID: $commit_id"
    echo "  📁 Output path: $output_path"
    
    # Check if daemon was running
    if check_nx_daemon; then
        restart_daemon=true
        log_info "NX daemon is running - will restart after backup"
    fi
    
    # Stop daemon for safe backup
    if ! stop_nx_daemon; then
        log_warning "Could not cleanly stop NX daemon"
    fi
    
    # Wait for SQLite files to close
    if ! wait_for_sqlite_close; then
        log_warning "SQLite files may still be active"
        
        # Ask user if they want to continue
        echo ""
        read -p "⚠️  Continue with potentially inconsistent backup? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            log_info "Backup cancelled by user"
            
            # Restart daemon if it was running
            if [ "$restart_daemon" = true ]; then
                log_info "Restarting NX daemon..."
                nx build --help >/dev/null 2>&1 &  # Start daemon quietly
            fi
            
            return 1
        fi
    fi
    
    # 🔥 NEW: Perform SQLite checkpoint before cleanup
    sqlite_checkpoint
    
    # 🔥 NEW: Clean up temporary files before compression
    cleanup_cache_files
    
    # Ensure output directory exists
    mkdir -p "$output_path"
    
    if ! check_nx_cache; then
        log_error "Cannot compress: NX cache directory not found"
        return 1
    fi
    
    get_cache_info
    
    log_info "Creating compressed archive..."
    echo "  📁 Source: $NX_CACHE_DIR/"
    echo "  📦 Target: $output_path/$cache_filename"
    
    # Create tar.gz with compression
    tar -czf "$output_path/$cache_filename" -C . "$NX_CACHE_DIR" 2>/dev/null
    
    local tar_exit_code=$?
    
    # Restart daemon if it was running before
    if [ "$restart_daemon" = true ]; then
        log_info "Restarting NX daemon..."
        # Trigger daemon start by running a harmless command
        nx --version >/dev/null 2>&1 &
    fi
    
    if [ $tar_exit_code -eq 0 ] && [ -f "$output_path/$cache_filename" ]; then
        COMPRESSED_SIZE=$(ls -lh "$output_path/$cache_filename" | awk '{print $5}')
        log_success "Cache compressed successfully!"
        echo "  📦 Compressed file: $COMPRESSED_SIZE"
        echo "  📁 Location: $output_path/$cache_filename"
        echo "  🔗 Commit ID: $commit_id"
        
        # Show compression ratio
        if command -v du >/dev/null 2>&1; then
            ORIGINAL_KB=$(du -sk "$NX_CACHE_DIR" 2>/dev/null | cut -f1 || echo "0")
            COMPRESSED_KB=$(du -sk "$output_path/$cache_filename" 2>/dev/null | cut -f1 || echo "0")
            if [ "$ORIGINAL_KB" -gt 0 ] && [ "$COMPRESSED_KB" -gt 0 ]; then
                RATIO=$(echo "scale=1; $COMPRESSED_KB * 100 / $ORIGINAL_KB" | bc -l 2>/dev/null || echo "unknown")
                echo "  📊 Compression: ${RATIO}% of original size"
            fi
        fi
        
        # 🔥 NEW: Verify backup integrity
        log_info "🔍 Verifying backup integrity..."
        if tar -tzf "$output_path/$cache_filename" >/dev/null 2>&1; then
            log_success "Backup integrity verified"
        else
            log_error "Backup integrity check failed!"
            return 1
        fi
        
        return 0
    else
        log_error "Failed to compress cache"
        return 1
    fi
}

case $ACTION in
    "compress")
        # Get commit ID from parameter, environment, or generate
        commit_id=${COMMIT_ID:-${CACHE_COMMIT_ID:-$(get_commit_id)}}
        # Get output path from parameter or default to tmp/upload
        output_path=${OUTPUT_PATH:-"tmp/upload"}
        
        # 🔥 CHANGED: Use safe compression
        safe_compress "$commit_id" "$output_path"
        ;;
        
    "extract")
        # Get commit ID from parameter, environment, or auto-detect
        commit_id=${COMMIT_ID:-${CACHE_COMMIT_ID}}
        
        log_info "Extracting NX cache from backup..."
        if [ -n "$commit_id" ]; then
            echo "  🔗 Target commit: $commit_id"
        fi
        ensure_dirs
        
        # Look for downloaded cache file
        CACHE_FILE=""
        if [ -n "$commit_id" ]; then
            target_filename=$(generate_cache_filename "$commit_id")
            if [ -f "$DOWNLOAD_DIR/$target_filename" ]; then
                CACHE_FILE="$DOWNLOAD_DIR/$target_filename"
            elif [ -f "$target_filename" ]; then
                CACHE_FILE="$target_filename"
            fi
        fi
        
        # Fallback to any .tar.gz file if specific commit not found
        if [ -z "$CACHE_FILE" ]; then
            if [ -f "$DOWNLOAD_DIR/nx-cache.tar.gz" ]; then
                CACHE_FILE="$DOWNLOAD_DIR/nx-cache.tar.gz"
            elif [ -f "nx-cache.tar.gz" ]; then
                CACHE_FILE="nx-cache.tar.gz"
            else
                # Look for any .tar.gz file in download directory
                CACHE_FILE=$(find "$DOWNLOAD_DIR" -name "*.tar.gz" -type f | head -1)
            fi
        fi
        
        if [ -z "$CACHE_FILE" ] || [ ! -f "$CACHE_FILE" ]; then
            log_error "No cache backup file found"
            log_info "Expected locations:"
            if [ -n "$commit_id" ]; then
                target_filename=$(generate_cache_filename "$commit_id")
                echo "  • $DOWNLOAD_DIR/$target_filename"
                echo "  • $target_filename"
            fi
            echo "  • $DOWNLOAD_DIR/nx-cache.tar.gz"
            echo "  • Any .tar.gz in $DOWNLOAD_DIR/"
            echo ""
            log_info "Download a backup first: npm run cache:remote:download"
            exit 1
        fi
        
        FILE_SIZE=$(ls -lh "$CACHE_FILE" | awk '{print $5}')
        log_info "Found cache backup: $CACHE_FILE ($FILE_SIZE)"
        
        # 🔥 NEW: Stop daemon before extraction for safety
        local restart_daemon=false
        if check_nx_daemon; then
            restart_daemon=true
            stop_nx_daemon
        fi
        
        # Backup existing cache if it exists
        if [ -d "$NX_CACHE_DIR" ]; then
            BACKUP_NAME=".nx-backup-$(date +%Y%m%d-%H%M%S)"
            log_warning "Existing cache found, backing up to: $BACKUP_NAME"
            mv "$NX_CACHE_DIR" "$BACKUP_NAME"
        fi
        
        # Extract the cache
        log_info "Extracting cache..."
        tar -xzf "$CACHE_FILE" -C . 2>/dev/null
        
        if [ $? -eq 0 ] && [ -d "$NX_CACHE_DIR" ]; then
            log_success "Cache extracted successfully!"
            get_cache_info
            
            # Clean up downloaded file
            rm -f "$CACHE_FILE"
            log_info "Cleaned up downloaded file"
            
            # Restart daemon if it was running
            if [ "$restart_daemon" = true ]; then
                log_info "Restarting NX daemon..."
                nx --version >/dev/null 2>&1 &
            fi
            
        else
            log_error "Failed to extract cache"
            
            # Restore backup if extraction failed
            if [ -d "$BACKUP_NAME" ]; then
                log_info "Restoring original cache..."
                mv "$BACKUP_NAME" "$NX_CACHE_DIR"
            fi
            
            # Restart daemon if it was running
            if [ "$restart_daemon" = true ]; then
                log_info "Restarting NX daemon..."
                nx --version >/dev/null 2>&1 &
            fi
            
            exit 1
        fi
        ;;
        
    "full-backup")
        # Get parameters with defaults
        commit_id=${COMMIT_ID:-${CACHE_COMMIT_ID:-$(get_commit_id)}}
        output_path=${OUTPUT_PATH:-"tmp/upload"}
        
        log_info "🚀 Starting full backup workflow..."
        echo "  🔗 Using commit ID: $commit_id"
        echo "  📁 Using output path: $output_path"
        
        # Export for child processes
        export CACHE_COMMIT_ID="$commit_id"
        
        # Step 1: Safe compress to specified path
        log_info "📦 Step 1: Safely compressing cache..."
        if ! safe_compress "$commit_id" "$output_path"; then
            log_error "Safe compression failed"
            exit 1
        fi
        
        # Step 2: Upload (backup.sh will auto-detect from the output path)
        log_info "☁️  Step 2: Uploading to S3..."
        if [ "$output_path" = "tmp/upload" ]; then
            # Use auto-detection if using default path
            bash tools/remote-cache/backup.sh upload
        else
            # Specify the exact file if using custom path
            cache_filename=$(generate_cache_filename "$commit_id")
            bash tools/remote-cache/backup.sh upload "$output_path/$cache_filename"
        fi
        
        if [ $? -eq 0 ]; then
            log_success "✅ Full backup completed successfully!"
            echo "  📁 Source: .nx/"
            echo "  📦 Compressed: $output_path/backup-$commit_id.tar.gz"
            echo "  ☁️  Uploaded: s3://${S3_NX_BUCKET:-your-bucket}/${S3_NX_PREFIX:-your-prefix}/backup-$commit_id.tar.gz"
            echo "  🔒 Backup was created safely with daemon management"
        else
            log_error "❌ Upload failed"
            exit 1
        fi
        ;;
        
    "full-restore")
        commit_id=${COMMIT_ID:-${CACHE_COMMIT_ID}}
        
        log_info "🔄 Starting full restore workflow..."
        
        if [ -n "$commit_id" ]; then
            echo "  🔗 Targeting commit ID: $commit_id"
            
            # Step 1: Download specific commit
            log_info "📥 Step 1: Downloading specific backup..."
            bash tools/remote-cache/backup.sh download "$commit_id"
            
            if [ $? -ne 0 ]; then
                log_error "Download failed for commit: $commit_id"
                exit 1
            fi
            
            # Step 2: Extract with commit ID context
            log_info "📦 Step 2: Extracting cache..."
            export CACHE_COMMIT_ID="$commit_id"
            bash "$0" extract "$commit_id"
            
        else
            echo "  🔗 Using latest available backup"
            
            # Step 1: Download latest
            log_info "📥 Step 1: Downloading latest backup..."
            bash tools/remote-cache/backup.sh download latest
            
            if [ $? -ne 0 ]; then
                log_error "Download failed"
                exit 1
            fi
            
            # Step 2: Extract
            log_info "📦 Step 2: Extracting cache..."
            bash "$0" extract
        fi
        
        if [ $? -eq 0 ]; then
            log_success "✅ Full restore completed successfully!"
            echo "  🔒 Restore was performed safely with daemon management"
        else
            log_error "❌ Extraction failed"
            exit 1
        fi
        ;;
        
    "clean")
        log_info "Cleaning temporary files..."
        
        if [ -d "$TMP_DIR" ]; then
            rm -rf "$TMP_DIR"/*
            log_success "Temporary files cleaned"
        else
            log_info "No temporary files to clean"
        fi
        
        # Also clean any backup files in current directory
        BACKUP_COUNT=$(find . -maxdepth 1 -name "*.tar.gz" -type f | wc -l)
        if [ "$BACKUP_COUNT" -gt 0 ]; then
            find . -maxdepth 1 -name "*.tar.gz" -type f -delete
            log_success "Removed $BACKUP_COUNT backup files from current directory"
        fi
        ;;
        
    "status")
        log_info "NX Cache Status"
        echo "$(printf '%.40s' '=')"
        
        # Cache directory status
        if [ -d "$NX_CACHE_DIR" ]; then
            log_success "NX cache exists"
            get_cache_info
        else
            log_warning "NX cache not found"
            echo "  💡 Run 'nx build' or 'nx test' to generate cache"
        fi
        
        echo ""
        echo "📁 Directory Status:"
        echo "  📂 Upload dir: $UPLOAD_DIR $([ -d "$UPLOAD_DIR" ] && echo "✅" || echo "❌")"
        echo "  📂 Download dir: $DOWNLOAD_DIR $([ -d "$DOWNLOAD_DIR" ] && echo "✅" || echo "❌")"
        
        # Check for files in temp directories
        if [ -d "$UPLOAD_DIR" ]; then
            UPLOAD_FILES=$(find "$UPLOAD_DIR" -name "*.tar.gz" | wc -l)
            [ "$UPLOAD_FILES" -gt 0 ] && echo "  📦 Upload files: $UPLOAD_FILES ready"
        fi
        
        if [ -d "$DOWNLOAD_DIR" ]; then
            DOWNLOAD_FILES=$(find "$DOWNLOAD_DIR" -name "*.tar.gz" | wc -l)
            [ "$DOWNLOAD_FILES" -gt 0 ] && echo "  📥 Download files: $DOWNLOAD_FILES ready"
        fi
        
        # 🔥 NEW: NX Daemon status
        echo ""
        echo "🤖 NX Daemon Status:"
        if check_nx_daemon; then
            log_warning "NX daemon is running"
            echo "  ⚠️  Backup may require daemon restart for consistency"
        else
            log_success "NX daemon is stopped"
            echo "  ✅ Safe for backup operations"
        fi
        
        # 🔥 NEW: SQLite files status
        echo ""
        echo "💾 SQLite Files Status:"
        if check_sqlite_files; then
            log_warning "Active SQLite files detected"
            echo "  ⚠️  .wal/.shm files present - database is active"
            echo "  💡 Consider stopping daemon before backup"
        else
            log_success "No active SQLite files"
            echo "  ✅ Safe for backup operations"
        fi
        
        # Git status
        echo ""
        echo "🔗 Git Integration:"
        if git rev-parse --git-dir >/dev/null 2>&1; then
            CURRENT_COMMIT=$(git rev-parse --short HEAD 2>/dev/null || echo "unknown")
            CURRENT_BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
            echo "  🌿 Branch: $CURRENT_BRANCH"
            echo "  🔗 Commit: $CURRENT_COMMIT"
        else
            log_info "Not in a git repository"
        fi
        ;;
        
    "init")
        log_info "Initializing cache helper directories..."
        ensure_dirs
        
        # Create .gitignore entries
        if [ ! -f .gitignore ]; then
            touch .gitignore
        fi
        
        # Add entries if they don't exist
        grep -q "^tmp/$" .gitignore 2>/dev/null || echo "tmp/" >> .gitignore
        grep -q "^\.nx/$" .gitignore 2>/dev/null || echo ".nx/" >> .gitignore &&  echo ".nx*" >> .gitignore
        grep -q "^.*\.tar\.gz$" .gitignore 2>/dev/null || echo "*.tar.gz" >> .gitignore
        
        log_success "Cache helper initialized!"
        echo "  📁 Created: $UPLOAD_DIR/"
        echo "  📁 Created: $DOWNLOAD_DIR/"
        echo "  📝 Updated: .gitignore"
        ;;
        
    "help"|"")
        echo "🛠️  NX Cache Helper - Local Cache Management (Safe Version)"
        echo ""
        echo "Usage: $0 <action>"
        echo ""
        echo "Actions:"
        echo "  compress    🔒 Safely compress .nx cache to tmp/upload/ (stops daemon)"
        echo "  extract     📦 Extract downloaded backup to .nx/ (stops daemon)"
        echo "  clean       🧹 Clean temporary files"
        echo "  status      📊 Show cache and directory status + safety checks" 
        echo "  init        🔧 Initialize directories and .gitignore"
        echo "  help        📖 Show this help"
        echo ""
        echo "🔒 Safety Features:"
        echo "  • Automatically stops NX daemon before backup/restore"
        echo "  • Waits for SQLite .wal/.shm files to close"
        echo "  • Verifies backup integrity"
        echo "  • Restarts daemon after operations"
        echo "  • Provides backup of existing cache before restore"
        echo ""
        echo "Typical Workflow:"
        echo "  1. npm run cache:compress     # 🔒 Safe compress local cache"
        echo "  2. npm run cache:remote:upload # ☁️  Upload to S3"
        echo "  3. npm run cache:remote:download # 📥 Download from S3"
        echo "  4. npm run cache:extract      # 🔒 Safe extract to local cache"
        echo ""
        echo "Quick Commands:"
        echo "  npm run cache:full:backup     # 🔒 Safe compress + upload"
        echo "  npm run cache:full:restore    # 📥 Download + safe extract"
        echo ""
        echo "💡 This script safely manages NX daemon and SQLite files"
        ;;
        
    *)
        log_error "Unknown action: $ACTION"
        echo ""
        echo "Available actions: compress, extract, clean, status, init, help"
        echo "Run '$0 help' for detailed usage"
        exit 1
        ;;
esac