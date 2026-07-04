# Troubleshooting Guide - Bird UI for Glitch Soc

## Installation Issues

### Issue: "Not a valid Mastodon/Glitch installation"

**Symptoms:**
- Error message during installation
- Script exits immediately

**Causes:**
- Wrong path provided
- Missing `config/themes.yml`
- Not a Mastodon/Glitch directory

**Solutions:**

```bash
# Verify correct path
ls /your/path/config/themes.yml
ls /your/path/app/javascript/flavours

# Check if directory is Mastodon
grep -r "Mastodon" /your/path/README.md 2>/dev/null || echo "Not found"

# Use correct path
sudo bash install.sh --path /opt/mastodon  # Adjust path
```

### Issue: "Permission denied" during installation

**Symptoms:**
- Error when creating directories
- Cannot write files

**Causes:**
- Missing `sudo`
- Insufficient user permissions
- Directory owned by different user

**Solutions:**

```bash
# Use sudo
sudo bash install.sh --path /opt/mastodon

# Or fix permissions
sudo chown -R $(whoami):$(whoami) /opt/mastodon

# Or restore proper ownership
sudo chown -R mastodon:mastodon /opt/mastodon
```

### Issue: "curl: command not found"

**Symptoms:**
- Cannot download installer with curl

**Causes:**
- curl not installed
- Network issues

**Solutions:**

```bash
# Install curl
sudo apt-get install curl  # Debian/Ubuntu
sudo yum install curl      # CentOS/RHEL

# Or download manually
git clone https://github.com/GitEspelunca/Espelunca_birdUI.git
cd Espelunca_birdUI
sudo bash install.sh --path /opt/mastodon
```

### Issue: Installation completes but no output

**Symptoms:**
- Script runs silently
- No error messages
- Unclear if success or failure

**Solutions:**

```bash
# Use verbose mode
sudo bash install.sh --path /opt/mastodon --verbose

# Check logs
cat Espelunca_birdUI/install.log
cat Espelunca_birdUI/error.log

# Verify manually
ls /opt/mastodon/app/javascript/flavours/bird-ui/
ls /opt/mastodon/app/javascript/skins/bird-ui/
grep bird-ui /opt/mastodon/config/themes.yml
```

## Asset Compilation Issues

### Issue: Assets compilation fails

**Symptoms:**
```
WEBPACK Failed to compile with 1 errors
Error: Cannot find module
```

**Causes:**
- Missing dependencies
- Node.js version mismatch
- Corrupted node_modules
- Disk space full

**Solutions:**

```bash
cd /opt/mastodon

# Check Node version
node --version  # Should be 16+

# Clear cache
rm -rf node_modules/.cache
rm -rf public/packs

# Reinstall dependencies
yarn install

# Check disk space
df -h /opt/mastodon

# Recompile with verbose output
RAILS_ENV=production bundle exec rails assets:precompile:all 2>&1 | tail -50
```

### Issue: Compilation takes too long (>30 minutes)

**Symptoms:**
- Still compiling after 20+ minutes
- Server load high

**Causes:**
- Low system resources
- Many other processes running
- First compilation (always slower)

**Solutions:**

```bash
# Check system resources
free -h
df -h

# Stop other services
sudo systemctl stop sidekiq

# Compile with specific configuration
cd /opt/mastodon
WORKERPROCESSES=2 RAILS_ENV=production bundle exec rails assets:precompile

# Monitor progress
tail -f log/production.log
```

### Issue: "Webpacker has not yet been run"

**Symptoms:**
```
Webpacker can't find application.js in manifest.json.
Assets precompiled but webpacker hasn't run yet.
```

**Causes:**
- Webpacker not compiled
- Yarn build incomplete

**Solutions:**

```bash
cd /opt/mastodon

# Run webpacker explicitly
yarn install
yarn build

# Then compile assets
RAILS_ENV=production bundle exec rails assets:precompile

# Clear cache
RAILS_ENV=production bundle exec rails cache:clear

# Restart
sudo systemctl restart mastodon-web
```

## Themes Not Appearing

### Issue: Bird UI themes don't appear in Preferences

**Symptoms:**
- Settings page loads normally
- Theme dropdown doesn't show Bird UI options
- Other themes visible

**Causes:**
- Assets not compiled
- Cache not cleared
- Themes not registered in `config/themes.yml`
- Browser cache

**Solutions:**

