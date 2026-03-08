# Bachene Soft - Professional Stock & Sales Manager

[![Flutter](https://img.shields.io/badge/Flutter-v3.7.2-blue.svg)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-green.svg)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
[![License](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

A high-performance, professional stock and sales management application built with **Flutter**. Designed with **Clean Architecture** principles, this project demonstrates senior-level expertise in mobile development, state management, and robust local data persistence.

---

## 📸 visual Overview

| Home Screen | New Sale | Add Inventory |
| :---: | :---: | :---: |
| ![Home](screenshots/sm_new_sale.jpg) | ![New Sale](screenshots/sm_stock_entry2.jpg) | ![Add Inventory](screenshots/sm_home.jpg) |

| Client Management | Supplier Management | Inventory Check |
| :---: | :---: | :---: |
| ![Clients](screenshots/sm_client.jpg) | ![Suppliers](screenshots/sm_supplier.jpg) | ![Inventory](screenshots/sm_check_stock.jpg) |

| Daily Closures |
| :---: |
| ![Closures](screenshots/sm_purchase_history.jpg) |

---

## 🏗️ Architecture & Design

This project strictly adheres to **Clean Architecture** to ensure maintainability, testability, and scalability.

```mermaid
graph TD
    subgraph Presentation_Layer["Presentation Layer (Flutter UI)"]
        UI[Flutter Widgets / Screens]
        Providers[ChangeNotifier Providers]
    end

    subgraph Domain_Layer["Domain Layer (Business Logic)"]
        Entities[Business Entities]
        RepoInterfaces[Repository Interfaces]
        UseCases[Use Cases - Optional]
    end

    subgraph Data_Layer["Data Layer (Infrastructure)"]
        Repos[Repository Implementations]
        Models[Data Models / Serialization]
        
        subgraph Data_Sources["Data Sources"]
            SQL[(SQLite / Local DB)]
        end
    end

    UI --> Providers
    Providers --> RepoInterfaces
    RepoInterfaces --> Repos
    Repos --> Models
    Models --> Entities
    Repos --> SQL
```

### Key Architectural Highlights:
- **Decoupling**: Business logic is completely separated from the UI and Data layers.
- **Dependency Injection**: Constructor-based DI is used throughout, following the **Dependency Inversion Principle**.
- **Type Safety**: Explicit type casting and generic handling ensure a stable, runtime-safe experience.
- **Mapping**: Clear separation between UI-facing `Entities` and database-focused `Models`.

---

## 🛠️ Technology Stack

- **Core**: [Flutter](https://flutter.dev) / Dart
- **Persistence**: `sqflite` (SQLite) for robust local storage.
- **State Management**: `provider` for efficient reactive updates.
- **Security**: 
    - `local_auth` for Biometric (Fingerprint/Face) authentication.
    - Custom Secure PIN lock system.
- **Reporting**: 
    - `pdf` & `flutter_pdfview` for professional receipt generation.
    - `share_plus` for easy data export.
- **Hardware Integration**: `blue_thermal_printer` for Bluetooth printing support.
- **Design**: `google_fonts` (Poppins) for a premium, modern aesthetic.

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>= 3.7.2)
- Android Studio / VS Code

### Installation
1. Clone the repository:
   ```bash
   git clone https://github.com/your-username/stock_manager.git
   ```
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

---

## 📝 Documentations

The project is thoroughly documented using **Triple-Slash DocComments** (`///`), making it easy for other developers to understand the business roles and API contracts of all core components.

---

© 2026 Bachene Soft. All rights reserved.
