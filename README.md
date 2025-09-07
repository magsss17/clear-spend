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
├── backend/                    # Backend API & Services
│   ├── contracts/             # AlgoKit smart contracts
│   │   ├── attestation_oracle.py
│   │   └── allowance_manager.py
│   ├── services/              # Core business logic
│   │   ├── blockchain_service.py
│   │   └── oracle_service.py
│   ├── api/                   # FastAPI endpoints
│   │   ├── routes/            # API routes
│   │   └── models/            # Request/Response models
│   ├── tests/                 # Comprehensive testing
│   ├── deployment/            # Docker & deployment configs
│   └── main.py                # FastAPI application
├── ClearSpend/                # iOS SwiftUI app source code
│   ├── Views/                 # SwiftUI views
│   ├── Models/                # Data models
│   ├── Services/              # Algorand integration
│   ├── ViewModels/            # Business logic
│   └── Assets.xcassets/       # App assets and resources
├── ClearSpend.xcodeproj/      # Xcode project file
├── docs/                      # Documentation
│   ├── ARCHITECTURE.md        # System architecture
│   ├── API.md                 # API documentation
│   └── config.env.example     # Environment template
├── scripts/                   # Utility scripts
│   ├── setup.sh              # Project setup script
│   ├── start_backend.py      # Backend startup script
│   ├── test_integration.py   # Integration tests
│   ├── demo_backend_integration.py # Demo script
│   └── utilities/            # Utility scripts
│       ├── create_clearspend_asa.py
│       └── generate_testnet_wallet.py
├── tools/                     # Development tools
├── Makefile                   # Build automation
├── .gitignore                 # Git ignore rules
└── requirements.txt           # Python dependencies
```

## 🚦 Getting Started

### Prerequisites
- Python 3.11+
- Xcode 15+
- iOS 17+
- Algorand Testnet account
- AlgoKit installed (`pipx install algokit`)

### Quick Setup
```bash
# Clone repository
git clone https://github.com/yourteam/clearspend.git
cd clear-spend

# Run automated setup
./scripts/setup.sh

# Start the backend
make backend
```

### Manual Setup
```bash
# Install dependencies
make install

# Configure environment
cp docs/config.env.example docs/config.env
# Edit docs/config.env with your Algorand credentials

# Deploy smart contracts
make deploy

# Start the backend API
make backend
```

### iOS App Setup
```bash
# Open in Xcode
open ios-app/ClearSpendApp.xcodeproj

# Build and run on simulator
make ios
```

### Available Commands
```bash
make help          # Show all available commands
make install       # Install dependencies
make backend       # Start backend API
make ios          # Build iOS app
make test         # Run all tests
make deploy       # Deploy smart contracts
make docker       # Run with Docker Compose
make clean        # Clean temporary files
```

## 🎮 Demo Flow

### Backend API Flow
1. **Start Backend** → API running on `http://localhost:8000`
2. **Deploy Contracts** → Smart contracts deployed to Algorand Testnet
3. **Add Merchants** → Oracle service manages merchant attestations
4. **Verify Purchases** → Real-time purchase verification via API
5. **Execute Transactions** → Atomic transfer groups for secure purchases

### iOS App Flow
1. **Teen opens app** → Sees $1000 allowance (10 ALGO at $100/ALGO rate)
2. **Initiates purchase** → Selects merchant and amount
3. **API Verification** → Backend verifies purchase via atomic transfers
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