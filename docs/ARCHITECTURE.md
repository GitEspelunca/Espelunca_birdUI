# Architecture - Bird UI for Glitch Soc

## System Overview

```
Glitch Soc v4.7.0-alpha.1+
├── app/javascript/flavours/
│   ├── glitch/          ← Original Glitch flavour (unchanged)
│   ├── vanilla/         ← Original Vanilla flavour (unchanged)
│   └── bird-ui/         ← NEW: Bird UI flavour
│
├── app/javascript/skins/
│   ├── glitch/          ← Original Glitch skins (unchanged)
│   ├── vanilla/         ← Original Vanilla skins (unchanged)
│   └── bird-ui/         ← NEW: Bird UI skins
│       ├── default/     ← Dark theme
│       ├── light/       ← Light theme
│       ├── contrast/    ← High contrast theme
│       └── accessible/  ← Accessible theme
│
└── app/javascript/styles/
    ├── application.scss ← Core styles (unchanged)
    ├── bird-ui-auto.scss            ← NEW
    ├── bird-ui-accessible.scss      ← NEW
    └── bird-ui-accessible-plus.scss ← NEW
```

## How Flavours Work

### Theme Discovery

Glitch Soc uses `app/lib/themes.rb` which automatically discovers themes:

```ruby
# Discovers all flavours
Rails.root.glob('app/javascript/flavours/*/theme.yml')

# Discovers all skins
Rails.root.glob('app/javascript/skins/*/*')
```

### Theme Registration

Each flavour requires:

1. **theme.yml** - Configuration file
   ```yaml
   pack_directory: app/javascript/flavours/bird-ui/entrypoints
   signed_in_preload: [...]  # Optional preload files
   locales: locales          # Optional localization directory
   screenshot: [...]         # Optional preview images
   ```

2. **names.yml** - Human-readable names
   ```yaml
   en:
     flavours:
       bird-ui:
         name: "Bird UI"
         description: "..."
     skins:
       bird-ui:
         default: "Dark"
         light: "Light"
   ```

3. **Entry points** - SCSS/JS files in `entrypoints/`
   ```
   entrypoints/
   └── application.tsx
   ```

## Skin Registration

Skins are auto-discovered from `app/javascript/skins/{flavour}/{skin}/`

Requirements:
- Must contain at least one of: `common.scss`, `index.scss`, `application.scss`
- Flat directory structure (no subdirectories)

Bird UI skins:
```
skins/bird-ui/
├── default/
│   ├── index.scss       ← Main dark theme
│   └── common.scss      ← Shared styles
├── light/
│   └── index.scss
├── contrast/
│   └── index.scss
└── accessible/
    └── index.scss
```

## CSS Variables Strategy

Bird UI uses CSS custom properties for theming:

```scss
// Defined in each skin's index.scss
:root {
  --color-primary: #1d9bf0;
  --color-background: #0f1419;
  --color-text-primary: #e7e9ea;
  /* ... etc ... */
}
```

Used in flavour styles:
```scss
body {
  background-color: var(--color-background);
  color: var(--color-text-primary);
}
```

Benefits:
- ✅ Skins don't duplicate component styles
- ✅ Easy theme switching at runtime
- ✅ Minimal CSS file size

## Entry Points

Three entry points for different use cases:

### 1. bird-ui-auto.scss
- **Purpose**: Respects user's OS preference + Mastodon setting
- **Usage**: Default for most users
- **Theme switching**: Auto-respects `[data-color-scheme]` attribute

### 2. bird-ui-accessible.scss  
- **Purpose**: Accessible theme with enhanced contrast
- **Usage**: For users with mild vision impairment

### 3. bird-ui-accessible-plus.scss
- **Purpose**: Maximum contrast + larger text
- **Usage**: For users with serious vision impairment

## Installation Flow

```
install.sh
├── Validation
│   ├── Check path is valid Mastodon/Glitch
│   └── Verify directory structure exists
│
├── Backup
│   └── Create timestamped backup of current installation
│
├── Copy Files
│   ├── Copy flavour → app/javascript/flavours/bird-ui/
│   ├── Copy skins → app/javascript/skins/bird-ui/
│   └── Copy entry points → app/javascript/styles/
│
├── Configuration
│   ├── Update config/themes.yml
│   ├── Update config/locales/*.yml
│   └── Set file permissions
│
└── Output
    └── Display next steps to user
```

## File Ownership

After installation, files must be owned by the Mastodon user:

```bash
sudo chown -R mastodon:mastodon /opt/mastodon/app/javascript/flavours/bird-ui
sudo chown -R mastodon:mastodon /opt/mastodon/app/javascript/skins/bird-ui
```

The installation script handles this automatically.

## Asset Compilation

After installation, assets must be recompiled:

```bash
RAILS_ENV=production bundle exec rails assets:precompile
```

This:
1. Discovers all themes via `app/lib/themes.rb`
2. Compiles each theme's entry point
3. Generates CSS/JS bundles in `public/packs/`
4. Creates manifest for serving correct assets

## Localization

Theme names are localized via `config/locales/*.yml`:

```yaml
# config/locales/en.yml
themes:
  bird-ui-auto: Mastodon Bird UI
  bird-ui-accessible: Mastodon Bird UI (Accessible)
```

The `themes:` section key maps to theme names in `config/themes.yml`.

## Compatibility

### ✅ Compatible
- ✅ Glitch Soc v4.7.0-alpha.1+
- ✅ Mastodon v4.0+
- ✅ All existing flavours (glitch, vanilla)
- ✅ All existing skins
- ✅ Vanilla Mastodon instances (if Bird UI deployed)

### ⚠️ Notes
- Requires React (already in Mastodon)
- Requires SCSS compiler (already in build process)
- No breaking changes to core

## Performance Considerations

### CSS Bundle Sizes
- **Default (Dark)**: ~45KB minified
- **Light**: +5KB (incremental changes only)
- **Contrast**: +3KB
- **Accessible**: +8KB

### Loading
- Themes are loaded per-user setting
- Only selected theme's CSS is sent to browser
- Skins use CSS variables (minimal recomputation)

### Memory
- No server-side memory increase
- Client-side: standard CSS overhead

## Troubleshooting Architecture Issues

### Theme not appearing
1. Check `app/lib/themes.rb` discovered themes
2. Verify `theme.yml` exists and is valid YAML
3. Verify `entrypoints/application.tsx` exists
4. Check assets were recompiled

### Skin not loading
1. Check skin directory structure
2. Verify `index.scss` or `common.scss` exists
3. Check `config/themes.yml` for skin reference
4. Clear asset cache and recompile

### Permission errors
1. Check file ownership: `ls -la app/javascript/flavours/bird-ui/`
2. Fix if needed: `sudo chown -R mastodon:mastodon <path>`
3. Verify read permissions: `chmod a+r`

## Future Enhancements

- [ ] Theme editor UI
- [ ] Live theme preview
- [ ] Additional skin variations
- [ ] Component animation options
- [ ] Accessibility audits

## References

- [Glitch Soc Documentation](https://glitch-soc.github.io/docs/)
- [Mastodon Themes System](https://github.com/mastodon/mastodon/tree/main/app/lib)
- [Bird UI Original](https://github.com/rollecode/mastodon-bird-ui)
