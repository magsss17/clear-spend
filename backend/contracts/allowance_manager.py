"""
ClearSpend Allowance Manager Smart Contract
Manages teen allowances with parental controls using AlgoKit
"""

from algopy import ARC4Contract, UInt64, Bytes, Global, Txn, op, subroutine, arc4
from algopy.arc4 import String, Bool, Address, DynamicArray

class AllowanceRecord(ARC4Contract):
    """Allowance record data structure"""
    teen_address: Address
    weekly_amount: UInt64
    last_allowance_time: UInt64
    total_issued: UInt64
    is_paused: Bool
    savings_locked: UInt64
    savings_unlock_time: UInt64

class AllowanceManager(ARC4Contract):
    """
    ClearSpend Allowance Management Contract
    Manages teen allowances with parental controls and savings features
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
        self.total_issued = UInt64(0)
        self.savings_locked = UInt64(0)
        self.savings_unlock_time = UInt64(0)
        self.contract_created = Global.latest_timestamp
    
    @arc4.abimethod
    def issue_weekly_allowance(self) -> UInt64:
        """Issue weekly allowance (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can issue allowance"
        assert not self.is_paused, "Allowance is currently paused"
        
        # Check if a week has passed
        current_time = Global.latest_timestamp
        week_in_seconds = UInt64(604800)  # 7 days
        
        assert current_time >= self.last_allowance_time + week_in_seconds, "Weekly allowance already issued"
        
        # Update last allowance time and total issued
        self.last_allowance_time = current_time
        self.total_issued += self.weekly_allowance
        
        # Log the allowance issuance
        op.log(b"ALLOWANCE_ISSUED")
        op.log(op.itob(self.weekly_allowance))
        op.log(op.itob(self.total_issued))
        op.log(op.itob(current_time))
        
        return self.weekly_allowance
    
    @arc4.abimethod
    def issue_emergency_allowance(self, amount: UInt64) -> UInt64:
        """Issue emergency allowance (parent only, bypasses weekly limit)"""
        assert Txn.sender == self.parent.native, "Only parent can issue emergency allowance"
        assert not self.is_paused, "Allowance is currently paused"
        assert amount > UInt64(0), "Amount must be positive"
        
        # Update total issued
        self.total_issued += amount
        
        op.log(b"EMERGENCY_ALLOWANCE_ISSUED")
        op.log(op.itob(amount))
        op.log(op.itob(self.total_issued))
        
        return amount
    
    @arc4.abimethod
    def pause_allowance(self) -> None:
        """Pause allowance (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can pause"
        self.is_paused = Bool(True)
        
        op.log(b"ALLOWANCE_PAUSED")
        op.log(op.itob(Global.latest_timestamp))
    
    @arc4.abimethod
    def resume_allowance(self) -> None:
        """Resume allowance (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can resume"
        self.is_paused = Bool(False)
        
        op.log(b"ALLOWANCE_RESUMED")
        op.log(op.itob(Global.latest_timestamp))
    
    @arc4.abimethod
    def update_weekly_amount(self, new_amount: UInt64) -> None:
        """Update weekly allowance amount (parent only)"""
        assert Txn.sender == self.parent.native, "Only parent can update amount"
        assert new_amount > UInt64(0), "Amount must be positive"
        
        old_amount = self.weekly_allowance
        self.weekly_allowance = new_amount
        
        op.log(b"WEEKLY_AMOUNT_UPDATED")
        op.log(op.itob(old_amount))
        op.log(op.itob(new_amount))
    
    @arc4.abimethod
    def timelock_savings(
        self,
        amount: UInt64,
        unlock_time: UInt64
    ) -> Bool:
        """Lock funds until specified time (teen feature)"""
        assert Txn.sender == self.teen.native, "Only teen can lock savings"
        assert unlock_time > Global.latest_timestamp, "Unlock time must be in future"
        assert amount > UInt64(0), "Amount must be positive"
        
        # Check if there are existing locked savings
        if self.savings_locked > UInt64(0):
            # If unlock time has passed, release previous savings
            if Global.latest_timestamp >= self.savings_unlock_time:
                self.savings_locked = UInt64(0)
                self.savings_unlock_time = UInt64(0)
            else:
                # Cannot lock new savings while old ones are still locked
                return Bool(False)
        
        # Lock new savings
        self.savings_locked = amount
        self.savings_unlock_time = unlock_time
        
        op.log(b"SAVINGS_LOCKED")
        op.log(op.itob(amount))
        op.log(op.itob(unlock_time))
        
        return Bool(True)
    
    @arc4.abimethod
    def unlock_savings(self) -> UInt64:
        """Unlock savings if time has passed (teen feature)"""
        assert Txn.sender == self.teen.native, "Only teen can unlock savings"
        assert self.savings_locked > UInt64(0), "No locked savings"
        assert Global.latest_timestamp >= self.savings_unlock_time, "Savings still locked"
        
        unlocked_amount = self.savings_locked
        self.savings_locked = UInt64(0)
        self.savings_unlock_time = UInt64(0)
        
        op.log(b"SAVINGS_UNLOCKED")
        op.log(op.itob(unlocked_amount))
        
        return unlocked_amount
    
    @arc4.abimethod
    def process_purchase_atomic(
        self,
        merchant_name: String,
        amount: UInt64
    ) -> Bool:
        """
        Process purchase as part of atomic group
        Group should contain:
        1. App call to attestation oracle (verify purchase)
        2. This app call (check allowance limits)
        3. ASA transfer (execute payment)
        """
        
        # Verify not paused
        assert not self.is_paused, "Allowance is paused"
        
        # Verify teen is sender
        assert Txn.sender == self.teen.native, "Only teen can make purchases"
        
        # Verify atomic group structure
        assert Global.group_size == UInt64(3), "Invalid atomic group"
        
        # This should be the second transaction in the group
        assert Txn.group_index == UInt64(1), "Invalid group position"
        
        # Check if amount is reasonable (not more than weekly allowance)
        assert amount <= self.weekly_allowance, "Purchase exceeds weekly allowance"
        
        # Log purchase
        op.log(b"PURCHASE_PROCESSED")
        op.log(merchant_name.bytes)
        op.log(op.itob(amount))
        op.log(op.itob(Global.latest_timestamp))
        
        return Bool(True)
    
    @arc4.abimethod
    def transfer_allowance_control(self, new_parent: Address) -> None:
        """Transfer allowance control to new parent (current parent only)"""
        assert Txn.sender == self.parent.native, "Only current parent can transfer control"
        
        old_parent = self.parent
        self.parent = new_parent
        
        op.log(b"CONTROL_TRANSFERRED")
        op.log(old_parent.bytes)
        op.log(new_parent.bytes)
    
    @arc4.abimethod(readonly=True)
    def get_allowance_status(self) -> tuple[UInt64, Bool, UInt64, UInt64, UInt64, UInt64]:
        """Get current allowance status"""
        return (
            self.weekly_allowance,
            self.is_paused,
            self.last_allowance_time,
            self.total_issued,
            self.savings_locked,
            self.savings_unlock_time
        )
    
    @arc4.abimethod(readonly=True)
    def get_contract_info(self) -> tuple[Address, Address, UInt64, UInt64]:
        """Get contract information"""
        return (
            self.parent,
            self.teen,
            self.attestation_app_id,
            self.contract_created
        )
    
    @arc4.abimethod(readonly=True)
    def can_issue_allowance(self) -> Bool:
        """Check if weekly allowance can be issued"""
        if self.is_paused:
            return Bool(False)
        
        current_time = Global.latest_timestamp
        week_in_seconds = UInt64(604800)
        
        return Bool(current_time >= self.last_allowance_time + week_in_seconds)
    
    @arc4.abimethod(readonly=True)
    def can_unlock_savings(self) -> Bool:
        """Check if savings can be unlocked"""
        if self.savings_locked == UInt64(0):
            return Bool(False)
        
        return Bool(Global.latest_timestamp >= self.savings_unlock_time)
