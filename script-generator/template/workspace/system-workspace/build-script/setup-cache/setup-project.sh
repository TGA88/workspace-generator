#!/bin/bash
# ========================================
# NX Cache Strategy - Production Scripts
# ========================================

# workspaces/node-app/build-script/setup-cache/setup-project.sh
# Complete setup script for new team members
#!/bin/bash
set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }
warning() { echo -e "${YELLOW}$1${NC}"; }
error() { echo -e "${RED}$1${NC}"; }

clear
cat << 'EOF'
  _   ___  __   ____           _          
 | \ | \ \/ /  / ___|__ _  ___| |__   ___ 
 |  \| |\  /  | |   / _` |/ __| '_ \ / _ \
 | |\  |/  \  | |__| (_| | (__| | | |  __/
 |_| \_/_/\_\  \____\__,_|\___|_| |_|\___|
                                          
 Complete Team Setup - Production Ready
EOF

echo ""
info "🚀 NX Cache Strategy - Complete Team Setup"
info "=========================================="

# Step 1: Prerequisites Check
info "📋 Step 1: Prerequisites Check"
echo "=============================="

check_prereq() {
    local cmd="$1"
    local name="$2"
    
    if command -v "$cmd" &> /dev/null; then
        success "✅ $name found: $(which $cmd)"
    else
        error "❌ $name not found! Please install $name first."
        return 1
    fi
}

PREREQ_FAILED=0

check_prereq "git" "Git" || PREREQ_FAILED=1
check_prereq "node" "Node.js" || PREREQ_FAILED=1
check_prereq "pnpm" "pnpm" || PREREQ_FAILED=1
check_prereq "aws" "AWS CLI" || PREREQ_FAILED=1

# Check Node version
NODE_VERSION=$(node --version | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -ge 18 ]; then
    success "✅ Node.js version: $(node --version)"
else
    error "❌ Node.js version too old: $(node --version). Need 18+."
    PREREQ_FAILED=1
fi

if [ $PREREQ_FAILED -eq 1 ]; then
    error "❌ Prerequisites not met. Please install required tools."
    exit 1
fi

echo ""

# Step 2: Repository Structure Check
info "📁 Step 2: Repository Structure"
echo "==============================="

if [ ! -d ".git" ]; then
    error "❌ Not in repository root!"
    exit 1
fi

# Create directories if they don't exist
mkdir -p scripts/git-hooks
mkdir -p workspaces/node-app/tools/remote-cache
mkdir -p tmp

success "✅ Repository structure ready"

# Step 3: Dependencies Installation
info "📦 Step 3: Dependencies Installation"
echo "===================================="

if [ -d "workspaces/node-app" ]; then
    cd workspaces/node-app
    
    if [ -f "package.json" ]; then
        info "Installing dependencies..."
        pnpm install --frozen-lockfile
        success "✅ Dependencies installed"
    else
        warning "⚠️ package.json not found in workspaces/node-app"
    fi
    
    cd ../..
else
    warning "⚠️ workspaces/node-app directory not found"
fi

# Step 4: Cache Tools Installation
info "🛠️ Step 4: Cache Tools Installation"
echo "==================================="

# Create backup.sh if it doesn't exist
if [ ! -f "workspaces/node-app/tools/remote-cache/backup.sh" ]; then
    info "Creating backup.sh..."
    cat > workspaces/node-app/tools/remote-cache/backup.sh << 'BACKUP_SCRIPT'
#!/bin/bash
# Main cache management script
set -e

# Load environment
if [ -f .env ]; then
    export $(cat .env | grep -v '^#' | xargs)
fi

OPERATION=${1:-help}
CACHE_KEY=${2:-}
TARGET_DIR=${3:-tmp/download}

# S3 Configuration
S3_BUCKET=${S3_NX_BUCKET:-company-backups}
S3_PREFIX=${S3_NX_PREFIX:-your-team}
AWS_REGION=${AWS_DEFAULT_REGION:-us-east-1}

case $OPERATION in
    "download")
        echo "📥 Downloading cache: $CACHE_KEY"
        mkdir -p $TARGET_DIR
        
        if aws s3 cp "s3://$S3_BUCKET/$S3_PREFIX/backup-$CACHE_KEY.tar.gz" "$TARGET_DIR/" --region $AWS_REGION 2>/dev/null; then
            echo "✅ Downloaded: backup-$CACHE_KEY.tar.gz"
            exit 0
        else
            echo "❌ Cache not found: backup-$CACHE_KEY.tar.gz"
            exit 1
        fi
        ;;
        
    "upload")
        echo "📤 Uploading cache: $CACHE_KEY"
        if [ -f "$CACHE_KEY" ]; then
            if aws s3 cp "$CACHE_KEY" "s3://$S3_BUCKET/$S3_PREFIX/" --region $AWS_REGION; then
                echo "✅ Uploaded: $(basename $CACHE_KEY)"
            else
                echo "❌ Upload failed"
                exit 1
            fi
        else
            echo "❌ File not found: $CACHE_KEY"
            exit 1
        fi
        ;;
        
    "list")
        echo "📋 Recent caches:"
        aws s3 ls "s3://$S3_BUCKET/$S3_PREFIX/" --region $AWS_REGION | grep "backup-.*\.tar\.gz" | sort -k1,2 -r | head -10
        ;;
        
    "status")
        echo "🔍 Cache Status:"
        echo "Bucket: $S3_BUCKET"
        echo "Prefix: $S3_PREFIX"
        echo "Region: $AWS_REGION"
        
        if aws s3 ls "s3://$S3_BUCKET/$S3_PREFIX/" --region $AWS_REGION >/dev/null 2>&1; then
            echo "✅ S3 connection OK"
        else
            echo "❌ S3 connection failed"
            exit 1
        fi
        ;;
        
    *)
        echo "Usage: $0 <operation> [cache_key] [target_dir]"
        echo "Operations: download, upload, list, status"
        ;;
esac
BACKUP_SCRIPT
    
    chmod +x workspaces/node-app/tools/remote-cache/backup.sh
    success "✅ backup.sh created"
else
    success "✅ backup.sh already exists"
fi

# Step 5: Git Hooks Installation
info "🎣 Step 5: Git Hooks Installation"
echo "================================="

# Create pre-push hook if it doesn't exist
if [ ! -f "workspaces/node-app/build-script/setup-cache/pre-push" ]; then
    info "Creating pre-push hook..."
    cat > workspaces/node-app/build-script/setup-cache/pre-push << 'PREPUSH_SCRIPT'
#!/bin/bash
# Pre-push hook for NX cache management
set -e

if [ ! -d "workspaces/node-app" ]; then
    echo "❌ Not in repository root!"
    exit 1
fi

cd workspaces/node-app

GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'
info() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }

echo ""
info "🚀 Pre-push Hook (Smart Cache)"
info "=============================="

COMMIT=$(git rev-parse --short HEAD)
BRANCH=$(git branch --show-current)

info "Branch: $BRANCH"
info "Commit: $COMMIT"

# Check cache first
if [ -f .env ]; then
    info "Checking existing cache..."
    
    if bash tools/remote-cache/backup.sh download $COMMIT tmp/check 2>/dev/null; then
        success "✅ Cache exists! Skipping build."
        rm -rf tmp/check
        exit 0
    else
        info "No cache found, building..."
        rm -rf tmp/check 2>/dev/null || true
    fi
fi

# Build process
info "Building..."
start_time=$(date +%s)

pnpm install --frozen-lockfile --silent || exit 1
pnpm build:all || exit 1
pnpm lint:all || exit 1
pnpm test:all || exit 1

end_time=$(date +%s)
duration=$((end_time - start_time))

success "✅ Build completed in ${duration}s"

# Create cache
if [ -f .env ]; then
    export CACHE_COMMIT_ID="$COMMIT"
    npm run cache:full:backup --silent
    success "✅ Cache created: backup-$COMMIT.tar.gz"
fi

echo ""
PREPUSH_SCRIPT

    chmod +x workspaces/node-app/build-script/setup-cache/pre-push
    success "✅ pre-push hook created"
else
    success "✅ pre-push hook already exists"
fi

# Install hooks
info "Installing git hooks..."
mkdir -p .git/hooks

for hook_file in workspaces/node-app/build-script/setup-cache/*; do
    if [ -f "$hook_file" ]; then
        hook_name=$(basename "$hook_file")
        
        # Skip setup scripts, only install actual git hooks
        if [[ "$hook_name" == "setup-"* ]] || [[ "$hook_name" == "*.sh" ]]; then
            continue
        fi
        
        cp "$hook_file" ".git/hooks/$hook_name"
        chmod +x ".git/hooks/$hook_name"
        success "✅ Installed: $hook_name"
    fi
done

# Step 6: Environment Configuration
info "⚙️ Step 6: Environment Configuration"
echo "===================================="

ENV_FILE="workspaces/node-app/.env"
if [ ! -f "$ENV_FILE" ]; then
    info "Creating .env template..."
    cat > "$ENV_FILE" << 'ENV_TEMPLATE'
# NX Cache Configuration
S3_NX_BUCKET=your-company-backups
S3_NX_PREFIX=your-team
AWS_DEFAULT_REGION=us-east-1

# AWS Credentials (configure with your values)
# AWS_ACCESS_KEY_ID=your-access-key
# AWS_SECRET_ACCESS_KEY=your-secret-key

# Uncomment and configure the above for cache sharing
ENV_TEMPLATE
    warning "📝 .env template created - please configure with your credentials"
else
    success "✅ .env file already exists"
fi

# Step 7: Package.json Scripts
info "📜 Step 7: Package.json Scripts"
echo "==============================="

PACKAGE_JSON="workspaces/node-app/package.json"
if [ -f "$PACKAGE_JSON" ]; then
    # Check if cache scripts exist
    if grep -q "cache:full:backup" "$PACKAGE_JSON"; then
        success "✅ Cache scripts already exist in package.json"
    else
        warning "⚠️ Cache scripts not found in package.json"
        info "Please add these scripts to your package.json:"
        cat << 'SCRIPTS'
{
  "scripts": {
    "cache:full:backup": "npm run cache:compress tmp/upload && bash tools/remote-cache/backup.sh upload tmp/upload/backup-${CACHE_COMMIT_ID:-$(git rev-parse --short HEAD)}.tar.gz",
    "cache:full:restore": "npm run cache:download && npm run cache:extract",
    "cache:download": "bash tools/remote-cache/backup.sh download ${CACHE_COMMIT_ID:-$(git rev-parse --short HEAD)} tmp/download",
    "cache:extract": "mkdir -p .nx && tar -xzf tmp/download/*.tar.gz -C .nx",
    "cache:compress": "mkdir -p ${1:-tmp/upload} && tar -czf ${1:-tmp/upload}/backup-${CACHE_COMMIT_ID:-$(git rev-parse --short HEAD)}.tar.gz -C .nx .",
    "cache:remote:status": "bash tools/remote-cache/backup.sh status"
  }
}
SCRIPTS
    fi
else
    warning "⚠️ package.json not found"
fi

# Step 8: Testing
info "🧪 Step 8: Testing Setup"
echo "========================"

cd workspaces/node-app

# Test AWS connection
info "Testing AWS connection..."
if bash tools/remote-cache/backup.sh status 2>/dev/null; then
    success "✅ AWS S3 connection working"
else
    warning "⚠️ AWS S3 connection failed - please configure credentials"
fi

# Test pre-push hook
info "Testing pre-push hook..."
if [ -x "../../.git/hooks/pre-push" ]; then
    success "✅ Pre-push hook installed and executable"
else
    warning "⚠️ Pre-push hook not properly installed"
fi

cd ../..

# Step 9: Final Summary
echo ""
success "🎉 Setup Completed Successfully!"
echo ""
info "📋 What's been set up:"
info "  ✅ Repository structure"
info "  ✅ Cache management tools" 
info "  ✅ Git hooks (pre-push)"
info "  ✅ Environment configuration"
info "  ✅ Basic testing"

echo ""
info "🔧 Next steps:"
info "  1. Configure AWS credentials in .env"
info "  2. Add cache scripts to package.json (if needed)"
info "  3. Test: git commit --allow-empty -m 'test' && git push"
info "  4. Set up Azure DevOps pipeline"

echo ""
info "📚 Resources:"
info "  • Documentation: [link to your internal docs]"
info "  • Team chat: [your team channel]"
info "  • Troubleshooting: [link to troubleshooting guide]"

echo ""
success "Ready to cache! 🚀"

# ========================================
# workspaces/node-app/build-script/setup-cache/health-check.sh
# System health monitoring script
# ========================================

#!/bin/bash
# Health check script for NX Cache system

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

info() { echo -e "${BLUE}$1${NC}"; }
success() { echo -e "${GREEN}$1${NC}"; }
warning() { echo -e "${YELLOW}$1${NC}"; }
error() { echo -e "${RED}$1${NC}"; }

# Check if we're in the right directory
if [ ! -d "workspaces/node-app" ]; then
    error "❌ Please run from repository root"
    exit 1
fi

cd workspaces/node-app

echo ""
info "🏥 NX Cache System Health Check"
info "==============================="

HEALTH_SCORE=0
TOTAL_CHECKS=10

# Check 1: Environment file
info "🔍 1. Environment Configuration"
if [ -f .env ]; then
    success "  ✅ .env file exists"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
    
    # Check for required variables
    if grep -q "S3_NX_BUCKET" .env && grep -q "S3_NX_PREFIX" .env; then
        success "  ✅ Required environment variables configured"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    else
        warning "  ⚠️ Missing required environment variables"
    fi
else
    error "  ❌ .env file not found"
fi

# Check 2: Cache tools
info "🔍 2. Cache Tools"
if [ -x "tools/remote-cache/backup.sh" ]; then
    success "  ✅ backup.sh script exists and executable"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
else
    error "  ❌ backup.sh script missing or not executable"
fi

# Check 3: Git hooks
info "🔍 3. Git Hooks"
if [ -x "../../.git/hooks/pre-push" ]; then
    success "  ✅ Pre-push hook installed"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
else
    error "  ❌ Pre-push hook not installed"
fi

# Check 4: AWS connectivity
info "🔍 4. AWS S3 Connectivity"
if bash tools/remote-cache/backup.sh status >/dev/null 2>&1; then
    success "  ✅ AWS S3 connection working"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
else
    error "  ❌ AWS S3 connection failed"
fi

# Check 5: Package.json scripts
info "🔍 5. Package.json Scripts"
if grep -q "cache:full:backup" package.json; then
    success "  ✅ Cache scripts found in package.json"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
else
    warning "  ⚠️ Cache scripts not found in package.json"
fi

# Check 6: Node modules
info "🔍 6. Dependencies"
if [ -d "node_modules" ]; then
    success "  ✅ Dependencies installed"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
else
    warning "  ⚠️ Dependencies not installed"
fi

# Check 7: Build tools
info "🔍 7. Build System"
if command -v pnpm >/dev/null 2>&1; then
    success "  ✅ pnpm available"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
else
    error "  ❌ pnpm not found"
fi

# Check 8: Cache directory
info "🔍 8. Cache Directory"
if [ -d ".nx" ]; then
    success "  ✅ .nx cache directory exists"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
    
    CACHE_SIZE=$(du -sh .nx 2>/dev/null | cut -f1 || echo "unknown")
    info "     Cache size: $CACHE_SIZE"
else
    info "  ℹ️ .nx cache directory not found (will be created on first build)"
fi

# Check 9: Recent cache activity
info "🔍 9. Recent Cache Activity"
if bash tools/remote-cache/backup.sh list >/dev/null 2>&1; then
    RECENT_CACHES=$(bash tools/remote-cache/backup.sh list 2>/dev/null | wc -l)
    if [ $RECENT_CACHES -gt 0 ]; then
        success "  ✅ $RECENT_CACHES cache files found"
        HEALTH_SCORE=$((HEALTH_SCORE + 1))
    else
        info "  ℹ️ No cache files found (new setup?)"
    fi
else
    warning "  ⚠️ Cannot check remote cache activity"
fi

# Check 10: Git repository status
info "🔍 10. Git Repository"
if git status >/dev/null 2>&1; then
    success "  ✅ Git repository working"
    HEALTH_SCORE=$((HEALTH_SCORE + 1))
    
    CURRENT_BRANCH=$(git branch --show-current)
    info "     Current branch: $CURRENT_BRANCH"
else
    error "  ❌ Git repository issues"
fi

# Final score
echo ""
info "📊 Health Check Results"
info "======================="

PERCENTAGE=$((HEALTH_SCORE * 100 / TOTAL_CHECKS))

if [ $PERCENTAGE -ge 90 ]; then
    success "🎉 Excellent health: $HEALTH_SCORE/$TOTAL_CHECKS ($PERCENTAGE%)"
    success "    System is production-ready!"
elif [ $PERCENTAGE -ge 70 ]; then
    warning "⚠️ Good health: $HEALTH_SCORE/$TOTAL_CHECKS ($PERCENTAGE%)"
    warning "    Some issues need attention"
else
    error "❌ Poor health: $HEALTH_SCORE/$TOTAL_CHECKS ($PERCENTAGE%)"
    error "    Significant issues need to be resolved"
fi

echo ""
info "💡 Recommendations:"

if [ $HEALTH_SCORE -lt $TOTAL_CHECKS ]; then
    info "  • Review failed checks above"
    info "  • Run: bash scripts/complete-team-setup.sh"
    info "  • Check documentation for troubleshooting"
fi

if [ $PERCENTAGE -ge 80 ]; then
    info "  • System ready for production use"
    info "  • Monitor cache hit rates regularly"
    info "  • Set up automated health checks"
fi

echo ""

exit 0