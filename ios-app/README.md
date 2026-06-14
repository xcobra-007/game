# دومنة المناويج — iPhone app (Capacitor)

This wraps the single-file web game (`../dominoes.html`) into a native iOS app
using [Capacitor](https://capacitorjs.com). The web game is loaded inside a
`WKWebView`, just like the Android version.

> ⚠️ Building and running an iPhone app **requires a Mac with Xcode**. You cannot
> produce an `.ipa` on Linux/Windows. The steps below are run on a Mac.

## What's here

```
ios-app/
├── package.json            # Capacitor dependencies + helper scripts
├── capacitor.config.json   # appId, appName, webDir
├── scripts/sync-web.js     # copies ../dominoes.html -> www/index.html
├── www/                    # web root (index.html is generated, gitignored)
└── ios/                    # the native Xcode project (App.xcworkspace)
```

- **App ID:** `com.manawij.dominoes`
- **App name:** دومنة المناويج
- **Orientation:** portrait (iPhone)

## One-time setup on your Mac

1. Install prerequisites:
   - **Xcode** (from the App Store) + Command Line Tools
   - **Node.js 18+**
   - **CocoaPods**: `sudo gem install cocoapods`
2. From this folder:
   ```bash
   npm install
   npm run sync-web        # copies the latest game into www/index.html
   npx cap sync ios        # installs pods + copies web assets into the iOS project
   ```

## Build & run

Open the project in Xcode:
```bash
npx cap open ios
```
Then in Xcode:
1. Select the **App** target → **Signing & Capabilities** → choose your **Team**
   (a free Apple ID works for running on your own device; the **Apple Developer
   Program**, $99/yr, is required for TestFlight / App Store).
2. Pick your iPhone (or a Simulator) as the run destination.
3. Press **Run** (▶). To run on a physical device you'll trust the developer
   profile under *Settings → General → VPN & Device Management* on the phone.

## Updating the game

Whenever `../dominoes.html` changes, refresh the app contents:
```bash
npm run prepare-ios     # = sync-web + cap sync ios
```
then re-run from Xcode.

## App icon (optional)

To generate iOS icons from a single source image, you can use
[`@capacitor/assets`](https://github.com/ionic-team/capacitor-assets):
```bash
npm i -D @capacitor/assets
# place a 1024x1024 icon at resources/icon.png, then:
npx capacitor-assets generate --ios
```

## Notes / limitations

- Online multiplayer (PeerJS) and the web fonts need an internet connection.
  **1v1 vs AI works offline.** To make the app fully offline, the fonts and
  PeerJS would need to be inlined into `dominoes.html`.
- Apple may scrutinize simple "website in a webview" apps (App Review
  guideline 4.2). A real game with multiplayer generally qualifies.
