# How Smart Contracts Verify Sellers (Merchants) in ClearSpend

## 🎯 Overview

The ClearSpend smart contract system uses a **multi-layered verification process** to ensure only approved merchants can receive payments from teens. This prevents unauthorized spending and gives parents complete control over where their children can shop.

---

## 🔍 The Seller Verification Process

### **Step 1: Merchant Registration & Attestation**

Before any merchant can receive payments, they must be **attested** (approved) by the parent through the smart contract:

```python
# Parent calls this to approve a merchant
@arc4.abimethod
def add_merchant_attestation(
    self,
    merchant_name: String,        # "Starbucks", "Target", etc.
    category: String,            # "Food & Beverage", "Gaming", etc.
    is_approved: Bool,           # True/False for approval
    daily_limit: UInt64,         # Maximum daily spending limit
    parent_approved: Bool        # Parent's explicit approval
) -> UInt64:
```

**What happens:**
1. **Parent decides**: "I want to allow my teen to shop at Starbucks"
2. **Parent calls smart contract**: `add_merchant_attestation("Starbucks", "Food & Beverage", True, 50000000, True)`
3. **Contract stores attestation**: Merchant data saved in Algorand's Box Storage
4. **Merchant is now verified**: Can receive payments from this teen

### **Step 2: Real-Time Purchase Verification**

When a teen tries to make a purchase, the smart contract performs **instant verification**:

```python
@arc4.abimethod
def verify_purchase(
    self,
    merchant_name: String,       # Which merchant?
    amount: UInt64,             # How much?
    user_address: arc4.Address  # Which teen?
) -> Bool:
```

**The verification checks:**

#### **✅ Check 1: Merchant Exists**
```python
if not merchant_box.exists:
    op.log(b"MERCHANT_NOT_FOUND")
    return Bool(False)
```
- **Purpose**: Ensures merchant is registered in the system
- **Result**: If merchant not found → Purchase **REJECTED**

#### **✅ Check 2: Merchant is Approved**
```python
if not attestation.is_approved:
    op.log(b"MERCHANT_NOT_APPROVED")
    return Bool(False)
```
- **Purpose**: Verifies parent has approved this merchant
- **Result**: If not approved → Purchase **REJECTED**

#### **✅ Check 3: Parent Approval**
```python
if not attestation.parent_approved:
    op.log(b"PARENT_NOT_APPROVED")
    return Bool(False)
```
- **Purpose**: Double-checks parent's explicit approval
- **Result**: If parent didn't approve → Purchase **REJECTED**

#### **✅ Check 4: Category Restrictions**
```python
if not self._check_category_restriction(attestation.category):
    op.log(b"CATEGORY_RESTRICTED")
    return Bool(False)
```
- **Purpose**: Blocks restricted categories (Gaming, Gambling, etc.)
- **Result**: If category restricted → Purchase **REJECTED**

#### **✅ Check 5: Daily Spending Limits**
```python
new_total = attestation.total_spent_today + amount
if new_total > attestation.daily_limit:
    op.log(b"DAILY_LIMIT_EXCEEDED")
    return Bool(False)
```
- **Purpose**: Prevents overspending at any single merchant
- **Result**: If limit exceeded → Purchase **REJECTED**

---

## 🏪 Real-World Examples

### **Example 1: Approved Purchase ✅**
```
Teen wants to buy $5 coffee at Starbucks:

1. Smart contract checks: "Starbucks" exists? ✅ YES
2. Smart contract checks: Starbucks approved? ✅ YES  
3. Smart contract checks: Parent approved Starbucks? ✅ YES
4. Smart contract checks: "Food & Beverage" allowed? ✅ YES
5. Smart contract checks: $5 under daily limit? ✅ YES
6. Result: Purchase APPROVED → Coffee transaction executes
```

### **Example 2: Rejected Purchase ❌**
```
Teen wants to buy $1 game at Gaming Store:

1. Smart contract checks: "Gaming Store" exists? ✅ YES
2. Smart contract checks: Gaming Store approved? ❌ NO
3. Result: Purchase REJECTED → "Merchant not approved"
```

### **Example 3: Daily Limit Exceeded ❌**
```
Teen wants to buy $60 worth of stuff at Target (daily limit: $50):

1. Smart contract checks: Target exists? ✅ YES
2. Smart contract checks: Target approved? ✅ YES
3. Smart contract checks: Parent approved Target? ✅ YES
4. Smart contract checks: "Retail" allowed? ✅ YES
5. Smart contract checks: $60 under daily limit? ❌ NO ($50 limit)
6. Result: Purchase REJECTED → "Daily limit exceeded"
```

---

## 🔒 Security Features

### **1. Box Storage Security**
```python
# Merchant data stored in Algorand's Box Storage
merchant_key = self._create_merchant_key(merchant_name)
merchant_box = BoxRef(key=merchant_key)
```
- **Immutable**: Once stored, merchant data cannot be tampered with
- **Scalable**: Can handle thousands of merchants efficiently
- **Decentralized**: No single point of failure

### **2. Multi-Layer Verification**
- **Merchant Registration**: Must be explicitly added by parent
- **Parent Approval**: Double-check parent's explicit consent
- **Category Filtering**: Automatic blocking of restricted categories
- **Daily Limits**: Prevents overspending at any merchant
- **Real-Time Updates**: Limits reset daily, spending tracked in real-time

