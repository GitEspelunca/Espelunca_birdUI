# Customization Guide - Bird UI for Glitch Soc

## Overview

Bird UI is highly customizable. You can modify colors, layouts, components, and more without touching the core Mastodon/Glitch files.

## Color Customization

### Editing Skin Colors

Each skin in `/opt/mastodon/app/javascript/skins/bird-ui/` contains CSS variables:

#### Dark Skin (Default)

```bash
vim /opt/mastodon/app/javascript/skins/bird-ui/default/index.scss
```

Example:
```scss
:root {
  --color-primary: #1d9bf0;        /* Main accent color */
  --color-background: #0f1419;     /* Main background */
  --color-text-primary: #e7e9ea;   /* Main text */
  --color-border: #2f3336;         /* Borders */
  --color-success: #17bf63;        /* Success color */
  --color-warning: #ffb81c;        /* Warning color */
  --color-error: #f4453c;          /* Error color */
}
```

#### Light Skin

```bash
vim /opt/mastodon/app/javascript/skins/bird-ui/light/index.scss
```

#### High Contrast Skin

```bash
vim /opt/mastodon/app/javascript/skins/bird-ui/contrast/index.scss
```

#### Accessible Skin

```bash
vim /opt/mastodon/app/javascript/skins/bird-ui/accessible/index.scss
```

### Applying Custom Colors

1. Edit the skin file:
   ```bash
   vim /opt/mastodon/app/javascript/skins/bird-ui/default/index.scss
   ```

2. Change color values:
   ```scss
   :root {
     --color-primary: #your-hex-color;
   }
   ```

3. Recompile assets:
   ```bash
   cd /opt/mastodon
   RAILS_ENV=production bundle exec rails assets:precompile
   ```

4. Restart services:
   ```bash
   sudo systemctl restart mastodon-web
   ```

5. Hard refresh browser (Ctrl+Shift+R) to clear cache

## Creating Custom Skins

### Step 1: Create Skin Directory

```bash
mkdir -p /opt/mastodon/app/javascript/skins/bird-ui/my-custom-skin
```

### Step 2: Create index.scss

```bash
cat > /opt/mastodon/app/javascript/skins/bird-ui/my-custom-skin/index.scss << 'EOF'
:root {
  /* Your custom colors */
  --color-primary: #your-color;
  --color-background: #your-bg-color;
  --color-text-primary: #your-text-color;
  --color-border: #your-border-color;
  
  /* Copy other variables from default/index.scss */
  --color-success: #17bf63;
  --color-warning: #ffb81c;
  --color-error: #f4453c;
  --color-info: #1d9bf0;
}
EOF
```

### Step 3: Recompile Assets

```bash
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:precompile
```

### Step 4: Verify

The new skin should appear in Preferences > Appearance > Theme as `my-custom-skin`.

## Component Customization

### Modifying Status Component

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_status.scss
```

Example changes:
```scss
.status {
  display: flex;
  gap: 12px;
  padding: 16px;  /* Changed from 12px */
  border-bottom: 2px solid var(--color-border);  /* Changed from 1px */
  transition: all 0.3s ease;  /* Changed from 0.2s */
}
```

### Modifying Button Component

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_button.scss
```

### Modifying Navigation Component

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_navigation.scss
```

### Modifying Avatar Component

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_avatar.scss
```

## Layout Customization

### Sidebar Width

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/layouts/_main.scss
```

Change:
```scss
.drawer {
  width: 275px;  /* Change this value */
  min-width: 275px;
}
```

### Compose Box Height

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/layouts/_compose.scss
```

Change:
```scss
.compose-form__textarea__input {
  max-height: 400px;  /* Change this value */
}
```

## Typography Customization

### Font Family

Edit variables file:
```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/variables/_typography.scss
```

Change:
```scss
$typography: (
  family-base: 'Your Font Family', sans-serif,
  /* ... */
)
```

### Font Sizes

```scss
$typography: (
  size-xs: 12px,
  size-sm: 13px,
  size-md: 15px,  /* Change default */
  size-lg: 17px,
  size-xl: 20px,
)
```

## Spacing Customization

Edit spacing variables:
```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/variables/_spacing.scss
```

Example:
```scss
$spacing: (
  xs: 4px,
  sm: 8px,
  md: 12px,   /* Change standard spacing */
  lg: 16px,
  xl: 24px,
  xxl: 32px,
)
```

## Micro-Interactions Customization

### Favourite Button Animation

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/micro-interactions/_favourite.scss
```

Add animations:
```scss
@keyframes favourite-burst {
  0% { transform: scale(0); opacity: 1; }
  100% { transform: scale(1); opacity: 0; }
}

