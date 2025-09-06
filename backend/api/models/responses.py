"""
API Response Models
"""

from pydantic import BaseModel, Field
from typing import Optional, List, Dict, Any
from datetime import datetime

class BaseResponse(BaseModel):
    """Base response model"""
    success: bool = Field(..., description="Whether the operation was successful")
    message: Optional[str] = Field(None, description="Response message")
    timestamp: datetime = Field(default_factory=datetime.now, description="Response timestamp")

class ErrorResponse(BaseResponse):
    """Error response model"""
    success: bool = Field(False, description="Always false for error responses")
    error: str = Field(..., description="Error message")
    error_code: Optional[str] = Field(None, description="Error code")

class MerchantAttestationResponse(BaseResponse):
    """Response model for merchant attestations"""
    merchant_name: str = Field(..., description="Name of the merchant")
    category: str = Field(..., description="Category of the merchant")
    is_approved: bool = Field(..., description="Whether the merchant is approved")
    daily_limit: int = Field(..., description="Daily spending limit in microAlgos")
    total_spent_today: int = Field(..., description="Amount spent today in microAlgos")
    parent_approved: bool = Field(..., description="Whether parent has approved this merchant")
    last_update: int = Field(..., description="Last update timestamp")

class PurchaseResponse(BaseResponse):
    """Response model for purchase operations"""
    approved: bool = Field(..., description="Whether the purchase was approved")
    reason: Optional[str] = Field(None, description="Reason for approval/denial")
    transaction_id: Optional[str] = Field(None, description="Transaction ID if approved")
    explorer_link: Optional[str] = Field(None, description="Algorand Explorer link")
    amount: Optional[int] = Field(None, description="Purchase amount in microAlgos")
    merchant_name: Optional[str] = Field(None, description="Merchant name")

class AllowanceResponse(BaseResponse):
    """Response model for allowance operations"""
    teen_address: str = Field(..., description="Teen's Algorand address")
    weekly_amount: int = Field(..., description="Weekly allowance amount in microAlgos")
    total_issued: int = Field(..., description="Total amount issued in microAlgos")
    last_allowance_time: int = Field(..., description="Last allowance timestamp")
    is_paused: bool = Field(..., description="Whether allowance is paused")
    can_issue: bool = Field(..., description="Whether allowance can be issued now")

class TransactionResponse(BaseModel):
    """Response model for individual transactions"""
    id: str = Field(..., description="Transaction ID")
    type: str = Field(..., description="Transaction type")
    round: int = Field(..., description="Block round")
    timestamp: int = Field(..., description="Transaction timestamp")
    sender: str = Field(..., description="Sender address")
    receiver: Optional[str] = Field(None, description="Receiver address")
    amount: int = Field(..., description="Transaction amount in microAlgos")
    note: Optional[str] = Field(None, description="Transaction note")
    confirmed: bool = Field(..., description="Whether transaction is confirmed")
    explorer_link: str = Field(..., description="Algorand Explorer link")

class TransactionHistoryResponse(BaseResponse):
    """Response model for transaction history"""
    transactions: List[TransactionResponse] = Field(..., description="List of transactions")
    total_count: int = Field(..., description="Total number of transactions")
    user_address: str = Field(..., description="User's Algorand address")

class AccountInfoResponse(BaseResponse):
    """Response model for account information"""
    address: str = Field(..., description="Account address")
    balance: int = Field(..., description="Account balance in microAlgos")
    balance_algo: float = Field(..., description="Account balance in ALGO")
    assets: List[Dict[str, Any]] = Field(..., description="Account assets")
    created_apps: List[Dict[str, Any]] = Field(..., description="Created applications")
    created_assets: List[Dict[str, Any]] = Field(..., description="Created assets")

class MerchantAnalyticsResponse(BaseResponse):
    """Response model for merchant analytics"""
    merchant_name: str = Field(..., description="Name of the merchant")
    category: str = Field(..., description="Category of the merchant")
    daily_limit: int = Field(..., description="Daily spending limit in microAlgos")
    total_spent_today: int = Field(..., description="Amount spent today in microAlgos")
    daily_usage_percent: float = Field(..., description="Daily usage percentage")
    is_approved: bool = Field(..., description="Whether the merchant is approved")
    parent_approved: bool = Field(..., description="Whether parent has approved this merchant")
    last_update: int = Field(..., description="Last update timestamp")

class HealthCheckResponse(BaseResponse):
    """Response model for health check"""
    status: str = Field(..., description="Service status")
    algorand_connection: str = Field(..., description="Algorand connection status")
    last_round: int = Field(..., description="Last Algorand round")
    uptime: float = Field(..., description="Service uptime in seconds")
    version: str = Field(..., description="Service version")

class NetworkStatusResponse(BaseResponse):
    """Response model for network status"""
    last_round: int = Field(..., description="Last Algorand round")
    time_since_last_round: int = Field(..., description="Time since last round")
    catchup_time: int = Field(..., description="Catchup time")
    network: str = Field(..., description="Network type (testnet/mainnet)")

class SavingsResponse(BaseResponse):
    """Response model for savings operations"""
    teen_address: str = Field(..., description="Teen's Algorand address")
    amount_locked: int = Field(..., description="Amount locked in microAlgos")
    unlock_time: int = Field(..., description="Unlock timestamp")
    can_unlock: bool = Field(..., description="Whether savings can be unlocked now")

class ContractDeploymentResponse(BaseResponse):
    """Response model for contract deployment"""
    contract_type: str = Field(..., description="Type of contract deployed")
    app_id: int = Field(..., description="Application ID")
    transaction_id: str = Field(..., description="Deployment transaction ID")
    explorer_link: str = Field(..., description="Algorand Explorer link")
