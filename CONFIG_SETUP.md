# Configuration Setup Guide

⚠️ **IMPORTANT**: This repository has had all API keys and credentials removed for security.

## Required Configuration Before Building

### 1. Supabase Configuration
Edit `Thaqalayn/Config.swift` and replace the following placeholders:

```swift
static let supabaseURL = "YOUR_SUPABASE_URL_HERE"
static let supabaseAnonKey = "YOUR_SUPABASE_ANON_KEY_HERE"
```

**How to get your Supabase credentials:**
1. Go to [supabase.com](https://supabase.com)
2. Navigate to your project dashboard
3. Go to **Settings** → **API**
4. Copy **Project URL** and **anon/public key**

### 2. Project Information
Update the project information in `Config.swift`:

```swift
static let projectInfo = ProjectInfo(
    id: "YOUR_PROJECT_ID_HERE",
    name: "Thaqalayn",
    region: "us-east-1",
    organizationId: "YOUR_ORGANIZATION_ID_HERE"
)
```

## Example Config.swift

```swift
struct Config {
    // MARK: - Supabase Configuration
    static let supabaseURL = "https://your-project.supabase.co"
    static let supabaseAnonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    
    // MARK: - Project Information
    static let projectInfo = ProjectInfo(
        id: "your-project-id",
        name: "Thaqalayn",
        region: "us-east-1",
        organizationId: "your-org-id"
    )
}
```

## Security Best Practices

1. **Never commit API keys** to public repositories
2. **Use environment variables** in production
3. **Keep credentials in secure storage**
4. **Regenerate keys** if accidentally exposed

## Building the App

After adding your configuration:
1. Open `Thaqalayn.xcodeproj` in Xcode
2. Build and run the project
3. All features will work with your Supabase backend

## Need Help?

- Supabase documentation: https://supabase.com/docs
- Check `CLAUDE.md` for complete project information