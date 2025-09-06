# ClearSpend - Teen Financial Literacy on Algorand

## 🏆 Algorand x EasyA Harvard Hackathon Submission

ClearSpend is a blockchain-powered teen spending app that teaches financial responsibility through verifiable, parent-controlled digital allowances on Algorand.

## 🎯 Problem Statement

Teens lack transparent, educational tools for managing money digitally while parents struggle to monitor and guide spending habits effectively. Traditional teen debit cards offer limited controls and no verifiable spending history for building credit reputation.

## 💡 Our Solution

ClearSpend leverages Algorand's atomic transfers and smart contracts to create a trustless system where:
- **Every purchase is pre-verified** before money moves
- **Parents set smart controls** via on-chain attestations
- **Teens build verifiable spending history** for future credit
- **Educational gamification** teaches financial literacy

## 🚀 Key Features

### Core Hackathon Features (MVP)
- ✅ **ASA-based Allowances**: Weekly allowances issued as Algorand Standard Assets
- ✅ **Atomic Transfer Verification**: Purchases verified through atomic groups before execution
- ✅ **On-chain Attestation**: Oracle-based merchant/category verification via box storage
- ✅ **iOS Demo App**: Native SwiftUI app with teen-focused UX

### Smart Contract Architecture
1. **Attestation Oracle Contract** (`attestation_oracle.py`)
   - Merchant approval attestations in box storage
   - Category restrictions and daily limits
   - Real-time purchase verification

2. **Allowance Manager Contract** (`allowance_manager.py`)
   - Parent-controlled allowance issuance
   - Timelock savings functionality
   - Pause/resume capabilities

### Atomic Transfer Flow
```
1. App Call → Check attestation exists
2. App Call → Verify spending limits
3. ASA Transfer → Execute only if approved
```

## 📱 iOS App Features

### Teen View
- **Home**: Balance display, recent transactions, quick actions
- **Spend**: Smart purchase flow with category selection
- **Invest**: Introduction to saving and investment concepts
- **Learn**: Gamified financial education modules

### Technical Implementation
- SwiftUI for modern iOS UI
- Algorand SDK integration for blockchain interaction
- Mock attestation system for demo
- Real-time balance updates

## 🛠 Technology Stack

- **Blockchain**: Algorand (Testnet)
- **Smart Contracts**: PyTeal/Algorand Python
- **iOS**: Swift, SwiftUI
- **Features Used**:
  - ASAs (Algorand Standard Assets)
  - Atomic Transfers
  - Box Storage
  - Smart Contract App Calls

## 🏗 Project Structure

```
clear-spend/
├── ClearSpend/           # iOS app
│   ├── Views/           # SwiftUI views
│   ├── Models/          # Data models
│   ├── Services/        # Algorand integration
│   └── ViewModels/      # Business logic
├── contracts/           # Smart contracts
│   ├── attestation_oracle.py
│   └── allowance_manager.py
└── Package.swift        # SPM configuration
```

## 🚦 Getting Started

### Prerequisites
- Xcode 15+
- iOS 17+
- Algorand Testnet account

### Installation
```bash
# Clone repository
git clone https://github.com/yourteam/clearspend.git

# Open in Xcode
open ClearSpend/ClearSpend.xcodeproj

# Build and run on simulator
```

### Smart Contract Deployment
```bash
# Install AlgoKit
pipx install algokit

# Deploy contracts
algokit compile contracts/attestation_oracle.py
algokit deploy
```

## 🎮 Demo Flow

1. **Teen opens app** → Sees 150 ALGO allowance
2. **Initiates purchase** → Selects merchant and amount
3. **Atomic verification** → Smart contract checks attestation
4. **Approved purchases** → Instant confirmation with explorer link
5. **Rejected purchases** → Clear feedback on restrictions
6. **Learning rewards** → Earn XP for financial education

## 🔮 Future Roadmap

### Phase 2: Enhanced Features
- Multi-sig family wallets
- DeFi yield integration
- Credit score NFTs
- Merchant partnerships

### Phase 3: Scale & Adoption
- Parent management portal
- School district integration
- Real prepaid card rails
- Cross-chain reputation

## 🏅 Why We Win

### Innovation
- First teen finance app with **pre-purchase blockchain verification**
- Novel use of atomic transfers for parental controls

### Algorand Utilization
- Leverages unique Algorand features:
  - Atomic transfers for trustless verification
  - Box storage for scalable attestations
  - Low fees enabling micro-transactions

### Impact
- Addresses real need for teen financial education
- Builds on-chain credit history from young age
- Reduces financial fraud and overspending

### Feasibility
- Working MVP in 36 hours
- Clear path to production
- Minimal infrastructure requirements

## 👥 Team

**ClearSpend** - Building the future of teen finance on Algorand

## 📄 License

MIT License - Open source for the community

## 🔗 Links

- [Demo Video](#)
- [Presentation Slides](#)
- [Algorand Explorer](https://testnet.algoexplorer.io)

---

Built with 💜 at Algorand x EasyA Harvard Hackathon 2025