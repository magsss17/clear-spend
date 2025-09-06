# ClearSpend Smart Contracts Explained

## 🎯 Overview

ClearSpend uses **two main smart contracts** on the Algorand blockchain to create a trustless, parent-controlled teen spending system. These contracts work together to ensure every purchase is verified before money moves.

---

## 📋 Smart Contract Architecture

### **1. Attestation Oracle Contract** (`attestation_oracle.py`)
**Purpose**: Manages merchant approvals and purchase verification

### **2. Allowance Manager Contract** (`allowance_manager.py`)
**Purpose**: Manages teen allowances and parental controls

---

## 🔍 Contract 1: Attestation Oracle

### **What It Does**
The Attestation Oracle is the "gatekeeper" that verifies every purchase before it happens.

### **Key Features**

#### **🏪 Merchant Management**
```python
class MerchantAttestation(Struct):
    merchant_name: String        # "Starbucks", "Target", etc.
    category: String            # "Food & Beverage", "Gaming", etc.
    is_approved: Bool           # True/False for parent approval
    daily_limit: UInt64         # Maximum daily spending limit
    total_spent_today: UInt64   # Tracks daily spending
    parent_approved: Bool       # Parent's explicit approval
```

#### **💳 Purchase Verification**
```python
def verify_purchase(
    self,
    merchant_name: String,
    amount: UInt64,
    user_address: Address
) -> Bool:
    """Verify if purchase is allowed"""
    # 1. Check if merchant is approved
    # 2. Check if amount is within daily limit
    # 3. Check if parent has approved this merchant
    # 4. Return True/False
```

#### **📦 Box Storage**
- Uses Algorand's **Box Storage** for scalable merchant data
- Stores merchant attestations efficiently
- Enables real-time verification without expensive storage

### **How It Works in Practice**

1. **Parent Approves Merchant**: 
   - Parent calls `add_merchant_attestation()`
   - Sets daily limits and approval status
   - Data stored in box storage

2. **Teen Makes Purchase**:
   - iOS app calls `verify_purchase()`
   - Contract checks all rules instantly
   - Returns approval/rejection

3. **Real-Time Updates**:
   - Tracks daily spending automatically
   - Updates limits in real-time
   - Prevents overspending

---

## 🔍 Contract 2: Allowance Manager

### **What It Does**
The Allowance Manager handles the financial side - issuing allowances, managing savings, and parental controls.

### **Key Features**

#### **💰 Allowance Management**
```python
class AllowanceRecord(ARC4Contract):
    teen_address: Address           # Teen's wallet address
    weekly_amount: UInt64          # Weekly allowance amount
    last_allowance_time: UInt64    # When last allowance was issued
    total_issued: UInt64           # Total allowances issued
    is_paused: Bool               # Parent can pause allowances
    savings_locked: UInt64         # Amount locked in savings
    savings_unlock_time: UInt64    # When savings unlock
```

#### **👨‍👩‍👧‍👦 Parental Controls**
```python
def issue_weekly_allowance(self) -> UInt64:
    """Issue weekly allowance (parent only)"""
    # Only parent can call this
    # Checks if allowance is paused
    # Issues ASA tokens to teen
    # Updates tracking data

def pause_allowance(self) -> None:
    """Pause allowance (parent only)"""
    # Parent can pause all spending
    # Emergency control mechanism

def resume_allowance(self) -> None:
    """Resume allowance (parent only)"""
    # Parent can resume spending
    # Restores normal operation
```

#### **🏦 Savings Features**
```python
def lock_savings(self, amount: UInt64, lock_duration: UInt64) -> None:
    """Lock money in savings (parent only)"""
    # Parent can lock teen's money
    # Time-locked savings feature
    # Teaches delayed gratification

def unlock_savings(self) -> UInt64:
    """Unlock savings when time expires"""
    # Automatic unlocking after time period
    # Returns locked amount to teen
```

### **How It Works in Practice**

1. **Weekly Allowance**:
   - Parent calls `issue_weekly_allowance()`
   - Contract creates ASA tokens
   - Transfers to teen's wallet

2. **Emergency Controls**:
   - Parent can pause/resume allowances
   - Immediate spending control
   - Emergency safety mechanism

3. **Savings Education**:
   - Parent can lock money for time periods
   - Teaches delayed gratification
   - Automatic unlocking

