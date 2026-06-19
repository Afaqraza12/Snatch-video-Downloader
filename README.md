<div align="center">

<img src="https://img.shields.io/badge/version-1.0.0-blue?style=for-the-badge" />
<img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS-0ea5e9?style=for-the-badge" />
<img src="https://img.shields.io/badge/built%20with-Flutter-02569B?style=for-the-badge&logo=flutter" />
<img src="https://img.shields.io/badge/license-GPL%20v3-22c55e?style=for-the-badge" />

<br/><br/>

```
 ███████╗███╗   ██╗ █████╗ ████████╗ ██████╗██╗  ██╗
 ██╔════╝████╗  ██║██╔══██╗╚══██╔══╝██╔════╝██║  ██║
 ███████╗██╔██╗ ██║███████║   ██║   ██║     ███████║
 ╚════██║██║╚██╗██║██╔══██║   ██║   ██║     ██╔══██║
 ███████║██║ ╚████║██║  ██║   ██║   ╚██████╗██║  ██║
 ╚══════╝╚═╝  ╚═══╝╚═╝  ╚═╝   ╚═╝    ╚═════╝╚═╝  ╚═╝
```

### **Download Anything. Keep Everything.**
*YouTube • TikTok • Instagram — all in one free & open-source app*

<br/>

[📥 Download APK](#installation) · [✨ Features](#features) · [🛠 Build from Source](#build-from-source) · [🤝 Contribute](#contributing)

---

</div>

## 📱 What is Snatch?

**Snatch** is a free, open-source Flutter app that lets you download videos, audio, and shorts from the most popular platforms — without watermarks, without ads, and without any subscription.

> Built for people who believe your downloads should belong to you.

---

## ✨ Features

### 🎬 YouTube
- Download videos in **360p / 720p / 1080p**
- Extract **audio only** (MP3 / M4A)
- Download **YouTube Shorts**
- Saves directly to your **Gallery & Music Library**
- Real-time **download progress bar**

### 🎵 TikTok
- Download TikTok videos **without watermark**
- Paste URL → instant download
- Saves to gallery

### 📸 Instagram
- Download **Reels, Posts, Stories**
- Photos **and** videos supported
- **Zero watermark**
- Saves to gallery

---

## 📸 Screenshots

> *Coming soon — feel free to contribute screenshots!*

| YouTube | TikTok | Instagram | Downloads |
|---------|--------|-----------|-----------|
| ![yt](#) | ![tt](#) | ![ig](#) | ![dl](#) |

---

## 🚀 Installation

### Option 1 — Download APK (Easiest)

1. Go to [**Releases**](../../releases)
2. Download the latest `snatch-v1.0.0.apk`
3. Enable **Install from unknown sources** on your Android device
4. Install and enjoy ✅

### Option 2 — Build from Source

See [Build from Source](#build-from-source) below.

---

## 🛠 Build from Source

### Prerequisites

| Tool | Version |
|------|---------|
| Flutter | `>=3.10.0` |
| Dart | `>=3.0.0` |
| Android SDK | API 29+ |

### Steps

```bash
# 1. Clone the repo
git clone https://github.com/Afaqraza12/Snatch-video-Downloader.git
cd Snatch-video-Downloader

# 2. Install dependencies
flutter pub get

# 3. Run on device/emulator
flutter run

# 4. Build release APK
flutter build apk --release
```

APK will be at: `build/app/outputs/flutter-apk/app-release.apk`

---

## 📦 Tech Stack

| Layer | Technology |
|-------|-----------|
| Framework | Flutter (Dart) |
| YouTube extraction | `youtube_explode_dart` |
| HTTP & downloads | `dio` |
| State management | `provider` / `riverpod` |
| Gallery save | `media_store_plus` |
| Permissions | `permission_handler` |
| Storage | `path_provider` |
| Notifications | `fluttertoast` |

---

## 🔐 Permissions Required

```xml
INTERNET
READ_EXTERNAL_STORAGE
WRITE_EXTERNAL_STORAGE
READ_MEDIA_VIDEO
READ_MEDIA_AUDIO
READ_MEDIA_IMAGES
```

All permissions are used solely for downloading and saving media to your device. No data is collected or shared.

---

## 🗂 Project Structure

```
lib/
├── main.dart
├── screens/
│   ├── youtube_screen.dart
│   ├── tiktok_screen.dart
│   ├── instagram_screen.dart
│   └── downloads_screen.dart
├── services/
│   ├── youtube_service.dart
│   ├── tiktok_service.dart
│   ├── instagram_service.dart
│   └── download_manager.dart
├── providers/
│   └── download_provider.dart
└── widgets/
    ├── url_input_card.dart
    └── download_tile.dart
```

---

## 🤝 Contributing

Contributions are welcome! Here's how:

1. **Fork** this repository
2. Create a branch: `git checkout -b feature/your-feature`
3. Commit your changes: `git commit -m 'Add some feature'`
4. Push: `git push origin feature/your-feature`
5. Open a **Pull Request**

### Ideas for Contribution
- [ ] Add Twitter/X video support
- [ ] Add Facebook video support
- [ ] Batch download (multiple URLs at once)
- [ ] Built-in media player
- [ ] iOS support & App Store release
- [ ] Dark/light theme toggle

---

## ⚠️ Disclaimer

Snatch is intended for **personal use only**. Please respect the Terms of Service of each platform and only download content you have the right to download. The developer is not responsible for any misuse.

---

## 📄 License

This project is licensed under the **GNU General Public License v3.0**.
See the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by **[Afaq Raza](https://github.com/Afaqraza12)**

⭐ Star this repo if you find it useful!

</div>
