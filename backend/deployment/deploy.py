#!/usr/bin/env python3
"""
ClearSpend Backend Deployment Script
Deploys smart contracts and starts the backend service
"""

import os
import sys
import time
import logging
from pathlib import Path

# Add backend to path
sys.path.append(str(Path(__file__).parent.parent))

from services.blockchain_service import BlockchainService
from services.oracle_service import OracleService

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def deploy_contracts():
    """Deploy smart contracts to Algorand"""
    logger.info("Starting contract deployment...")
    
    try:
        # Initialize blockchain service
        blockchain_service = BlockchainService()
        
        # Test connection
        if not blockchain_service.connect_to_algorand():
            logger.error("Failed to connect to Algorand network")
            return False
        
        # Deploy attestation oracle
        logger.info("Deploying Attestation Oracle contract...")
        oracle_app_id = blockchain_service.deploy_attestation_oracle("demo_oracle_key")
        
        if oracle_app_id:
            logger.info(f"Attestation Oracle deployed with app ID: {oracle_app_id}")
        else:
            logger.error("Failed to deploy Attestation Oracle")
            return False
        
        # Deploy allowance manager
        logger.info("Deploying Allowance Manager contract...")
        manager_app_id = blockchain_service.deploy_allowance_manager(
            "demo_parent_key",
            "DEMO_PARENT_ADDRESS",
            "DEMO_TEEN_ADDRESS",
            150000000  # 150 ALGO
        )
        
        if manager_app_id:
            logger.info(f"Allowance Manager deployed with app ID: {manager_app_id}")
        else:
            logger.error("Failed to deploy Allowance Manager")
            return False
        
        logger.info("All contracts deployed successfully!")
        return True
        
    except Exception as e:
        logger.error(f"Contract deployment failed: {e}")
        return False

def setup_oracle():
    """Set up oracle with initial merchant attestations"""
    logger.info("Setting up oracle with initial merchants...")
    
    try:
        # Initialize services
        blockchain_service = BlockchainService()
        oracle_service = OracleService(blockchain_service)
        
        # Add some initial merchants
        initial_merchants = [
            {
                "merchant_name": "Starbucks",
                "category": "Food & Beverage",
                "is_approved": True,
                "daily_limit": 50000000,
                "parent_approved": True
            },
            {
                "merchant_name": "Target",
                "category": "Retail",
                "is_approved": True,
                "daily_limit": 100000000,
                "parent_approved": True
            },
            {
                "merchant_name": "Bookstore",
                "category": "Education",
                "is_approved": True,
                "daily_limit": 30000000,
                "parent_approved": True
            }
        ]
        
        for merchant_data in initial_merchants:
            from services.oracle_service import MerchantAttestation
            
            attestation = MerchantAttestation(
                merchant_name=merchant_data["merchant_name"],
                category=merchant_data["category"],
                is_approved=merchant_data["is_approved"],
                daily_limit=merchant_data["daily_limit"],
                total_spent_today=0,
                last_update=int(time.time()),
                parent_approved=merchant_data["parent_approved"]
            )
            
            result = oracle_service.add_merchant_attestation(attestation)
            if result.get("success"):
                logger.info(f"Added merchant: {merchant_data['merchant_name']}")
            else:
                logger.warning(f"Failed to add merchant: {merchant_data['merchant_name']}")
        
        logger.info("Oracle setup completed!")
        return True
        
    except Exception as e:
        logger.error(f"Oracle setup failed: {e}")
        return False

def main():
    """Main deployment function"""
    logger.info("ClearSpend Backend Deployment Starting...")
    
    # Check environment variables
    required_env_vars = [
        "ALGOD_TOKEN",
        "ALGOD_ADDRESS",
        "INDEXER_ADDRESS"
    ]
    
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    if missing_vars:
        logger.error(f"Missing required environment variables: {missing_vars}")
        logger.info("Please set the following environment variables:")
        for var in missing_vars:
            logger.info(f"  export {var}=<value>")
        return False
    
    # Deploy contracts
    if not deploy_contracts():
        logger.error("Contract deployment failed")
        return False
    
    # Set up oracle
    if not setup_oracle():
        logger.error("Oracle setup failed")
        return False
    
    logger.info("ClearSpend Backend Deployment Completed Successfully!")
    logger.info("You can now start the backend service with:")
    logger.info("  python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000")
    
    return True

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
