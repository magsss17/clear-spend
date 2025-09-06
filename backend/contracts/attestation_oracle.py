"""
ClearSpend Attestation Oracle Smart Contract
Manages merchant attestations and purchase verification using AlgoKit
"""

from algopy import ARC4Contract, UInt64, Bytes, Global, Txn, op, subroutine, BoxRef, arc4
from algopy.arc4 import String, Bool, Struct, DynamicArray, Address

class MerchantAttestation(Struct):
    """Merchant attestation data structure"""
    merchant_name: String
    category: String
    is_approved: Bool
    daily_limit: UInt64
    total_spent_today: UInt64
    last_update: UInt64
    parent_approved: Bool

class PurchaseRequest(Struct):
    """Purchase request data structure"""
    merchant_name: String
    amount: UInt64
    user_address: Address
    timestamp: UInt64

class AttestationOracle(ARC4Contract):
    """
    ClearSpend Purchase Attestation Oracle
    Verifies merchant purchases through atomic transfers and box storage
    """
    
    @arc4.abimethod(create="require")
    def initialize(self, oracle_address: arc4.Address) -> None:
        """Initialize the contract with oracle address"""
        self.oracle = oracle_address
        self.admin = Txn.sender
        self.total_merchants = UInt64(0)
        self.total_verifications = UInt64(0)
    
    @arc4.abimethod
    def add_merchant_attestation(
        self,
        merchant_name: String,
        category: String,
        is_approved: Bool,
        daily_limit: UInt64,
        parent_approved: Bool
    ) -> UInt64:
        """Add or update merchant attestation (oracle only)"""
        assert Txn.sender == self.oracle.native, "Only oracle can add attestations"
        
        # Create merchant attestation
        attestation = MerchantAttestation(
            merchant_name=merchant_name,
            category=category,
            is_approved=is_approved,
            daily_limit=daily_limit,
            total_spent_today=UInt64(0),
            last_update=Global.latest_timestamp,
            parent_approved=parent_approved
        )
        
        # Store in box storage with merchant name as key
        merchant_key = self._create_merchant_key(merchant_name)
        merchant_box = BoxRef(key=merchant_key)
        
        # Check if merchant already exists
        if not merchant_box.exists:
            self.total_merchants += UInt64(1)
        
        merchant_box.put(attestation.bytes)
        
        # Log the addition
        op.log(b"MERCHANT_ADDED")
        op.log(merchant_name.bytes)
        op.log(op.itob(self.total_merchants))
        
        return self.total_merchants
    
    @arc4.abimethod
    def verify_purchase(
        self,
        merchant_name: String,
        amount: UInt64,
        user_address: arc4.Address
    ) -> Bool:
        """
        Verify if purchase is allowed based on attestation
        Called as part of atomic transfer group
        """
        
        # Get merchant attestation from box storage
        merchant_key = self._create_merchant_key(merchant_name)
        merchant_box = BoxRef(key=merchant_key)
        
        if not merchant_box.exists:
            op.log(b"MERCHANT_NOT_FOUND")
            return Bool(False)
        
        attestation_bytes = merchant_box.get()
        attestation = MerchantAttestation.from_bytes(attestation_bytes)
        
        # Check if merchant is approved
        if not attestation.is_approved:
            op.log(b"MERCHANT_NOT_APPROVED")
            return Bool(False)
        
        # Check parent approval
        if not attestation.parent_approved:
            op.log(b"PARENT_NOT_APPROVED")
            return Bool(False)
        
        # Check category restrictions
        if not self._check_category_restriction(attestation.category):
            op.log(b"CATEGORY_RESTRICTED")
            return Bool(False)
        
        # Check daily limit
        if self._is_new_day(attestation.last_update):
            # Reset daily spending if it's a new day
            attestation.total_spent_today = UInt64(0)
        
        new_total = attestation.total_spent_today + amount
        if new_total > attestation.daily_limit:
            op.log(b"DAILY_LIMIT_EXCEEDED")
            return Bool(False)
        
        # Update spending
        attestation.total_spent_today = new_total
        attestation.last_update = Global.latest_timestamp
        merchant_box.put(attestation.bytes)
        
        # Increment verification counter
        self.total_verifications += UInt64(1)
        
        # Log the verification
        op.log(b"PURCHASE_VERIFIED")
        op.log(merchant_name.bytes)
        op.log(op.itob(amount))
        op.log(user_address.bytes)
        op.log(op.itob(self.total_verifications))
        
        return Bool(True)
    
    @arc4.abimethod
    def update_merchant_limits(
        self,
        merchant_name: String,
        new_daily_limit: UInt64,
        is_approved: Bool
    ) -> None:
        """Update merchant daily limits and approval status (oracle only)"""
        assert Txn.sender == self.oracle.native, "Only oracle can update limits"
        
        merchant_key = self._create_merchant_key(merchant_name)
        merchant_box = BoxRef(key=merchant_key)
        
        assert merchant_box.exists, "Merchant not found"
        
        attestation_bytes = merchant_box.get()
        attestation = MerchantAttestation.from_bytes(attestation_bytes)
        
        # Update limits
        attestation.daily_limit = new_daily_limit
        attestation.is_approved = is_approved
        attestation.last_update = Global.latest_timestamp
        
        merchant_box.put(attestation.bytes)
        
        op.log(b"MERCHANT_UPDATED")
        op.log(merchant_name.bytes)
        op.log(op.itob(new_daily_limit))
    
    @arc4.abimethod
    def parent_approve_merchant(
        self,
        merchant_name: String,
        approved: Bool
    ) -> None:
        """Allow parents to approve/disapprove specific merchants"""
        # In production, this would verify parent signature
        # For now, we'll allow any caller to simulate parent approval
        
        merchant_key = self._create_merchant_key(merchant_name)
        merchant_box = BoxRef(key=merchant_key)
        
        assert merchant_box.exists, "Merchant not found"
        
        attestation_bytes = merchant_box.get()
        attestation = MerchantAttestation.from_bytes(attestation_bytes)
        
        attestation.parent_approved = approved
        attestation.last_update = Global.latest_timestamp
        
        merchant_box.put(attestation.bytes)
        
        op.log(b"PARENT_APPROVAL_UPDATED")
        op.log(merchant_name.bytes)
        op.log(approved.bytes)
    
    @arc4.abimethod(readonly=True)
    def get_merchant_info(self, merchant_name: String) -> MerchantAttestation:
        """Get merchant attestation details"""
        merchant_key = self._create_merchant_key(merchant_name)
        merchant_box = BoxRef(key=merchant_key)
        
        assert merchant_box.exists, "Merchant not found"
        
        attestation_bytes = merchant_box.get()
        return MerchantAttestation.from_bytes(attestation_bytes)
    
    @arc4.abimethod(readonly=True)
    def get_contract_stats(self) -> tuple[UInt64, UInt64]:
        """Get contract statistics"""
        return (self.total_merchants, self.total_verifications)
    
    @arc4.abimethod
    def update_oracle(self, new_oracle: arc4.Address) -> None:
        """Update oracle address (admin only)"""
        assert Txn.sender == self.admin, "Only admin can update oracle"
        self.oracle = new_oracle
        
        op.log(b"ORACLE_UPDATED")
        op.log(new_oracle.bytes)
    
    @subroutine
    def _create_merchant_key(self, merchant_name: String) -> Bytes:
        """Create a unique key for merchant storage"""
        return Bytes(b"merchant_") + merchant_name.bytes
    
    @subroutine
    def _check_category_restriction(self, category: String) -> bool:
        """Check if category is restricted"""
        # Define restricted categories
        restricted = [b"Gaming", b"Gambling", b"Adult Content", b"Tobacco", b"Alcohol"]
        
        for restricted_cat in restricted:
            if category.bytes == restricted_cat:
                return False
        
        return True
    
    @subroutine
    def _is_new_day(self, last_timestamp: UInt64) -> bool:
        """Check if it's a new day since last update"""
        current_time = Global.latest_timestamp
        seconds_in_day = UInt64(86400)
        
        current_day = current_time // seconds_in_day
        last_day = last_timestamp // seconds_in_day
        
        return current_day > last_day
