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

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/purchases", tags=["purchases"])

# Global shared oracle service instance
_shared_oracle_service = None

def get_oracle_service() -> OracleService:
    """Get shared oracle service instance"""
    global _shared_oracle_service
    if _shared_oracle_service is None:
        blockchain_service = BlockchainService()
        _shared_oracle_service = OracleService(blockchain_service)
        logger.info("Created shared OracleService instance")
    return _shared_oracle_service

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
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Get the status of a purchase transaction"""
    try:
        # In production, this would query the blockchain for transaction status
        # For demo, we'll return a mock status
        
        return PurchaseResponse(
            success=True,
            approved=True,
            transaction_id=transaction_id,
            explorer_link=f"https://testnet.algoexplorer.io/tx/{transaction_id}",
            message="Transaction confirmed"
        )
        
    except Exception as e:
        logger.error(f"Failed to get purchase status: {e}")
        raise HTTPException(status_code=500, detail=str(e))
