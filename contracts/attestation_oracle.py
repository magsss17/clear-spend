from algopy import ARC4Contract, UInt64, Bytes, Global, Txn, op, subroutine, BoxRef, arc4
from algopy.arc4 import String, Bool, Struct, DynamicArray

class MerchantAttestation(Struct):
    merchant_name: String
    category: String
    is_approved: Bool
    daily_limit: UInt64
    total_spent_today: UInt64
    last_update: UInt64

class PurchaseAttestation(ARC4Contract):
    """
    ClearSpend Purchase Attestation Oracle
    Verifies merchant purchases through atomic transfers
    """
    
    @arc4.abimethod(create="require")
    def initialize(self, oracle_address: arc4.Address) -> None:
        """Initialize the contract with oracle address"""
        self.oracle = oracle_address
        self.admin = Txn.sender
    
    @arc4.abimethod
    def add_merchant_attestation(
        self,
        merchant_name: String,
        category: String,
        is_approved: Bool,
        daily_limit: UInt64
    ) -> None:
        """Add or update merchant attestation (oracle only)"""
        assert Txn.sender == self.oracle.native, "Only oracle can add attestations"
        
        attestation = MerchantAttestation(
            merchant_name=merchant_name,
            category=category,
            is_approved=is_approved,
            daily_limit=daily_limit,
            total_spent_today=UInt64(0),
            last_update=Global.latest_timestamp
        )
        
        # Store in box storage
        merchant_box = BoxRef(key=merchant_name.bytes)
        merchant_box.put(attestation.bytes)
    
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
        merchant_box = BoxRef(key=merchant_name.bytes)
        
        if not merchant_box.exists:
            return Bool(False)
        
        attestation_bytes = merchant_box.get()
        attestation = MerchantAttestation.from_bytes(attestation_bytes)
        
        # Check if merchant is approved
        if not attestation.is_approved:
            return Bool(False)
        
        # Check daily limit
        if self._is_new_day(attestation.last_update):
            # Reset daily spending if it's a new day
            attestation.total_spent_today = UInt64(0)
        
        new_total = attestation.total_spent_today + amount
        if new_total > attestation.daily_limit:
            return Bool(False)
        
        # Update spending
        attestation.total_spent_today = new_total
        attestation.last_update = Global.latest_timestamp
        merchant_box.put(attestation.bytes)
        
        # Log the verification
        op.log(merchant_name.bytes)
        op.log(op.itob(amount))
        op.log(user_address.bytes)
        
        return Bool(True)
    
    @arc4.abimethod
    def check_category_restriction(
        self,
        category: String,
        user_address: arc4.Address
    ) -> Bool:
        """Check if category is restricted for user"""
        
        # Define restricted categories
        restricted = [b"Gaming", b"Gambling", b"Adult Content"]
        
        for restricted_cat in restricted:
            if category.bytes == restricted_cat:
                return Bool(False)
        
        return Bool(True)
    
    @arc4.abimethod(readonly=True)
    def get_merchant_info(self, merchant_name: String) -> MerchantAttestation:
        """Get merchant attestation details"""
        merchant_box = BoxRef(key=merchant_name.bytes)
        
        assert merchant_box.exists, "Merchant not found"
        
        attestation_bytes = merchant_box.get()
        return MerchantAttestation.from_bytes(attestation_bytes)
    
    @arc4.abimethod
    def update_oracle(self, new_oracle: arc4.Address) -> None:
        """Update oracle address (admin only)"""
        assert Txn.sender == self.admin, "Only admin can update oracle"
        self.oracle = new_oracle
    
    @subroutine
    def _is_new_day(self, last_timestamp: UInt64) -> bool:
        """Check if it's a new day since last update"""
        current_time = Global.latest_timestamp
        seconds_in_day = UInt64(86400)
        
        current_day = current_time // seconds_in_day
        last_day = last_timestamp // seconds_in_day
        
        return current_day > last_day