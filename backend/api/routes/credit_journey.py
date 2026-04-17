"""
Credit Journey API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
import logging

from ...services.blockchain_service import BlockchainService
from ..deps import get_blockchain_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/credit-journey", tags=["credit-journey"])


@router.get("/{teen_address}")
async def get_credit_profile(
    teen_address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get teen credit profile from CreditJourney contract boxes."""
    try:
        profile = blockchain_service.get_credit_profile(teen_address)
        if profile.get("error"):
            raise HTTPException(status_code=502, detail=profile["error"])
        return {"success": True, "data": profile}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get credit profile for {teen_address}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{teen_address}/milestones")
async def get_credit_milestones(
    teen_address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get teen credit journey milestones from CreditJourney boxes."""
    try:
        milestones = blockchain_service.get_credit_milestones(teen_address)
        if milestones.get("error"):
            raise HTTPException(status_code=502, detail=milestones["error"])
        return {"success": True, "data": milestones}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get milestones for {teen_address}: {e}")
        raise HTTPException(status_code=500, detail=str(e))


@router.get("/{teen_address}/parent-insights")
async def get_parent_insights(
    teen_address: str,
    limit: int = 100,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Compute parent insights from indexer and on-chain credit state."""
    try:
        insights = blockchain_service.get_parent_insights(teen_address, limit=limit)
        if insights.get("error"):
            raise HTTPException(status_code=502, detail=insights["error"])
        return {"success": True, "data": insights}
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to compute parent insights for {teen_address}: {e}")
        raise HTTPException(status_code=500, detail=str(e))
