# Merchant Integration Fix

## Problem Identified

The parent approved merchants in the iOS app were not linked to the backend approved merchants. This created a disconnect where:

1. **Frontend Issues:**
   - `ParentControlView` used hardcoded `ApprovedMerchant.examples` instead of real backend data
   - `addMerchant()` function only printed to console without calling backend API
   - No real-time synchronization between parent approval changes and backend merchant attestations

2. **Backend Issues:**
   - Backend had proper merchant management endpoints, but iOS app wasn't using them
   - API response format didn't match what the iOS app expected

## Solution Implemented

### 1. Updated iOS App Models (`Transaction.swift`)

**Enhanced `ApprovedMerchant` struct:**
```swift
struct ApprovedMerchant: Identifiable, Codable {
    let id = UUID()
    let name: String
    let category: String
    let icon: String
    let isVerified: Bool
    let isApproved: Bool           // NEW: Backend approval status
    let parentApproved: Bool       // NEW: Parent approval status
    let dailyLimit: Int           // NEW: Daily spending limit
    let totalSpentToday: Int      // NEW: Amount spent today
    let lastUpdate: Int           // NEW: Last update timestamp
    
    // NEW: Computed properties
    var categoryIcon: String { ... }
    var dailyUsagePercent: Double { ... }
}
```

### 2. Enhanced AlgorandService (`AlgorandService.swift`)

**Added merchant management functions:**
```swift
// Fetch merchants from backend
func fetchMerchants() async -> [ApprovedMerchant]

// Add new merchant to backend
func addMerchant(name: String, category: String, dailyLimit: Int) async -> Bool

// Update parent approval status
func updateParentApproval(merchantName: String, approved: Bool) async -> Bool
```

### 3. Updated ParentControlView (`ParentControlView.swift`)

**Key improvements:**
- **Real-time data loading:** Uses `@State` variables to manage merchant data
- **Backend integration:** Calls `algorandService.fetchMerchants()` on view load
- **Interactive merchant management:** 
  - Toggle parent approval with visual feedback
  - Add new merchants that sync with backend
  - Show daily usage percentages and limits
- **User feedback:** Alert messages for successful/failed operations

**New UI features:**
```swift
// Dynamic merchant list with real backend data
ForEach(approvedMerchants, id: \.id) { merchant in
    merchantRow(merchant)
}

// Interactive approval toggle
Button(action: {
    Task {
        await toggleParentApproval(merchant)
    }
}) {
    Image(systemName: merchant.parentApproved ? "checkmark.circle.fill" : "xmark.circle.fill")
        .foregroundColor(merchant.parentApproved ? .green : .red)
}
```

### 4. Fixed Backend API Response (`merchants.py`)

**Updated endpoint format:**
```python
# Before: Dict[str, MerchantAttestationResponse]
# After: Dict[str, List[MerchantAttestationResponse]]

@router.get("/", response_model=Dict[str, List[MerchantAttestationResponse]])
async def get_all_merchants():
    # Returns: {"merchants": [merchant1, merchant2, ...]}
    return {"merchants": merchants}
```

## Integration Flow

### 1. **Loading Merchants**
```
iOS App → GET /api/v1/merchants/ → Backend → OracleService → Smart Contract
       ← [merchants array] ← Backend ← OracleService ← Smart Contract
```

### 2. **Adding Merchants**
```
Parent Control → Add Merchant → POST /api/v1/merchants/ → Backend → OracleService → Smart Contract
              ← Success/Failure ← Backend ← OracleService ← Smart Contract
```

### 3. **Updating Parent Approval**
```
Parent Control → Toggle Approval → POST /api/v1/merchants/{name}/parent-approval → Backend
               ← Success/Failure ← Backend ← OracleService ← Smart Contract
```

## Testing

Created `test_merchant_integration.py` to verify:
- ✅ Backend API endpoints work correctly
- ✅ API response format matches iOS app expectations
- ✅ Parent approval updates are persisted
- ✅ New merchants can be added successfully

## Benefits

1. **Real-time Synchronization:** Parent approval changes immediately sync with backend
2. **Persistent Data:** Merchant approvals are stored in smart contracts, not just local state
3. **Enhanced UX:** Visual feedback, loading states, and error handling
4. **Scalable Architecture:** Backend manages all merchant data centrally
5. **Blockchain Integration:** All changes are recorded on-chain for transparency

## Usage

1. **Start Backend:**
   ```bash
   cd backend && python main.py
   ```

2. **Test Integration:**
   ```bash
   python test_merchant_integration.py
   ```

3. **Use iOS App:**
   - Navigate to Parent Controls
   - View real merchant data from backend
   - Add new merchants
   - Toggle parent approval for existing merchants

The merchant approval system is now fully integrated between the iOS frontend and Python backend, with all changes persisted on the Algorand blockchain through smart contracts.
