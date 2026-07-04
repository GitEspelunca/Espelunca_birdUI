# Customization Guide - Bird UI for Glitch Soc

## Overview

Bird UI is highly customizable. You can modify:
- Color schemes
- Component styling
- Layout dimensions
- Typography
- Animations
- Responsive breakpoints

## Customizing Colors

### Method 1: Edit Skin CSS Variables

The easiest way to customize colors. Each skin defines CSS variables:

```bash
vim /opt/mastodon/app/javascript/skins/bird-ui/default/index.scss
```

Example variables:

```scss
:root {
  --color-primary: #1d9bf0;           /* Blue accent */
  --color-background: #0f1419;        /* Dark background */
  --color-text-primary: #e7e9ea;      /* Primary text */
  --color-text-secondary: #71767b;    /* Secondary text */
  --color-border: #2f3336;            /* Border color */
  --color-hover: rgba(255, 255, 255, 0.1); /* Hover effect */
}
```

Change values, save, and recompile:

```bash
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart mastodon-web
```

### Method 2: Create Custom Skin

Create a new skin without modifying existing ones:

```bash
mkdir -p /opt/mastodon/app/javascript/skins/bird-ui/my-custom-skin
```

Create `/opt/mastodon/app/javascript/skins/bird-ui/my-custom-skin/index.scss`:

```scss
:root {
  /* Your custom colors */
  --color-primary: #ff0000;           /* Red instead of blue */
  --color-background: #1a1a1a;        /* Darker background */
  --color-text-primary: #ffffff;
  --color-text-secondary: #cccccc;
  --color-border: #333333;
  --color-hover: rgba(255, 255, 255, 0.15);
  --color-success: #00cc00;           /* Green */
  --color-error: #ff4444;             /* Red */
  --color-warning: #ffaa00;           /* Orange */
}
```

Recompile and the skin will appear automatically:

```bash
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:precompile
```

Your new skin will appear in **Preferences > Appearance > Theme** as "My Custom Skin".

## Customizing Typography

### Font Family

Edit `/opt/mastodon/app/javascript/flavours/bird-ui/styles/variables/_typography.scss`:

```scss
@mixin define-typography {
  --font-family-base: 'Your Font', -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif;
  --font-family-mono: 'Courier New', monospace;
}
```

Or override in skin:

```scss
:root {
  --font-family-base: 'Segoe UI', 'Helvetica Neue', sans-serif;
}
```

### Font Sizes

Edit typography SCSS or override in skin:

```scss
:root {
  --font-size-xs: 12px;
  --font-size-sm: 13px;
  --font-size-md: 15px;    /* Default */
  --font-size-lg: 17px;
  --font-size-xl: 20px;
}
```

### Line Height

```scss
:root {
  --line-height-tight: 1.2;
  --line-height-normal: 1.5;   /* Default */
  --line-height-loose: 1.8;
}
```

## Customizing Layout

### Sidebar Width

Edit `/opt/mastodon/app/javascript/flavours/bird-ui/styles/layouts/_main.scss`:

```scss
.drawer {
  width: 275px;  /* Change this */
  min-width: 275px;
}
```

### Responsive Breakpoints

Edit mobile styles:

```scss
@media (max-width: 700px) {  /* Change breakpoint */
  .columns-area {
    flex-direction: column;
  }
}
```

### Component Spacing

Edit `/opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_status.scss`:

```scss
.status {
  padding: 12px 16px;  /* Change padding */
  gap: 12px;           /* Change gap */
}
```

## Customizing Components

### Status Card Styling

File: `/opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_status.scss`

Example modifications:

```scss
.status {
  border-radius: 8px;              /* Add rounded corners */
  background-color: #16202b;       /* Add background color */
  box-shadow: 0 1px 3px rgba(0,0,0,0.2); /* Add shadow */
  margin-bottom: 8px;              /* Add margin between items */
}

.status:hover {
  background-color: #1e2938;       /* Change hover color */
  box-shadow: 0 2px 6px rgba(0,0,0,0.3);
}
```

### Avatar Styling

File: `/opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_avatar.scss`

```scss
.avatar {
  border: 2px solid var(--color-primary);  /* Add border */
  box-shadow: 0 0 8px rgba(29, 155, 240, 0.3); /* Add glow */
  
  &--size-lg {
    width: 56px;  /* Make larger */
    height: 56px;
  }
}
```

### Button Styling

File: `/opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_button.scss`

```scss
.button--primary {
  border-radius: 25px;           /* More rounded */
  padding: 10px 20px;            /* More padding */
  font-weight: 600;              /* Bolder */
  box-shadow: 0 1px 3px rgba(0,0,0,0.2);
  
  &:hover {
    transform: translateY(-2px);  /* Lift effect */
    box-shadow: 0 4px 8px rgba(0,0,0,0.3);
  }
}
```

## Customizing Animations

### Transition Speeds

File: `/opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_status.scss`

```scss
.status {
  transition: background-color 0.1s ease;  /* Faster */
  /* or */
  transition: background-color 0.5s ease;  /* Slower */
}
```

### Adding Animations

Create new animation in skin:

```scss
@keyframes slideInLeft {
  from {
    opacity: 0;
    transform: translateX(-20px);
  }
  to {
    opacity: 1;
    transform: translateX(0);
  }
}

.status {
  animation: slideInLeft 0.3s ease;
}
```

### Remove Animations

For users with motion sensitivity:

