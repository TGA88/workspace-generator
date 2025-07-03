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
pnpm cache:fix:files    # Fix orphaned files
pnpm cache:fix:db       # Fix database issues
pnpm cache:fix          # Fix everything

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

### Targeted Fixes

```bash
# Fix orphaned files only
pnpm cache:fix:files

# Fix database inconsistencies only  
pnpm cache:fix:db

# Repair database integrity (size mismatches, etc.)
pnpm cache:fix

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

## 🤖 CI/CD Integration

### CI Pipeline Commands

```bash
# Validate cache health (exits with error if issues)
pnpm cache:ci

# Auto-fix cache issues in CI
pnpm cache:ci:auto-fix
```

### CI Configuration Examples

#### GitHub Actions
```yaml
# .github/workflows/ci.yml
- name: Validate Cache
  run: pnpm cache:ci

- name: Cleanup Cache (weekly)
  if: github.event.schedule  # For scheduled runs
  run: pnpm cache:optimize
```

#### Pre-commit Hook
```bash
# .husky/pre-commit
pnpm cache:check || echo "⚠️ Cache health issues detected"
```

### Environment Variables

```bash
# Configure cache limits (optional)
export NX_CACHE_MAX_ENTRIES=1000
export NX_CACHE_MAX_SIZE_MB=1024  
export NX_CACHE_MAX_ORPHANED=50
```

---

## ⚙️ Advanced Usage

### Direct Script Access

```bash
# Access cache utilities directly
./tools/nx-script/cache-utilities.sh help

