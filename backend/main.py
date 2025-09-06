"""
ClearSpend Backend API
Main FastAPI application with comprehensive backend services
"""

import os
import logging
from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from .api.routes import merchants, purchases, allowances, transactions, health
from .services.blockchain_service import BlockchainService
from .services.oracle_service import OracleService

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger(__name__)

# Global services
blockchain_service = None
oracle_service = None

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan manager"""
    global blockchain_service, oracle_service
    
    # Startup
    logger.info("Starting ClearSpend Backend API...")
    
    try:
        # Initialize blockchain service
        blockchain_service = BlockchainService()
        
        # Test connection
        if blockchain_service.connect_to_algorand():
            logger.info("Successfully connected to Algorand network")
        else:
            logger.warning("Failed to connect to Algorand network")
        
        # Initialize oracle service
        oracle_service = OracleService(blockchain_service)
        logger.info("Oracle service initialized")
        
        # Deploy contracts (in production, this would be done separately)
        logger.info("Deploying smart contracts...")
        blockchain_service.deploy_attestation_oracle("demo_oracle_key")
        blockchain_service.deploy_allowance_manager(
            "demo_parent_key",
            "DEMO_PARENT_ADDRESS",
            "DEMO_TEEN_ADDRESS",
            150000000  # 150 ALGO
        )
        
        logger.info("ClearSpend Backend API started successfully")
        
    except Exception as e:
        logger.error(f"Failed to start ClearSpend Backend API: {e}")
        raise
    
    yield
    
    # Shutdown
    logger.info("Shutting down ClearSpend Backend API...")

# Create FastAPI application
app = FastAPI(
    title="ClearSpend Backend API",
    description="Backend API for ClearSpend - Teen Financial Literacy on Algorand",
    version="1.0.0",
    lifespan=lifespan
)

# Add CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include API routes
app.include_router(health.router)
app.include_router(merchants.router)
app.include_router(purchases.router)
app.include_router(allowances.router)
app.include_router(transactions.router)

@app.get("/")
async def root():
    """Root endpoint"""
    return {
        "message": "ClearSpend Backend API",
        "version": "1.0.0",
        "status": "running",
        "description": "Teen Financial Literacy on Algorand",
        "endpoints": {
            "health": "/api/v1/health/",
            "merchants": "/api/v1/merchants/",
            "purchases": "/api/v1/purchases/",
            "allowances": "/api/v1/allowances/",
            "transactions": "/api/v1/transactions/",
            "docs": "/docs"
        }
    }

@app.exception_handler(HTTPException)
async def http_exception_handler(request, exc):
    """Custom HTTP exception handler"""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "success": False,
            "error": exc.detail,
            "status_code": exc.status_code
        }
    )

@app.exception_handler(Exception)
async def general_exception_handler(request, exc):
    """General exception handler"""
    logger.error(f"Unhandled exception: {exc}")
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "error": "Internal server error",
            "status_code": 500
        }
    )

# Dependency injection for services
def get_blockchain_service() -> BlockchainService:
    """Get blockchain service instance"""
    if blockchain_service is None:
        raise HTTPException(status_code=503, detail="Blockchain service not initialized")
    return blockchain_service

def get_oracle_service() -> OracleService:
    """Get oracle service instance"""
    if oracle_service is None:
        raise HTTPException(status_code=503, detail="Oracle service not initialized")
    return oracle_service

# Make services available to routes
app.dependency_overrides[get_blockchain_service] = get_blockchain_service
app.dependency_overrides[get_oracle_service] = get_oracle_service

if __name__ == "__main__":
    import uvicorn
    
    # Get configuration from environment
    host = os.getenv("HOST", "0.0.0.0")
    port = int(os.getenv("PORT", 8000))
    debug = os.getenv("DEBUG", "false").lower() == "true"
    
    logger.info(f"Starting server on {host}:{port}")
    
    uvicorn.run(
        "main:app",
        host=host,
        port=port,
        reload=debug,
        log_level="info"
    )
