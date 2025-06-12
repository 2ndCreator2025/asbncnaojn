# 🚀 TestFlight Deployment Setup Guide

This guide will help you set up automated TestFlight deployment for your Flutter app using GitHub Actions.

## 📋 Prerequisites

1. **Apple Developer Account** with App Store Connect access
2. **App Store Connect API Key** (see steps below)
3. **Xcode project** properly configured with Bundle ID
4. **GitHub repository** with your Flutter project

## 🔑 Step 1: Create App Store Connect API Key

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **Users and Access** → **Integrations** → **App Store Connect API**
3. Click **Generate API Key**
4. Set the following:
   - **Name**: GitHub Actions TestFlight
   - **Access**: App Manager or Developer
5. **Download the .p8 file** (you can only download it once!)
6. Note down:
   - **Key ID** (10-character string)
   - **Issuer ID** (UUID format)
   - **Team ID** (10-character alphanumeric)

## 🔧 Step 2: Configure GitHub Secrets

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Add the following **Repository secrets**:

### Required Secrets:

#### `APPLE_API_PRIVATE_KEY`
**Option 1: Direct paste (with \n characters):**
```
-----BEGIN PRIVATE KEY-----\nYOUR_PRIVATE_KEY_CONTENT_HERE\n-----END PRIVATE KEY-----
```

**Option 2: From .p8 file:**
```bash
# Replace \n with literal \n characters:
cat /path/to/AuthKey_XXXXXXXXXX.p8 | tr '\n' '\n' | sed 's/$/\\n/g' | tr -d '\n'
```

Paste the result as the secret value (it should contain literal `\n` characters).

#### `API_KEY_ID`
The 10-character Key ID from App Store Connect (e.g., `ABC123DEFG`)

#### `ISSUER_ID`
The UUID Issuer ID from App Store Connect (e.g., `12345678-1234-1234-1234-123456789012`)

#### `TEAM_ID`
Your Apple Developer Team ID (e.g., `ABC123DEFG`)

#### `APP_ID`
Your app's Bundle Identifier from `ios/Runner/Info.plist` (e.g., `com.yourcompany.yourapp`)

## 📱 Step 3: Configure Your App

### Update Bundle ID
Edit `ios/Runner/Info.plist` and replace the Bundle Identifier:
```xml
<key>CFBundleIdentifier</key>
<string>com.yourcompany.yourapp</string>
```

### Update App Name
```xml
<key>CFBundleName</key>
<string>Your App Name</string>
<key>CFBundleDisplayName</key>
<string>Your App Display Name</string>
```

## 🚀 Step 4: Deploy

1. **Push to main branch**:
   ```bash
   git add .
   git commit -m "Setup TestFlight deployment"
   git push origin main
   ```

2. **Or trigger manually**:
   - Go to **Actions** tab in GitHub
   - Select **🚀 TestFlight iOS Deploy**
   - Click **Run workflow**

## 📊 Step 5: Monitor Deployment

1. **GitHub Actions**: Monitor the workflow progress in the Actions tab
2. **App Store Connect**: Check [TestFlight section](https://appstoreconnect.apple.com) for processing status
3. **Processing time**: Usually takes 10-30 minutes for Apple to process your build

## 🛠️ Troubleshooting

### Common Issues:

#### "Invalid authentication key credential"
- **Problem**: API key is not properly base64 encoded
- **Solution**: Re-encode your .p8 file: `base64 -i AuthKey_XXXXXXXXXX.p8`

#### "No profiles for the bundle identifier"
- **Problem**: Bundle ID not registered in App Store Connect
- **Solution**: Create app in App Store Connect with matching Bundle ID

#### "Build number already exists"
- **Problem**: Duplicate build number
- **Solution**: Increment version in `pubspec.yaml` or use manual workflow trigger

#### "Team ID not found"
- **Problem**: Incorrect Team ID
- **Solution**: Get Team ID from Apple Developer portal → Membership

### Debug Commands:

```bash
# Check your current Bundle ID
plutil -extract CFBundleIdentifier raw ios/Runner/Info.plist

# Verify Flutter setup
flutter doctor -v

# Test iOS build locally
flutter build ios --release --no-codesign
```

## 📚 Additional Resources

- [App Store Connect API Documentation](https://developer.apple.com/documentation/appstoreconnectapi)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Flutter iOS Deployment Guide](https://docs.flutter.dev/deployment/ios)

## 🎉 Success!

Once your workflow runs successfully:
1. Your app will be uploaded to TestFlight
2. You can add internal/external testers in App Store Connect
3. Testers will receive notifications to install your app

---

💡 **Tip**: Save your .p8 file securely! You can only download it once from App Store Connect.

