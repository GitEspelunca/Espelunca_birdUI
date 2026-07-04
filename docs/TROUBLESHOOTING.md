# Troubleshooting - Bird UI for Glitch Soc

## Installation Issues

### Installation script not found

**Error:**
```
bash: ./install.sh: No such file or directory
```

**Solutions:**

1. Download script directly:
   ```bash
   curl -O https://raw.githubusercontent.com/GitEspelunca/Espelunca_birdUI/main/install.sh
   bash install.sh --path /opt/mastodon
   ```

2. Clone repository:
   ```bash
   git clone https://github.com/GitEspelunca/Espelunca_birdUI.git
   cd Espelunca_birdUI
   bash install.sh --path /opt/mastodon
   ```

3. Check internet connection:
   ```bash
   ping github.com
   ```

### Permission denied

**Error:**
```
Permission denied while trying to connect to Docker daemon
```

**Solutions:**

1. Use `sudo`:
   ```bash
   sudo bash install.sh --path /opt/mastodon
   ```

2. Add user to docker group (if using Docker):
   ```bash
   sudo usermod -aG docker $USER
   newgrp docker
   ```

3. Check directory permissions:
   ```bash
   ls -ld /opt/mastodon
   sudo chown -R mastodon:mastodon /opt/mastodon
   ```

### "Not a valid Mastodon/Glitch installation"

**Error:**
```
Error: Not a valid Mastodon/Glitch installation: /path/to/mastodon
```

**Solutions:**

1. Verify path is correct:
   ```bash
   ls /your/path/config/themes.yml
   ls /your/path/app/javascript/flavours
   ```

2. Check Mastodon version:
   ```bash
   grep VERSION /your/path/lib/mastodon/version.rb
   # Should be 4.7.0 or higher
   ```

3. Try with correct path:
   ```bash
   bash install.sh --path /opt/mastodon  # Adjust path as needed
   ```

## Asset Compilation Issues

### Compilation fails with no error message

**Error:**
```
RAILS_ENV=production bundle exec rails assets:precompile
# Hangs or crashes silently
```

**Solutions:**

1. Check available disk space:
   ```bash
   df -h /opt/mastodon
   # Need at least 5GB free
   ```

2. Check available RAM:
   ```bash
   free -h
   # Need at least 2GB free
   ```

3. Clear cache before compilation:
   ```bash
   cd /opt/mastodon
   rm -rf public/packs node_modules/.cache
   rm -rf tmp/cache
   RAILS_ENV=production bundle exec rails assets:precompile
   ```

4. Enable verbose output:
   ```bash
   cd /opt/mastodon
   RAILS_ENV=production NODE_ENV=production bundle exec rails assets:precompile --verbose
   ```

### SCSS compilation error

**Error:**
```
Sass::SyntaxError: Inconsistent indentation
```

**Solution:**

Check SCSS syntax in Bird UI files (spaces vs tabs):

```bash
# Verify no tabs in SCSS files
grep -P '\t' /opt/mastodon/app/javascript/flavours/bird-ui/styles/**/*.scss

# Fix if found
sed -i 's/\t/  /g' /opt/mastodon/app/javascript/flavours/bird-ui/styles/**/*.scss
```

### Memory errors during compilation

**Error:**
```
JavaScript heap out of memory
```

**Solutions:**

1. Increase Node memory:
   ```bash
   cd /opt/mastodon
   NODE_OPTIONS="--max_old_space_size=4096" RAILS_ENV=production bundle exec rails assets:precompile
   ```

2. Close other applications consuming RAM

3. Add swap if no physical RAM:
   ```bash
   sudo dd if=/dev/zero of=/swapfile bs=1G count=4
   sudo chmod 600 /swapfile
   sudo mkswap /swapfile
   sudo swapon /swapfile
   ```

## Theme Not Appearing

### Themes don't show in Preferences

**Symptoms:**
- No Bird UI options in **Preferences > Appearance > Theme**
- Only see Mastodon/Glitch themes

**Solutions:**

1. Verify installation:
   ```bash
   grep bird-ui /opt/mastodon/config/themes.yml
   # Should show: bird-ui-auto, bird-ui-accessible, etc.
   ```

2. Check flavour exists:
   ```bash
   ls /opt/mastodon/app/javascript/flavours/bird-ui/theme.yml
   ```

3. Verify skins exist:
   ```bash
   ls /opt/mastodon/app/javascript/skins/bird-ui/
   # Should show: default/, light/, contrast/, accessible/
   ```

4. Recompile assets:
   ```bash
   cd /opt/mastodon
   RAILS_ENV=production bundle exec rails assets:clobber
   RAILS_ENV=production bundle exec rails assets:precompile
   ```

5. Clear Rails cache:
   ```bash
   cd /opt/mastodon
   RAILS_ENV=production bundle exec rails cache:clear
   ```

6. Restart web service:
   ```bash
   sudo systemctl restart mastodon-web
   ```

7. Hard refresh browser (Ctrl+Shift+R or Cmd+Shift+R)

### Themes show but are broken/unstyled