.favourite-icon--active {
  animation: favourite-burst 0.6s ease-out;
}
```

### Boost Button Animation

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/micro-interactions/_boost.scss
```

## Feature Customization

### Feed Layout

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/features/_feed.scss
```

### Compose Form

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/features/_compose.scss
```

### Notifications

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/features/_notifications.scss
```

## Workflow for Customization

### Development Setup

```bash
# 1. Create a feature branch
git clone https://github.com/GitEspelunca/Espelunca_birdUI.git
cd Espelunca_birdUI
git checkout -b my-customizations

# 2. Make your changes
vim skins/bird-ui/default/index.scss

# 3. Test locally (if you have local Mastodon setup)
bash install.sh --path /path/to/local/mastodon
cd /path/to/local/mastodon
RAILS_ENV=development bundle exec rails assets:precompile

# 4. View changes at http://localhost:3000

# 5. Commit changes
git add .
git commit -m "Customize: Add my custom theme"

# 6. Submit PR if contributing back
git push origin my-customizations
```

### Production Deployment

```bash
# 1. Test in staging environment first
# 2. Backup production
# 3. Apply changes to production Mastodon installation
cp -r skins/bird-ui/my-skin /opt/mastodon/app/javascript/skins/bird-ui/

# 4. Recompile
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:precompile

# 5. Restart
sudo systemctl restart mastodon-web

# 6. Verify in browser
```

## Advanced: Creating a Variant

Create a complete new variant based on Bird UI:

```bash
# Copy entire flavour
cp -r /opt/mastodon/app/javascript/flavours/bird-ui \
      /opt/mastodon/app/javascript/flavours/bird-ui-dark

# Update theme.yml
vim /opt/mastodon/app/javascript/flavours/bird-ui-dark/theme.yml
# Change: pack_directory: app/javascript/flavours/bird-ui-dark/entrypoints

# Update names.yml
vim /opt/mastodon/app/javascript/flavours/bird-ui-dark/names.yml
# Change flavour name to bird-ui-dark

# Customize styles
vim /opt/mastodon/app/javascript/flavours/bird-ui-dark/styles/themes/_dark.scss

# Recompile
cd /opt/mastodon && RAILS_ENV=production bundle exec rails assets:precompile
```

## Rollback Customization

If you mess up customizations, rollback using git:

```bash
# In Espelunca_birdUI repository
git checkout skins/bird-ui/default/index.scss

# Or restore from installation backup
cp /opt/mastodon_backup_birdui_TIMESTAMP/app/javascript/skins/bird-ui/* \
   /opt/mastodon/app/javascript/skins/bird-ui/

# Recompile
cd /opt/mastodon && RAILS_ENV=production bundle exec rails assets:precompile
```

## Testing Customizations

### Browser DevTools

1. Open DevTools (F12)
2. Go to Console tab
3. Try modifying CSS variables:
   ```javascript
   document.documentElement.style.setProperty('--color-primary', '#ff0000');
   ```

### Quick Preview

Use browser extensions like Stylus to preview changes before deployment.

## Common Customizations

### Make Status Cards Wider

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_status.scss

# Change:
.status {
  padding: 12px 32px;  /* Increase horizontal padding */
}
```

### Larger Avatars

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_avatar.scss

# Change:
.avatar--size-lg {
  width: 64px;  /* Changed from 48px */
  height: 64px;
}
```

### Rounded Buttons

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_button.scss

# Change:
.button {
  border-radius: 8px;  /* Changed from 20px for more square buttons */
}
```

### Compact Mode

```bash
vim /opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_status.scss

# Change:
.status {
  padding: 8px 12px;  /* Reduced from 12px 16px */
  gap: 8px;           /* Reduced from 12px */
}
```

## Tips & Tricks

1. **Use CSS Variables**: Always use `var(--color-primary)` instead of hardcoding colors
2. **Mobile First**: Test on mobile after changes
3. **Accessibility**: Maintain WCAG contrast ratios
4. **Performance**: Use `transition` sparingly
5. **Browser Compatibility**: Test in Firefox, Chrome, Safari
6. **Backup First**: Always backup before major changes

## Getting Help

- Check existing customizations in examples/
- Review SCSS files for existing patterns
- Ask on GitHub Issues
- Share customizations with community

## Next Steps

- [Installation Guide](./INSTALLATION.md)
- [Architecture](./ARCHITECTURE.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
- [FAQ](./FAQ.md)
