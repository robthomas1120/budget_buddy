# Budget Buddy (Expo)

Budget Buddy is a mobile-first personal finance application built with **React Native** and **Expo**. It helps users track income and expenses, manage budgets, set savings goals, and visualize their financial health.

## 🚀 Features

- **Dashboard**: 
  - View current balance at a glance.
  - See recent transactions.
  - Privacy mode to hide sensitive balance information.
- **Transaction Management**: 
  - Add identifying information for income and expenses.
  - Categorize transactions (Food, Transport, Salary, etc.).
  - Link transactions to specific budgets.
  - Date and time picker integration.
- **Budgeting**: 
  - Create weekly or monthly budgets.
  - Track spending against limits with visual progress bars.
  - Real-time updates as transactions are added.
- **Savings Goals**: 
  - Set targets for specific goals (e.g., Laptop, Vacation).
  - Deposit funds directly from accounts with automatic balance deduction.
  - Track progress towards your targets.
- **Account Management**: 
  - Manage multiple accounts (Bank, Cash, E-Wallet).
  - Track balances for each account type.
- **Theme Support**: 
  - Switch between **Light**, **Dark**, and **Dark Pink** themes.
  - Persistent theme preference.

## 🛠 Tech Stack

- **Framework**: [Expo](https://expo.dev/) (React Native)
- **Language**: TypeScript
- **Database**: `expo-sqlite` (Local persistence)
- **UI Component Library**: `react-native-paper`
- **Navigation**: React Navigation (Bottom Tabs & Native Stack)
- **State Management**: React Context API
- **Icons**: Material Community Icons (`@expo/vector-icons`)

## 📦 Installation & Setup

1.  **Prerequisites**:
    - Node.js (LTS recommended)
    - Expo CLI

2.  **Clone the Repository**:
    ```bash
    git clone <repository-url>
    cd budget_buddy
    ```

3.  **Install Dependencies**:
    ```bash
    npm install
    ```

4.  **Run the App**:
    ```bash
    npx expo start
    ```
    - Scan the QR code with **Expo Go** on your Android/iOS device.
    - Press `a` for Android Emulator or `i` for iOS Simulator.

## 📱 Building for Production (iOS)

This project is configured for **EAS Build**.

1.  **Install EAS CLI**:
    ```bash
    npm install -g eas-cli
    ```

2.  **Login to Expo**:
    ```bash
    eas login
    ```

3.  **Build for iOS**:
    ```bash
    eas build -p ios
    ```

## 📂 Project Structure

```
src/
├── components/   # Reusable UI components (Cards, ListItems, Modals)
├── context/      # App-wide state (AppContext, ThemeContext)
├── database/     # SQLite helpers and schema definitions
├── navigation/   # Navigation configuration (Tab & Stack navigators)
├── screens/      # Application screens (Dashboard, Budget, Savings, etc.)
├── theme/        # Theme definitions (Colors, Fonts)
└── types/        # TypeScript interfaces and types
```
