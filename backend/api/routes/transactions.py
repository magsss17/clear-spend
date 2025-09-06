"""
Transaction Management API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import List
import logging

from ..models.requests import TransactionHistoryRequest, AccountInfoRequest
from ..models.responses import (
    TransactionHistoryResponse,
    TransactionResponse,
    AccountInfoResponse
)
from ...services.blockchain_service import BlockchainService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/transactions", tags=["transactions"])

# Dependency injection
def get_blockchain_service() -> BlockchainService:
    return BlockchainService()

@router.get("/{user_address}", response_model=TransactionHistoryResponse)
async def get_transaction_history(
    user_address: str,
    limit: int = 50,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get transaction history for a user"""
    try:
        # Get transaction history from blockchain
        transactions = blockchain_service.get_transaction_history(user_address, limit)
        
        # Format transactions
        formatted_transactions = []
        for tx in transactions:
            formatted_tx = TransactionResponse(
                id=tx.get("id", ""),
                type=tx.get("type", ""),
                round=tx.get("round", 0),
                timestamp=tx.get("timestamp", 0),
                sender=tx.get("sender", ""),
                receiver=tx.get("receiver"),
                amount=tx.get("amount", 0),
                note=tx.get("note"),
                confirmed=tx.get("confirmed", False),
                explorer_link=f"https://testnet.algoexplorer.io/tx/{tx.get('id', '')}"
            )
            formatted_transactions.append(formatted_tx)
        
        return TransactionHistoryResponse(
            success=True,
            transactions=formatted_transactions,
            total_count=len(formatted_transactions),
            user_address=user_address,
            message="Transaction history retrieved successfully"
        )
        
    except Exception as e:
        logger.error(f"Failed to get transaction history: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{user_address}/analytics", response_model=dict)
async def get_transaction_analytics(
    user_address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get transaction analytics for a user"""
    try:
        # Get transaction history
        transactions = blockchain_service.get_transaction_history(user_address, 100)
        
        # Calculate analytics
        total_spent = sum(tx.get("amount", 0) for tx in transactions if tx.get("type") == "pay")
        total_received = sum(tx.get("amount", 0) for tx in transactions if tx.get("receiver") == user_address)
        transaction_count = len(transactions)
        
        # Group by merchant (from transaction notes)
        merchant_spending = {}
        for tx in transactions:
            if tx.get("type") == "pay" and tx.get("note"):
                note = tx.get("note", "").decode() if isinstance(tx.get("note"), bytes) else str(tx.get("note", ""))
                if "ClearSpend purchase at" in note:
                    merchant = note.replace("ClearSpend purchase at ", "").strip()
                    if merchant not in merchant_spending:
                        merchant_spending[merchant] = 0
                    merchant_spending[merchant] += tx.get("amount", 0)
        
        return {
            "success": True,
            "user_address": user_address,
            "analytics": {
                "total_spent": total_spent,
                "total_received": total_received,
                "transaction_count": transaction_count,
                "merchant_spending": merchant_spending,
                "net_balance": total_received - total_spent
            },
            "message": "Analytics retrieved successfully"
        }
        
    except Exception as e:
        logger.error(f"Failed to get transaction analytics: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/account/{address}/info", response_model=AccountInfoResponse)
async def get_account_info(
    address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get account information"""
    try:
        account_info = blockchain_service.get_account_balance(address)
        
        if account_info.get("error"):
            raise HTTPException(status_code=400, detail=account_info["error"])
        
        return AccountInfoResponse(
            success=True,
            address=account_info["address"],
            balance=account_info["balance"],
            balance_algo=account_info["balance_algo"],
            assets=account_info["assets"],
            created_apps=account_info["created_apps"],
            created_assets=account_info["created_assets"],
            message="Account information retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get account info: {e}")
        raise HTTPException(status_code=500, detail=str(e))
