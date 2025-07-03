# 🛠️ Nx Scripts Documentation

> Complete reference for all scripts in `tools/nx-script/` directory

## 📋 Table of Contents

- [Script Overview](#-script-overview)
- [Core Utilities](#-core-utilities)
- [Statistics & Analysis](#-statistics--analysis)
- [Cleanup & Maintenance](#-cleanup--maintenance)
- [Project Management](#-project-management)
- [Diagnostics & Repair](#-diagnostics--repair)
- [CI/CD Integration](#-cicd-integration)
- [Wrapper Scripts](#-wrapper-scripts)
- [Maintainer Notes](#-maintainer-notes)

---

## 📊 Script Overview

| Script | Purpose | Complexity | Usage Frequency |
|--------|---------|------------|----------------|
| `cache-utilities.sh` | 🎯 Core utilities engine | High | Daily |
| `cache-stats-v2.sh` | 📊 Statistics & reporting | Medium | Daily |
| `nx-cache-cleanup-v2.sh` | 🧹 Global cache cleanup | Medium | Weekly |
| `cache-validation.sh` | ✅ CI/CD validation | Low | CI runs |
| `project-cache-details.sh` | 🔍 Project analysis | Low | As needed |
| `cache-diagnostic.sh` | 🔬 Deep diagnostics | High | Troubleshooting |
| `cache-repair.sh` | 🔧 Database repair | High | Issues only |
| `project-cache-cleanup-v2.sh` | 🎯 Project cleanup | Medium | As needed |
| `project-optimize.sh` | 🚀 Project optimization | Medium | As needed |
| `enhanced-hash-detector.sh` | 🕵️ Hash detection | High | Debug only |
| `cache-manager.sh` | 🌐 Universal wrapper | Low | Alternative |

---

## 🎯 Core Utilities

### `cache-utilities.sh`
**Primary cache management engine with multiple sub-commands**

#### **Purpose**
Central hub for all cache operations. Contains most core functionality used by other scripts.

#### **Key Functions**
```bash
# Project management
show_projects()                    # List all cached projects
show_targets()                     # List targets for specific project
issues_for_project()              # Find project-specific issues

# Analysis
find_orphaned_folders()           # Find orphaned cache folders
generate_cache_analysis()         # Generate filesystem analysis
count_orphaned_entries()          # Count orphaned entries
validate_cache_size()             # Detailed size validation

# Cleanup
clean_orphaned_folders()          # Remove orphaned folders
clean_suspicious_items()          # Remove non-standard items
clean_db_orphans()               # Remove orphaned DB entries
clean_project_versions()         # Clean specific project versions

# Utilities
show_projects_with_many_versions() # Find projects with >N versions
show_cache_age_distribution()     # Show cache age analysis
show_largest_entries()            # Show largest cache entries
search_cache()                    # Search cache by pattern
backup_database()                 # Backup database with timestamp
```

#### **Usage**
```bash
./cache-utilities.sh <command> [args]

# Examples
./cache-utilities.sh projects
./cache-utilities.sh orphaned
./cache-utilities.sh clean-project my-app 3
./cache-utilities.sh many-versions 5
```

#### **Input/Output**
- **Input**: SQLite database, filesystem cache directory
- **Output**: Formatted reports, confirmation prompts
- **Side Effects**: File/database modifications with user confirmation

#### **Dependencies**
- SQLite3
- Standard Unix utilities (find, du, awk, basename)
- Nx workspace structure (.nx/cache, .nx/workspace-data)

#### **Maintainer Notes**
- **Core script** - Most other scripts depend on this
- Contains official Nx folder recognition: `terminalOutputs`, `cloud`, `d`, `run.json`
- Uses temporary files in `/tmp/` for analysis
- Always creates backups before destructive operations
- Cross-platform compatible (macOS/Linux)

---

## 📊 Statistics & Analysis

### `cache-stats-v2.sh`
**Comprehensive cache statistics and reporting**

#### **Purpose**
Generate detailed cache statistics including per-project breakdown, size analysis, and health metrics.

#### **Key Functions**
```bash
# Database analysis
count_cache_entries()             # Count total cache entries
get_cache_size_mb()              # Calculate cache size
analyze_storage_efficiency()     # Compare DB vs filesystem

# Reporting functions
show_per_project_breakdown()     # Project-wise statistics
show_largest_caches()           # Top 10 largest entries
show_recent_activity()          # Recent cache usage
show_cache_age_analysis()       # Age distribution
show_orphaned_analysis()        # Orphaned entries count
```

#### **Usage**
```bash
./cache-stats-v2.sh
# No arguments - generates full report
```

#### **Sample Output**
```
📊 Nx Cache Statistics
======================
Database: D2F519A2...db (0.24 MB)
Cache directory: 56.20MB (187 folders)

📋 Database summary:
  Cache entries: 187
  Task entries: 187

📊 Per-project cache breakdown:
[Detailed table of projects, targets, versions, sizes]

📈 Top 10 largest cache entries:
[Largest caches with sizes and projects]

💾 Storage efficiency:
  Database size: 53.37MB
  Hash folders size: 46.33MB
  Cache efficiency: 115.2%
```

#### **Maintainer Notes**
- **Read-only operations** - Safe to run anytime
- Automatically detects .nx directory location
- Separates official Nx folders from hash folders in calculations
- Cross-platform size calculation (macOS stat vs Linux du)

---

### `project-cache-details.sh`
**Detailed project-specific cache analysis**

#### **Purpose**
Show comprehensive cache information for specific projects with filtering capabilities.

#### **Key Functions**
```bash
build_where_clause()             # Build SQL WHERE conditions safely
show_project_summary()           # Version counts by project:target
show_detailed_entries()          # Individual cache entries
show_full_hash_list()           # Complete hash list for copying
show_cache_age_distribution()   # Age analysis for project
```

#### **Usage**
```bash
./project-cache-details.sh [project_pattern] [target_pattern]

# Examples
./project-cache-details.sh                              # All projects
./project-cache-details.sh my-app                       # Specific project
./project-cache-details.sh my-app build                 # Project + target
./project-cache-details.sh "" test                      # All test targets
./project-cache-details.sh web-nextjs                   # Pattern matching
```

#### **Input/Output**
- **Input**: Project/target patterns (optional)
- **Output**: Filtered cache details, hash lists, metadata
- **Side Effects**: None (read-only)

#### **Maintainer Notes**
- **SQL injection protection** - Uses parameterized patterns
- Supports partial matching with LIKE patterns
- Shows both summary and detailed views
- Useful for debugging specific project cache issues

---

## 🧹 Cleanup & Maintenance

### `nx-cache-cleanup-v2.sh`
**Global cache cleanup with configurable retention**

#### **Purpose**
Clean old cache entries across all projects with flexible version retention policies.

#### **Key Functions**
```bash
parse_arguments()                # Handle command line options
validate_keep_versions()         # Validate numeric inputs
generate_cleanup_analysis()      # Analyze what will be deleted
perform_cleanup()               # Execute cleanup with confirmation
show_final_status()             # Display results summary
```

#### **Usage**
```bash
./nx-cache-cleanup-v2.sh [options] [keep_versions]

# Options:
#   -y, --yes       Auto-confirm (for CI)
#   -f, --force     Force mode (skip safety checks)
#   -h, --help      Show help

# Examples
./nx-cache-cleanup-v2.sh                    # Keep 3 versions (default)
./nx-cache-cleanup-v2.sh 5                  # Keep 5 versions
./nx-cache-cleanup-v2.sh 1 -y               # Keep 1, auto-confirm
./nx-cache-cleanup-v2.sh 0 -f -y            # Delete ALL cache
```

#### **Cleanup Algorithm**
```sql
-- Uses ROW_NUMBER() to rank cache entries
WITH ranked_cache AS (
    SELECT 
        td.hash,
        ROW_NUMBER() OVER (
            PARTITION BY td.project, td.target, COALESCE(td.configuration, '') 
            ORDER BY co.accessed_at DESC, co.created_at DESC
        ) as rank
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
)
SELECT hash FROM ranked_cache WHERE rank > $KEEP_VERSIONS
```

#### **Safety Features**
- **Database backup** before any changes
- **Confirmation prompts** for destructive operations
- **Special confirmation** for delete-all mode (`keep_versions=0`)
- **Dry-run analysis** showing what will be deleted
- **VACUUM** operation after cleanup

#### **Maintainer Notes**
- **Destructive operations** - Always creates backups
- Handles both database and filesystem cleanup
- CI-friendly with auto-confirm options
- Proper error handling and rollback capabilities

---

### `project-cache-cleanup-v2.sh`
**Project-specific cache cleanup**

#### **Purpose**
Clean cache entries for a specific project while preserving configurable number of versions per target.

#### **Key Functions**
```bash
validate_project()              # Check if project exists in DB
show_current_status()           # Display current cache state
calculate_cleanup_scope()       # Determine what will be deleted
perform_project_cleanup()       # Execute cleanup for project
show_final_project_status()     # Display remaining cache
```

#### **Usage**
```bash
./project-cache-cleanup-v2.sh <project> [keep_versions]

# Examples
./project-cache-cleanup-v2.sh my-app                    # Keep 3 versions
./project-cache-cleanup-v2.sh my-app 2                  # Keep 2 versions
./project-cache-cleanup-v2.sh @scope/package 1          # Scoped package
```

#### **Project-Specific Algorithm**
```sql
-- Ranks versions within project only
WITH project_ranked AS (
    SELECT 
        td.hash,
        td.target,
        td.configuration,
        ROW_NUMBER() OVER (
            PARTITION BY td.target, COALESCE(td.configuration, '') 
            ORDER BY co.accessed_at DESC, co.created_at DESC
        ) as rank
    FROM task_details td
    LEFT JOIN cache_outputs co ON td.hash = co.hash
    WHERE td.project = '$PROJECT'
)
SELECT hash FROM project_ranked WHERE rank > $KEEP_VERSIONS
```

#### **Maintainer Notes**
- **Project-scoped operations** - Only affects specified project
- Shows before/after comparison
- Handles scoped npm packages correctly
- Lists available projects if project not found

---

### `project-optimize.sh`
**Comprehensive project optimization**

#### **Purpose**
Complete optimization workflow for a specific project including cleanup, orphan removal, and database optimization.

#### **Key Functions**
```bash
detect_workspace()              # Auto-detect .nx location
validate_project_exists()       # Ensure project is in database
create_database_backup()        # Backup before operations
execute_optimization_steps()    # Run complete optimization pipeline
show_optimization_summary()     # Display final results
```

#### **Optimization Pipeline**
```bash
# Step 1: Clean project cache versions
./project-cache-cleanup-v2.sh $PROJECT $KEEP_VERSIONS

# Step 2: Clean orphaned files related to project
# (Currently shows info, future: smart cleanup)

# Step 3: Clean orphaned DB entries for project
# Removes DB entries where cache folders don't exist

# Step 4: Clean suspicious items (system-wide)
./cache-utilities.sh clean-suspicious

# Step 5: Optimize database
sqlite3 $DB_FILE "VACUUM;"
```

#### **Usage**
```bash
./project-optimize.sh <project> [keep_versions]

# Examples
./project-optimize.sh my-app                    # Optimize, keep 3 versions
./project-optimize.sh my-app 2                  # Keep 2 versions
./project-optimize.sh frontend-app 1            # Aggressive optimization
```

#### **Maintainer Notes**
- **Comprehensive workflow** - Calls multiple other scripts
- Auto-detects workspace from various directory levels
- Creates timestamped backups
- Shows final project status after optimization

---

## 🔬 Diagnostics & Repair

### `cache-diagnostic.sh`
**Deep cache system diagnostics**

#### **Purpose**
Comprehensive analysis of cache system health, identifying issues and providing detailed technical information.

#### **Key Functions**
```bash
analyze_database_structure()     # Database size, table counts
analyze_filesystem_structure()   # Separate hash/official folders
detect_orphaned_entries()       # Both DB and filesystem orphans
calculate_storage_efficiency()   # Compare logical vs physical sizes
show_recent_activity()          # Last 5 cache operations
generate_recommendations()      # Actionable suggestions
```

#### **Analysis Categories**
```bash
# Database Analysis
- File size and table row counts
- Data consistency checks
- Integrity validation

# Filesystem Analysis  
- Hash folders vs Official Nx folders
- Size calculations (handles macOS/Linux differences)
- Suspicious items detection

# Orphaned Analysis
- Database entries without cache files
- Cache files without database entries
- Detailed listings with sizes

# Storage Efficiency
- Database recorded size vs actual filesystem size
- Efficiency percentage calculation
- Issue identification (>15% difference = warning)
```

#### **Sample Output**
```
🔍 Nx Cache Diagnostic Report (Corrected)
==========================================

📂 Paths:
  NX Directory: .nx
  Database: .nx/workspace-data/D2F519A2...db
  Cache Directory: .nx/cache

📊 Database Information:
  File size: 0.24 MB (253952 bytes)

📋 Table Counts:
  task_details: 187 rows
  cache_outputs: 187 rows

📁 Filesystem Analysis:
  📊 Hash folders: 187 folders, 46.33MB
  📊 Official folders: 2 folders, 9.87MB
  📊 Total filesystem: 56.20MB

💾 Storage Efficiency:
  Database recorded: 53.37MB
  Hash folders actual: 46.33MB
  Hash folder efficiency: 115.2%
  ⚠️  Efficiency issue: Database and filesystem sizes don't match
```

#### **Maintainer Notes**
- **Read-only diagnostics** - Safe to run anytime
- Recognizes official Nx folders (`terminalOutputs`, `cloud`, `d`)
- Cross-platform size calculation
- Provides actionable recommendations
- Useful for troubleshooting performance issues

---

### `cache-repair.sh`
**Database integrity repair and optimization**

#### **Purpose**
Fix database inconsistencies, size mismatches, and perform database maintenance operations.

#### **Key Functions**
```bash
analyze_current_issues()         # Identify repair needs
backup_database_safely()        # Create timestamped backup
clean_orphaned_task_entries()    # Remove orphaned task_details
fix_missing_cache_entries()     # Remove DB entries for missing files
update_size_mismatches()        # Sync DB sizes with filesystem
handle_suspicious_folders()     # Review non-standard items
optimize_database()             # VACUUM and performance tuning
verify_final_consistency()      # Post-repair validation
```

#### **Repair Operations**
```bash
# 1. Orphaned Task Cleanup
DELETE FROM task_details 
WHERE hash NOT IN (SELECT hash FROM cache_outputs);

# 2. Missing Cache Entry Cleanup
# For each cache_outputs entry:
#   - Check if .nx/cache/{hash} folder exists
#   - If not, remove from both tables

# 3. Size Mismatch Correction
# For each hash folder:
#   - Calculate actual filesystem size
#   - Update cache_outputs.size if different

# 4. Database Optimization
VACUUM;  # Rebuild database for optimal performance
```

#### **Safety Features**
- **Automatic backup** with timestamp
- **Confirmation prompts** for all operations
- **Suspicious item review** - asks permission per item
- **Final verification** - checks repair success
- **Rollback capability** - backup available for restore

#### **Usage**
```bash
./cache-repair.sh
# Interactive mode with prompts
```

#### **Sample Repair Session**
```
🔧 Cache Repair Tool (Nx Official Structure Aware)
==================================================

🔍 Current Issues Analysis:
  📋 Orphaned task entries: 0
  📁 Missing cache folders: 0 (0.00MB recorded)
  🔍 Size mismatches: 8 entries

📦 Database backed up to: repair-backup.20250619-143422

🤔 Repair Plan:
  1. Clean 0 orphaned task entries
  2. Remove 0 missing cache entries from database
  3. Update 8 size mismatches
  5. Optimize database

Proceed with repair? (y/N):
```

#### **Maintainer Notes**
- **High-risk operations** - Always creates backups
- Respects official Nx folder structure
- Cross-platform size calculations
- Shows detailed before/after analysis
- Essential for fixing corruption issues

---

### `enhanced-hash-detector.sh`
**Advanced hash detection and analysis**

#### **Purpose**
Detect current hash for project builds using multiple methods. **Note: Not used in production due to performance concerns.**

#### **Key Functions**
```bash
detect_workspace_location()     # Auto-detect Nx workspace
run_dry_run_analysis()         # Method 1: Dry run hash detection
run_actual_build_analysis()    # Method 2: Actual build analysis
find_latest_cache_entry()      # Method 3: Filesystem analysis
query_database_hashes()        # Method 4: Database lookup
try_alternative_methods()      # Method 5: nx show, logs
determine_authoritative_hash()  # Combine all methods
validate_hash_existence()      # Verify hash validity
export_hash_variables()        # Export for other scripts
```

#### **Detection Methods**
```bash
# Method 1: Dry Run (Fast but sometimes incomplete)
NX_VERBOSE_LOGGING=true npx nx $TARGET $PROJECT --dry-run

# Method 2: Actual Run (Accurate but slow)
npx nx $TARGET $PROJECT

# Method 3: Latest Cache (Fast but may be stale)
ls -t .nx/cache/ | grep "^[0-9]" | head -1

# Method 4: Database Query (Fast and recent)
SELECT hash FROM task_details WHERE project='...' ORDER BY accessed_at DESC

# Method 5: Alternative (nx show, logs)
npx nx show project $PROJECT
find .nx -name "*.log" -exec grep -l "$PROJECT" {} \;
```

#### **Hash Priority Logic**
```bash
if [ dry_run_hash == actual_run_hash ]; then
    CURRENT_HASH = consistent_hash     # Highest confidence
elif [ actual_run_hash != empty ]; then
    CURRENT_HASH = actual_run_hash     # High confidence
elif [ dry_run_hash != empty ]; then
    CURRENT_HASH = dry_run_hash        # Medium confidence
elif [ database_hash != empty ]; then
    CURRENT_HASH = database_hash       # Low confidence (stale)
else
    CURRENT_HASH = "UNKNOWN"           # No detection possible
fi
```

#### **Usage**
```bash
./enhanced-hash-detector.sh <project> [target]

# Examples
./enhanced-hash-detector.sh my-app build
./enhanced-hash-detector.sh frontend-lib test
```

#### **Performance Warning**
```bash
# ⚠️ Performance Impact:
# - Dry run: 5-30 seconds
# - Actual run: 30 seconds to 10+ minutes
# - Database query: <1 second
#
# 🚫 Not recommended for:
# - Large projects
# - Production automation
# - Frequent usage
#
# ✅ Use instead:
# - cache:project:info (shows all hashes)
# - Database queries (instant)
```

#### **Maintainer Notes**
- **Development/debug tool only** - Too slow for production
- Multiple fallback methods for reliability
- Comprehensive validation and export
- Cross-platform compatibility
- Detailed debugging output

---

## ✅ CI/CD Integration

### `cache-validation.sh`
**CI/CD cache validation and health checks**

#### **Purpose**
Lightweight cache validation designed for CI/CD pipelines with configurable thresholds and exit codes.

#### **Key Functions**
```bash
parse_validation_arguments()     # Handle CLI options
count_cache_entries()           # Fast entry counting
get_cache_size_mb()            # Size calculation
count_orphaned_entries()       # Orphaned entry detection
validate_database_integrity()   # SQLite integrity check
generate_validation_report()    # CI-friendly reporting
exit_with_appropriate_code()    # Return proper exit codes
```

#### **Validation Thresholds (Configurable)**
```bash
# Default limits (can be overridden)
MAX_CACHE_ENTRIES=1000           # Maximum cache entries
MAX_CACHE_SIZE_MB=1024           # Maximum cache size (1GB)
MAX_ORPHANED_ENTRIES=50          # Maximum orphaned entries

# Override via environment variables
export NX_CACHE_MAX_ENTRIES=500
export NX_CACHE_MAX_SIZE_MB=2048
export NX_CACHE_MAX_ORPHANED=100
```

#### **Commands & Exit Codes**
```bash
# Validation commands
./cache-validation.sh validate          # Full validation, no exit codes
./cache-validation.sh validate-ci       # CI mode with exit codes
./cache-validation.sh count             # Check entry count only
./cache-validation.sh size              # Check size only
./cache-validation.sh orphaned          # Check orphaned entries only
./cache-validation.sh health            # Health check with recommendations

# Exit codes
0 = All validations passed
1 = Critical issues found (>2 failures)
2 = Minor issues found (1-2 failures)
```

#### **CI Integration Examples**
```yaml
# GitHub Actions
- name: Validate Cache Health
  run: ./tools/nx-script/cache-validation.sh validate-ci

# With custom limits
- name: Validate Cache (Custom Limits)
  run: |
    export NX_CACHE_MAX_ENTRIES=500
    export NX_CACHE_MAX_SIZE_MB=2048
    ./tools/nx-script/cache-validation.sh validate-ci
```

#### **Sample CI Output**
```
🔍 Cache Validation Report
=========================
Cache Directory: .nx/cache
Database: D2F519A2...db

📊 Cache Entries: 187
  ✅ Cache entries within limit

💾 Cache Size: 56MB
  ✅ Cache size within limit

🔍 Orphaned Entries: 0
  ✅ Orphaned entries within acceptable range

🗄️  Database Health: ok
  ✅ Database integrity OK

📊 Summary:
  ✅ All validations passed!
  🎯 Cache is healthy and optimized
```

#### **Maintainer Notes**
- **Lightweight and fast** - Designed for frequent CI runs
- **Configurable thresholds** - Adaptable to project needs
- **Proper exit codes** - Integrates well with CI systems
- **No side effects** - Read-only operations only

---

## 🌐 Wrapper Scripts

### `cache-manager.sh`
**Universal workspace-aware wrapper script**

#### **Purpose**
Auto-detect workspace structure and provide unified interface to all cache scripts regardless of current directory.

#### **Key Functions**
```bash
detect_workspace()              # Find .nx directory at any level
show_debug_info()              # Workspace detection debugging
run_script()                   # Execute script in correct context
show_available_scripts()       # List all scripts in directory
```

#### **Workspace Detection Logic**
```bash
# Searches up directory tree for .nx
if [ -d ".nx" ]; then
    nx_dir="$(pwd)/.nx"          # Current directory
elif [ -d "../.nx" ]; then
    nx_dir="$(cd .. && pwd)/.nx"  # Parent directory
elif [ -d "../../.nx" ]; then
    nx_dir="$(cd ../.. && pwd)/.nx"  # Grandparent directory
else
    echo "❌ .nx directory not found"
    exit 1
fi
```

#### **Command Mapping**
```bash
# Maps friendly commands to actual scripts
"stats"|"s"     → cache-stats-v2.sh
"cleanup"|"c"   → nx-cache-cleanup-v2.sh
"project"|"p"   → project-cache-cleanup-v2.sh
"hash"|"h"      → enhanced-hash-detector.sh
"utils"|"u"     → cache-utilities.sh
"debug"|"d"     → show_debug_info
```

#### **Usage**
```bash
./cache-manager.sh <command> [args]

# Examples
./cache-manager.sh stats
./cache-manager.sh cleanup
./cache-manager.sh project my-app 2
./cache-manager.sh utils orphaned
./cache-manager.sh debug
```

#### **Benefits**
- **Directory agnostic** - Works from any subdirectory
- **Simplified interface** - Shorter command names
- **Workspace validation** - Ensures correct Nx workspace
- **Debug capabilities** - Shows workspace detection info

#### **Maintainer Notes**
- **Alternative interface** - Main scripts can still be used directly
- Useful for developers working in subdirectories
- Provides unified entry point to all cache tools
- Good for shell aliases and shortcuts

---

## 🔧 Maintainer Notes

### Architecture Overview

```
tools/nx-script/
├── cache-utilities.sh          # 🎯 Core engine (most functions)
├── cache-stats-v2.sh          # 📊 Statistics (read-only)
├── nx-cache-cleanup-v2.sh     # 🧹 Global cleanup (destructive)
├── project-cache-cleanup-v2.sh # 🎯 Project cleanup (destructive)
├── project-optimize.sh        # 🚀 Optimization pipeline
├── cache-diagnostic.sh        # 🔬 Deep analysis (read-only)
├── cache-repair.sh            # 🔧 Database repair (high-risk)
├── cache-validation.sh        # ✅ CI validation (read-only)
├── project-cache-details.sh   # 🔍 Project analysis (read-only)
├── enhanced-hash-detector.sh  # 🕵️ Hash detection (slow)
└── cache-manager.sh           # 🌐 Universal wrapper
```

### Script Dependencies

```bash
# Core Dependencies (all scripts)
- SQLite3 (database operations)
- Standard Unix utilities (find, du, awk, grep, etc.)
- Bash 4.0+ (associative arrays, advanced features)

# Nx Dependencies
- .nx/cache directory (cache storage)
- .nx/workspace-data/*.db (SQLite database)
- Nx workspace structure

# Cross-Platform Considerations
- macOS: Uses `stat -f%z` for file sizes
- Linux: Uses `stat -c%s` for file sizes
- Both: `du -sb` as fallback
```

### Safety Mechanisms

```bash
# All Destructive Operations
✅ Database backups before changes
✅ Confirmation prompts (unless --yes)
✅ Dry-run analysis showing impact
✅ VACUUM after database modifications
✅ Error handling and rollback capabilities

# Official Nx Structure Recognition
OFFICIAL_ITEMS=("terminalOutputs" "cloud" "d" "run.json")
# These are never deleted or considered suspicious
```

### Performance Considerations

```bash
# Fast Operations (< 1 second)
- cache-stats-v2.sh
- cache-validation.sh 
- project-cache-details.sh
- cache-utilities.sh (most commands)

# Medium Operations (1-10 seconds)
- nx-cache-cleanup-v2.sh
- project-cache-cleanup-v2.sh
- cache-diagnostic.sh

# Slow Operations (10+ seconds)
- enhanced-hash-detector.sh (avoid in production)
- cache-repair.sh (with large caches)
- project-optimize.sh (calls multiple scripts)
```

### Error Handling Patterns

```bash
# Standard Error Handling
set -e                          # Exit on error (where appropriate)
[ ! -f "$DB_FILE" ] && echo "❌ Database not found" && exit 1
sqlite3 "$DB_FILE" "..." 2>/dev/null || echo "0"

# Cleanup Patterns
trap 'rm -f /tmp/cache_analysis_*' EXIT
rm -f "$temp_file"

# Confirmation Patterns
read -p "🤔 Proceed? (y/N): " -n 1 -r
[[ ! $REPLY =~ ^[Yy]$ ]] && echo "❌ Cancelled" && exit 0
```

### Database Schema Reference

```sql
-- task_details table
CREATE TABLE task_details (
    hash TEXT,
    project TEXT,
    target TEXT,
    configuration TEXT
);

-- cache_outputs table  
CREATE TABLE cache_outputs (
    hash TEXT,
    size INTEGER,
    created_at DATETIME,
    accessed_at DATETIME
);

-- Common queries
SELECT td.project, td.target, COUNT(*) 
FROM task_details td 
GROUP BY td.project, td.target;

SELECT td.hash, co.size, co.accessed_at
FROM task_details td
LEFT JOIN cache_outputs co ON td.hash = co.hash
WHERE td.project = ?;
```

### Testing & Validation

```bash
# Before modifying scripts:
1. Test with small cache (< 10 entries)
2. Verify database backup creation
3. Test rollback procedures
4. Check cross-platform compatibility
5. Validate CI integration

# Regression testing:
./cache-validation.sh validate-ci  # Should always pass
./cache-diagnostic.sh             # Check for efficiency issues
./cache-stats-v2.sh              # Verify statistics accuracy
```

### Future Improvements

```bash
# Potential enhancements:
- Configuration file support (.nxcacherc)
- Better project hash association tracking  
- Integration with Nx Cloud
- Performance optimizations for large caches
- Web dashboard for cache monitoring
- Automated cleanup scheduling
```

### Support & Debugging

```bash
# For debugging script issues:
1. Run with bash -x: bash -x ./script.sh
2. Check database integrity: sqlite3 db "PRAGMA integrity_check;"
3. Verify filesystem permissions: ls -la .nx/
4. Test SQL queries manually: sqlite3 db < query.sql
5. Check system resources: df -h, free -m

# Common issues:
- Permission denied: Check .nx/ ownership
- Database locked: Close other Nx processes
- Size calculation errors: Check filesystem type
- Script hangs: Interrupt with Ctrl+C, check for large files
```

---

*Documentation last updated: June 2025*  
*For questions about specific scripts, refer to inline comments in each file.*