# WASL — Delivery App 🚀

> **"Relax, we've got it delivered."**  
> A modern, full-featured delivery application built with Flutter.

---

## Overview

**WASL** is a premium Flutter delivery application that connects users with local stores and restaurants, enabling seamless order placement, real-time tracking, and fast doorstep delivery — all wrapped in a beautiful, RTL-ready Arabic UI.

---

## Features

- 🔐 **Secure Authentication** — Login & registration via IdentityServer4 with token management
- 🏠 **Smart Home Feed** — Categorized stores, offer sliders, and search
- 🛒 **Cart & Orders** — Add items, review cart, and place orders
- 📍 **Address Management** — Add, edit, and delete delivery addresses
- 👤 **User Profile** — Manage personal info and settings
- 🌙 **Theme Support** — Light/dark mode via ThemeCubit
- 🌍 **Full RTL Support** — Designed natively for Arabic users

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3.x / Dart |
| State Management | Flutter BLoC / Cubit |
| Navigation | GoRouter |
| Networking | Dio + Interceptors |
| Secure Storage | flutter_secure_storage |
| Fonts | Google Fonts (Cairo) |
| Architecture | Clean Architecture (Feature-First) |

---

## Project Structure

```
lib/
├── core/           # Network, theme, shared utilities
├── features/
│   ├── auth/       # Login & registration
│   ├── home/       # Home feed, offers, categories
│   ├── profile/    # User profile & settings
│   ├── address/    # Address CRUD
│   ├── cart/       # Shopping cart
│   └── splash/     # Splash & onboarding
└── main.dart
```

---

## Getting Started

```bash
# Clone the repository
git clone https://github.com/your-username/wasl.git

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## License

This project is licensed under the **CC BY-NC 4.0** license.  
Commercial use is strictly prohibited.  
See [LICENSE](./LICENSE) for details.

---

<p align="center">Built with ❤️ using Flutter</p>
