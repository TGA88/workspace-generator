# 🗄️ Nx Cache Management Guide

> Complete guide for managing Nx cache in aam-audithub-system monorepo

## 📋 Table of Contents

- [Quick Start](#-quick-start)
- [Daily Commands](#-daily-commands)
- [Analysis & Monitoring](#-analysis--monitoring)
- [Maintenance & Cleanup](#-maintenance--cleanup)
- [Project Management](#-project-management)
- [CI/CD Integration](#-cicd-integration)
- [Advanced Usage](#-advanced-usage)
- [Troubleshooting](#-troubleshooting)
- [Best Practices](#-best-practices)

---

## 🚀 Quick Start

### Essential Commands (Remember These!)

```bash
# Health check - run this daily
pnpm cache:check

# View statistics  
pnpm cache:stats

# Clean old cache (safe)
pnpm cache:clean

# Full optimization (recommended weekly)
pnpm cache:optimize

# Get help
pnpm cache:help
```

### When Things Go Wrong

```bash
# Find problems
pnpm cache:issues

# Fix specific issues
pnpm cache:fix              # 🆕 Auto-repair for CI/CD
pnpm cache:fix:interactive  # Manual review mode
pnpm cache:fix:verbose      # 🆕 Auto-repair + detailed logs
pnpm cache:fix:dry-run      # 🆕 Preview what would be fixed

# Nuclear option (emergency only)
pnpm cache:reset
```

---

## 📊 Daily Commands

### Health Monitoring

```bash
# Quick health check with recommendations
pnpm cache:check
# ✅ Shows: cache size, entries count, health score, recommendations

# Detailed statistics
pnpm cache:stats  
# ✅ Shows: per-project breakdown, largest entries, recent activity

# Quick status overview
pnpm cache:monitor
# ✅ Shows: total size and entry count
```

### Basic Cleanup

```bash
# Clean old cache entries (keeps 3 versions per target)
pnpm cache:clean

# Aggressive cleanup (keeps only latest version)
pnpm cache:clean:latest

# Clean specific number of versions
./tools/nx-script/nx-cache-cleanup-v2.sh 2  # Keep 2 versions
```

---

## 🔍 Analysis & Monitoring

### Finding Issues

```bash
# Find all cache issues
pnpm cache:issues
# ✅ Shows: orphaned files + projects with many versions

# Find specific problems
pnpm cache:find:orphans   # Orphaned cache folders
pnpm cache:find:largest   # Largest cache entries  
pnpm cache:find:old       # Projects with >3 versions
```

### Listing & Searching

```bash
# List all projects
pnpm cache:list

# Recent cache activity
pnpm cache:list:recent

# Search for specific pattern
pnpm cache:search my-app
```

### Real-time Monitoring

```bash
# Watch cache health (updates every 10 seconds)
pnpm cache:watch

# Manual monitoring
pnpm cache:monitor
```

---

## 🧹 Maintenance & Cleanup

### Full Optimization (Recommended)

```bash
# Complete optimization - does everything:
# 1. Clean old entries
# 2. Remove orphaned files  
# 3. Clean suspicious items
# 4. Fix database issues
# 5. Repair size mismatches
pnpm cache:optimize
```

### 🆕 Enhanced Cache Repair (Updated with Flags)

```bash
# 🤖 CI/CD Friendly - Auto-repair without prompts
pnpm cache:fix              # Non-interactive mode (recommended for CI)
pnpm cache:fix:verbose      # Non-interactive + detailed logging

# 👤 Manual Control - Interactive mode
pnpm cache:fix:interactive  # Original behavior with prompts

# 🔍 Preview Mode - See what would be fixed
pnpm cache:fix:dry-run      # Dry run with detailed analysis
```

#### **Repair Operations:**
1. **Clean orphaned task entries** - Remove database entries without cache files
2. **Remove missing cache entries** - Clean database entries for deleted cache folders  
3. **Update size mismatches** - Sync database sizes with actual filesystem sizes
4. **Review suspicious folders** - Handle non-standard cache items (interactive only)
5. **Optimize database** - VACUUM and ANALYZE for performance

#### **Mode Comparison:**

| Mode | Prompts | Suspicious Folders | Detailed Output | Best For |
|------|---------|-------------------|----------------|----------|
| `cache:fix` | ❌ Auto-confirm | ⏭️ Skip (safety) | ⚖️ Standard | CI/CD |
| `cache:fix:verbose` | ❌ Auto-confirm | ⏭️ Skip (safety) | ✅ Detailed | Debugging |
| `cache:fix:interactive` | ✅ Ask each | ✅ Review each | ⚖️ Standard | Manual use |
| `cache:fix:dry-run` | ❌ Preview only | 👁️ Show only | ✅ Detailed | Planning |

### Traditional Cleanup Methods

```bash
# Fix specific issue types only
pnpm cache:fix:files        # Fix orphaned files only
pnpm cache:fix:db          # Fix database inconsistencies only

# Emergency reset (deletes everything)
pnpm cache:reset
```

### Advanced Maintenance

```bash
# Backup database before major changes
pnpm cache:backup

# Advanced diagnostics
pnpm cache:debug

# Direct utility access
pnpm cache:util orphaned
pnpm cache:util largest 5
```

---

## 🔧 Project Management

### Project Analysis

```bash
# Show all cache for specific project (shows all hashes)
pnpm cache:project:info my-app

# Find project-specific issues
pnpm cache:project:issues my-app

# View project hashes from database (fast)
pnpm cache:project:info my-app | grep hash
```

### Project Cleanup

```bash
# Clean project cache (keep 3 versions)
pnpm cache:project:clean my-app

# Keep only 2 versions
pnpm cache:project:clean my-app 2

# Full project optimization
pnpm cache:project:optimize my-app 2
```

### Project Examples

```bash
# Frontend project - view cache info
pnpm cache:project:info aam-audithub-web-nextjs
pnpm cache:project:clean aam-audithub-web-nextjs 2

# API service - get latest hash quickly
pnpm cache:project:info @aam-audithub-system/audit-api-service

# UI library - manual hash lookup
sqlite3 .nx/workspace-data/*.db "
  SELECT hash, target, datetime(co.accessed_at) 
  FROM task_details td
  LEFT JOIN cache_outputs co ON td.hash = co.hash
  WHERE project = '@aam-audithub-system/ui-components'
  ORDER BY co.accessed_at DESC LIMIT 3;
"
```

---

## 🤖 CI/CD Integration (Updated)

### 🆕 Enhanced CI Pipeline Commands

```bash
# Health validation (exits with error if critical issues)
pnpm cache:ci

# 🆕 Auto-repair for CI/CD (non-interactive, safe)
pnpm cache:fix              # Recommended for automated pipelines
pnpm cache:fix:verbose      # Use when you need detailed logs

# 🆕 Preview before applying in CI
pnpm cache:fix:dry-run      # See what would be repaired (useful for PR checks)
```

### 🚀 Modern CI Configuration Examples

#### **GitHub Actions (Recommended Setup)**
```yaml
name: Cache Maintenance
on:
  schedule:
    - cron: '0 2 * * 1'  # Weekly maintenance
  pull_request:          # PR validation
  push:
    branches: [main]     # Post-merge cleanup

jobs:
  cache-health:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '20'
          cache: 'pnpm'
          
      - name: Install dependencies
        run: pnpm install
        
      # 🆕 Preview cache issues on PRs
      - name: Check cache health (PR)
        if: github.event_name == 'pull_request'
        run: |
          pnpm cache:check
          pnpm cache:fix:dry-run
        
      # 🆕 Auto-fix on main branch and scheduled runs
      - name: Auto-repair cache issues
        if: github.event_name != 'pull_request'
        run: pnpm cache:fix:verbose
        continue-on-error: true
        
      - name: Optimize cache (scheduled only)
        if: github.event.schedule
        run: pnpm cache:optimize
        
      # Upload artifacts on failure
      - name: Upload repair logs
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: cache-repair-backup-${{ github.run_id }}
          path: |
            .nx/workspace-data/*.repair-backup.*
            repair-*.log
          retention-days: 7
```

#### **Azure DevOps (Enhanced Pipeline)**
```yaml
# azure-pipelines.yml
trigger:
  branches:
    include: [main, develop]

schedules:
- cron: "0 2 * * 1"  # Weekly maintenance
  displayName: Weekly cache cleanup
  branches:
    include: [main]
  always: true

jobs:
- job: CacheHealth
  displayName: 'Cache Health & Maintenance'
  pool:
    vmImage: 'ubuntu-latest'
    
  steps:
  - task: NodeTool@0
    inputs:
      versionSpec: '20.x'
      
  - script: |
      npm install -g pnpm
      pnpm install
    displayName: 'Install dependencies'
    
  # 🆕 Different strategy based on trigger
  - script: pnpm cache:check && pnpm cache:fix:dry-run
    displayName: 'Validate cache health (PR build)'
    condition: eq(variables['Build.Reason'], 'PullRequest')
    
  - script: pnpm cache:fix:verbose
    displayName: 'Auto-repair cache issues'
    condition: ne(variables['Build.Reason'], 'PullRequest')
    continueOnError: true
    
  - script: pnpm cache:optimize
    displayName: 'Full cache optimization (scheduled)'
    condition: eq(variables['Build.Reason'], 'Schedule')
    
  # Backup artifacts
  - task: PublishBuildArtifacts@1
    condition: failed()
    displayName: 'Upload cache backup'
    inputs:
      pathToPublish: '.nx/workspace-data'
      artifactName: 'cache-repair-backup'
```

#### **Pre-commit Hook (Smart Validation)**
```bash
# .husky/pre-commit
#!/bin/sh
. "$(dirname "$0")/_/husky.sh"

# Quick health check (non-blocking)
pnpm cache:check || echo "⚠️ Cache health issues detected - consider running 'pnpm cache:fix'"

# Optional: Show what would be fixed (informational)
if ! pnpm cache:fix:dry-run | grep -q "No issues found"; then
    echo "💡 Run 'pnpm cache:fix' to resolve cache issues"
fi
```

### 🔧 Environment Configuration

```bash
# Control cache behavior in CI/CD
export NX_CACHE_MAX_ENTRIES=1000
export NX_CACHE_MAX_SIZE_MB=2048  
export NX_CACHE_MAX_ORPHANED=50

# 🆕 Control repair behavior
export NX_REPAIR_AUTO_CONFIRM=true      # Force non-interactive
export NX_REPAIR_VERBOSE=true           # Detailed logging
export NX_REPAIR_SKIP_SUSPICIOUS=true   # Skip suspicious folders
```

---

## ⚙️ Advanced Usage (Updated)

### 🆕 Direct Script Access with Flags

```bash
# Traditional direct access
./tools/nx-script/cache-utilities.sh help
./tools/nx-script/cache-utilities.sh projects

# 🆕 Enhanced cache repair with flags
./tools/nx-script/cache-repair.sh              # Interactive (default)
./tools/nx-script/cache-repair.sh -y           # CI-friendly non-interactive
./tools/nx-script/cache-repair.sh -y -v        # Non-interactive + verbose
./tools/nx-script/cache-repair.sh -d           # Dry run preview
./tools/nx-script/cache-repair.sh -d -v        # Detailed dry run
./tools/nx-script/cache-repair.sh --help       # Show all options
```

### 🔄 Comprehensive Troubleshooting Workflows

#### **Development Workflow (Interactive)**
```bash
echo "=== 🔍 ANALYSIS PHASE ==="
pnpm cache:stats                    # Current state
pnpm cache:issues                   # Identify problems
pnpm cache:fix:dry-run             # Preview fixes

echo "=== 🔧 REPAIR PHASE ==="
pnpm cache:fix:interactive         # Manual control

echo "=== ✅ VERIFICATION PHASE ==="
pnpm cache:stats                   # Verify improvements
pnpm cache:check                   # Health score
```

#### **CI/CD Workflow (Automated)**
```bash
echo "=== 🤖 AUTOMATED REPAIR ==="
pnpm cache:fix:verbose            # Auto-repair with logs

echo "=== 📊 POST-REPAIR ANALYSIS ==="
pnpm cache:stats                  # Current state
pnpm cache:check                  # Validation
```

#### **Emergency Workflow (When Things Break)**
```bash
echo "=== 🚨 EMERGENCY DIAGNOSIS ==="
pnpm cache:debug                  # Deep analysis
pnpm cache:issues                 # List all problems

echo "=== 🔧 EMERGENCY REPAIR ==="
pnpm cache:fix:verbose           # Detailed repair
# If that fails:
pnpm cache:reset                 # Nuclear option

echo "=== 🏗️ REBUILD ==="
pnpm cache:optimize              # Full optimization
```

### 📊 Database Queries for Advanced Users

```bash
# Get latest hash for specific project (fast!)
sqlite3 .nx/workspace-data/*.db "
  SELECT 
    hash,
    target,
    configuration,
    datetime(co.accessed_at) as last_used,
    ROUND(co.size/1024.0/1024.0, 2) as size_mb
  FROM task_details td
  LEFT JOIN cache_outputs co ON td.hash = co.hash
  WHERE project = 'my-app' AND target = 'build'
  ORDER BY co.accessed_at DESC
  LIMIT 5;
"

# Find projects with most cache versions
sqlite3 .nx/workspace-data/*.db "
  SELECT 
    project,
    target,
    COUNT(*) as versions,
    ROUND(SUM(co.size)/1024.0/1024.0, 2) as total_mb
  FROM task_details td
  LEFT JOIN cache_outputs co ON td.hash = co.hash
  GROUP BY project, target
  HAVING COUNT(*) > 3
  ORDER BY COUNT(*) DESC
  LIMIT 10;
"

# Cache efficiency analysis
sqlite3 .nx/workspace-data/*.db "
  SELECT 
    'Database' as source,
    COUNT(*) as entries,
    ROUND(SUM(size)/1024.0/1024.0, 2) as size_mb
  FROM cache_outputs
  UNION ALL
  SELECT 
    'Filesystem' as source,
    COUNT(*) as entries,
    0 as size_mb  -- Would need shell calculation
  FROM (SELECT DISTINCT hash FROM cache_outputs);
"
```

---

## 🛠️ Troubleshooting (Updated)

### 🆕 Enhanced Troubleshooting Matrix

| Problem | Quick Fix | Detailed Investigation | Prevention |
|---------|-----------|----------------------|------------|
| **Slow builds** | `pnpm cache:optimize` | `pnpm cache:debug` | Weekly `cache:optimize` |
| **Size growing** | `pnpm cache:clean` | `pnpm cache:find:largest` | Daily `cache:check` |
| **DB corruption** | `pnpm cache:fix:verbose` | `pnpm cache:fix:dry-run` first | Backup before changes |
| **Orphaned files** | `pnpm cache:fix` | `pnpm cache:find:orphans` | Regular maintenance |
| **CI failures** | `pnpm cache:fix -y` | Check CI logs | Use `cache:fix` in pipeline |

### 🔍 Diagnostic Commands by Symptom

#### **Cache Size Issues:**
```bash
# Quick investigation
pnpm cache:stats | grep -E "(Size|Largest)"
pnpm cache:find:largest

# Detailed analysis  
pnpm cache:debug
pnpm cache:util age

# Resolution
pnpm cache:clean                   # Conservative
pnpm cache:clean:latest           # Aggressive
```

#### **Performance Issues:**
```bash
# Database analysis
pnpm cache:debug | grep -E "(Efficiency|Orphaned)"

# Repair approach
pnpm cache:fix:dry-run            # See what needs fixing
pnpm cache:fix:verbose            # Apply fixes with detailed logs
pnpm cache:optimize               # Full optimization
```

#### **CI/CD Issues:**
```bash
# Local reproduction
pnpm cache:fix:dry-run            # Preview what CI would do
pnpm cache:fix -y -v              # Simulate CI repair

# CI debugging
# Add to pipeline: pnpm cache:fix:verbose --debug
```

### 🆕 Recovery Procedures

#### **From Repair Backup:**
```bash
# List available backups
ls -la .nx/workspace-data/*.repair-backup.*

# Restore from backup (if repair went wrong)
cp .nx/workspace-data/database.db.repair-backup.20241224-143022 .nx/workspace-data/database.db

# Verify restoration
pnpm cache:stats
```

#### **Complete Cache Reset (Emergency):**
```bash
# 1. Backup current state
pnpm cache:backup

# 2. Complete reset
pnpm cache:reset

# 3. Rebuild cache with first build
npx nx build my-app

# 4. Verify
pnpm cache:stats
```

---

## 💡 Best Practices (Updated)

### 🆕 CI/CD Best Practices

#### **Pipeline Integration:**
```yaml
# ✅ DO: Use non-interactive mode
- run: pnpm cache:fix

# ❌ DON'T: Use interactive mode in CI
- run: pnpm cache:fix:interactive

# ✅ DO: Preview on PRs, auto-fix on main
- run: pnpm cache:fix:dry-run        # PR builds
- run: pnpm cache:fix:verbose        # Main builds

# ✅ DO: Handle failures gracefully
- run: pnpm cache:fix
  continue-on-error: true
```

#### **Monitoring Strategy:**
```bash
# Daily: Quick health checks
pnpm cache:check

# Weekly: Full optimization  
pnpm cache:optimize

# Monthly: Deep analysis
pnpm cache:debug
pnpm cache:issues
```

### 🔧 Development Workflow

#### **Before Major Changes:**
```bash
# 1. Create backup
pnpm cache:backup

# 2. Check current state
pnpm cache:stats

# 3. Preview what would change
pnpm cache:fix:dry-run
```

#### **Regular Maintenance:**
```bash
# Weekly developer routine
pnpm cache:check                  # Health score
pnpm cache:fix:interactive        # Fix with review
pnpm cache:stats                  # Verify improvements
```

### 🚨 When NOT to Use Auto-Repair

```bash
# ❌ DON'T auto-repair when:
# - Cache size is unexpectedly huge (investigate first)
# - Build times suddenly increased (analyze before fixing)
# - Multiple developers report cache issues (coordinate first)

# ✅ DO investigate first:
pnpm cache:debug                  # Deep analysis
pnpm cache:fix:dry-run           # See what would change
pnpm cache:issues                # List specific problems

# Then decide on repair strategy
```

---

## 📞 Support & Resources

### Getting Help

```bash
# Built-in help system
pnpm cache:help                   # Overview of all commands
pnpm cache:fix --help            # 🆕 Detailed repair options
pnpm cache:debug                 # Deep diagnostic info
```

### 🆕 Enhanced Logging & Debugging

```bash
# Enable verbose logging for any command
export NX_CACHE_VERBOSE=true
pnpm cache:fix                   # Will show detailed output

# Debug mode for troubleshooting
export NX_CACHE_DEBUG=true
pnpm cache:stats                 # Shows internal details
```

### Useful Resources

- **Nx Documentation**: [https://nx.dev/features/cache-task-results](https://nx.dev/features/cache-task-results)
- **Script Location**: `./tools/nx-script/`
- **Database Location**: `.nx/workspace-data/*.db`
- **Cache Location**: `.nx/cache/`
- **🆕 Backup Location**: `.nx/workspace-data/*.repair-backup.*`

### Report Issues Template

When reporting cache issues, include:

```bash
# 1. System info & current state
pnpm cache:debug

# 2. Cache statistics  
pnpm cache:stats

# 3. What repair would do (without applying)
pnpm cache:fix:dry-run

# 4. Recent activity
pnpm cache:list:recent

# 5. Project-specific info (if applicable)
pnpm cache:project:info <project-name>

# 6. Any error messages or unusual behavior
```

---

## 🔄 Migration Guide

### From Old Cache Scripts

If you're upgrading from older cache management scripts:

```bash
# Old way (deprecated)
./tools/nx-script/cache-repair.sh

# 🆕 New way (recommended)
pnpm cache:fix                    # CI/CD friendly
pnpm cache:fix:interactive        # When you need control
pnpm cache:fix:verbose            # When you need details
pnpm cache:fix:dry-run           # When you need preview
```

### Package.json Updates

Update your `package.json` scripts section:

```json
{
  "scripts": {
    "// === 🔧 Enhanced Cache Repair ===": "",
    "cache:fix": "./tools/nx-script/cache-repair.sh -y",
    "cache:fix:interactive": "./tools/nx-script/cache-repair.sh",
    "cache:fix:verbose": "./tools/nx-script/cache-repair.sh -y -v",
    "cache:fix:dry-run": "./tools/nx-script/cache-repair.sh -d -v"
  }
}
```

---

*Last updated: December 2024*  
*Enhanced with CI/CD automation and improved repair capabilities*  
*For questions or improvements, contact the DevOps team.*