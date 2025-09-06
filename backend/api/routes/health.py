"""
Health Check and System Status API Routes
"""

from fastapi import APIRouter, HTTPException, Depends
import time
import logging

from ..models.responses import (
    HealthCheckResponse,
    NetworkStatusResponse,
    BaseResponse
)
from ...services.blockchain_service import BlockchainService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/api/v1/health", tags=["health"])

# Track service start time
service_start_time = time.time()

# Dependency injection
def get_blockchain_service() -> BlockchainService:
    return BlockchainService()

@router.get("/", response_model=HealthCheckResponse)
async def health_check(
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Health check endpoint"""
    try:
        # Test Algorand connection
        is_connected = blockchain_service.connect_to_algorand()
        
        if is_connected:
            status = "healthy"
            algorand_connection = "connected"
            network_status = blockchain_service.get_network_status()
            last_round = network_status.get("last_round", 0)
        else:
            status = "unhealthy"
            algorand_connection = "disconnected"
            last_round = 0
        
        uptime = time.time() - service_start_time
        
        return HealthCheckResponse(
            success=True,
            status=status,
            algorand_connection=algorand_connection,
            last_round=last_round,
            uptime=uptime,
            version="1.0.0",
            message="Health check completed"
        )
        
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return HealthCheckResponse(
            success=False,
            status="unhealthy",
            algorand_connection="error",
            last_round=0,
            uptime=time.time() - service_start_time,
            version="1.0.0",
            message=f"Health check failed: {str(e)}"
        )

@router.get("/network", response_model=NetworkStatusResponse)
async def get_network_status(
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get Algorand network status"""
    try:
        network_status = blockchain_service.get_network_status()
        
        if network_status.get("error"):
            raise HTTPException(status_code=500, detail=network_status["error"])
        
        return NetworkStatusResponse(
            success=True,
            last_round=network_status["last_round"],
            time_since_last_round=network_status["time_since_last_round"],
            catchup_time=network_status["catchup_time"],
            network=network_status["network"],
            message="Network status retrieved successfully"
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get network status: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/contracts", response_model=BaseResponse)
async def get_contract_status(
    blockchain_service: BlockchainService = Depends(get_blockchain_service)
):
    """Get smart contract deployment status"""
    try:
        contracts = {
            "attestation_oracle": {
                "deployed": blockchain_service.attestation_oracle_app_id is not None,
                "app_id": blockchain_service.attestation_oracle_app_id
            },
            "allowance_manager": {
                "deployed": blockchain_service.allowance_manager_app_id is not None,
                "app_id": blockchain_service.allowance_manager_app_id
            }
        }
        
        return BaseResponse(
            success=True,
            message="Contract status retrieved successfully",
            data=contracts
        )
        
    except Exception as e:
        logger.error(f"Failed to get contract status: {e}")
        raise HTTPException(status_code=500, detail=str(e))
