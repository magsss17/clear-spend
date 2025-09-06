"""
ClearSpend Blockchain Service
Handles all Algorand blockchain interactions using AlgoKit
"""

import os
import json
from typing import Dict, List, Optional, Tuple
from datetime import datetime, timedelta
from algosdk import account, mnemonic, transaction
from algosdk.v2client import algod, indexer
from algosdk.transaction import (
    ApplicationCallTxn, 
    PaymentTxn, 
    AssetTransferTxn, 
    assign_group_id,
    wait_for_confirmation
)
from algosdk.atomic_transaction_composer import (
    AtomicTransactionComposer, 
    TransactionWithSigner,
    AccountTransactionSigner
)
from algosdk.abi import Contract
import base64
import logging

logger = logging.getLogger(__name__)

class BlockchainService:
    """Service for handling Algorand blockchain operations"""
    
    def __init__(self):
        self.algod_token = os.getenv("ALGOD_TOKEN", "")
        self.algod_address = os.getenv("ALGOD_ADDRESS", "https://testnet-api.algonode.cloud")
        self.indexer_address = os.getenv("INDEXER_ADDRESS", "https://testnet-idx.algonode.cloud")
        
        # Initialize clients
        self.algod_client = algod.AlgodClient(self.algod_token, self.algod_address)
        self.indexer_client = indexer.IndexerClient("", self.indexer_address)
        
        # Contract addresses (will be set after deployment)
        self.attestation_oracle_app_id = None
        self.allowance_manager_app_id = None
        
        # Demo accounts for testing
        self.demo_parent_mnemonic = os.getenv("DEMO_PARENT_MNEMONIC", "")
        self.demo_teen_mnemonic = os.getenv("DEMO_TEEN_MNEMONIC", "")
        self.demo_oracle_mnemonic = os.getenv("DEMO_ORACLE_MNEMONIC", "")
    
    def connect_to_algorand(self) -> bool:
        """Test connection to Algorand network"""
        try:
            status = self.algod_client.status()
            logger.info(f"Connected to Algorand. Last round: {status.get('last-round', 0)}")
            return True
        except Exception as e:
            logger.error(f"Failed to connect to Algorand: {e}")
            return False
    
    def get_account_balance(self, address: str) -> Dict:
        """Get account balance and information"""
        try:
            account_info = self.algod_client.account_info(address)
            balance = account_info.get('amount', 0)
            
            return {
                "address": address,
                "balance": balance,
                "balance_algo": balance / 1_000_000,  # Convert microAlgos to ALGO
                "assets": account_info.get('assets', []),
                "created_apps": account_info.get('created-apps', []),
                "created_assets": account_info.get('created-assets', [])
            }
        except Exception as e:
            logger.error(f"Failed to get account balance for {address}: {e}")
            return {"error": str(e)}
    
    def get_transaction_history(self, address: str, limit: int = 50) -> List[Dict]:
        """Get transaction history for an address"""
        try:
            transactions = self.indexer_client.search_transactions(
                address=address,
                limit=limit
            )
            
            formatted_transactions = []
            for tx in transactions.get('transactions', []):
                formatted_tx = {
                    "id": tx.get('id'),
                    "type": tx.get('tx-type'),
                    "round": tx.get('confirmed-round'),
                    "timestamp": tx.get('round-time'),
                    "sender": tx.get('sender'),
                    "amount": tx.get('payment-transaction', {}).get('amount', 0),
                    "note": tx.get('note'),
                    "confirmed": tx.get('confirmed-round') is not None
                }
                formatted_transactions.append(formatted_tx)
            
            return formatted_transactions
        except Exception as e:
            logger.error(f"Failed to get transaction history for {address}: {e}")
            return []
    
    def create_atomic_purchase_group(
        self,
        teen_private_key: str,
        merchant_name: str,
        amount: int,
        teen_address: str,
        merchant_address: str
    ) -> Dict:
        """
        Create atomic transaction group for purchase verification and execution
        Group structure:
        1. App call to attestation oracle (verify purchase)
        2. App call to allowance manager (check limits)
        3. Payment transaction (execute payment)
        """
        try:
            if not self.attestation_oracle_app_id or not self.allowance_manager_app_id:
                return {"error": "Smart contracts not deployed"}
            
            # Get suggested parameters
            params = self.algod_client.suggested_params()
            
            # Transaction 1: Verify purchase with attestation oracle
            attestation_txn = ApplicationCallTxn(
                sender=teen_address,
                sp=params,
                index=self.attestation_oracle_app_id,
                app_args=[
                    b"verify_purchase",
                    merchant_name.encode(),
                    amount.to_bytes(8, 'big'),
                    teen_address.encode()
                ],
                accounts=[merchant_address]
            )
            
            # Transaction 2: Check allowance limits
            allowance_txn = ApplicationCallTxn(
                sender=teen_address,
                sp=params,
                index=self.allowance_manager_app_id,
                app_args=[
                    b"process_purchase_atomic",
                    merchant_name.encode(),
                    amount.to_bytes(8, 'big')
                ]
            )
            
            # Transaction 3: Payment to merchant
            payment_txn = PaymentTxn(
                sender=teen_address,
                sp=params,
                receiver=merchant_address,
                amt=amount,
                note=f"ClearSpend purchase at {merchant_name}".encode()
            )
            
            # Assign group ID to make them atomic
            group_id = assign_group_id([attestation_txn, allowance_txn, payment_txn])
            
            # Sign transactions
            signed_attestation = attestation_txn.sign(teen_private_key)
            signed_allowance = allowance_txn.sign(teen_private_key)
            signed_payment = payment_txn.sign(teen_private_key)
            
            # Submit atomic group
            txid = self.algod_client.send_transactions([signed_attestation, signed_allowance, signed_payment])
            
            # Wait for confirmation
            confirmed_txn = wait_for_confirmation(self.algod_client, txid, 4)
            
            return {
                "success": True,
                "transaction_id": txid,
                "confirmed_round": confirmed_txn.get('confirmed-round'),
                "explorer_link": f"https://testnet.algoexplorer.io/tx/{txid}"
            }
            
        except Exception as e:
            logger.error(f"Failed to create atomic purchase group: {e}")
            return {"error": str(e)}
    
    def deploy_attestation_oracle(self, deployer_private_key: str) -> Optional[int]:
        """Deploy the attestation oracle smart contract"""
        try:
            # This would use AlgoKit's deployment tools in production
            # For now, we'll simulate deployment
            logger.info("Deploying Attestation Oracle contract...")
            
            # In a real implementation, this would:
            # 1. Compile the contract using AlgoKit
            # 2. Deploy to the network
            # 3. Return the app ID
            
            # Simulate deployment for demo
            self.attestation_oracle_app_id = 12345  # Mock app ID
            logger.info(f"Attestation Oracle deployed with app ID: {self.attestation_oracle_app_id}")
            
            return self.attestation_oracle_app_id
            
        except Exception as e:
            logger.error(f"Failed to deploy attestation oracle: {e}")
            return None
    
    def deploy_allowance_manager(
        self, 
        deployer_private_key: str,
        parent_address: str,
        teen_address: str,
        weekly_allowance: int
    ) -> Optional[int]:
        """Deploy the allowance manager smart contract"""
        try:
            logger.info("Deploying Allowance Manager contract...")
            
            # Simulate deployment for demo
            self.allowance_manager_app_id = 12346  # Mock app ID
            logger.info(f"Allowance Manager deployed with app ID: {self.allowance_manager_app_id}")
            
            return self.allowance_manager_app_id
            
        except Exception as e:
            logger.error(f"Failed to deploy allowance manager: {e}")
            return None
    
    def call_attestation_oracle(
        self,
        caller_private_key: str,
        method: str,
        args: List[bytes]
    ) -> Dict:
        """Call methods on the attestation oracle contract"""
        try:
            if not self.attestation_oracle_app_id:
                return {"error": "Attestation oracle not deployed"}
            
            params = self.algod_client.suggested_params()
            caller_address = account.address_from_private_key(caller_private_key)
            
            txn = ApplicationCallTxn(
                sender=caller_address,
                sp=params,
                index=self.attestation_oracle_app_id,
                app_args=[method.encode()] + args
            )
            
            signed_txn = txn.sign(caller_private_key)
            txid = self.algod_client.send_transaction(signed_txn)
            
            confirmed_txn = wait_for_confirmation(self.algod_client, txid, 4)
            
            return {
                "success": True,
                "transaction_id": txid,
                "confirmed_round": confirmed_txn.get('confirmed-round')
            }
            
        except Exception as e:
            logger.error(f"Failed to call attestation oracle: {e}")
            return {"error": str(e)}
    
    def call_allowance_manager(
        self,
        caller_private_key: str,
        method: str,
        args: List[bytes]
    ) -> Dict:
        """Call methods on the allowance manager contract"""
        try:
            if not self.allowance_manager_app_id:
                return {"error": "Allowance manager not deployed"}
            
            params = self.algod_client.suggested_params()
            caller_address = account.address_from_private_key(caller_private_key)
            
            txn = ApplicationCallTxn(
                sender=caller_address,
                sp=params,
                index=self.allowance_manager_app_id,
                app_args=[method.encode()] + args
            )
            
            signed_txn = txn.sign(caller_private_key)
            txid = self.algod_client.send_transaction(signed_txn)
            
            confirmed_txn = wait_for_confirmation(self.algod_client, txid, 4)
            
            return {
                "success": True,
                "transaction_id": txid,
                "confirmed_round": confirmed_txn.get('confirmed-round')
            }
            
        except Exception as e:
            logger.error(f"Failed to call allowance manager: {e}")
            return {"error": str(e)}
    
    def monitor_transactions(self, address: str, callback) -> None:
        """Monitor transactions for an address (for real-time updates)"""
        try:
            last_round = 0
            
            while True:
                # Get latest round
                status = self.algod_client.status()
                current_round = status.get('last-round', 0)
                
                if current_round > last_round:
                    # Check for new transactions
                    transactions = self.get_transaction_history(address, limit=10)
                    
                    for tx in transactions:
                        if tx.get('round', 0) > last_round:
                            callback(tx)
                    
                    last_round = current_round
                
                # Wait before next check
                import time
                time.sleep(5)
                
        except Exception as e:
            logger.error(f"Failed to monitor transactions: {e}")
    
    def get_network_status(self) -> Dict:
        """Get current network status"""
        try:
            status = self.algod_client.status()
            return {
                "last_round": status.get('last-round', 0),
                "time_since_last_round": status.get('time-since-last-round', 0),
                "catchup_time": status.get('catchup-time', 0),
                "network": "testnet" if "testnet" in self.algod_address else "mainnet"
            }
        except Exception as e:
            logger.error(f"Failed to get network status: {e}")
            return {"error": str(e)}
