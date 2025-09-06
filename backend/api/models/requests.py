"""
API Request Models
"""

from pydantic import BaseModel, Field
from typing import Optional, List
from datetime import datetime

class MerchantAttestationRequest(BaseModel):
    """Request model for adding merchant attestations"""
    merchant_name: str = Field(..., description="Name of the merchant")
    category: str = Field(..., description="Category of the merchant")
    is_approved: bool = Field(..., description="Whether the merchant is approved")
    daily_limit: int = Field(..., description="Daily spending limit in microAlgos")
    parent_approved: bool = Field(True, description="Whether parent has approved this merchant")
    merchant_address: Optional[str] = Field(None, description="Merchant's Algorand address")

class PurchaseRequest(BaseModel):
    """Request model for purchase verification"""
    merchant_name: str = Field(..., description="Name of the merchant")
    amount: int = Field(..., description="Purchase amount in microAlgos")
    user_address: str = Field(..., description="User's Algorand address")
    timestamp: Optional[int] = Field(None, description="Purchase timestamp")

class AllowanceRequest(BaseModel):
    """Request model for allowance operations"""
    teen_address: str = Field(..., description="Teen's Algorand address")
    weekly_amount: int = Field(..., description="Weekly allowance amount in microAlgos")
    parent_private_key: Optional[str] = Field(None, description="Parent's private key for signing")

class EmergencyAllowanceRequest(BaseModel):
    """Request model for emergency allowance"""
    teen_address: str = Field(..., description="Teen's Algorand address")
    amount: int = Field(..., description="Emergency allowance amount in microAlgos")
    parent_private_key: Optional[str] = Field(None, description="Parent's private key for signing")

class SavingsRequest(BaseModel):
    """Request model for savings operations"""
    teen_address: str = Field(..., description="Teen's Algorand address")
    amount: int = Field(..., description="Amount to lock in microAlgos")
    unlock_time: int = Field(..., description="Unix timestamp when savings unlock")
    teen_private_key: Optional[str] = Field(None, description="Teen's private key for signing")

class ParentApprovalRequest(BaseModel):
    """Request model for parent approval operations"""
    merchant_name: str = Field(..., description="Name of the merchant")
    approved: bool = Field(..., description="Whether to approve or disapprove")
    parent_private_key: Optional[str] = Field(None, description="Parent's private key for signing")

class MerchantUpdateRequest(BaseModel):
    """Request model for updating merchant limits"""
    merchant_name: str = Field(..., description="Name of the merchant")
    new_daily_limit: int = Field(..., description="New daily limit in microAlgos")
    is_approved: bool = Field(..., description="Whether the merchant is approved")

class TransactionHistoryRequest(BaseModel):
    """Request model for transaction history"""
    user_address: str = Field(..., description="User's Algorand address")
    limit: int = Field(50, description="Maximum number of transactions to return")
    start_date: Optional[datetime] = Field(None, description="Start date for filtering")
    end_date: Optional[datetime] = Field(None, description="End date for filtering")

class AccountInfoRequest(BaseModel):
    """Request model for account information"""
    address: str = Field(..., description="Algorand address to query")
