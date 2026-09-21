# 🚇 Cairo Metro Navigator

A modern, offline-first Cairo Metro navigation and route planning application built with **Flutter** and **GetX**. The app provides real-time route calculations, transfer minimization, accurate dynamic fare calculations based on official transit tiers, and an intelligent offline area guide.

---

## ✨ Features

- **🚀 Smart Multi-Criteria Route Optimization (BFS Graph Traversal):**
  - **Fastest Route:** Minimizes total stations and transit duration.
  - **Comfort Route:** Prioritizes fewer line transfers to ensure a smoother, easier commute.
- **💰 Realistic Fare Calculation:**
  - Automated fare calculation matching Cairo Metro's official transit tier system.
  - Category-based dynamic pricing (**Standard**, **Seniors 60+**, and **Special Needs**).
  - Minimum fare unification across alternative routes for the same source-destination pair.
- **📍 Location-Aware & Offline-First:**
  - **GPS Integration:** Instant detection of the nearest metro station using device sensors without requiring mobile data.
  - **Local Directory Search:** Built-in offline database for 35+ major Cairo landmarks and districts (e.g., Abbas El Akkad, Faisal, El Salam).
  - Graceful fallback with offline error notifications when network lookups fail.
- **🗺️ Interactive Landmarks & Station Exploration:**
  - Quick-select famous Cairo landmarks mapped directly to their nearest metro stops.
  - Vertical timeline showing intermediate stops, active line colors, and walking transfer times.
- **📜 Trip History & Search Caching:**
  - Save trips locally with custom destination tags (`destinationTag`) reflecting search queries and landmarks.
  - View trip summaries including ticket price, duration, passenger badge, and intermediate stops.
- **🌍 Internationalization & Theming:**
  - Full Arabic and English bilingual support (RTL/LTR).
  - Persistent Dark and Light themes.

---

## 🛠️ Tech Stack & Architecture

- **Framework:** [Flutter](https://flutter.dev/) (Dart)
- **State Management:** [GetX](https://pub.dev/packages/get)
- **Routing Engine:** Graph data structure with Breadth-First Search (BFS) & multi-attribute path evaluation.
- **Local Persistence:** `shared_preferences`
- **Geolocation & External Maps:** `geolocator`, `geocoding`, `url_launcher`

---

## 📸 Screenshots

| Route Planning | Route Options & Timeline | Landmarks & Offline Search | Trip History |
| :---: | :---: | :---: | :---: |
| *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* | *(Add Screenshot)* |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.0.0)
- Android Studio / VS Code
- Dart SDK

### Installation

1. **Clone the repository:**
   ```bash
   git clone [https://github.com/your-username/cairo-metro-app.git](https://github.com/your-username/cairo-metro-app.git)
   cd cairo-metro-app