```bash
# 1. Verify themes registered
grep bird-ui /opt/mastodon/config/themes.yml

# 2. Check asset compilation
ls /opt/mastodon/public/packs/themes/ | grep bird-ui

# 3. Clear Rails cache
cd /opt/mastodon
RAILS_ENV=production bundle exec rails cache:clear

# 4. Check database
sudo -u mastodon psql mastodon_production -c \
  "SELECT id, var, value FROM settings LIMIT 10;"

# 5. Clear browser cache
# Use Ctrl+Shift+Delete or clear manually

# 6. Hard refresh in browser
# Use Ctrl+Shift+R (Windows/Linux) or Cmd+Shift+R (Mac)

# 7. Restart services
sudo systemctl restart mastodon-web

# 8. Check Rails logs
tail -f /opt/mastodon/log/production.log
```

### Issue: Themes appear but don't apply

**Symptoms:**
- Theme selectable in dropdown
- Selection saves
- But styling doesn't change

**Causes:**
- CSS not loading
- Browser cache
- Stylesheet path wrong
- Service worker cached old assets

**Solutions:**

```bash
# 1. Clear browser cache
# Ctrl+Shift+Delete or Settings > Clear browsing data

# 2. Clear service worker
# In DevTools: Application > Service Workers > Unregister

# 3. Hard refresh
Ctrl+Shift+R (or Cmd+Shift+R)

# 4. Check stylesheet loading
# Open DevTools > Network tab
# Look for bird-ui CSS files
# Should see 200 status codes

# 5. Verify CSS path
ls -la /opt/mastodon/public/packs/css/

# 6. Check web server logs
sudo tail -f /var/log/nginx/mastodon.access.log
```

### Issue: Only some themes appear

**Symptoms:**
- Some Bird UI skins visible (e.g., Dark)
- Others missing (e.g., Light)

**Causes:**
- Partial installation
- Some skin files missing
- Incomplete asset compilation

**Solutions:**

```bash
# 1. Verify all skins exist
ls /opt/mastodon/app/javascript/skins/bird-ui/
# Should show: accessible, contrast, default, light

# 2. Check themes.yml
grep bird-ui /opt/mastodon/config/themes.yml

# 3. Reinstall if needed
sudo bash install.sh --path /opt/mastodon

# 4. Recompile
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:precompile

# 5. Restart
sudo systemctl restart mastodon-web
```

## Glitch/Vanilla Themes Broken

### Issue: Existing themes stopped working after Bird UI installation

**Symptoms:**
- Glitch theme broken
- Vanilla theme broken
- Previously working themes don't apply

