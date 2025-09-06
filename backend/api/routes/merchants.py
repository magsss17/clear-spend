"""
Merchant Management API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
from typing import Dict, List
import logging

from ..models.requests import (
    MerchantAttestationRequest,
    MerchantUpdateRequest,
    ParentApprovalRequest
)
from ..models.responses import (
    MerchantAttestationResponse,
    MerchantAnalyticsResponse,
    BaseResponse
)
from ...services.oracle_service import OracleService
from ...services.blockchain_service import BlockchainService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/merchants", tags=["merchants"])

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

@router.get("/", response_model=Dict[str, List[MerchantAttestationResponse]])
async def get_all_merchants(
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Get all merchant attestations"""
    try:
        attestations = oracle_service.get_merchant_attestations()
        
        merchants = []
        for name, attestation in attestations.items():
            merchants.append(MerchantAttestationResponse(
                success=True,
                merchant_name=attestation.merchant_name,
                category=attestation.category,
                is_approved=attestation.is_approved,
                daily_limit=attestation.daily_limit,
                total_spent_today=attestation.total_spent_today,
                parent_approved=attestation.parent_approved,
                last_update=attestation.last_update
            ))
        
        return {"merchants": merchants}
        
    except Exception as e:
        logger.error(f"Failed to get merchants: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{merchant_name}", response_model=MerchantAttestationResponse)
async def get_merchant(
    merchant_name: str,
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Get specific merchant attestation"""
    try:
        attestation = oracle_service.get_merchant_attestation(merchant_name)
        
        if not attestation:
            raise HTTPException(status_code=404, detail="Merchant not found")
        
        return MerchantAttestationResponse(
            success=True,
            merchant_name=attestation.merchant_name,
            category=attestation.category,
            is_approved=attestation.is_approved,
            daily_limit=attestation.daily_limit,
            total_spent_today=attestation.total_spent_today,
            parent_approved=attestation.parent_approved,
            last_update=attestation.last_update
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get merchant {merchant_name}: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/", response_model=BaseResponse)
async def add_merchant(
    request: MerchantAttestationRequest,
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Add or update merchant attestation"""
    try:
        from ...services.oracle_service import MerchantAttestation
        
        attestation = MerchantAttestation(
            merchant_name=request.merchant_name,
            category=request.category,
            is_approved=request.is_approved,
            daily_limit=request.daily_limit,
            total_spent_today=0,
            last_update=int(__import__('time').time()),
            parent_approved=request.parent_approved,
            merchant_address=request.merchant_address
        )
        
        result = oracle_service.add_merchant_attestation(attestation)
        
        if result.get("error"):
            raise HTTPException(status_code=400, detail=result["error"])
        
        return BaseResponse(
            success=True,
            message=f"Merchant {request.merchant_name} added successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to add merchant: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.put("/{merchant_name}/limits", response_model=BaseResponse)
async def update_merchant_limits(
    merchant_name: str,
    request: MerchantUpdateRequest,
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Update merchant daily limits and approval status"""
    try:
        result = oracle_service.update_merchant_limits(
            merchant_name=merchant_name,
            new_daily_limit=request.new_daily_limit,
            is_approved=request.is_approved
        )
        
        if result.get("error"):
            raise HTTPException(status_code=400, detail=result["error"])
        
        return BaseResponse(
            success=True,
            message=f"Merchant {merchant_name} limits updated successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to update merchant limits: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{merchant_name}/parent-approval", response_model=BaseResponse)
async def update_parent_approval(
    merchant_name: str,
    request: ParentApprovalRequest,
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Update parent approval for a merchant"""
    try:
        result = oracle_service.parent_approve_merchant(
            merchant_name=merchant_name,
            approved=request.approved
        )
        
        if result.get("error"):
            raise HTTPException(status_code=400, detail=result["error"])
        
        return BaseResponse(
            success=True,
            message=f"Parent approval for {merchant_name} updated to {request.approved}"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to update parent approval: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{merchant_name}/analytics", response_model=MerchantAnalyticsResponse)
async def get_merchant_analytics(
    merchant_name: str,
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Get analytics for a specific merchant"""
    try:
        analytics = oracle_service.get_merchant_analytics(merchant_name)
        
        if analytics.get("error"):
            raise HTTPException(status_code=404, detail=analytics["error"])
        
        return MerchantAnalyticsResponse(
            success=True,
            merchant_name=analytics["merchant_name"],
            category=analytics["category"],
            daily_limit=analytics["daily_limit"],
            total_spent_today=analytics["total_spent_today"],
            daily_usage_percent=analytics["daily_usage_percent"],
            is_approved=analytics["is_approved"],
            parent_approved=analytics["parent_approved"],
            last_update=analytics["last_update"]
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get merchant analytics: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/sync", response_model=BaseResponse)
async def sync_merchants(
    oracle_service: OracleService = Depends(get_oracle_service)
):
    """Sync merchant attestations with blockchain"""
    try:
        result = oracle_service.sync_with_blockchain()
        
        if result.get("error"):
            raise HTTPException(status_code=500, detail=result["error"])
        
        return BaseResponse(
            success=True,
            message=f"Synced {result['synced_merchants']} merchants with blockchain"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to sync merchants: {e}")
        raise HTTPException(status_code=500, detail=str(e))
