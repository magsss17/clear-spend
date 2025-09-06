from algopy import ARC4Contract, UInt64, Bytes, Global, Txn, op, subroutine, arc4
from algopy.arc4 import String, Bool, Address, DynamicArray

class AllowanceManager(ARC4Contract):
    """
    ClearSpend Allowance Management Contract
    Manages teen allowances with parental controls
    """
    
    @arc4.abimethod(create="require")
    def initialize(
        self,
        parent_address: Address,
        teen_address: Address,
        weekly_allowance: UInt64,
        attestation_app_id: UInt64
    ) -> None:
        """Initialize allowance contract"""
        self.parent = parent_address
        self.teen = teen_address
        self.weekly_allowance = weekly_allowance
        self.attestation_app_id = attestation_app_id
        self.last_allowance_time = Global.latest_timestamp
        self.is_paused = Bool(False)
    
    @arc4.abimethod
    def issue_weekly_allowance(self) -> UInt64:
        """Issue weekly allowance (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can issue allowance"
        
        # Check if a week has passed
        current_time = Global.latest_timestamp
        week_in_seconds = UInt64(604800)  # 7 days
        
        assert current_time >= self.last_allowance_time + week_in_seconds, "Weekly allowance already issued"
        
        # Update last allowance time
        self.last_allowance_time = current_time
        
        # Transfer would happen here in production
        op.log(op.itob(self.weekly_allowance))
        
        return self.weekly_allowance
    
    @arc4.abimethod
    def pause_allowance(self) -> None:
        """Pause allowance (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can pause"
        self.is_paused = Bool(True)
    
    @arc4.abimethod
    def resume_allowance(self) -> None:
        """Resume allowance (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can resume"
        self.is_paused = Bool(False)
    
    @arc4.abimethod
    def update_weekly_amount(self, new_amount: UInt64) -> None:
        """Update weekly allowance amount (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can update amount"
        self.weekly_allowance = new_amount
    
    @arc4.abimethod
    def timelock_savings(
        self,
        amount: UInt64,
        unlock_time: UInt64
    ) -> Bool:
        """Lock funds until specified time (teen feature)"""
        assert Txn.sender == self.teen.native, "Only teen can lock savings"
        assert unlock_time > Global.latest_timestamp, "Unlock time must be in future"
        
        # Store timelock info (would integrate with actual ASA transfer)
        op.log(op.itob(amount))
        op.log(op.itob(unlock_time))
        
        return Bool(True)
    
    @arc4.abimethod(readonly=True)
    def get_allowance_status(self) -> tuple[UInt64, Bool, UInt64]:
        """Get current allowance status"""
        return (
            self.weekly_allowance,
            self.is_paused,
            self.last_allowance_time
        )
    
    @arc4.abimethod
    def process_purchase_atomic(
        self,
        merchant_name: String,
        amount: UInt64
    ) -> Bool:
        """
        Process purchase as part of atomic group
        Group should contain:
        1. App call to attestation oracle
        2. This app call
        3. ASA transfer
        """
        
        # Verify not paused
        assert not self.is_paused, "Allowance is paused"
        
        # Verify teen is sender
        assert Txn.sender == self.teen.native, "Only teen can make purchases"
        
        # Verify atomic group structure
        assert Global.group_size == UInt64(3), "Invalid atomic group"
        
        # First transaction should be attestation check
        assert Txn.group_index == UInt64(1), "Invalid group position"
        
        # Log purchase
        op.log(merchant_name.bytes)
        op.log(op.itob(amount))
        
        return Bool(True)