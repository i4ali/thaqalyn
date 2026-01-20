# How to Create Archive Build for App Store

## Step 1: Open Xcode Project
1. Open `Thaqalayn.xcodeproj` in Xcode
2. Select "Any iOS Device (arm64)" as the destination (NOT simulator)

## Step 2: Archive the App
1. In Xcode menu: **Product → Archive**
2. Wait for the build to complete
3. Xcode will automatically open the Organizer window

## Step 3: Upload to App Store Connect
1. In the Organizer window, select your archive
2. Click **"Distribute App"**
3. Select **"App Store Connect"**
4. Choose **"Upload"**
5. Follow the prompts to upload

## Step 4: Select Build in App Store Connect
1. Go back to App Store Connect
2. Navigate to your app → App Store → iOS App → Build
3. Select the uploaded build
4. Save changes

## Alternative: Command Line Archive
If you prefer command line, I can help you run:
```bash
xcodebuild -project Thaqalayn.xcodeproj -scheme Thaqalayn -destination generic/platform=iOS archive -archivePath build/Thaqalayn.xcarchive
```

Let me know if you'd like me to help with the command line approach!