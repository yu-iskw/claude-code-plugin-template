# Multi-Platform Marketplace Deployment Guide

This guide explains how to configure and deploy your plugins to the Claude Code, Cursor, and OpenAI Codex marketplaces.

## Overview

The template supports unified marketplace configuration that generates platform-specific marketplace metadata for all three AI coding assistant platforms. You define your marketplace information once in `plugin-config.json` and the build system generates platform-specific configurations.

## Quick Start

### 1. Add Marketplace Configuration

Update your plugin's `plugin-config.json` to include marketplace metadata:

```json
{
  "name": "my-plugin",
  "version": "1.0.0",
  "description": "My awesome plugin",
  "author": {"name": "Your Name"},
  "license": "Apache-2.0",
  "repository": "https://github.com/you/my-plugin",
  
  "platforms": {
    "claude": {"enabled": true},
    "cursor": {"enabled": true},
    "codex": {"enabled": true}
  },
  
  "marketplace": {
    "claude": {
      "enabled": true,
      "tags": ["productivity", "development"],
      "icons": {
        "light": "./assets/icon-light.png",
        "dark": "./assets/icon-dark.png"
      },
      "screenshots": [
        "./assets/screenshot-1.png",
        "./assets/screenshot-2.png"
      ],
      "privacyPolicy": "https://example.com/privacy",
      "termsOfService": "https://example.com/terms"
    },
    "cursor": {
      "enabled": true,
      "tags": ["productivity", "development"],
      "icons": {
        "light": "./assets/icon-light.png",
        "dark": "./assets/icon-dark.png"
      }
    },
    "codex": {
      "enabled": true,
      "tags": ["productivity"],
      "icons": {
        "default": "./assets/icon.png"
      }
    }
  }
}
```

### 2. Generate Marketplace Configurations

Generate platform-specific marketplace JSON files:

```bash
make generate-marketplace
```

This creates:
- `.claude-plugin/marketplace.json`
- `.cursor-plugin/marketplace.json`
- `.codex-plugin/marketplace.json`

### 3. Validate Marketplace Configurations

Ensure all marketplace configurations are valid:

```bash
make validate-marketplace
```

This checks:
- ✅ Valid JSON syntax
- ✅ Required fields present
- ✅ Asset files exist
- ✅ Proper formatting for each platform

## Marketplace Configuration Schema

### Common Fields (All Platforms)

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | ✅ | Plugin name (inherited from plugin-config.json) |
| `version` | string | ✅ | Plugin version (inherited from plugin-config.json) |
| `description` | string | ✅ | Short description (inherited from plugin-config.json) |
| `tags` | string[] | ❌ | Search tags for marketplace discovery |
| `icons` | object | ❌ | Icon URLs for marketplace display |
| `license` | string | ❌ | Plugin license (inherited if not specified) |
| `repository` | string | ❌ | Repository URL (inherited if not specified) |

### Platform-Specific Fields

#### Claude Code Marketplace

```json
{
  "marketplace": {
    "claude": {
      "enabled": true,
      "tags": ["dev-tools", "productivity"],
      "icons": {
        "light": "./assets/icon-light.png",
        "dark": "./assets/icon-dark.png"
      },
      "screenshots": ["./assets/screenshot-1.png"],
      "privacyPolicy": "https://example.com/privacy",
      "termsOfService": "https://example.com/terms",
      "categories": ["development", "productivity"],
      "author": {
        "name": "Your Name",
        "email": "email@example.com",
        "url": "https://example.com"
      }
    }
  }
}
```

**Icon Requirements:**
- Light icon: 256x256px, light background
- Dark icon: 256x256px, dark background
- Format: PNG with transparency

**Screenshot Requirements:**
- Size: 1280x720px or similar aspect ratio
- Format: PNG or JPG
- Count: 1-5 recommended

#### Cursor Marketplace

```json
{
  "marketplace": {
    "cursor": {
      "enabled": true,
      "tags": ["dev-tools", "productivity"],
      "icons": {
        "light": "./assets/icon-light.png",
        "dark": "./assets/icon-dark.png"
      },
      "categories": ["development"],
      "popularity": "trending"
    }
  }
}
```