# Common direct commands
./tools/nx-script/cache-utilities.sh projects
./tools/nx-script/cache-utilities.sh many-versions 5
./tools/nx-script/cache-utilities.sh clean-project my-app 2
```

### Database Queries

```bash
# Get latest hash for specific project (fast!)
sqlite3 .nx/workspace-data/*.db "
  SELECT 
    hash,
    target,
    configuration,
    datetime(co.accessed_at) as last_used
  FROM task_details td
  LEFT JOIN cache_outputs co ON td.hash = co.hash  
  WHERE project = 'my-app'
  ORDER BY co.accessed_at DESC
  LIMIT 5;
"

# Find all hashes for project:target
sqlite3 .nx/workspace-data/*.db "
  SELECT hash, datetime(co.accessed_at) as last_used
  FROM task_details td
  LEFT JOIN cache_outputs co ON td.hash = co.hash
  WHERE project = 'my-app' AND target = 'build'
  ORDER BY co.accessed_at DESC;
"
```

### Custom Scripts

```bash
# Create custom cleanup for specific projects
pnpm cache:util clean-project frontend-* 1
pnpm cache:util clean-project *-api-* 2
```

---

## 🚨 Troubleshooting

### Common Issues & Solutions

#### "Size mismatches: X entries"
```bash
# ✅ Safe to fix - usually filesystem vs database differences
pnpm cache:fix
```

#### "High cache count (>1000)"
```bash
# ✅ Clean old entries
pnpm cache:clean
# or more aggressive
pnpm cache:clean:latest
```

#### "Cache uses X% of disk space"
```bash
# ✅ Full optimization
pnpm cache:optimize
```

#### "Orphaned folders found"
```bash
# ✅ Clean orphaned files
pnpm cache:fix:files
```

### Performance Issues

#### Slow cache operations
```bash
# 1. Check cache health
pnpm cache:debug

# 2. Optimize database
pnpm cache:fix

# 3. Clean old entries
pnpm cache:optimize
```

#### Large cache size
```bash
# 1. Find largest entries
pnpm cache:find:largest

# 2. Clean specific projects
pnpm cache:project:clean large-project 1

# 3. Aggressive cleanup
pnpm cache:clean:latest
```

### Emergency Procedures

#### Complete cache corruption
```bash
# 1. Backup current state
pnpm cache:backup

# 2. Reset cache
pnpm cache:reset

# 3. Rebuild
nx run-many --target=build --all
```

#### Database issues
```bash
# 1. Diagnose
pnpm cache:debug

# 2. Repair
pnpm cache:fix

# 3. If still broken, reset
pnpm cache:reset
```

---

## 💡 Best Practices

### Daily Workflow

```bash
# Morning routine
pnpm cache:check

# Before major builds
pnpm cache:optimize  # Weekly

# After feature development
pnpm cache:project:clean feature-branch 2
```

### Project Lifecycle

```bash
# New project setup
# ✅ No special cache setup needed

# During development  
# ✅ Monitor with: pnpm cache:check
# ✅ Clean when needed: pnpm cache:clean

# Before release
# ✅ Optimize: pnpm cache:optimize
# ✅ Validate: pnpm cache:ci
```

### Maintenance Schedule

| Frequency | Command | Purpose |
|-----------|---------|---------|
| **Daily** | `pnpm cache:check` | Health monitoring |
| **Weekly** | `pnpm cache:optimize` | Full maintenance |
| **Monthly** | `pnpm cache:debug` | Deep diagnostics |
| **As needed** | `pnpm cache:fix` | Fix specific issues |

### Cache Size Guidelines

| Cache Size | Action | Command |
|------------|---------|---------|
| **< 500MB** | ✅ Healthy | Continue monitoring |
| **500MB - 1GB** | ⚠️ Monitor | `pnpm cache:clean` |
| **1GB - 2GB** | 🔧 Cleanup | `pnpm cache:optimize` |
| **> 2GB** | 🚨 Action needed | `pnpm cache:clean:latest` |

### Project-specific Guidelines

```bash
# Frontend apps (large builds)
pnpm cache:project:clean frontend-app 2

# API services (fast builds) 
pnpm cache:project:clean api-service 1

# Shared libraries (keep more for reuse)
pnpm cache:project:clean shared-lib 3
```

### CI/CD Best Practices

1. **Validate cache health** in CI pipeline
2. **Auto-fix minor issues** with `cache:ci:auto-fix`
3. **Schedule weekly cleanup** in CI
4. **Monitor cache size** in production

### Security Considerations

- **Regular cleanup** prevents disk space issues
- **Database backup** before major changes
- **Monitor orphaned files** for security
- **Validate cache integrity** in CI

---

## 📞 Support

## 💡 **ทำไมไม่มี `cache:project:hash`?**

```bash
# ❌ ปัญหาของการหา "current hash":
pnpm cache:project:hash my-app build
# → รัน dry-run + actual build → ใช้เวลานานมาก!
# → ไม่เหมาะสำหรับ project ใหญ่

# ✅ วิธีที่ดีกว่า:
pnpm cache:project:info my-app  
# → ดู hash ทั้งหมด + metadata แบบเร็ว
# → ไม่ต้องรัน build
```

## ✅ **แนวทางที่แนะนำแทน**

### **1. ใช้ `cache:project:info` (เร็วที่สุด)**
```bash
# แสดงทุก hash ของ project พร้อม details
pnpm cache:project:info my-app
# ✅ เร็ว, ไม่รัน build, แสดงทุก hash + metadata
```

### **2. Query Database โดยตรง (สำหรับ advanced users)**
```bash
# หา hash ล่าสุดของ project:target
sqlite3 .nx/workspace-data/*.db "
  SELECT 
    hash,
    target,
    configuration,
    datetime(co.accessed_at) as last_used
  FROM task_details td
  LEFT JOIN cache_outputs co ON td.hash = co.hash
  WHERE project = 'my-app' AND target = 'build'
  ORDER BY co.accessed_at DESC
  LIMIT 1;
"
```

### **3. ถ้าต้องการ Hash ปัจจุบันจริงๆ (ช้า)**
```bash
# รัน build แล้วดู output
npx nx build my-app --verbose
# ดู terminal output สำหรับ hash

# หรือใช้ script โดยตรง (ไม่แนะนำสำหรับ project ใหญ่)
./tools/nx-script/enhanced-hash-detector.sh my-app build
```

---

## 📞 Support

### Getting Help

```bash
# Built-in help
pnpm cache:help

# Detailed help  
pnpm cache:help:full

# Debug information
pnpm cache:debug
```

### Useful Resources

- **Nx Documentation**: [https://nx.dev/features/cache-task-results](https://nx.dev/features/cache-task-results)
- **Script Location**: `./tools/nx-script/`
- **Database Location**: `.nx/workspace-data/*.db`
- **Cache Location**: `.nx/cache/`

### Report Issues

When reporting cache issues, include:

```bash
# 1. System info
pnpm cache:debug

# 2. Cache statistics  
pnpm cache:stats

# 3. Recent activity
pnpm cache:list:recent

# 4. Project-specific info (if applicable)
pnpm cache:project:info <project-name>
```

---

*Last updated: June 2025*  
*For questions or improvements, contact the DevOps team.*