# SPLANTS Quick Reference - Verification Scripts

## System Check Script

**Purpose:** Verify system meets requirements BEFORE installation

**Command:**
```bash
./scripts_check-system.sh
```

**When to use:**
- Before installing SPLANTS for the first time
- When moving to a new computer/server
- When troubleshooting system-level issues

**What it checks:**
1. ✅ Operating system (Linux/macOS/Windows)
2. ✅ Docker installed and running
3. ✅ Docker Compose available
4. ✅ RAM (minimum 4GB)
5. ✅ Disk space (minimum 20GB)
6. ✅ Internet connectivity
7. ✅ Ports 3000 and 5432 available
8. ✅ Utilities (curl, git)

**Output:**
- Green ✅ = PASS
- Yellow ⚠️ = WARNING (may work but not ideal)
- Red ❌ = FAIL (must fix before proceeding)

**Example successful output:**
```
================================================
Summary
================================================

Checks Passed:   10
Warnings:        0
Checks Failed:   0

✅ System is ready to run SPLANTS!
```

---

## Installation Verification Script

**Purpose:** Verify SPLANTS is installed correctly and working

**Command:**
```bash
./scripts_verify-installation.sh
```

**When to use:**
- Immediately after first-time setup
- After updating SPLANTS
- When troubleshooting runtime issues
- Before deploying to production

**What it validates:**
1. ✅ .env configuration file exists
2. ✅ API keys are set correctly
3. ✅ Docker containers running (db, app, web)
4. ✅ Health endpoints responding
5. ✅ API authentication working
6. ✅ Database connection established
7. ✅ No errors in logs

**Output:**
- Green ✅ = PASS
- Yellow ⚠️ = WARNING (working but needs attention)
- Red ❌ = FAIL (not working, must fix)

**Example successful output:**
```
================================================
Verification Summary
================================================

Checks Passed:   12
Warnings:        0
Checks Failed:   0

✅ SPLANTS installation is working!

Access Your SPLANTS System:
  🌐 Web UI:      http://localhost:3000
  📚 API Docs:    http://localhost:3000/api/docs
```

---

## Common Workflows

### First-Time Installation
```bash
# 1. Check system
./scripts_check-system.sh

# 2. If checks pass, run setup
make start

# 3. Verify installation
./scripts_verify-installation.sh

# 4. Access system
# Open http://localhost:3000
```

### After Updating SPLANTS
```bash
# 1. Pull updates
git pull

# 2. Rebuild
make rebuild

# 3. Verify everything works
./scripts_verify-installation.sh
```

### Troubleshooting Issues
```bash
# 1. Run verification to identify problem
./scripts_verify-installation.sh

# 2. Check logs if needed
make logs

# 3. Check system if verification suggests system issues
./scripts_check-system.sh
```

---

## Script Options

Both scripts are standalone and require no arguments.

**Make them executable (if needed):**
```bash
chmod +x scripts_check-system.sh
chmod +x scripts_verify-installation.sh
```

---

## Integration with Makefile

You can also use make commands for verification:

```bash
# Check service status
make status

# Run API tests
make test

# View logs
make logs
```

---

## Exit Codes

Both scripts use standard exit codes:

- `0` = All checks passed (success)
- `1` = Some checks failed (issues found)

**Use in automation:**
```bash
if ./scripts_verify-installation.sh; then
    echo "Deployment successful!"
else
    echo "Deployment failed, check output above"
    exit 1
fi
```

---

## Interpreting Results

### All Checks Pass ✅
**Meaning:** System/installation is ready  
**Action:** Proceed with confidence

### Some Warnings ⚠️
**Meaning:** Works but not optimal  
**Action:** Review warnings, fix when convenient  
**Example:** Lower RAM than recommended

### Some Checks Fail ❌
**Meaning:** Won't work properly  
**Action:** Follow remediation steps in output  
**Example:** Docker not running, port in use

---

## Tips

1. **Run system check first** - Catch issues before installing
2. **Run verification after setup** - Confirm correct installation
3. **Save the output** - Helpful for troubleshooting:
   ```bash
   ./scripts_verify-installation.sh > verification.log 2>&1
   ```
4. **Re-run after fixes** - Verify your fixes worked
5. **Use in CI/CD** - Automate deployment verification

---

## Troubleshooting the Scripts

**Script won't run:**
```bash
chmod +x scripts_check-system.sh
chmod +x scripts_verify-installation.sh
```

**"command not found":**
```bash
# Run with bash explicitly
bash scripts_check-system.sh
bash scripts_verify-installation.sh
```

**Color codes not showing:**
- Your terminal may not support ANSI colors
- Output is still valid, just less pretty

---

## Related Commands

| Command | Purpose |
|---------|---------|
| `make start` | Start SPLANTS (runs setup wizard if needed) |
| `make stop` | Stop all services |
| `make status` | Check if containers are running |
| `make logs` | View application logs |
| `make test` | Run API test suite |
| `make restart` | Restart all services |

---

**For detailed documentation, see:**
- [README.md](README.md) - Complete documentation
- [SETUP_GUIDE.md](SETUP_GUIDE.md) - Step-by-step installation
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Problem solving

---

*Last Updated: 2025-11-12*  
*SPLANTS Version: 2.1.1*