**Causes:**
- themes.yml corrupted
- File permissions changed
- Core files overwritten (shouldn't happen)

**Solutions:**

```bash
# 1. Check backup
ls /opt/mastodon_backup_birdui_*/

# 2. Compare themes.yml
grep -E "^glitch:|^vanilla:" /opt/mastodon/config/themes.yml

# 3. If missing, restore from backup
TIMESTAMP=1234567890  # Use correct timestamp
cp /opt/mastodon_backup_birdui_$TIMESTAMP/config/themes.yml \
   /opt/mastodon/config/themes.yml

# 4. Verify flavours not modified
ls /opt/mastodon/app/javascript/flavours/glitch/theme.yml
ls /opt/mastodon/app/javascript/flavours/vanilla/theme.yml

# 5. Recompile
cd /opt/mastodon && RAILS_ENV=production bundle exec rails assets:precompile

# 6. Restart
sudo systemctl restart mastodon-web
```

## Performance Issues

### Issue: Instance slow after Bird UI installation

**Symptoms:**
- Web pages load slowly
- High server load
- Database queries slow

**Causes:**
- Compilation didn't complete properly
- Service still recompiling
- Database indexes need rebuild

**Solutions:**

```bash
# 1. Check if still compiling
ps aux | grep rails

# 2. Wait for compilation to finish
watch -n 1 'ps aux | grep packs'

# 3. Check system resources
free -h
df -h
top -b -n 1 | head -20

# 4. Check database connections
sudo -u mastodon psql mastodon_production -c \
  "SELECT count(*) FROM pg_stat_activity;"

# 5. Rebuild database indexes
cd /opt/mastodon
RAILS_ENV=production bundle exec rails db:migrate

# 6. Check service worker
Redis issues? Check:
redis-cli ping  # Should return PONG
```

## Browser-Specific Issues

### Issue: Theme looks wrong in specific browser

**Symptoms:**
- Theme works in Chrome, broken in Firefox
- Colors different in Safari
- Layout broken in IE

**Causes:**
- CSS compatibility issues
- Browser-specific bugs
- Vendor prefixes needed

**Solutions:**

```bash
# 1. Open DevTools in problematic browser
F12 or right-click > Inspect

# 2. Check CSS in Elements tab
# Look for red underlines or warnings

# 3. Check Console tab
# Look for JavaScript errors

# 4. Test in incognito/private mode
# Eliminates extension conflicts

# 5. Report with:
# - Browser name and version
# - Screenshot
# - Expected vs actual
```

### Issue: Responsive design broken on mobile

**Symptoms:**
- Layout broken on phone
- Sidebar not responsive
- Touch interactions not working

**Causes:**
- Media queries not working
- Viewport meta tag issue
- JavaScript viewport code

**Solutions:**

```bash
# 1. Check browser DevTools
# F12 > Toggle device toolbar (Ctrl+Shift+M)

# 2. Test on actual device
# Not just simulator

# 3. Check media queries
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/responsive/

# 4. Verify viewport meta tag
# Should be in HTML head
# <meta name="viewport" content="width=device-width, initial-scale=1">

# 5. Test with:
# - Different screen sizes
# - Different orientations
# - Touch interactions
```

## Database Issues

### Issue: "ActiveRecord::DatabaseConnectionError"

**Symptoms:**
```
PG::Error: could not connect to server
```

**Causes:**
- PostgreSQL down
- Connection pool exhausted
- Wrong credentials

**Solutions:**

```bash
# 1. Check PostgreSQL status
sudo systemctl status postgresql

# 2. Start if stopped
sudo systemctl start postgresql

# 3. Test connection
sudo -u mastodon psql mastodon_production -c "SELECT 1"

# 4. Check connections
sudo -u mastodon psql mastodon_production -c \
  "SELECT count(*) FROM pg_stat_activity WHERE state='active';"

# 5. Check Rails config
vim /opt/mastodon/config/database.yml

# 6. Restart all services
sudo systemctl restart postgresql
sudo systemctl restart mastodon-web
sudo systemctl restart mastodon-sidekiq
```

## Support & Debug

### Enable Debug Logging

```bash
# Set Rails to debug level
export RAILS_LOG_LEVEL=debug

# Recompile with verbose
RAILS_ENV=production bundle exec rails assets:precompile RAILS_LOG_LEVEL=debug

# Follow logs in real-time
tail -f /opt/mastodon/log/production.log
```

### Collect Debug Information

```bash
#!/bin/bash
# save_debug_info.sh

echo "=== System Info ==="
uname -a
echo ""

echo "=== Glitch Soc Version ==="
grep VERSION /opt/mastodon/lib/mastodon/version.rb
echo ""

echo "=== Ruby Version ==="
ruby --version
echo ""

echo "=== Node Version ==="
node --version
echo ""

echo "=== Themes ==="
grep bird-ui /opt/mastodon/config/themes.yml
echo ""

echo "=== Flavour Files ==="
ls -la /opt/mastodon/app/javascript/flavours/bird-ui/ | head -20
echo ""

echo "=== Skins ==="
ls -la /opt/mastodon/app/javascript/skins/bird-ui/
echo ""

echo "=== Recent Errors ==="
tail -50 /opt/mastodon/log/production.log | grep -i error
```

### When to Report Issues

Include:
- [ ] Glitch Soc version
- [ ] Installation method (curl, git, manual)
- [ ] Installation logs
- [ ] Error messages (full text)
- [ ] Steps to reproduce
- [ ] Screenshots if applicable
- [ ] System info (OS, RAM, CPU)

## Getting Help

1. **Check Documentation**
   - [INSTALLATION.md](./INSTALLATION.md)
   - [ARCHITECTURE.md](./ARCHITECTURE.md)
   - [CUSTOMIZATION.md](./CUSTOMIZATION.md)
   - [FAQ.md](./FAQ.md)

2. **Search Issues**
   - https://github.com/GitEspelunca/Espelunca_birdUI/issues

3. **Open New Issue**
   - Include all debug information
   - Be specific about symptoms
   - Provide error logs

4. **Community Support**
   - Mastodon fediverse discussions
   - Glitch Soc documentation
   - Bird UI original repository

## Quick Reference

### Emergency Commands

```bash
# Rollback to backup
TIMESTAMP=1234567890
cp -r /opt/mastodon_backup_birdui_$TIMESTAMP/* /opt/mastodon/

# Clear all caches
cd /opt/mastodon && RAILS_ENV=production bundle exec rails cache:clear

# Recompile everything
cd /opt/mastodon && rm -rf public/packs && RAILS_ENV=production bundle exec rails assets:precompile

# Restart services
sudo systemctl restart mastodon-web mastodon-sidekiq

# Monitor logs
sudo tail -f /opt/mastodon/log/production.log
```

### Health Check

```bash
# Test all systems
echo "Themes:" && grep bird-ui /opt/mastodon/config/themes.yml
echo "Flavours:" && ls /opt/mastodon/app/javascript/flavours/bird-ui/
echo "Skins:" && ls /opt/mastodon/app/javascript/skins/bird-ui/
echo "Packs:" && ls /opt/mastodon/public/packs/css/ | grep bird-ui | head -5
```