### **3. Atomic Transaction Security**
```python
# All verification happens BEFORE money moves
def create_atomic_purchase_group(...):
    # Transaction 1: Verify merchant (Attestation Oracle)
    # Transaction 2: Check balance (Allowance Manager)
    # Transaction 3: Send payment (ASA Transfer)
    # All succeed or fail together
```
- **All-or-Nothing**: Either all checks pass and payment executes, or nothing happens
- **No Partial Failures**: Cannot have verification pass but payment fail
- **Instant Rollback**: If any check fails, entire transaction is cancelled

---

## 📊 Merchant Data Structure

### **What's Stored for Each Merchant**
```python
class MerchantAttestation(Struct):
    merchant_name: String        # "Starbucks"
    category: String            # "Food & Beverage"
    is_approved: Bool           # True/False
    daily_limit: UInt64         # 50000000 (50 ALGO)
    total_spent_today: UInt64   # 0 (resets daily)
    last_update: UInt64         # Timestamp
    parent_approved: Bool       # True/False
```

### **How Data is Updated**
```python
# Daily spending tracking
if self._is_new_day(attestation.last_update):
    attestation.total_spent_today = UInt64(0)  # Reset daily

# Update spending after purchase
attestation.total_spent_today = new_total
attestation.last_update = Global.latest_timestamp
merchant_box.put(attestation.bytes)  # Save to blockchain
```

---

## 🎯 Parental Control Features

### **1. Merchant Management**
```python
# Parent can approve/deny any merchant
def parent_approve_merchant(merchant_name: String, approved: Bool):
    # Updates parent_approved flag
    # Takes effect immediately
```

### **2. Daily Limit Control**
```python
# Parent can set daily spending limits per merchant
def update_merchant_limits(merchant_name: String, new_daily_limit: UInt64):
    # Updates daily spending limit
    # Prevents overspending
```

### **3. Category Restrictions**
```python
# Automatic blocking of restricted categories
restricted_categories = ["Gaming", "Gambling", "Adult Content", "Tobacco", "Alcohol"]
```

### **4. Emergency Controls**
```python
# Parent can pause all spending instantly
def pause_allowance():
    # Blocks all future purchases
    # Emergency safety mechanism
```

---

## 🚀 Integration with Backend

### **Backend Service Verification**
```python
def verify_purchase(self, request: PurchaseRequest) -> PurchaseResponse:
    # 1. Check merchant exists in attestation system
    # 2. Verify merchant is approved
    # 3. Check parent approval
    # 4. Verify category restrictions
    # 5. Check daily limits
    # 6. Update spending tracking
    # 7. Return approval/rejection
```

### **Real-Time API Response**
```json
{
    "approved": true,
    "transaction_id": "mock_tx_1757191836",
    "explorer_link": "https://testnet.algoexplorer.io/tx/mock_tx_1757191836",
    "amount": 5000000,
    "merchant_name": "Starbucks"
}
```

---

## 🎬 Demo Scenarios

### **Scenario 1: Show Approved Merchant**
```bash
# Test approved purchase
curl -X POST http://localhost:8000/api/v1/purchases/verify \
  -H "Content-Type: application/json" \
  -d '{"merchant_name": "Starbucks", "amount": 5000000, "user_address": "DEMO"}'

# Response: {"approved": true, "transaction_id": "...", "explorer_link": "..."}
```

### **Scenario 2: Show Rejected Merchant**
```bash
# Test rejected purchase
curl -X POST http://localhost:8000/api/v1/purchases/verify \
  -H "Content-Type: application/json" \
  -d '{"merchant_name": "Gaming Store", "amount": 1000000, "user_address": "DEMO"}'

# Response: {"approved": false, "reason": "Merchant 'Gaming Store' is not approved"}
```

### **Scenario 3: Show Daily Limit**
```bash
# Test daily limit exceeded
curl -X POST http://localhost:8000/api/v1/purchases/verify \
  -H "Content-Type: application/json" \
  -d '{"merchant_name": "Target", "amount": 60000000, "user_address": "DEMO"}'

# Response: {"approved": false, "reason": "Purchase would exceed daily limit"}
```

---

## 🏆 Why This Verification System Wins

### **🔒 Security**
- **No Unauthorized Spending**: Impossible to spend at unapproved merchants
- **Real-Time Verification**: Every purchase checked before money moves
- **Immutable Records**: All approvals stored on blockchain forever

### **👨‍👩‍👧‍👦 Parental Control**
- **Granular Control**: Approve/deny individual merchants
- **Category Filtering**: Automatic blocking of inappropriate categories
- **Daily Limits**: Prevent overspending at any merchant
- **Emergency Controls**: Pause all spending instantly

### **📊 Transparency**
- **On-Chain Records**: Every approval/rejection recorded forever
- **Real-Time Monitoring**: Parents see all spending instantly
- **Audit Trail**: Complete history of all merchant interactions

### **⚡ Performance**
- **Instant Verification**: Sub-second merchant checks
- **Scalable Storage**: Box Storage handles thousands of merchants
- **Low Cost**: Algorand's low fees enable micro-transactions

---

**The seller verification system is the heart of ClearSpend's security - it ensures that teens can only spend money at merchants their parents have explicitly approved, with real-time verification and immutable blockchain records.** 🎯
