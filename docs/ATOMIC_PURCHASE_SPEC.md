# Atomic purchase flow (MVP spec)

This document is the **source of truth** for the 3-transaction **ALGO** atomic purchase group used by ClearSpend. It aligns with the on-chain–only MVP (no DB, no Apple Pay). High-level vision notes live in [ONCHAIN_ARCHITECTURE_PLAN.md](ONCHAIN_ARCHITECTURE_PLAN.md).

## Transaction group (fixed size = 3)

| Index | Type | Sender | App / receiver | Purpose |
|-------|------|--------|----------------|----------|
| **0** | ApplicationCall | **Teen** | **AttestationOracle** app (`attestation_app_id` from AllowanceManager) | `verify_purchase(merchant_name, amount, user_address)` — merchant policy + daily limit; binds payment txn 2 to `merchant_address` on-chain |
| **1** | ApplicationCall | **Teen** | **AllowanceManager** app | `process_purchase_atomic(merchant_name, amount)` — pause / instance active / weekly cap; validates txn 0 and txn 2 |
| **2** | Payment | **Teen** | **Merchant** (ALGO receiver) | Pay **exactly** `amount` microAlgos to the merchant address stored in the oracle attestation |

All three must succeed or the whole group fails.

## ABI methods (ARC-4)

### AttestationOracle

- **`add_merchant_attestation(merchant_name, category, is_approved, daily_limit, parent_approved, merchant_address)`**  
  - Callable only by **`oracle`** (`Txn.sender == self.oracle`).  
  - `merchant_address` is the **on-chain payout address** for txn 2.

- **`verify_purchase(merchant_name, amount, user_address)`**  
  - **Requires** `Global.group_size == 3` and `Txn.group_index == 0`.  
  - **Requires** `Txn.sender == user_address` (teen is the caller).  
  - Loads `MerchantAttestation` for `merchant_name` from box storage.  
  - **Requires** `gtxn.PaymentTransaction(2)` satisfies:
    - `sender == user_address`
    - `amount == amount` (arg)
    - `receiver == attestation.merchant_address` (native `Account`)  
  - Then runs approval / category / daily limit logic and updates `total_spent_today` when allowed.

- **`parent_approve_merchant(merchant_name, approved)`**  
  - Callable only by **`oracle`** (oracle attests off-chain parent consent). **Not** open to arbitrary callers.

### AllowanceManager

- **`initialize(parent_address, teen_address, weekly_allowance, attestation_app_id)`**  
  - Sets `is_live = True`, `spent_this_week = 0`, `week_bucket_start = 0`, etc.

- **`process_purchase_atomic(merchant_name, amount)`**  
  - **Requires** `Global.group_size == 3`, `Txn.group_index == 1`, `Txn.sender == teen`.  
  - **Requires** `is_live`, not `is_paused`.  
  - **Requires** `gtxn.ApplicationCallTransaction(0)`:
    - `app_id == Application(attestation_app_id)`
    - `sender == teen`  
  - **Requires** `gtxn.PaymentTransaction(2)`:
    - `sender == teen`
    - `amount == amount` (arg)  
  - **Weekly cap:** within the current **604800 s** bucket, `spent_this_week + amount <= weekly_allowance`; then increments `spent_this_week`.

- **`role_of(address) -> UInt64`** (readonly): `0` = none, `1` = parent, `2` = teen.

- **`get_instance_active() -> Bool`** (readonly): parent soft-disable flag.

- **`get_weekly_purchase_usage() -> (UInt64, UInt64)`** (readonly): `(spent_this_week, week_bucket_start)`.

- **`set_instance_active(active)`**: parent only; toggles `is_live`.

## Client / backend builder checklist

When constructing the group:

1. **Foreign apps**: both app calls must include the **other** app in foreign arrays if required by your SDK (typical: AM call includes AO app id; AO call may include AM for reads—follow deployment tooling defaults).

2. **Merchant address**: read from **`get_merchant_info(merchant_name)`** on the oracle (or equivalent off-chain indexer read of box data). The **PaymentTxn receiver must match** that address or txn 0 will reject.

3. **Same `amount`**: the arg to `verify_purchase` and `process_purchase_atomic` and the **PaymentTxn amount** must be identical (microAlgos).

4. **Same teen**: `user_address` in `verify_purchase` must equal the **sender** of all three transactions.

5. **Optional traceability**: set payment `note` to a short `purchase_ref` (bytes) for Indexer correlation (off-chain convention; not enforced by these contracts).

## ABI / deployment note

`MerchantAttestation` on-chain now includes **`merchant_address`**. Existing deployments that stored the **old** struct layout **must be redeployed** or re-seeded; box bytes are not auto-migrated.

## Testnet smoke checklist

1. Deploy **AttestationOracle** and **AllowanceManager**; run `initialize` on both; link AM with `attestation_app_id`.
2. As **oracle**, call **`add_merchant_attestation`** with a real testnet **merchant payout address**.
3. As **oracle**, ensure **`parent_approve_merchant`** is set as needed (`approved=True`) if attestation requires it.
4. Fund the **teen** account with enough ALGO for amount + fees.
5. Build atomic group (txn order 0 → 1 → 2) with correct ARC-4 args and **PaymentTxn** to `merchant_address`.
6. Sign all three with the **teen** key; submit group.
7. **Expect success:** explorer shows one atomic group; teen balance decreases by `amount + fees`; merchant receives `amount`.
8. **Expect failure cases:**
   - Wrong payment receiver → group fails (oracle rejects).
   - `amount` mismatch between pay and app args → group fails.
   - `weekly_allowance` exceeded by cumulative spends in the same week bucket → AM rejects.
   - `pause_allowance` → AM rejects.
   - `set_instance_active(False)` → AM rejects.
9. Read **`get_weekly_purchase_usage`** after a successful purchase and confirm `spent_this_week` increased.
10. Read **`role_of`** for parent and teen addresses and confirm `1` and `2`.
