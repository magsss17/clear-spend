"""
Purchase Management API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import List
import logging

from ..models.requests import PurchaseRequest
from ..models.responses import PurchaseResponse
from ...services.oracle_service import OracleService
from ...services.blockchain_service import BlockchainService
from ..deps import get_oracle_service
from ..deps import get_blockchain_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/purchases", tags=["purchases"])

@router.post("/verify", response_model=PurchaseResponse)
async def verify_purchase(
    request: PurchaseRequest,
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Verify if a purchase is allowed without executing it"""
    try:
        from ...services.oracle_service import PurchaseRequest as OraclePurchaseRequest
        
        oracle_request = OraclePurchaseRequest(
            merchant_name=request.merchant_name,
            amount=request.amount,
            user_address=request.user_address,
            timestamp=request.timestamp
        )
        
        result = oracle_service.verify_purchase(oracle_request)
        
        return PurchaseResponse(
            success=True,
            approved=result.approved,
            reason=result.reason,
            transaction_id=result.transaction_id,
            explorer_link=result.explorer_link,
            amount=request.amount,
            merchant_name=request.merchant_name
        )
        
    except Exception as e:
        logger.error(f"Failed to verify purchase: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/execute", response_model=PurchaseResponse)
async def execute_purchase(
    request: PurchaseRequest,
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Execute a purchase using atomic transactions"""
    try:
        from ...services.oracle_service import PurchaseRequest as OraclePurchaseRequest
        
        # For demo purposes, we'll use a mock private key
        # In production, this would come from secure authentication
        teen_private_key = "demo_private_key_for_testing_only"
        
        oracle_request = OraclePurchaseRequest(
            merchant_name=request.merchant_name,
            amount=request.amount,
            user_address=request.user_address,
            timestamp=request.timestamp
        )
        
        result = oracle_service.execute_purchase_atomic(
            teen_private_key=teen_private_key,
            teen_address=request.user_address,
            request=oracle_request
        )
        
        return PurchaseResponse(
            success=True,
            approved=result.approved,
            reason=result.reason,
            transaction_id=result.transaction_id,
            explorer_link=result.explorer_link,
            amount=request.amount,
            merchant_name=request.merchant_name
        )
        
    except Exception as e:
        logger.error(f"Failed to execute purchase: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{transaction_id}/status", response_model=PurchaseResponse)
async def get_purchase_status(
    transaction_id: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get the status of a purchase transaction"""
    try:
        status = blockchain_service.get_transaction_status(transaction_id)
        if status.get("error"):
            raise HTTPException(status_code=404, detail=status["error"])

        return PurchaseResponse(
            success=True,
            approved=bool(status.get("confirmed")),
            transaction_id=status.get("id", transaction_id),
            explorer_link=f"https://testnet.algoexplorer.io/tx/{transaction_id}",
            amount=status.get("amount"),
            message="Transaction confirmed" if status.get("confirmed") else "Transaction pending"
        )

    except Exception as e:
        logger.error(f"Failed to get purchase status: {e}")
        raise HTTPException(status_code=500, detail=str(e))
