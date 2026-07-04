# Installation Guide - Bird UI for Glitch Soc v4.7.0-alpha.1+

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Quick Installation](#quick-installation)
3. [Step-by-Step Installation](#step-by-step-installation)
4. [Verification](#verification)
5. [Troubleshooting](#troubleshooting)

## Prerequisites

- **Glitch Soc v4.7.0-alpha.1** or later
- `bash` 4.0 or higher
- Write permissions to Glitch Soc directory
- `sudo` access for file permissions
- Node.js and Yarn (for asset compilation)
- Rails environment configured

## Quick Installation

### One-Line Installation

```bash
bash <(curl -s https://raw.githubusercontent.com/GitEspelunca/Espelunca_birdUI/main/install.sh) --path /opt/mastodon
```

### Or from cloned repository

```bash
git clone https://github.com/GitEspelunca/Espelunca_birdUI.git
cd Espelunca_birdUI
sudo bash install.sh --path /opt/mastodon
```

## Step-by-Step Installation

### Step 1: Validate Your Installation

```bash
# Check if themes.yml exists
ls /opt/mastodon/config/themes.yml

# Check flavours directory
ls /opt/mastodon/app/javascript/flavours
```

### Step 2: Run Installation Script

```bash
cd /path/to/Espelunca_birdUI
sudo bash install.sh --path /opt/mastodon
```

**Installation will:**
- ✅ Create automatic backup of current installation
- ✅ Copy Bird UI flavour to `app/javascript/flavours/bird-ui/`
- ✅ Copy Bird UI skins to `app/javascript/skins/bird-ui/`
- ✅ Copy entry points to `app/javascript/styles/`
- ✅ Update `config/themes.yml` with new theme entries
- ✅ Update locale files with theme names
- ✅ Set correct file permissions

### Step 3: Recompile Assets

```bash
cd /opt/mastodon

# For production
RAILS_ENV=production bundle exec rails assets:precompile

# For development
RAILS_ENV=development bundle exec rails assets:precompile
```

**⏱️ This may take 5-15 minutes**

### Step 4: Restart Mastodon Services

```bash
# Using systemd
sudo systemctl restart mastodon-web
sudo systemctl restart mastodon-sidekiq

# Or with Docker Compose
docker-compose restart web sidekiq

# Or manually
sudo systemctl restart mastodon-*
```

### Step 5: Verify Installation

1. Navigate to your Glitch Soc instance
2. Log in to your account
3. Go to **Preferences > Appearance > Theme**
4. You should see:
   - `Mastodon Bird UI` (or `bird-ui-auto`)
   - `Mastodon Bird UI (Accessible)`
   - `Mastodon Bird UI (Accessible Plus)`
5. Select one and save

## Verification

### Check Themes Installation

```bash
grep "bird-ui" /opt/mastodon/config/themes.yml
```

Expected output:
```
bird-ui-auto: styles/bird-ui-auto.scss
bird-ui-accessible: styles/bird-ui-accessible.scss
bird-ui-accessible-plus: styles/bird-ui-accessible-plus.scss
```

### Check Flavour Installation

```bash
ls -la /opt/mastodon/app/javascript/flavours/bird-ui/
```

Should show:
- `theme.yml`
- `names.yml`
- `entrypoints/`
- `styles/`
- etc.

### Check Skins Installation

```bash
ls -la /opt/mastodon/app/javascript/skins/bird-ui/
```

Should show:
- `default/`
- `light/`
- `contrast/`
- `accessible/`

## Troubleshooting

### Issue: "Not a valid Mastodon/Glitch installation"

**Solution:** Verify the path is correct:

```bash
ls /your/path/config/themes.yml
ls /your/path/app/javascript/flavours
```

### Issue: Assets fail to compile

**Solution:** Clear asset cache and retry:

```bash
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:clobber
RAILS_ENV=production bundle exec rails assets:precompile
```

### Issue: Themes don't appear in Preferences

**Possible causes:**
1. Assets not compiled - run `assets:precompile` again
2. Service not restarted - restart with `systemctl restart mastodon-web`
3. Browser cache - clear browser cache or use incognito mode
4. Database cache - clear Rails cache:

```bash
cd /opt/mastodon
RAILS_ENV=production bundle exec rails cache:clear
```

### Issue: "Permission denied" errors

**Solution:** Ensure proper ownership:

```bash
sudo chown -R mastodon:mastodon /opt/mastodon/app/javascript/flavours/bird-ui
sudo chown -R mastodon:mastodon /opt/mastodon/app/javascript/skins/bird-ui
chmod -R a+r /opt/mastodon/app/javascript/flavours/bird-ui
chmod -R a+r /opt/mastodon/app/javascript/skins/bird-ui
```

### Issue: Glitch or Vanilla themes break after installation

**Solution:** They should not be affected. Verify:

```bash
grep "glitch\|vanilla" /opt/mastodon/config/themes.yml
```

If missing, check backup:

```bash
ls -la /opt/mastodon_backup_birdui_*/
```

Restore from backup if needed:

```bash
cp /opt/mastodon_backup_birdui_TIMESTAMP/config/themes.yml /opt/mastodon/config/themes.yml
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart mastodon-web
```

## Advanced Options

### Set Bird UI as Default Theme

```bash
sudo bash install.sh --path /opt/mastodon --default
```

### Enable Verbose Output

```bash
sudo bash install.sh --path /opt/mastodon --verbose
```

### Skip Backup

```bash
bash install.sh --path /opt/mastodon --no-backup
```

## Logs

Installation logs are saved to:
- Success: `./install.log`
- Errors: `./error.log`

View logs:

```bash
cat Espelunca_birdUI/install.log
cat Espelunca_birdUI/error.log
```

## Rollback

If you need to restore your previous installation:

```bash
# Find the backup
ls -la /opt/mastodon_backup_birdui_*/

# Restore
TIMESTAMP=1234567890  # Use your timestamp
cp -r /opt/mastodon_backup_birdui_$TIMESTAMP/* /opt/mastodon/

# Recompile and restart
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart mastodon-web
```

## Getting Help

1. Check [docs/ARCHITECTURE.md](./ARCHITECTURE.md) for technical details
2. Check [docs/TROUBLESHOOTING.md](./TROUBLESHOOTING.md) for common issues
3. Open an issue on [GitHub](https://github.com/GitEspelunca/Espelunca_birdUI/issues)

## Next Steps

- [Customize Bird UI](./CUSTOMIZATION.md)
- [Understand the Architecture](./ARCHITECTURE.md)
- [View FAQ](./FAQ.md)
