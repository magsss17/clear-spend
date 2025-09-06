# ClearSpend Testnet Setup Guide

## 🚀 Quick Start for Hackathon Demo

### Step 1: Fund the Demo Account

1. **Account Address**: `UYN4IOH5G2HRKRITQVDDE4IAIZZ4NHGR3GQZSWFYGOIUGZFB2RCCZKNWGQ`
2. **Open Testnet Dispenser**: https://testnet.algoexplorer.io/dispenser
3. **Request ALGOs**: Paste the address above and request 10 ALGO
4. **Verify Funding**: Check balance at https://testnet.algoexplorer.io/address/UYN4IOH5G2HRKRITQVDDE4IAIZZ4NHGR3GQZSWFYGOIUGZFB2RCCZKNWGQ

### Step 2: Create ClearSpend Dollar ASA

Once funded (balance > 0.1 ALGO), run:

```bash
python3 create_clearspend_asa.py
```

This will:
- Create the ClearSpend Dollar (CSD) ASA token
- Save configuration to `clearspend_asa_config.json`
- Output the Asset ID needed for iOS app

### Step 3: Update iOS App

Copy the Asset ID from the script output and update `AlgorandService.swift`:

```swift
private let clearSpendAsaId: UInt64 = YOUR_ASSET_ID_HERE
```

### Step 4: Opt-in to ASA (for receiving tokens)

The account needs to opt-in to receive ASA tokens. This is handled automatically in the app.

## 🎯 What This Enables

- **Real Testnet Transactions**: All purchases create actual blockchain transactions
- **Live ASA Transfers**: ClearSpend Dollars are real tokens on Algorand
- **Explorer Verification**: Every transaction visible on testnet.algoexplorer.io
- **Atomic Groups**: Transaction groups demonstrating Algorand's unique capabilities

## 📊 Demo Flow

1. **Teen opens app** → Real testnet balance loads (150 CSD)
2. **Makes purchase** → Creates atomic transaction group on testnet
3. **Transaction confirms** → Real txId and explorer link shown
4. **Balance updates** → Live balance refreshes from blockchain

## 🔧 Troubleshooting

### Account Not Funded
- Visit dispenser: https://testnet.algoexplorer.io/dispenser
- Wait 30 seconds between requests
- Alternative: Use different testnet dispenser sites

### ASA Creation Fails
- Ensure account has sufficient ALGO (minimum 0.1)
- Check network connectivity
- Verify mnemonic is exactly 25 words

### iOS App Shows 0 Balance
- Verify ASA ID is correct in AlgorandService.swift
- Check account opted-in to ASA
- Ensure testnet connectivity

## 🏆 Hackathon Impact

This real testnet integration demonstrates:

- **Novel Use Case**: Pre-purchase verification via atomic transfers
- **Algorand Features**: ASAs, atomic groups, box storage (planned)
- **Real-world Utility**: Actual financial controls for teens
- **Scalability**: Testnet performance shows production readiness

---

**Next Steps**: Once ASA is created, the app will have full testnet functionality for the hackathon demo!