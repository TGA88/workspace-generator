#!/bin/bash
# backup.sh - Script เดียวทำทุกอย่าง
# Simple S3 Backup Tool for Developers

# Load environment variables from .env if exists (optional)
if [ -f .env ]; then
    source .env
elif [ -f ../.env ]; then
    source ../.env
fi

# Get S3 settings from environment (either .env file or system environment)
BUCKET=${S3_NX_BUCKET}
PREFIX=${S3_NX_PREFIX}

# Check required S3 settings
if [ -z "$BUCKET" ] || [ -z "$PREFIX" ]; then
    echo "⚠️  Missing required S3 configuration:"
    [ -z "$BUCKET" ] && echo "❌ S3_NX_BUCKET not set"
    [ -z "$PREFIX" ] && echo "❌ S3_NX_PREFIX not set"
    echo ""
    echo "💡 Set via .env file:"
    echo "S3_NX_BUCKET=your-bucket"
    echo "S3_NX_PREFIX=your-team"
    echo ""
    echo "💡 Or export environment variables:"
    echo "export S3_NX_BUCKET=your-bucket"
    echo "export S3_NX_PREFIX=your-team"
    exit 1
fi

ACTION=$1
FILE_OR_ID=$2
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

# Check if AWS CLI is available
check_aws() {
    if ! command -v aws &> /dev/null; then
        log_error "AWS CLI not found. Please install: sudo apt install awscli"
        exit 1
    fi
    
    # Test AWS credentials
    if ! aws sts get-caller-identity >/dev/null 2>&1; then
        log_error "AWS credentials not configured or invalid"
        log_info "Check your credentials setup:"
        log_info "• Environment: export AWS_ACCESS_KEY_ID=..."
        log_info "• Profile: aws configure --profile your-profile"
        log_info "• .env file: AWS_ACCESS_KEY_ID=... (in .env)"
        exit 1
    fi
}

# Show AWS user info
show_aws_info() {
    if aws sts get-caller-identity >/dev/null 2>&1; then
        local user_arn=$(aws sts get-caller-identity --query Arn --output text 2>/dev/null)
        local account_id=$(aws sts get-caller-identity --query Account --output text 2>/dev/null)
        local user_id=$(aws sts get-caller-identity --query UserId --output text 2>/dev/null)
        
        # Extract username from ARN
        local username=""
        if [[ "$user_arn" == *":user/"* ]]; then
            username=$(echo "$user_arn" | sed 's|.*:user/||')
        elif [[ "$user_arn" == *":assumed-role/"* ]]; then
            username=$(echo "$user_arn" | sed 's|.*:assumed-role/||' | cut -d'/' -f1)
            username="$username (role)"
        else
            username="$(echo "$user_arn" | sed 's|.*/||')"
        fi
        
        echo "🔑 AWS User: $username"
        echo "🏢 Account: $account_id"
        
        # Show profile if using one
        if [ -n "$AWS_PROFILE" ]; then
            echo "👤 Profile: $AWS_PROFILE"
        fi
    else
        log_error "Cannot get AWS user info"
    fi
}

# Generate commit ID
get_commit_id() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        git rev-parse --short HEAD
    else
        date +%Y%m%d-%H%M%S
    fi
}

# Get file metadata for upload
get_metadata() {
    local file=$1
    local commit_id=$2
    
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch=$(git branch --show-current 2>/dev/null || echo "unknown")
        local author=$(git log -1 --pretty=format:'%an <%ae>' 2>/dev/null || echo "unknown")
        local message=$(git log -1 --pretty=format:'%s' 2>/dev/null | head -c 100 || echo "no message")
        
        echo "commit-id=$commit_id,branch=$branch,author=$author,message=$message,uploaded-by=$(whoami),upload-time=$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    else
        echo "commit-id=$commit_id,uploaded-by=$(whoami),upload-time=$(date -u +%Y-%m-%dT%H:%M:%SZ),source=manual"
    fi
}

