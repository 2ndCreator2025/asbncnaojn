# flutter_testflight_app

A Flutter project with automated TestFlight deployment via GitHub Actions using Fastlane.

## Getting Started

This project is a starting point for a Flutter application with CI/CD pipeline to TestFlight using Fastlane for iOS deployment automation.

### Prerequisites

1. Flutter SDK installed
2. Xcode installed (for iOS development)
3. Apple Developer Account
4. App Store Connect API Key
5. Ruby and Bundler (for Fastlane)

### GitHub Secrets Setup

To use the GitHub Actions workflow for TestFlight deployment, you need to add the following secrets to your GitHub repository:

1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Add the following repository secrets:

- `API_KEY_ID`: Your App Store Connect API Key ID
- `APPLE_ID`: Your app's Apple ID from App Store Connect
- `ISSUER_ID`: Your App Store Connect API Issuer ID
- `PRIVATE_KEY_FILE`: Your App Store Connect API private key content (the .p8 file content)

### App Store Connect API Key Setup

1. Go to [App Store Connect](https://appstoreconnect.apple.com/)
2. Navigate to Users and Access → Keys
3. Create a new API key with App Manager or Developer role
4. Download the .p8 file and note the Key ID and Issuer ID

### iOS App Configuration

1. **Open project in Xcode**: `ios/Runner.xcworkspace`
2. **Configure Bundle Identifier**: 
   - Select Runner project → Runner target → General tab
   - Change Bundle Identifier from `com.example.flutterTestflightApp` to your unique identifier (e.g., `com.yourcompany.yourapp`)
3. **Set up code signing**:
   - Go to Signing & Capabilities tab
   - Enable "Automatically manage signing"
   - Select your Apple Developer team
4. **Create app record in App Store Connect**:
   - Go to [App Store Connect](https://appstoreconnect.apple.com/)
   - Create a new app with the same Bundle Identifier
5. **Update Fastlane configuration**:
   - Edit `ios/fastlane/Appfile` with your bundle identifier and Apple ID email

### Fastlane Setup

Fastlane is already initialized in this project. To configure it:

1. Edit `ios/fastlane/Appfile`:
   ```ruby
   app_identifier("com.yourcompany.yourapp") # Your bundle identifier
   apple_id("your_email@example.com") # Your Apple Developer account email
   ```

2. Available Fastlane lanes:
   ```bash
   cd ios
   
   # Build and upload to TestFlight
   bundle exec fastlane beta
   
   # Build only (no upload)
   bundle exec fastlane build_only
   
   # Setup certificates (if using match)
   bundle exec fastlane certificates
   ```

### Running the Project

```bash
flutter pub get
flutter run
```

### Manual Build and Upload

```bash
# Using Fastlane (recommended)
cd ios
bundle exec fastlane beta

# Or build for iOS manually
flutter build ios --release
```

### GitHub Actions Workflow

The workflow (`.github/workflows/testflight.yml`) will:

1. Setup Flutter and dependencies
2. Run Flutter tests
3. Setup Ruby and install Fastlane
4. Use Fastlane to build and upload to TestFlight
   - Build Flutter app for iOS
   - Archive the app using Xcode
   - Export the IPA file
   - Upload to TestFlight using App Store Connect API

The workflow triggers on:
- Push to main branch
- Pull requests to main branch
- Manual dispatch

## Troubleshooting

### "No profiles for 'com.example.flutterTestflightApp' were found"

This error occurs when there's no provisioning profile for your bundle identifier. To fix:

1. **Change the Bundle Identifier**:
   - Open `ios/Runner.xcworkspace` in Xcode
   - Select Runner project → Runner target → General tab
   - Change Bundle Identifier to something unique (e.g., `com.yourcompany.yourapp`)
   - Update `ios/fastlane/Appfile` with the new identifier

2. **Enable Automatic Code Signing**:
   - In Xcode, go to Signing & Capabilities tab
   - Check "Automatically manage signing"
   - Select your Apple Developer team

3. **Create App in App Store Connect**:
   - Go to App Store Connect and create a new app
   - Use the same Bundle Identifier as in Xcode

### Alternative: Use Manual Code Signing

If you prefer manual code signing, use the `beta_manual` lane:
```bash
cd ios
bundle exec fastlane beta_manual
```

This requires setting up provisioning profiles manually in Apple Developer Portal.

## Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [App Store Connect API Documentation](https://developer.apple.com/documentation/appstoreconnectapi)
- [TestFlight Documentation](https://developer.apple.com/testflight/)
- [Fastlane Documentation](https://docs.fastlane.tools/)
- [Fastlane iOS Beta Deployment](https://docs.fastlane.tools/getting-started/ios/beta-deployment/)
# asbncnaojn
