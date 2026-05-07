<p align="center"><img width="128" height="128" alt="Frame 2147227910" src="https://github.com/user-attachments/assets/ee37ab6e-2903-4374-8ff1-b6ef071f28f7" /></p>

<h1 align="center">Media Downloader</h1>
<p align="center"><a href="https://github.com/pixel-point/media-downloader/releases/latest/download/MediaDownloader-macos-arm64.dmg">Download for macOS</a></p>

https://github.com/user-attachments/assets/c81f8c07-835d-4d37-87cf-926caa0fe6c1

Beautiful native macOS video downloader with support for [thousands of sites](https://github.com/yt-dlp/yt-dlp/blob/master/supportedsites.md) through [yt-dlp](https://github.com/yt-dlp/yt-dlp/tree/master).

Media Downloader lets you download, quickly copy, reveal, and trim videos from social media and video platforms in one focused app. Paste a URL from services such as YouTube, Instagram, X, TikTok, Vimeo, Reddit, and many other sites supported by `yt-dlp`; the app downloads an MP4, copies the finished file to the clipboard, saves it to your chosen folder, and keeps a local history for fast access.

## Features

- Download videos from thousands of `yt-dlp` supported websites.
- Paste a URL and start downloading from a clean Spotlight-style macOS window.
- Convert and merge downloads to broadly compatible MP4 output with H.264/AAC when possible.
- Automatically copy the downloaded file after completion.
- Keep a local download history with thumbnails.
- Copy files again, reveal them in Finder, or open the original source URL from history.
- Trim downloaded videos and either save the trimmed MP4 or copy the trimmed clip.
- Choose and persist a custom download folder.
- Check GitHub Releases for app updates from the settings menu.

## Local Development Requirements

These requirements are only needed when building or running the app locally from source:

- macOS 14 or newer
- Xcode Command Line Tools or Xcode with Swift 5.9+
- `yt-dlp`
- `ffmpeg`

For local development, install the Xcode Command Line Tools:

```sh
xcode-select --install
```

For local development, install runtime dependencies with Homebrew:

```sh
brew install yt-dlp ffmpeg
```

For local development, verify the tools are available:

```sh
yt-dlp --version
ffmpeg -version
```

## Local Development Build and Run

From the repository root:

```sh
./script/build_and_run.sh
```

The script runs `swift build`, creates a local development app bundle at `dist/MediaDownloader.app`, and launches it.

You can also run SwiftPM directly during local development:

```sh
swift build
swift test
```

Useful local development script modes:

```sh
./script/build_and_run.sh --verify
./script/build_and_run.sh --logs
./script/build_and_run.sh --telemetry
./script/build_and_run.sh --debug
./script/build_and_run.sh --setup
```

## Release Build, Signing, and Notarization

The app checks `https://api.github.com/repos/pixel-point/media-downloader/releases/latest` for updates and compares the latest release tag, such as `v0.2.0`, with `CFBundleShortVersionString`.

Release credentials should live in a local `.env` file copied from `.env.example`. Do not commit `.env`, `.p8`, `.p12`, certificates, provisioning profiles, or private keys; the repo ignores them.

To create and publish signed, notarized macOS zip and drag-to-Applications DMG artifacts:

```sh
./script/release_macos.sh v0.2.0
```

To create local signed and notarized artifacts without publishing a GitHub release:

```sh
./script/package_macos.sh
```

The release script runs tests, builds a release `.app`, signs it with hardened runtime, submits it to Apple notarization, staples the ticket, creates `dist/release/MediaDownloader-macos-<arch>.zip` and `dist/release/MediaDownloader-macos-<arch>.dmg`, and uploads both artifacts to the matching GitHub release. The DMG contains `MediaDownloader.app` and an `Applications` shortcut for the standard drag-to-install flow.

## How It Works

Media Downloader uses `yt-dlp` to fetch media and `ffmpeg` to merge, convert, trim, and export video files. Downloads are saved to the selected local folder. App preferences are stored in `UserDefaults`, while history and generated thumbnails are stored under the app's Application Support directory.

## Project Structure

- `Package.swift` - Swift Package Manager manifest.
- `Sources/MediaDownloader` - macOS app source code.
- `Tests/MediaDownloaderTests` - unit tests.
- `script/build_and_run.sh` - local build, bundle, launch, debug, and logging helper.
- `script/create_dmg.sh` - creates the drag-to-Applications DMG from a built app bundle.
- `dist/` - generated local app bundle output.

## Notes

Site support depends on the installed `yt-dlp` version. If a site stops working, update `yt-dlp` first:

```sh
brew upgrade yt-dlp
```