case $ACTION in
    "upload")
        # Auto-detect file path if not provided
        if [ -z "$FILE_OR_ID" ]; then
            log_info "No file specified, auto-detecting from tmp/upload/..."
            
            # Try to find file with current commit ID
            COMMIT=$(get_commit_id)
            DEFAULT_FILE="tmp/upload/backup-$COMMIT.tar.gz"
            
            if [ -f "$DEFAULT_FILE" ]; then
                FILE_OR_ID="$DEFAULT_FILE"
                log_info "Found file for current commit: $FILE_OR_ID"
            else
                # Look for any .tar.gz file in tmp/upload/
                LATEST_FILE=$(find tmp/upload/ -name "*.tar.gz" -type f 2>/dev/null | head -1)
                if [ -n "$LATEST_FILE" ] && [ -f "$LATEST_FILE" ]; then
                    FILE_OR_ID="$LATEST_FILE"
                    log_info "Found latest file: $FILE_OR_ID"
                else
                    log_error "No backup file found in tmp/upload/"
                    echo ""
                    echo "Expected file: $DEFAULT_FILE"
                    echo "Or run: npm run cache:compress first"
                    exit 1
                fi
            fi
        fi
        
        if [ ! -f "$FILE_OR_ID" ]; then
            log_error "File not found: $FILE_OR_ID"
            exit 1
        fi
        
        check_aws
        
        # Generate commit ID and S3 key
        COMMIT=$(get_commit_id)
        S3_KEY="$PREFIX/backup-$COMMIT.tar.gz"
        FILE_SIZE=$(ls -lh "$FILE_OR_ID" | awk '{print $5}')
        
        log_info "Uploading backup..."
        echo "  📁 File: $FILE_OR_ID ($FILE_SIZE)"
        echo "  🔗 Commit: $COMMIT"
        echo "  📂 To: s3://$BUCKET/$S3_KEY"
        
        # Check if file already exists
        if aws s3api head-object --bucket "$BUCKET" --key "$S3_KEY" >/dev/null 2>&1; then
            log_warning "File already exists: $S3_KEY"
            read -p "Overwrite? (y/N): " CONFIRM
            if [[ ! "$CONFIRM" =~ ^[Yy]$ ]]; then
                log_info "Upload cancelled"
                exit 1
            fi
        fi
        
        # Upload with metadata
        METADATA=$(get_metadata "$FILE_OR_ID" "$COMMIT")
        
        aws s3api put-object \
            --bucket "$BUCKET" \
            --key "$S3_KEY" \
            --body "$FILE_OR_ID" \
            --metadata "$METADATA"
        
        if [ $? -eq 0 ]; then
            log_success "Upload successful!"
            echo "🌐 Location: s3://$BUCKET/$S3_KEY"
            
            # Save last backup info
            echo "$COMMIT" > .last-backup
            echo "$(date '+%Y-%m-%d %H:%M:%S') | upload | $COMMIT | $S3_KEY" >> .backup-history
            
            # Show current file count
            FILE_COUNT=$(aws s3 ls "s3://$BUCKET/$PREFIX/" | grep -c backup-)
            echo "📊 Total backups in $PREFIX/: $FILE_COUNT files"
        else
            log_error "Upload failed"
            exit 1
        fi
        ;;
        
    "download")
        if [ -z "$FILE_OR_ID" ]; then
            log_error "Commit ID required"
            echo "Usage: $0 download <commit-id> [output-path]"
            echo "       $0 download latest [output-path]"
            echo ""
            echo "Examples:"
            echo "  $0 download abc123              # Download to backup-abc123.tar.gz"
            echo "  $0 download abc123 ./downloads  # Download to ./downloads/"
            echo "  $0 download latest              # Download latest to current dir"
            echo ""
            echo "💡 Get commit ID from: $0 list"
            exit 1
        fi
        
        check_aws
        
        log_info "Download backup from S3"
        show_aws_info
        echo ""
        
        if [ "$FILE_OR_ID" = "latest" ]; then
            log_info "Finding latest backup..."
            COMMIT=$(aws s3api list-objects-v2 \
                --bucket "$BUCKET" \
                --prefix "$PREFIX/backup-" \
                --query 'sort_by(Contents, &LastModified)[-1].Key' \
                --output text | sed 's|.*/backup-\(.*\)\.tar\.gz|\1|')
            
            if [ "$COMMIT" = "None" ] || [ -z "$COMMIT" ]; then
                log_error "No backups found in $PREFIX/"
                exit 1
            fi
            
            log_info "Latest backup: $COMMIT"
        else
            COMMIT="$FILE_OR_ID"
        fi
        
        S3_KEY="$PREFIX/backup-$COMMIT.tar.gz"
        
        # Determine output path
        if [ -n "$OUTPUT_PATH" ]; then
            if [ -d "$OUTPUT_PATH" ]; then
                # If output path is directory, use it with default filename
                OUTPUT_FILE="$OUTPUT_PATH/backup-$COMMIT.tar.gz"
            else
                # If output path is file, use it as is
                OUTPUT_FILE="$OUTPUT_PATH"
                # Create directory if needed
                OUTPUT_DIR=$(dirname "$OUTPUT_FILE")
                [ ! -d "$OUTPUT_DIR" ] && mkdir -p "$OUTPUT_DIR"
            fi
        else
            # Default to tmp/download directory
            mkdir -p tmp/download
            OUTPUT_FILE="tmp/download/backup-$COMMIT.tar.gz"
        fi
        
        log_info "Downloading backup..."
        echo "  🔗 Commit: $COMMIT"
        echo "  📂 From: s3://$BUCKET/$S3_KEY"
        echo "  📁 To: $OUTPUT_FILE"
        
        aws s3api get-object \
            --bucket "$BUCKET" \
            --key "$S3_KEY" \
            "$OUTPUT_FILE"
        
        if [ $? -eq 0 ]; then
            log_success "Download successful!"
            echo "📁 File: $OUTPUT_FILE ($(ls -lh "$OUTPUT_FILE" | awk '{print $5}'))"
            
            # Save download history
            echo "$(date '+%Y-%m-%d %H:%M:%S') | download | $COMMIT | $OUTPUT_FILE" >> .backup-history
        else
            log_error "Download failed"
            log_info "Check if commit ID exists: $0 list"
            exit 1
        fi
        ;;
        
    "list")
        check_aws
        
        log_info "Listing backups in s3://$BUCKET/$PREFIX/"
        echo "$(printf '%.60s' '=')"
        printf "%-12s %-20s %-10s %s\n" "COMMIT" "DATE" "SIZE" "S3_KEY"
        echo "$(printf '%.60s' '-')"
        
        aws s3api list-objects-v2 \
            --bucket "$BUCKET" \
            --prefix "$PREFIX/backup-" \
            --query 'sort_by(Contents, &LastModified) | reverse(@) | [*].[Key,LastModified,Size]' \
            --output text | while read -r key last_modified size; do
            
            if [ -n "$key" ] && [ "$key" != "None" ]; then
                commit=$(echo "$key" | sed 's|.*/backup-\(.*\)\.tar\.gz|\1|')
                date_only=$(echo "$last_modified" | cut -dT -f1)
                
                # Convert size to human readable
                if command -v numfmt >/dev/null 2>&1; then
                    size_human=$(numfmt --to=iec "$size")
                else
                    size_human="${size}B"
                fi
                
                printf "%-12s %-20s %-10s %s\n" "$commit" "$date_only" "$size_human" "$key"
            fi
        done | head -20
        
        # Show summary
        TOTAL_FILES=$(aws s3 ls "s3://$BUCKET/$PREFIX/" | grep -c backup- 2>/dev/null || echo "0")
        echo ""
        echo "📊 Total backups: $TOTAL_FILES files"
        
        if [ -f .last-backup ]; then
            LAST_COMMIT=$(cat .last-backup)
            echo "🔗 Last uploaded: $LAST_COMMIT"
        fi
        ;;
        
    "status")
        log_info "Backup System Status"
        echo "$(printf '%.40s' '=')"
        
        # AWS status
        echo "🔑 AWS Status:"
        if command -v aws >/dev/null 2>&1; then
            if aws sts get-caller-identity >/dev/null 2>&1; then
                show_aws_info
            else
                log_error "AWS credentials not configured"
            fi
        else
            log_error "AWS CLI not installed"
        fi
        echo ""
        
        # Configuration
        echo "⚙️  Configuration:"
        echo "  🗂️  Bucket: $BUCKET"
        echo "  📁 Prefix: $PREFIX"
        echo "  🌍 Region: ${AWS_DEFAULT_REGION:-us-east-1}"
        echo ""
        
        # Bucket access
        echo "🗂️  Bucket Access:"
        if aws s3api head-bucket --bucket "$BUCKET" >/dev/null 2>&1; then
            log_success "Bucket accessible: $BUCKET"
            
            FILE_COUNT=$(aws s3 ls "s3://$BUCKET/$PREFIX/" | grep -c backup- 2>/dev/null || echo "0")
            log_success "Prefix accessible: $PREFIX/ ($FILE_COUNT files)"
        else
            log_error "Cannot access bucket: $BUCKET"
            log_info "Contact admin to verify permissions"
        fi
        echo ""
        
        # Git status
        echo "🔗 Git Status:"
        if git rev-parse --git-dir >/dev/null 2>&1; then
            CURRENT_BRANCH=$(git branch --show-current)
            CURRENT_COMMIT=$(git rev-parse --short HEAD)
            UNCOMMITTED=$(git status --porcelain | wc -l)
            
            echo "  🌿 Branch: $CURRENT_BRANCH"
            echo "  🔗 Commit: $CURRENT_COMMIT"
            if [ "$UNCOMMITTED" -gt 0 ]; then
                log_warning "Uncommitted changes: $UNCOMMITTED files"
            else
                log_success "Working directory clean"
            fi
        else
            log_info "Not in a git repository (will use timestamp)"
        fi
        ;;
        
    "history")
        check_aws
        
        log_info "Activity History"
        show_aws_info
        echo ""
        
        if [ -f .backup-history ]; then
            log_info "Recent Activity"
            echo "$(printf '%.60s' '=')"
            printf "%-20s %-10s %-12s %s\n" "TIMESTAMP" "ACTION" "COMMIT" "FILE"
            echo "$(printf '%.60s' '-')"
            tail -10 .backup-history | while IFS='|' read -r timestamp action commit file; do
                printf "%-20s %-10s %-12s %s\n" "$timestamp" "$action" "$commit" "$file"
            done
        else
            log_info "No history found"
            log_info "History will be created after first upload/download"
        fi
        ;;
        
    *)
        echo "🛠️  S3 Backup Tool - Simple Version"
        echo ""
        echo "Usage:"
        echo "  $0 upload [file]             Upload backup file (auto-detect if not specified)"
        echo "  $0 download <id> [path]      Download backup by commit ID"  
        echo "  $0 download latest [path]    Download latest backup"
        echo "  $0 list                      List all backups"
        echo "  $0 status                    Show system status"
        echo "  $0 history                   Show activity history"
        echo ""
        echo "Examples:"
        echo "  $0 upload                    # Auto-detect from tmp/upload/"
        echo "  $0 upload cache.tar.gz       # Upload specific file"
        echo "  $0 download abc123           # Download to tmp/download/"
        echo "  $0 download abc123 ./downloads/"
        echo "  $0 download latest ./backups/latest.tar.gz"
        echo ""
        echo "Setup S3 configuration:"
        echo "  S3_NX_BUCKET=your-bucket-name"
        echo "  S3_NX_PREFIX=your-team-name"
        echo ""
        echo "💡 AWS Credentials (choose one):"
        echo "  • .env file: AWS_ACCESS_KEY_ID=... AWS_SECRET_ACCESS_KEY=..."
        echo "  • Environment: export AWS_ACCESS_KEY_ID=..."
        echo "  • AWS Profile: aws configure --profile your-profile"
        echo "  • IAM Role: (automatic on EC2/Lambda)"
        echo ""
        echo "💡 Current config:"
        if [ -n "$BUCKET" ] && [ -n "$PREFIX" ]; then
            echo "  🗂️  Bucket: $BUCKET"
            echo "  📁 Prefix: $PREFIX"
            
            # Show AWS user if available
            if aws sts get-caller-identity >/dev/null 2>&1; then
                echo ""
                show_aws_info
            fi
        else
            log_warning "S3 configuration not set"
        fi
        ;;
esac