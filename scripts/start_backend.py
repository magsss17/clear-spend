#!/usr/bin/env python3
"""
ClearSpend Backend Startup Script
Easy way to start the backend service with proper configuration
"""

import os
import sys
import subprocess
import logging
from pathlib import Path

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def check_requirements():
    """Check if all requirements are met"""
    logger.info("Checking requirements...")
    
    # Check Python version
    if sys.version_info < (3, 11):
        logger.error("Python 3.11+ is required")
        return False
    
    # Check if requirements are installed
    try:
        import fastapi
        import uvicorn
        import algosdk
        logger.info("✓ Core dependencies installed")
    except ImportError as e:
        logger.error(f"Missing dependency: {e}")
        logger.info("Please run: pip install -r requirements.txt")
        return False
    
    # Check environment variables
    required_vars = ["ALGOD_TOKEN", "ALGOD_ADDRESS"]
    missing_vars = [var for var in required_vars if not os.getenv(var)]
    
    if missing_vars:
        logger.warning(f"Missing environment variables: {missing_vars}")
        logger.info("Using default testnet configuration...")
    
    return True

def start_backend():
    """Start the backend service"""
    logger.info("Starting ClearSpend Backend...")
    
    # Set default environment variables if not set
    os.environ.setdefault("HOST", "0.0.0.0")
    os.environ.setdefault("PORT", "8000")
    os.environ.setdefault("DEBUG", "true")
    os.environ.setdefault("ALGOD_ADDRESS", "https://testnet-api.algonode.cloud")
    os.environ.setdefault("INDEXER_ADDRESS", "https://testnet-idx.algonode.cloud")
    
    try:
        # Start the FastAPI application
        cmd = [
            sys.executable, "-m", "uvicorn",
            "backend.main:app",
            "--host", os.getenv("HOST", "0.0.0.0"),
            "--port", os.getenv("PORT", "8000"),
            "--reload" if os.getenv("DEBUG", "false").lower() == "true" else "--no-reload"
        ]
        
        logger.info(f"Starting server with command: {' '.join(cmd)}")
        subprocess.run(cmd, check=True)
        
    except KeyboardInterrupt:
        logger.info("Shutting down backend...")
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to start backend: {e}")
        return False
    except Exception as e:
        logger.error(f"Unexpected error: {e}")
        return False
    
    return True

def main():
    """Main function"""
    logger.info("ClearSpend Backend Startup")
    logger.info("=" * 50)
    
    # Check requirements
    if not check_requirements():
        logger.error("Requirements check failed")
        sys.exit(1)
    
    # Start backend
    if not start_backend():
        logger.error("Failed to start backend")
        sys.exit(1)
    
    logger.info("Backend stopped successfully")

if __name__ == "__main__":
    main()
