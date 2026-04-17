"""
Allowance Management API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
import logging

from ..models.requests import (
    AllowanceRequest,
    EmergencyAllowanceRequest,
    SavingsRequest
)
from ..models.responses import (
    AllowanceResponse,
    SavingsResponse,
    BaseResponse
)
from ...services.blockchain_service import BlockchainService
from ..deps import get_blockchain_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/allowances", tags=["allowances"])

@router.post("/issue", response_model=AllowanceResponse)
async def issue_weekly_allowance(
    request: AllowanceRequest,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Issue weekly allowance to teen"""
    try:
        # For demo purposes, we'll simulate the allowance issuance
        # In production, this would call the smart contract
        
        if not blockchain_service.allowance_manager_app_id:
            raise HTTPException(status_code=400, detail="Allowance manager contract not deployed")
        
        # Mock response for demo
        return AllowanceResponse(
            success=True,
            teen_address=request.teen_address,
            weekly_amount=request.weekly_amount,
            total_issued=request.weekly_amount * 4,  # Mock 4 weeks issued
            last_allowance_time=int(__import__('time').time()),
            is_paused=False,
            can_issue=True,
            message="Weekly allowance issued successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to issue allowance: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/emergency", response_model=AllowanceResponse)
async def issue_emergency_allowance(
    request: EmergencyAllowanceRequest,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Issue emergency allowance to teen"""
    try:
        # For demo purposes, we'll simulate the emergency allowance issuance
        
        return AllowanceResponse(
            success=True,
            teen_address=request.teen_address,
            weekly_amount=request.amount,
            total_issued=request.amount,
            last_allowance_time=int(__import__('time').time()),
            is_paused=False,
            can_issue=True,
            message="Emergency allowance issued successfully"
        )
        
    except Exception as e:
        logger.error(f"Failed to issue emergency allowance: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{teen_address}/status", response_model=AllowanceResponse)
async def get_allowance_status(
    teen_address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get current allowance status from on-chain contract state."""
    try:
        state_result = blockchain_service.get_allowance_state()
        if state_result.get("error"):
            raise HTTPException(status_code=502, detail=state_result["error"])

        global_state = state_result.get("global_state", {})
        return AllowanceResponse(
            success=True,
            teen_address=teen_address,
            weekly_amount=int(global_state.get("weekly_allowance", 0)),
            total_issued=int(global_state.get("total_issued", 0)),
            last_allowance_time=int(global_state.get("last_allowance_time", 0)),
            is_paused=bool(global_state.get("is_paused", 0)),
            can_issue=bool(global_state.get("can_issue", False)),
            message="Allowance status retrieved successfully"
        )

    except Exception as e:
        logger.error(f"Failed to get allowance status: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{teen_address}/pause", response_model=BaseResponse)
async def pause_allowance(
    teen_address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Pause allowance for a teen"""
    try:
        # For demo purposes, we'll simulate pausing
        # In production, this would call the smart contract
        
        return BaseResponse(
            success=True,
            message=f"Allowance for {teen_address} paused successfully"
        )
        
    except Exception as e:
        logger.error(f"Failed to pause allowance: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/{teen_address}/resume", response_model=BaseResponse)
async def resume_allowance(
    teen_address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Resume allowance for a teen"""
    try:
        # For demo purposes, we'll simulate resuming
        # In production, this would call the smart contract
        
        return BaseResponse(
            success=True,
            message=f"Allowance for {teen_address} resumed successfully"
        )
        
    except Exception as e:
        logger.error(f"Failed to resume allowance: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/savings/lock", response_model=SavingsResponse)
async def lock_savings(
    request: SavingsRequest,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Lock teen savings until specified time"""
    try:
        # For demo purposes, we'll simulate locking savings
        # In production, this would call the smart contract
        
        return SavingsResponse(
            success=True,
            teen_address=request.teen_address,
            amount_locked=request.amount,
            unlock_time=request.unlock_time,
            can_unlock=False,
            message="Savings locked successfully"
        )
        
    except Exception as e:
        logger.error(f"Failed to lock savings: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.post("/savings/unlock", response_model=SavingsResponse)
async def unlock_savings(
    teen_address: str,
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Unlock teen savings if time has passed"""
    try:
        # For demo purposes, we'll simulate unlocking savings
        # In production, this would call the smart contract
        
        return SavingsResponse(
            success=True,
            teen_address=teen_address,
            amount_locked=0,
            unlock_time=0,
            can_unlock=True,
            message="Savings unlocked successfully"
        )
        
    except Exception as e:
        logger.error(f"Failed to unlock savings: {e}")
        raise HTTPException(status_code=500, detail=str(e))