```scss
@media (prefers-reduced-motion: reduce) {
  * {
    animation: none !important;
    transition: none !important;
  }
}
```

## Customizing Dark/Light Mode

### Edit Light Theme

File: `/opt/mastodon/app/javascript/flavours/bird-ui/styles/themes/_light.scss`

```scss
@mixin apply-theme {
  background-color: #f5f5f5;    /* Slightly gray instead of white */
  color: #1a1a1a;               /* Darker text */
  
  --color-background: #f5f5f5;
  --color-text-primary: #1a1a1a;
  --color-border: #d0d0d0;      /* Lighter border */
}
```

### Edit Dark Theme

File: `/opt/mastodon/app/javascript/flavours/bird-ui/styles/themes/_dark.scss`

```scss
@mixin apply-theme {
  background-color: #050505;     /* Blacker background */
  color: #f0f0f0;
  
  --color-background: #050505;
  --color-text-primary: #f0f0f0;
  --color-border: #1a1a1a;       /* Very dark border */
}
```

## Customizing High Contrast Theme

File: `/opt/mastodon/app/javascript/skins/bird-ui/contrast/index.scss`

```scss
:root {
  /* Maximum contrast for accessibility */
  --color-primary: #0000ff;           /* Pure blue */
  --color-background: #000000;        /* Pure black */
  --color-text-primary: #ffffff;      /* Pure white */
  --color-border: #ffffff;            /* White borders */
  --color-success: #00aa00;           /* Bright green */
  --color-error: #ff0000;             /* Bright red */
  --color-warning: #ffff00;           /* Bright yellow */
}
```

## Adding Custom SCSS Modules

### Create New Component Style

1. Create file: `/opt/mastodon/app/javascript/flavours/bird-ui/styles/components/_my-component.scss`

```scss
.my-component {
  display: flex;
  gap: var(--spacing-md, 12px);
  padding: var(--spacing-lg, 16px);
  border-radius: 8px;
  background-color: var(--color-background-secondary);
  
  &:hover {
    background-color: var(--color-hover);
  }
}
```

2. Import in `/opt/mastodon/app/javascript/flavours/bird-ui/styles/bird-ui.scss`:

```scss
@use './components/my-component';
```

3. Recompile:

```bash
cd /opt/mastodon && RAILS_ENV=production bundle exec rails assets:precompile
```

## Using CSS Custom Properties

Bird UI provides these variables:

```scss
/* Colors */
--color-primary
--color-background
--color-background-secondary
--color-text-primary
--color-text-secondary
--color-border
--color-hover

/* Typography */
--font-family-base
--font-size-md
--line-height-normal

/* Spacing */
--spacing-xs
--spacing-sm
--spacing-md
--spacing-lg
--spacing-xl
```

Use them in your custom styles:

```scss
.my-element {
  background-color: var(--color-background);
  color: var(--color-text-primary);
  padding: var(--spacing-lg);
  font-family: var(--font-family-base);
}
```

## Testing Your Changes

### Development Mode

```bash
cd /opt/mastodon
RAILS_ENV=development bundle exec rails assets:precompile
sudo systemctl restart mastodon-web
```

### Hot Reload (with Webpack)

```bash
cd /opt/mastodon
./bin/webpack-dev-server  # In separate terminal
```

Then browse and changes reload automatically.

### Production Build

```bash
cd /opt/mastodon
RAILS_ENV=production bundle exec rails assets:clobber
RAILS_ENV=production bundle exec rails assets:precompile
sudo systemctl restart mastodon-web
```

## Tips & Best Practices

1. **Use CSS Variables**: Don't hardcode colors, use `var(--color-primary)` instead
2. **Test Accessibility**: Use high contrast mode and check readability
3. **Mobile First**: Design for mobile, then enhance for desktop
4. **Backup**: Always backup before major changes
5. **Version Control**: Track your changes in git
6. **Browser DevTools**: Use F12 to inspect and test styles live
7. **Reduce Motion**: Always include `@media (prefers-reduced-motion)`

## Example: Creating a Purple Theme

```bash
mkdir -p /opt/mastodon/app/javascript/skins/bird-ui/purple
```

Create file `/opt/mastodon/app/javascript/skins/bird-ui/purple/index.scss`:

```scss
:root {
  --color-primary: #9c27b0;           /* Purple */
  --color-primary-dark: #7b1fa2;
  --color-primary-light: #ba68c8;
  
  --color-background: #1a0d2e;        /* Dark purple */
  --color-background-secondary: #2d1b4e;
  --color-background-tertiary: #3d2663;
  
  --color-text-primary: #f3e5f5;      /* Light purple text */
  --color-text-secondary: #c2a0d0;
  --color-text-tertiary: #9973b3;
  
  --color-border: #4a2f6d;
  --color-hover: rgba(156, 39, 176, 0.1);
  --color-focus: rgba(156, 39, 176, 0.2);
}
```

Recompile and "Purple" theme appears in preferences!

## Getting Help

- Check [ARCHITECTURE.md](./ARCHITECTURE.md) for technical details
- Review existing styles for examples
- Open an issue on [GitHub](https://github.com/GitEspelunca/Espelunca_birdUI/issues)

## Related Documentation

- [Installation Guide](./INSTALLATION.md)
- [Architecture](./ARCHITECTURE.md)
- [FAQ](./FAQ.md)
- [Troubleshooting](./TROUBLESHOOTING.md)
