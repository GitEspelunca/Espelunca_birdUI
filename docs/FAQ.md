# FAQ - Bird UI for Glitch Soc

## General Questions

### Q: Is Bird UI compatible with my Glitch Soc version?

**A:** Bird UI requires Glitch Soc v4.7.0-alpha.1 or later. Check your version:

```bash
grep VERSION /path/to/mastodon/lib/mastodon/version.rb
```

### Q: Will Bird UI break my existing Glitch/Vanilla themes?

**A:** No. Bird UI is completely separate:
- Glitch theme remains unchanged
- Vanilla theme remains unchanged  
- All existing skins remain available
- Users can switch between themes freely

### Q: Do I need to reinstall after Mastodon updates?

**A:** Not necessarily, but it's recommended. Run the installer again:

```bash
bash install.sh --path /opt/mastodon
```

It will update files if needed while preserving your backups.

## Installation Questions

### Q: Can I install Bird UI on a live instance?

**A:** Yes, but backup first:

```bash
sudo cp -r /opt/mastodon /opt/mastodon_manual_backup
```

Then run installer. There will be brief downtime during asset compilation (~5-15 mins).

### Q: What happens if installation fails?

**A:** The installer creates an automatic backup:

```bash
ls -la /opt/mastodon_backup_birdui_*/
```

To restore:

```bash
TIMESTAMP=1234567890
cp -r /opt/mastodon_backup_birdui_$TIMESTAMP/* /opt/mastodon/
cd /opt/mastodon && RAILS_ENV=production bundle exec rails assets:precompile
```

### Q: Can I install on Docker/Podman?

**A:** Yes:

```bash
# Enter container
docker exec -it mastodon-web bash

# Download and run installer
curl -s https://raw.githubusercontent.com/GitEspelunca/Espelunca_birdUI/main/install.sh | bash -s -- --path /mastodon

# Recompile
cd /mastodon && RAILS_ENV=production bundle exec rails assets:precompile

# Restart
exit
docker-compose restart web
```

## Customization Questions

### Q: How do I change Bird UI colors?

**A:** Edit the skin SCSS files in your Glitch installation:

```bash
vim /opt/mastodon/app/javascript/skins/bird-ui/default/index.scss
```

Change CSS variables, then recompile:

```bash
cd /opt/mastodon && RAILS_ENV=production bundle exec rails assets:precompile
```

### Q: Can I create a custom skin?

**A:** Yes! Create a new directory:

```bash
mkdir -p /opt/mastodon/app/javascript/skins/bird-ui/my-skin
```

Add `index.scss` with your variables:

```scss
:root {
  --color-primary: #your-color;
  --color-background: #your-bg;
  /* ... etc ... */
}
```

Recompile and the skin will appear automatically.

### Q: How do I modify Bird UI components?

**A:** Edit SCSS in the flavour:

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_status.scss
```

Recompile assets after changes.

## Troubleshooting Questions

### Q: Themes don't appear in Preferences after installation

**A:** 

1. Verify compilation succeeded:
   ```bash
   ls -la /opt/mastodon/public/packs/themes/
   ```

2. Clear Rails cache:
   ```bash
   cd /opt/mastodon && RAILS_ENV=production bundle exec rails cache:clear
   ```

3. Hard refresh browser (Ctrl+Shift+R)

4. Check browser console for errors (F12)

### Q: "Permission denied" during installation

**A:** You need `sudo` for permission changes:

```bash
sudo bash install.sh --path /opt/mastodon
```

Or ensure mastodon user owns the directory:

```bash
sudo chown -R mastodon:mastodon /opt/mastodon/app/javascript
```

### Q: Installation script not found / 404 error

**A:** Ensure you have the correct URL and branch:

```bash
# Test URL
curl -I https://raw.githubusercontent.com/GitEspelunca/Espelunca_birdUI/main/install.sh

# Clone instead
git clone https://github.com/GitEspelunca/Espelunca_birdUI.git
cd Espelunca_birdUI
sudo bash install.sh --path /opt/mastodon
```

### Q: Assets compilation fails

**A:**

1. Clear cache:
   ```bash
   cd /opt/mastodon && rm -rf public/packs/* node_modules/.cache/
   ```

2. Rebuild:
   ```bash
   yarn install
   RAILS_ENV=production bundle exec rails assets:precompile
   ```

3. Check logs:
   ```bash
   tail -f /opt/mastodon/log/production.log
   ```

## Performance Questions

### Q: Does Bird UI slow down the instance?

**A:** No. Bird UI:
- Uses the same Mastodon components
- Only adds CSS styling
- Minimal JavaScript overhead
- No database changes
- CSS variables are efficient

### Q: How much disk space does Bird UI use?

**A:** 
- Flavour files: ~2MB
- Skins: ~100KB
- Total: ~2.1MB (negligible)

### Q: Why is asset compilation slow?

**A:** Asset compilation is a Webpack process and can take 5-15 minutes depending on:
- Server CPU
- RAM available
- Number of themes
- Other running processes

This is normal and only happens during setup/updates.

## Localization Questions

### Q: How do I add another language?

**A:** Edit locale files:

```bash
vim /opt/mastodon/config/locales/de.yml  # German example
```

Add Bird UI theme entries:

```yaml
themes:
  bird-ui-auto: Mastodon Bird UI
  bird-ui-accessible: Mastodon Bird UI (Zugänglich)
  bird-ui-accessible-plus: Mastodon Bird UI (Zugänglich Plus)
```

### Q: How do I change theme display names?

**A:** Edit locale files (e.g., `config/locales/en.yml`):

```yaml
themes:
  bird-ui-auto: My Custom Name
```

## Support & Contributing

### Q: Where can I report bugs?

**A:** Open an issue on [GitHub](https://github.com/GitEspelunca/Espelunca_birdUI/issues)

### Q: How can I contribute improvements?

**A:** 

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

### Q: Is there community support?

**A:** 
- GitHub Issues: Report bugs and request features
- GitHub Discussions: Ask questions and share ideas
- Mastodon: Discuss on fediverse

## Related Resources

- [Installation Guide](./INSTALLATION.md)
- [Architecture Documentation](./ARCHITECTURE.md)
- [Customization Guide](./CUSTOMIZATION.md)
- [Troubleshooting Guide](./TROUBLESHOOTING.md)
- [Original Bird UI](https://github.com/rollecode/mastodon-bird-ui)
- [Glitch Soc Documentation](https://glitch-soc.github.io/docs/)
