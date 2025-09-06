# ClearSpend iOS Setup Guide

## Quick Start

1. **Open Xcode** (version 15 or later)
2. **Create New Project**:
   - Choose "iOS" → "App"
   - Product Name: `ClearSpend`
   - Interface: SwiftUI
   - Language: Swift
   - Bundle Identifier: `com.clearspend.app`

3. **Add Files to Project**:
   - Delete the default `ContentView.swift`
   - Drag all files from `ios-app/` into your Xcode project
   - Make sure to select "Copy items if needed"

4. **File Organization** (optional but recommended):
   - Create groups in Xcode:
     - Views (drag all View files here)
     - Models (drag Model files here) 
     - Services (drag Service files here)
     - ViewModels (drag ViewModel files here)

5. **Build & Run**:
   - Select iOS Simulator (iPhone 15 Pro recommended)
   - Press Cmd+R to build and run

## Project Structure

```
ClearSpend/
├── ClearSpendApp.swift          # App entry point
├── ContentView.swift            # Main tab view
├── Models/
│   └── Transaction.swift        # Data models
├── Services/
│   └── AlgorandService.swift    # Mock Algorand integration
├── ViewModels/
│   └── WalletViewModel.swift    # Business logic
└── Views/
    ├── HomeView.swift           # Home tab
    ├── SpendView.swift          # Spend tab
    ├── InvestView.swift         # Invest tab
    ├── LearnView.swift          # Learn tab
    ├── PurchaseResultView.swift # Purchase confirmation
    ├── TransactionRowView.swift # Transaction list item
    ├── TransactionHistoryView.swift # Full transaction history
    └── SettingsView.swift       # Settings screen
```

## Key Features Demonstrated

✅ **Teen-focused UI**: Purple accent, modern SwiftUI design
✅ **Mock ASA Balance**: Shows 150 ALGO allowance
✅ **Purchase Flow**: Merchant selection → Category → Atomic verification
✅ **Result Screen**: Success/failure with Algorand explorer links
✅ **Learning Gamification**: XP tracking and educational modules
✅ **Investment Education**: Portfolio overview and options

## Demo Flow

1. **Home Tab**: View balance and recent transactions
2. **Spend Tab**: 
   - Enter merchant name (try "Spotify" or "Steam")
   - Enter amount (try 10.99 vs 60.00 to see approval/rejection)
   - Select category
   - Tap "Verify & Purchase" to see atomic transfer simulation
3. **Result Screen**: Shows blockchain verification
4. **Invest/Learn Tabs**: Educational content

## For Hackathon Demo

This demonstrates Algorand's unique features:
- **Atomic Transfers**: Purchase only executes if verification passes
- **Box Storage**: Merchant attestations stored on-chain
- **ASA Integration**: Allowances as Algorand Standard Assets
- **Smart Contract Verification**: Pre-purchase validation

Perfect for a 2-minute hackathon demo! 🚀

## Troubleshooting

- **Build errors**: Make sure deployment target is iOS 17+
- **Missing imports**: All files use only built-in SwiftUI/Foundation
- **Simulator issues**: Try iPhone 15 Pro simulator for best results

Good luck with your hackathon! 🏆