---

## 🔗 How They Work Together

### **Atomic Transfer Flow**
```
1. Teen initiates purchase in iOS app
2. App calls Attestation Oracle → verify_purchase()
3. If approved, creates atomic transfer group:
   - App Call → Attestation Oracle (verification)
   - App Call → Allowance Manager (balance check)
   - ASA Transfer → Merchant (payment)
4. All transactions succeed or fail together
```

### **Real-World Example**
```
Teen wants to buy $5 coffee at Starbucks:

1. iOS app calls: verify_purchase("Starbucks", 5000000, teen_address)
2. Attestation Oracle checks:
   ✅ Starbucks is approved
   ✅ $5 is under daily limit
   ✅ Parent approved Starbucks
3. If approved, atomic transfer executes:
   ✅ Verification recorded
   ✅ Balance updated
   ✅ Payment sent to Starbucks
4. Teen gets coffee, parent gets transaction record
```

---

## 🎯 Key Benefits

### **🔒 Security**
- **No Unauthorized Spending**: Every purchase verified before execution
- **Parental Control**: Parents can pause/approve merchants instantly
- **Atomic Transfers**: All-or-nothing execution prevents partial failures

### **📊 Transparency**
- **On-Chain Records**: Every transaction recorded on Algorand
- **Real-Time Monitoring**: Parents see all spending instantly
- **Verifiable History**: Builds credit reputation from young age

### **🎓 Education**
- **Savings Features**: Time-locked savings teach delayed gratification
- **Category Controls**: Parents can restrict gaming, encourage education
- **Real Money**: Teens learn with real financial consequences

### **⚡ Performance**
- **Box Storage**: Scalable merchant data storage
- **Low Fees**: Algorand's low transaction costs
- **Fast Verification**: Sub-second purchase verification

---

## 🛠 Technical Implementation

### **Algorand Features Used**
- **ASAs**: Algorand Standard Assets for allowances
- **Atomic Transfers**: Multi-transaction groups
- **Box Storage**: Scalable data storage
- **Smart Contract App Calls**: Contract interactions
- **ARC4 Standard**: Modern contract interface

### **Integration Points**
- **Backend API**: Calls smart contracts via Algorand SDK
- **iOS App**: Initiates purchase verification
- **Parent Dashboard**: Manages merchant approvals
- **Algorand Explorer**: Public transaction records

---

## 🎬 Demo Scenarios

### **Scenario 1: Approved Purchase**
```
1. Teen: "I want to buy coffee at Starbucks"
2. App: Calls Attestation Oracle
3. Oracle: "✅ Approved - Starbucks is parent-approved"
4. Result: Purchase executes, teen gets coffee
```

### **Scenario 2: Rejected Purchase**
```
1. Teen: "I want to buy games at Gaming Store"
2. App: Calls Attestation Oracle
3. Oracle: "❌ Rejected - Gaming Store not approved"
4. Result: Purchase blocked, teen learns about restrictions
```

### **Scenario 3: Emergency Pause**
```
1. Parent: "I need to pause all spending"
2. Parent: Calls Allowance Manager → pause_allowance()
3. Result: All future purchases blocked until resumed
```

---

## 🏆 Why This Architecture Wins

### **Innovation**
- **First teen finance app** with pre-purchase blockchain verification
- **Novel use** of atomic transfers for parental controls
- **Real-time** merchant approval system

### **Algorand Advantages**
- **Low fees** enable micro-transactions
- **Fast finality** for instant verification
- **Box storage** for scalable merchant data
- **Atomic transfers** for secure multi-step operations

### **Real Impact**
- **Teens learn** real financial responsibility
- **Parents get** transparent control and monitoring
- **Merchants benefit** from verified, guaranteed payments
- **Society gains** financially literate young adults

---

## 🚀 Future Enhancements

### **Phase 2 Features**
- **Multi-sig wallets** for family accounts
- **DeFi integration** for allowance yield
- **Credit score NFTs** for reputation building
- **Merchant partnerships** for exclusive deals

### **Phase 3 Scale**
- **School district integration**
- **Real prepaid card rails**
- **Cross-chain reputation**
- **Global teen finance platform**

---

**The smart contracts are the heart of ClearSpend - they make the impossible possible: giving teens real financial freedom while giving parents real control, all through the power of blockchain technology.** 🎯
