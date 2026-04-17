"""
Shared dependency providers for API routes.
"""

from fastapi import HTTPException

from ..services.blockchain_service import BlockchainService
from ..services.oracle_service import OracleService

_blockchain_service: BlockchainService | None = None
_oracle_service: OracleService | None = None


def set_services(blockchain_service: BlockchainService, oracle_service: OracleService) -> None:
    """Set shared service instances during app startup."""
    global _blockchain_service, _oracle_service
    _blockchain_service = blockchain_service
    _oracle_service = oracle_service


def clear_services() -> None:
    """Clear shared service instances during app shutdown."""
    global _blockchain_service, _oracle_service
    _blockchain_service = None
    _oracle_service = None


def get_blockchain_service() -> BlockchainService:
    """Return the shared blockchain service."""
    if _blockchain_service is None:
        raise HTTPException(status_code=503, detail="Blockchain service not initialized")
    return _blockchain_service


def get_oracle_service() -> OracleService:
    """Return the shared oracle service."""
    if _oracle_service is None:
        raise HTTPException(status_code=503, detail="Oracle service not initialized")
    return _oracle_service
