#!/bin/bash
# Setup script to install git hooks for the team

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

echo ""
info "🎣 Git Hooks Setup"
info "=================="

# Check if we're in repository root
if [ ! -d ".git" ]; then
    error "❌ Not in repository root! Please run from repository root."
    exit 1
fi

if [ ! -d "workspaces/node-app/build-script/setup-cache" ]; then
    error "❌ workspaces/node-app/build-script/setup-cache/ directory not found!"
    exit 1
fi

# Create hooks directory
mkdir -p .git/hooks

# Install hooks
HOOKS_INSTALLED=0

for hook_file in workspaces/node-app/build-script/setup-cache/*; do
    if [ -f "$hook_file" ]; then
        hook_name=$(basename "$hook_file")
        
        # Skip setup scripts, only install actual git hooks
        if [[ "$hook_name" == "setup-"* ]] || [[ "$hook_name" == "*.sh" ]]; then
            continue
        fi
        
        target_file=".git/hooks/$hook_name"
        
        info "Installing: $hook_name"
        cp "$hook_file" "$target_file"
        chmod +x "$target_file"
        
        if [ -x "$target_file" ]; then
            success "✅ $hook_name installed"
            HOOKS_INSTALLED=$((HOOKS_INSTALLED + 1))
        else
            warning "⚠️ $hook_name installation failed"
        fi
    fi
done

if [ $HOOKS_INSTALLED -gt 0 ]; then
    echo ""
    success "🎉 $HOOKS_INSTALLED git hooks installed!"
    
    echo ""
    info "💡 What's next:"
    info "  1. Configure .env in workspaces/node-app/"
    info "  2. Test: git commit --allow-empty -m 'test' && git push"
    info "  3. Watch pre-push hook run automatically"
    
else
    warning "⚠️ No hooks were installed"
fi

echo ""