**Icon Requirements:**
- Similar to Claude Code
- 256x256px PNG with transparency

#### Codex Marketplace

```json
{
  "marketplace": {
    "codex": {
      "enabled": true,
      "tags": ["dev-tools"],
      "icons": {
        "default": "./assets/icon.png"
      },
      "keywords": ["development", "productivity"],
      "pricing": "free"
    }
  }
}
```

**Icon Requirements:**
- Single icon: 256x256px minimum
- Format: PNG with transparency

## Publishing to Marketplaces

### Claude Code Marketplace

1. **Prepare your plugin:**
   ```bash
   make generate-manifests
   make generate-marketplace
   make validate-marketplace
   ```

2. **Package your plugin:**
   ```bash
   cd plugins/my-plugin
   zip -r ../my-plugin.zip .
   ```

3. **Submit to marketplace:**
   - Visit [Claude Code Plugin Marketplace](https://code.claude.com/plugins)
   - Sign in with your Anthropic account
   - Click "Submit Plugin"
   - Upload your plugin package
   - Fill in marketplace metadata from `.claude-plugin/marketplace.json`
   - Review and submit for approval

4. **Monitor approval:**
   - Check email for approval/feedback
   - Typical approval time: 2-7 days

### Cursor Marketplace

1. **Prepare your plugin:**
   ```bash
   make generate-manifests
   make generate-marketplace
   make validate-marketplace
   ```

2. **Verify Cursor manifest:**
   - Ensure `.cursor-plugin/plugin.json` exists
   - Plugin name must be in kebab-case
   - Verify all required fields are present

3. **Submit to marketplace:**
   - Visit [Cursor Plugin Marketplace](https://cursor.com/plugins)
   - Sign in with your Cursor account
   - Click "Publish Plugin"
   - Upload `.cursor-plugin/` directory
   - Fill in marketplace information
   - Submit for review

4. **Installation by users:**
   - Users can find your plugin in marketplace
   - One-click install in Cursor settings
   - Automatic updates

### OpenAI Codex Marketplace

1. **Prepare your plugin:**
   ```bash
   make generate-manifests
   make generate-marketplace
   make validate-marketplace
   ```

2. **Verify Codex manifest:**
   - Ensure `.codex-plugin/plugin.json` exists
   - Includes required `skills` field
   - All required marketplace fields present

3. **Submit to marketplace:**
   - Visit [OpenAI Codex Plugins](https://developers.openai.com/codex/plugins)
   - Sign in with your OpenAI account
   - Click "Publish Plugin"
   - Upload plugin files and marketplace JSON
   - Complete marketplace submission form
   - Submit for review

4. **Integration:**
   - Review typically takes 5-14 days
   - Once approved, available to Codex users
   - Will appear in plugin discovery

## Asset Management

### Directory Structure

Recommended structure for marketplace assets:

```
plugins/my-plugin/
├── assets/
│   ├── icon-light.png      # Light theme icon (256x256)
│   ├── icon-dark.png       # Dark theme icon (256x256)
│   ├── icon.png            # Fallback icon (256x256)
│   └── screenshots/
│       ├── screenshot-1.png
│       ├── screenshot-2.png
│       └── screenshot-3.png
├── plugin-config.json
└── ...
```

### Asset Path References

In `plugin-config.json`, use relative paths from plugin root:

```json
{
  "marketplace": {
    "claude": {
      "icons": {
        "light": "./assets/icon-light.png",
        "dark": "./assets/icon-dark.png"
      },
      "screenshots": [
        "./assets/screenshots/screenshot-1.png",
        "./assets/screenshots/screenshot-2.png"
      ]
    }
  }
}
```

## Versioning & Updates

### Semantic Versioning

Follow semantic versioning for releases:

```
MAJOR.MINOR.PATCH
```

- **MAJOR**: Breaking changes to plugin interface
- **MINOR**: New features, backward compatible
- **PATCH**: Bug fixes

### Update Process

1. **Update version in `plugin-config.json`:**
   ```json
   {
     "version": "1.2.0"
   }
   ```

2. **Regenerate marketplace configs:**
   ```bash
   make generate-marketplace
   ```

3. **Re-publish to marketplaces:**
   - Each marketplace handles updates differently
   - Some auto-update from package, others require re-submission
   - Check marketplace documentation for update process

## Best Practices

### Plugin Naming

- ✅ **DO**: Use descriptive, lowercase names with hyphens
  - `code-formatter`, `test-runner`, `documentation-helper`
- ❌ **DON'T**: Use generic, vague, or uppercase names
  - `tool`, `plugin`, `MYNEWTOOL`

### Descriptions

- ✅ **DO**: Write clear, concise descriptions (50-150 characters)
  - "Automatically format code using industry standards"
- ❌ **DON'T**: Be vague or include too much detail
  - "A plugin that does things"

### Tags

- ✅ **DO**: Use 3-5 relevant, searchable tags
  - `["productivity", "development", "automation"]`
- ❌ **DON'T**: Use too many or irrelevant tags
  - `["awesome", "cool", "new", "best"]`

### Icons & Screenshots

- ✅ **DO**: Use high-quality, professional visuals
  - Clear icons, professional screenshots
- ❌ **DON'T**: Use low-resolution or unprofessional images
  - Blurry icons, cluttered screenshots

### Documentation

- Link to comprehensive README in your repository
- Include usage examples and API documentation
- Maintain clear contribution guidelines
- Keep changelog updated with releases

## Troubleshooting

### "Invalid JSON in marketplace config"

**Problem**: Generated marketplace JSON is malformed

**Solution**:
1. Check your `plugin-config.json` is valid JSON
2. Run `make validate-marketplace` for details
3. Verify all file paths in icons/screenshots exist

### "Required field missing"

**Problem**: Marketplace config is missing required fields

**Solution**:
- Ensure your `plugin-config.json` includes:
  - `name`, `version`, `description`
  - All required marketplace-specific fields
- Run `make validate-marketplace` to see which field is missing

### "Icon file not found"

**Problem**: Asset file referenced in config doesn't exist

**Solution**:
1. Verify file exists at path specified
2. Use relative paths from plugin root
3. Check file name capitalization and extension

### "Submission rejected by marketplace"

**Problem**: Marketplace team rejected your plugin

**Common reasons**:
- Policy violation (malware, illegal content, etc.)
- Quality issues (incomplete documentation, poor UX)
- Configuration errors (invalid metadata, missing fields)
- Platform-specific restrictions

**Solution**:
- Review marketplace guidelines carefully
- Check rejection feedback email
- Fix reported issues
- Resubmit with improvements

## FAQ

**Q: Can I deploy to one marketplace but not others?**

A: Yes! Set `enabled: false` in the marketplace section for platforms you don't want to target.

```json
{
  "marketplace": {
    "claude": {"enabled": true},
    "cursor": {"enabled": false},
    "codex": {"enabled": false}
  }
}
```

**Q: How long does marketplace approval typically take?**

A: 
- Claude Code: 2-7 days
- Cursor: 1-3 days
- Codex: 5-14 days

**Q: Can I update my plugin after submission?**

A: Yes, but it depends on the marketplace:
- Some auto-update from source
- Others require re-submission
- Check each marketplace's update policy

**Q: What if my plugin gets rejected?**

A: 
1. Check rejection email for specific reason
2. Review marketplace's plugin policies
3. Fix reported issues
4. Resubmit to marketplace

**Q: Do I need separate icons for each platform?**

A: No, but it's recommended for best results:
- Claude Code: Light & dark variants
- Cursor: Light & dark variants
- Codex: Single icon is fine

**Q: How do I handle authentication/credentials?**

A: Use environment variables or secure credential storage:
- Document in README
- Never commit API keys
- Use `.env` files (in `.gitignore`)
- Document setup process for users

## Resources

- [Claude Code Plugin Documentation](https://code.claude.com/docs/en/plugins)
- [Cursor Plugin Documentation](https://cursor.com/docs/plugins)
- [OpenAI Codex Plugin Documentation](https://developers.openai.com/codex/plugins/build)
- [Semantic Versioning](https://semver.org/)
- [How to Write Good Documentation](https://www.wikihow.com/Write-Good-Documentation)
