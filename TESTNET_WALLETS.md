# Algorand Testnet Wallets

## ⚠️ PUBLIC TEST WALLETS - INTENTIONALLY EXPOSED FOR DEMO ⚠️

**IMPORTANT:** These wallet mnemonics, secret keys, and addresses are **purposely exposed** for testing and demonstration purposes. These are TESTNET wallets with no real value. DO NOT use this approach with mainnet wallets or real funds.

---

## Test Wallet 1
**Purpose:** Primary spending wallet for demo transactions

**Address:** `A4LCT5DIHALLMID6J3F5DLOIFWOU7PPEF6GPIA2FA37UYXCLORMT537TOI`

**Mnemonic (25 words):**
```
limb junk pond fame radio black already anxiety fold wide olive funny boat shallow piano rude width castle truth sand loop tonight track absent whale
```

**Balance:** 10 ALGO (testnet)

**Explorer:** https://testnet.algoexplorer.io/address/A4LCT5DIHALLMID6J3F5DLOIFWOU7PPEF6GPIA2FA37UYXCLORMT537TOI

---

## Test Wallet 2
**Purpose:** Recipient wallet for demo transfers

**Address:** `QWCF2G23COMXXBZQVOJHLIH74YDACEZBQGD5RQTKPMTUXEGJONEBDKGLNA`

**Mnemonic (25 words):**
```
tag cabin pig doctor practice wing fit cargo warm swear marine protect tumble convince little bridge immune rookie east duty lend security sister about renew
```

**Balance:** 10 ALGO (testnet)

**Explorer:** https://testnet.algoexplorer.io/address/QWCF2G23COMXXBZQVOJHLIH74YDACEZBQGD5RQTKPMTUXEGJONEBDKGLNA

---

## Demo Wallet (Used in iOS App)
**Purpose:** Primary wallet configured in AlgorandService.swift

**Address:** `UYN4IOH5G2HRKRITQVDDE4IAIZZ4NHGR3GQZSWFYGOIUGZFB2RCCZKNWGQ`

**Mnemonic (25 words):**
```
first canvas energy brass base lamp trouble fee soda first voyage panic giggle differ palace kitchen empty sword palm treat warfare artefact rib absent midnight
```

**Balance:** Check on explorer

**Explorer:** https://testnet.algoexplorer.io/address/UYN4IOH5G2HRKRITQVDDE4IAIZZ4NHGR3GQZSWFYGOIUGZFB2RCCZKNWGQ

---

## Usage Notes

### For Testing:
1. These wallets are funded with testnet ALGO
2. Get more testnet ALGO at: https://testnet.algoexplorer.io/dispenser
3. All transactions are on Algorand TESTNET - no real value

### Security Notice:
- ✅ **SAFE:** These are testnet wallets for demo purposes
- ❌ **NEVER:** Expose mainnet wallet mnemonics like this
- ❌ **NEVER:** Commit real secret keys to version control
- ✅ **ALWAYS:** Use secure key management (Keychain, Privy, etc.) in production

### Transaction Explorer:
View all transactions at: https://lora.algokit.io/testnet/

### Example Transaction IDs:
- Khan Academy: `RS7DE6PVJQKJCFOT3GRKWUUPCZLFA7U5Z463XAHPV45BNY7WUHLQ`
- Community Charity: `BWWLE2NRIMZ6REM5BWWFAEAM7SYREKPC655ICIVOPM4CEDLLVABQ`
- Amazon: `IHZKLH4PGI25NYOJWQ3YOOXN66DIKYU3WWRGONRXURDEKEWQAMFA`

---

## Development Setup

To use these wallets in your development environment:

```javascript
// testnet-setup.js
const WALLETS = {
    wallet1: {
        address: "A4LCT5DIHALLMID6J3F5DLOIFWOU7PPEF6GPIA2FA37UYXCLORMT537TOI",
        mnemonic: "limb junk pond fame radio black already anxiety fold wide olive funny boat shallow piano rude width castle truth sand loop tonight track absent whale"
    },
    wallet2: {
        address: "QWCF2G23COMXXBZQVOJHLIH74YDACEZBQGD5RQTKPMTUXEGJONEBDKGLNA", 
        mnemonic: "tag cabin pig doctor practice wing fit cargo warm swear marine protect tumble convince little bridge immune rookie east duty lend security sister about renew"
    }
};
```

---

**Last Updated:** December 2024
**Network:** Algorand Testnet
**Purpose:** ClearSpend Demo Application