**Symptoms:**
- Theme appears but no styling applied
- Layout broken

**Solutions:**

1. Check for CSS compilation errors:
   ```bash
   tail -100 /opt/mastodon/log/production.log | grep -i error
   tail -100 /opt/mastodon/log/development.log | grep -i error
   ```

2. Check if CSS files exist:
   ```bash
   find /opt/mastodon/public/packs -name '*bird*ui*'
   # Should have .js and .css files
   ```

3. Clear browser cache:
   - Chrome: Ctrl+Shift+Delete
   - Firefox: Ctrl+Shift+Delete
   - Safari: Cmd+Option+E

4. Try different browser to rule out cache issues

5. Check browser console for errors (F12)

## Service Issues

### Mastodon web service crashes after installation

**Error:**
```
sudo systemctl status mastodon-web
# Shows "failed" or "inactive"
```

**Solutions:**

1. Check error logs:
   ```bash
   tail -50 /opt/mastodon/log/production.log
   sudo journalctl -u mastodon-web -n 50
   ```

2. Check file permissions:
   ```bash
   ls -la /opt/mastodon/app/javascript/flavours/bird-ui/
   # Should be readable by mastodon user
   ```

3. Fix permissions if needed:
   ```bash
   sudo chown -R mastodon:mastodon /opt/mastodon/app/javascript/flavours/bird-ui
   sudo chown -R mastodon:mastodon /opt/mastodon/app/javascript/skins/bird-ui
   sudo chmod -R a+r /opt/mastodon/app/javascript/flavours/bird-ui
   sudo chmod -R a+r /opt/mastodon/app/javascript/skins/bird-ui
   ```

4. Restart service:
   ```bash
   sudo systemctl restart mastodon-web
   ```

### Sidekiq crashes

**Error:**
```
sudo systemctl status mastodon-sidekiq
# Shows errors
```

**Solution:**

Asset compilation doesn't affect Sidekiq, but verify:

```bash
sudo systemctl restart mastodon-sidekiq
sudo journalctl -u mastodon-sidekiq -n 50
```

## Performance Issues

### Slow page loads after installing Bird UI

**Solutions:**

1. Check CSS file sizes:
   ```bash
   ls -lh /opt/mastodon/public/packs/themes/
   # Each .css should be < 100KB
   ```

2. Enable gzip compression (nginx):
   ```bash
   # In /etc/nginx/nginx.conf
   gzip on;
   gzip_types text/css text/javascript application/javascript;
   gzip_comp_level 6;
   ```

3. Monitor server resources:
   ```bash
   htop
   # Check CPU and memory usage
   ```

4. Clear unused skins to reduce compile time:
   ```bash
   cd /opt/mastodon/app/javascript/skins/bird-ui
   rm -rf contrast/  # Remove if not needed
   ```

## Revert/Rollback

### Completely remove Bird UI

```bash
# Restore from backup
TIMESTAMP=$(ls -td /opt/mastodon_backup_birdui_*/ | head -1 | grep -oE '[0-9]+$')
cp -r /opt/mastodon_backup_birdui_$TIMESTAMP/* /opt/mastodon/

# Or manually remove
rm -rf /opt/mastodon/app/javascript/flavours/bird-ui
rm -rf /opt/mastodon/app/javascript/skins/bird-ui
rm /opt/mastodon/app/javascript/styles/bird-ui-*.scss

# Remove from config
sed -i '/bird-ui/d' /opt/mastodon/config/themes.yml

# Recompile
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart mastodon-web
```

### Restore specific backup

```bash
# List backups
ls -lad /opt/mastodon_backup_birdui_*/

# Restore specific timestamp
TIMESTAMP=1234567890
cp -r /opt/mastodon_backup_birdui_$TIMESTAMP/config/themes.yml /opt/mastodon/config/
cp -r /opt/mastodon_backup_birdui_$TIMESTAMP/config/locales/ /opt/mastodon/config/

# Recompile
cd /opt/mastodon && RAILS_ENV=production bundle exec rails assets:precompile
```

## Getting Help

### Check logs for clues

```bash
# Production logs
tail -100 /opt/mastodon/log/production.log

# Development logs
tail -100 /opt/mastodon/log/development.log

# System logs
sudo journalctl -u mastodon-web -n 100
sudo journalctl -u mastodon-sidekiq -n 100

# Nginx logs (if used)
tail -50 /var/log/nginx/error.log
```

### Report an issue

When reporting, include:

```bash
# Glitch version
grep VERSION /opt/mastodon/lib/mastodon/version.rb

# OS info
uname -a

# Relevant logs
tail -100 /opt/mastodon/log/production.log

# Error messages from browser console (F12)

# Installation command used
echo $YOUR_INSTALL_COMMAND
```

Open issue: https://github.com/GitEspelunca/Espelunca_birdUI/issues

## Related Documentation

- [Installation Guide](./INSTALLATION.md)
- [Architecture](./ARCHITECTURE.md)
- [FAQ](./FAQ.md)
- [Customization](./CUSTOMIZATION.md)
