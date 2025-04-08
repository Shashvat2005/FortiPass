# 🔐 FortiPass - Password & Account Manager App

FortiPass is a modern, secure, and user-friendly Flutter application designed to safely store and manage your passwords and accounts. With advanced security features like biometric authentication and protected password visibility, FortiPass ensures your sensitive information stays in the right hands—yours.

## ✨ Features

- 🔒 **Biometric Authentication**  
  Secure login using fingerprint or facial recognition for supported devices.

- 🧱 **Super Secure Page**  
  A dedicated vault protected by an additional layer of security to store your most sensitive entries.

- 👁️ **Authenticate to Unhide Passwords**  
  Prevent shoulder surfing and accidental exposure with authentication required to view stored passwords.

- 📂 **Organized Password Management**  
  Add, edit, archive, and delete your passwords and account entries with a clean UI.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (https://flutter.dev/docs/get-started/install)
- Dart
- Android Studio or Visual Studio Code

### Installation

```bash
git clone https://github.com/yourusername/fortipass.git
cd fortipass
flutter pub get
flutter run
```

## 📦 Packages Used

- [`local_auth`](https://pub.dev/packages/local_auth) ^2.3.0 – Biometric authentication  
- [`sqflite`](https://pub.dev/packages/sqflite) ^2.4.1 – SQLite-based local database  
- [`path_provider`](https://pub.dev/packages/path_provider) ^2.1.5 – Access device paths  
- [`path`](https://pub.dev/packages/path) ^1.9.0 – File system path utilities  
- [`shared_preferences`](https://pub.dev/packages/shared_preferences) ^2.5.3 – Store simple app settings and flags  


## 📁 Folder Structure

```
fortipass/
├── lib/
│   ├── main.dart
|   ├── myapp.dart
│   ├── Pages/
│   │   ├── home.dart
│   │   ├── search.dart
│   │   ├── settings.dart
│   │   ├── Super_secure.dart
│   │   ├── Authentication/
│   │   │   ├── Auth_screen.dart
│   │   │   └── Setup_screen.dart
├── pubspec.yaml
└── README.md
```

## ✅ To-Do

- [x] Add biometric authentication
- [x] Create secure vault page
- [x] Enable password visibility with auth
- [ ] Implement cloud backup (planned)
- [ ] Add dark mode toggle (planned)

---

### 👨‍💻 Developed by [Shashvat Garg](https://github.com/Shashvat2005)

Feel free to fork this repo, submit issues, and make pull requests. Contributions are welcome!
