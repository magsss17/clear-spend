"""
ClearSpend Oracle Service
Manages merchant attestations and purchase verification
"""

import os
import json
from typing import Dict, List, Optional
from datetime import datetime, timedelta
from pydantic import BaseModel
import logging
from .blockchain_service import BlockchainService

logger = logging.getLogger(__name__)

class MerchantAttestation(BaseModel):
    """Merchant attestation data model"""
    merchant_name: str
    category: str
    is_approved: bool
    daily_limit: int  # in microAlgos
    total_spent_today: int
    last_update: int
    parent_approved: bool
    merchant_address: Optional[str] = None

class PurchaseRequest(BaseModel):
    """Purchase request data model"""
    merchant_name: str
    amount: int  # in microAlgos
    user_address: str
    timestamp: Optional[int] = None

class PurchaseResponse(BaseModel):
    """Purchase response data model"""
    approved: bool
    reason: Optional[str] = None
    transaction_id: Optional[str] = None
    explorer_link: Optional[str] = None

class OracleService:
    """Service for managing merchant attestations and purchase verification"""
    
    def __init__(self, blockchain_service: BlockchainService):
        self.blockchain_service = blockchain_service
        self.merchant_attestations: Dict[str, MerchantAttestation] = {}
        self.oracle_private_key = os.getenv("ORACLE_PRIVATE_KEY", "")
        self._initialize_demo_merchants()
    
    def _initialize_demo_merchants(self):
        """Initialize demo merchants for testing"""
        demo_merchants = {
            "Starbucks": {
                "merchant_name": "Starbucks",
                "category": "Food & Beverage",
                "is_approved": True,
                "daily_limit": 50000000,  # 50 ALGO
                "total_spent_today": 0,
                "last_update": int(datetime.now().timestamp()),
                "parent_approved": True,
                "merchant_address": "DEMO_STARBUCKS_ADDRESS"
            },
            "Target": {
                "merchant_name": "Target",
                "category": "Retail",
                "is_approved": True,
                "daily_limit": 100000000,  # 100 ALGO
                "total_spent_today": 0,
                "last_update": int(datetime.now().timestamp()),
                "parent_approved": True,
                "merchant_address": "DEMO_TARGET_ADDRESS"
            },
            "Gaming Store": {
                "merchant_name": "Gaming Store",
                "category": "Gaming",
                "is_approved": False,
                "daily_limit": 0,
                "total_spent_today": 0,
                "last_update": int(datetime.now().timestamp()),
                "parent_approved": False,
                "merchant_address": "DEMO_GAMING_ADDRESS"
            },
            "Bookstore": {
                "merchant_name": "Bookstore",
                "category": "Education",
                "is_approved": True,
                "daily_limit": 30000000,  # 30 ALGO
                "total_spent_today": 0,
                "last_update": int(datetime.now().timestamp()),
                "parent_approved": True,
                "merchant_address": "DEMO_BOOKSTORE_ADDRESS"
            }
        }
        
        for name, data in demo_merchants.items():
            self.merchant_attestations[name] = MerchantAttestation(**data)
    
    def add_merchant_attestation(self, attestation: MerchantAttestation) -> Dict:
        """Add or update merchant attestation"""
        try:
            # Store locally
            self.merchant_attestations[attestation.merchant_name] = attestation
            
            # In production, this would also update the blockchain
            if self.blockchain_service.attestation_oracle_app_id and self.oracle_private_key:
                result = self.blockchain_service.call_attestation_oracle(
                    self.oracle_private_key,
                    "add_merchant_attestation",
                    [
                        attestation.merchant_name.encode(),
                        attestation.category.encode(),
                        str(attestation.is_approved).encode(),
                        attestation.daily_limit.to_bytes(8, 'big'),
                        str(attestation.parent_approved).encode()
                    ]
                )
                
                if not result.get("success"):
                    logger.error(f"Failed to update blockchain: {result.get('error')}")
                    return {"error": "Failed to update blockchain"}
            
            logger.info(f"Added merchant attestation for {attestation.merchant_name}")
            return {"success": True, "merchant": attestation.merchant_name}
            
        except Exception as e:
            logger.error(f"Failed to add merchant attestation: {e}")
            return {"error": str(e)}
    
    def update_merchant_limits(
        self, 
        merchant_name: str, 
        new_daily_limit: int, 
        is_approved: bool
    ) -> Dict:
        """Update merchant daily limits and approval status"""
        try:
            if merchant_name not in self.merchant_attestations:
                return {"error": "Merchant not found"}
            
            merchant = self.merchant_attestations[merchant_name]
            merchant.daily_limit = new_daily_limit
            merchant.is_approved = is_approved
            merchant.last_update = int(datetime.now().timestamp())
            
            # Update blockchain
            if self.blockchain_service.attestation_oracle_app_id and self.oracle_private_key:
                result = self.blockchain_service.call_attestation_oracle(
                    self.oracle_private_key,
                    "update_merchant_limits",
                    [
                        merchant_name.encode(),
                        new_daily_limit.to_bytes(8, 'big'),
                        str(is_approved).encode()
                    ]
                )
                
                if not result.get("success"):
                    logger.error(f"Failed to update blockchain: {result.get('error')}")
                    return {"error": "Failed to update blockchain"}
            
            logger.info(f"Updated limits for {merchant_name}: {new_daily_limit} microAlgos, approved: {is_approved}")
            return {"success": True, "merchant": merchant_name}
            
        except Exception as e:
            logger.error(f"Failed to update merchant limits: {e}")
            return {"error": str(e)}
    
    def parent_approve_merchant(self, merchant_name: str, approved: bool) -> Dict:
        """Allow parents to approve/disapprove specific merchants"""
        try:
            if merchant_name not in self.merchant_attestations:
                return {"error": "Merchant not found"}
            
            merchant = self.merchant_attestations[merchant_name]
            merchant.parent_approved = approved
            merchant.last_update = int(datetime.now().timestamp())
            
            # Update blockchain
            if self.blockchain_service.attestation_oracle_app_id:
                # In production, this would use parent's private key
                result = self.blockchain_service.call_attestation_oracle(
                    self.oracle_private_key,  # Using oracle key for demo
                    "parent_approve_merchant",
                    [
                        merchant_name.encode(),
                        str(approved).encode()
                    ]
                )
                
                if not result.get("success"):
                    logger.error(f"Failed to update blockchain: {result.get('error')}")
                    return {"error": "Failed to update blockchain"}
            
            logger.info(f"Parent approval updated for {merchant_name}: {approved}")
            return {"success": True, "merchant": merchant_name, "approved": approved}
            
        except Exception as e:
            logger.error(f"Failed to update parent approval: {e}")
            return {"error": str(e)}
    
    def verify_purchase(self, request: PurchaseRequest) -> PurchaseResponse:
        """Verify if a purchase is allowed"""
        try:
            # Check if merchant exists
            if request.merchant_name not in self.merchant_attestations:
                return PurchaseResponse(
                    approved=False,
                    reason="Merchant not found in attestation system"
                )
            
            merchant = self.merchant_attestations[request.merchant_name]
            
            # Check if merchant is approved
            if not merchant.is_approved:
                return PurchaseResponse(
                    approved=False,
                    reason=f"Merchant '{request.merchant_name}' is not approved for purchases"
                )
            
            # Check parent approval
            if not merchant.parent_approved:
                return PurchaseResponse(
                    approved=False,
                    reason=f"Merchant '{request.merchant_name}' is not approved by parent"
                )
            
            # Check category restrictions
            restricted_categories = ["Gaming", "Gambling", "Adult Content", "Tobacco", "Alcohol"]
            if merchant.category in restricted_categories:
                return PurchaseResponse(
                    approved=False,
                    reason=f"Category '{merchant.category}' is restricted"
                )
            
            # Check daily limit
            current_time = int(datetime.now().timestamp())
            
            # Reset daily spending if it's a new day
            if self._is_new_day(merchant.last_update, current_time):
                merchant.total_spent_today = 0
                merchant.last_update = current_time
            
            # Check if purchase would exceed daily limit
            new_total = merchant.total_spent_today + request.amount
            if new_total > merchant.daily_limit:
                return PurchaseResponse(
                    approved=False,
                    reason=f"Purchase would exceed daily limit of {merchant.daily_limit} microAlgos"
                )
            
            # Update spending
            merchant.total_spent_today = new_total
            merchant.last_update = current_time
            
            # In production, this would create an actual atomic transaction
            mock_transaction_id = f"mock_tx_{int(datetime.now().timestamp())}"
            
            return PurchaseResponse(
                approved=True,
                transaction_id=mock_transaction_id,
                explorer_link=f"https://testnet.algoexplorer.io/tx/{mock_transaction_id}"
            )
            
        except Exception as e:
            logger.error(f"Failed to verify purchase: {e}")
            return PurchaseResponse(
                approved=False,
                reason=f"Verification error: {str(e)}"
            )
    
    def execute_purchase_atomic(
        self,
        teen_private_key: str,
        teen_address: str,
        request: PurchaseRequest
    ) -> PurchaseResponse:
        """Execute purchase using atomic transactions"""
        try:
            # First verify the purchase
            verification = self.verify_purchase(request)
            if not verification.approved:
                return verification
            
            # Get merchant address
            merchant = self.merchant_attestations[request.merchant_name]
            merchant_address = merchant.merchant_address or "DEMO_MERCHANT_ADDRESS"
            
            # Execute atomic transaction group
            result = self.blockchain_service.create_atomic_purchase_group(
                teen_private_key=teen_private_key,
                merchant_name=request.merchant_name,
                amount=request.amount,
                teen_address=teen_address,
                merchant_address=merchant_address
            )
            
            if result.get("success"):
                return PurchaseResponse(
                    approved=True,
                    transaction_id=result.get("transaction_id"),
                    explorer_link=result.get("explorer_link")
                )
            else:
                return PurchaseResponse(
                    approved=False,
                    reason=f"Transaction failed: {result.get('error')}"
                )
                
        except Exception as e:
            logger.error(f"Failed to execute atomic purchase: {e}")
            return PurchaseResponse(
                approved=False,
                reason=f"Execution error: {str(e)}"
            )
    
    def get_merchant_attestations(self) -> Dict[str, MerchantAttestation]:
        """Get all merchant attestations"""
        return self.merchant_attestations
    
    def get_merchant_attestation(self, merchant_name: str) -> Optional[MerchantAttestation]:
        """Get specific merchant attestation"""
        return self.merchant_attestations.get(merchant_name)
    
    def get_merchant_analytics(self, merchant_name: str) -> Dict:
        """Get analytics for a specific merchant"""
        try:
            if merchant_name not in self.merchant_attestations:
                return {"error": "Merchant not found"}
            
            merchant = self.merchant_attestations[merchant_name]
            
            # Calculate daily spending percentage
            daily_usage_percent = (merchant.total_spent_today / merchant.daily_limit * 100) if merchant.daily_limit > 0 else 0
            
            return {
                "merchant_name": merchant_name,
                "category": merchant.category,
                "daily_limit": merchant.daily_limit,
                "total_spent_today": merchant.total_spent_today,
                "daily_usage_percent": round(daily_usage_percent, 2),
                "is_approved": merchant.is_approved,
                "parent_approved": merchant.parent_approved,
                "last_update": merchant.last_update
            }
            
        except Exception as e:
            logger.error(f"Failed to get merchant analytics: {e}")
            return {"error": str(e)}
    
    def sync_with_blockchain(self) -> Dict:
        """Sync local attestations with blockchain state"""
        try:
            # In production, this would read from the blockchain
            # and update local state accordingly
            logger.info("Syncing with blockchain...")
            
            # For demo, just return success
            return {"success": True, "synced_merchants": len(self.merchant_attestations)}
            
        except Exception as e:
            logger.error(f"Failed to sync with blockchain: {e}")
            return {"error": str(e)}
    
    def _is_new_day(self, last_timestamp: int, current_timestamp: int) -> bool:
        """Check if it's a new day since last update"""
        seconds_in_day = 86400
        current_day = current_timestamp // seconds_in_day
        last_day = last_timestamp // seconds_in_day
        return current_day > last_day
