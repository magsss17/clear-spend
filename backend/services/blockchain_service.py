"""
ClearSpend Blockchain Service
Handles all Algorand blockchain interactions using AlgoKit
"""

import os
import json
from typing import Any, Dict, List, Optional, Tuple
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
from algosdk.abi import Contract, TupleType
import base64
import logging
import httpx

logger = logging.getLogger(__name__)

class BlockchainService:
    """Service for handling Algorand blockchain operations"""
    
    def __init__(self):
        self.algod_token = os.getenv("ALGOD_TOKEN", "")
        self.algod_address = os.getenv("ALGOD_ADDRESS", "https://testnet-api.algonode.cloud")
        self.indexer_address = os.getenv("INDEXER_ADDRESS", "https://testnet-idx.algonode.cloud")
        self.ipfs_gateway_base = os.getenv("IPFS_GATEWAY_BASE", "https://gateway.pinata.cloud/ipfs")
        
        # Initialize clients
        self.algod_client = algod.AlgodClient(self.algod_token, self.algod_address)
        self.indexer_client = indexer.IndexerClient("", self.indexer_address)
        
        # Contract app IDs (prefer env config; may be set later after deployment)
        self.attestation_oracle_app_id = self._read_int_env("ATTESTATION_ORACLE_APP_ID")
        self.allowance_manager_app_id = self._read_int_env("ALLOWANCE_MANAGER_APP_ID")
        self.credit_journey_app_id = self._read_int_env("CREDIT_JOURNEY_APP_ID")
        
        # Demo accounts for testing
        self.demo_parent_mnemonic = os.getenv("DEMO_PARENT_MNEMONIC", "")
        self.demo_teen_mnemonic = os.getenv("DEMO_TEEN_MNEMONIC", "")
        self.demo_oracle_mnemonic = os.getenv("DEMO_ORACLE_MNEMONIC", "")

    @staticmethod
    def _read_int_env(key: str) -> Optional[int]:
        """Read an optional integer environment variable."""
        value = os.getenv(key)
        if value is None or value == "":
            return None
        try:
            return int(value)
        except ValueError:
            logger.warning(f"Invalid integer for {key}: {value}")
            return None

    def _decode_note(self, note: Any) -> Optional[str]:
        """Decode an indexer note payload to UTF-8 text when possible."""
        if note is None:
            return None
        try:
            if isinstance(note, bytes):
                return note.decode("utf-8", errors="replace")
            if isinstance(note, str):
                decoded = base64.b64decode(note)
                return decoded.decode("utf-8", errors="replace")
            return str(note)
        except Exception:
            return str(note)

    def _app_global_state(self, app_id: int) -> Dict[str, Any]:
        """Fetch and decode application global state."""
        app = self.algod_client.application_info(app_id)
        kvs = app.get("params", {}).get("global-state", [])
        decoded: Dict[str, Any] = {}
        for entry in kvs:
            key = base64.b64decode(entry["key"]).decode("utf-8", errors="ignore")
            value = entry.get("value", {})
            if value.get("type") == 1:
                decoded[key] = base64.b64decode(value.get("bytes", "")).decode("utf-8", errors="replace")
            else:
                decoded[key] = value.get("uint", 0)
        return decoded

    def _list_box_names(self, app_id: int) -> List[bytes]:
        """List box names for an app."""
        boxes = self.algod_client.application_boxes(app_id).get("boxes", [])
        return [base64.b64decode(b["name"]) for b in boxes]

    def _read_box_bytes(self, app_id: int, box_name: bytes) -> bytes:
        """Read a box value by name."""
        response = self.algod_client.application_box_by_name(app_id, box_name)
        raw = response.get("value", "")
        if isinstance(raw, str):
            return base64.b64decode(raw)
        return raw

    def _fetch_ipfs_json(self, cid: str) -> Optional[Dict[str, Any]]:
        """Fetch JSON metadata from an IPFS gateway."""
        if not cid:
            return None
        url = f"{self.ipfs_gateway_base.rstrip('/')}/{cid}"
        try:
            with httpx.Client(timeout=8.0) as client:
                response = client.get(url)
                response.raise_for_status()
                payload = response.json()
                if isinstance(payload, dict):
                    return payload
                return {"data": payload}
        except Exception as e:
            logger.warning(f"Failed to fetch IPFS metadata for CID {cid}: {e}")
            return None

    def _decode_attestation_box(self, payload: bytes) -> Dict[str, Any]:
        """Decode MerchantAttestation ARC4 payload (supports 7-field and 8-field variants)."""
        # Current on-chain struct: (name, category, approved, daily_limit, spent_today, last_update, parent_approved)
        v1 = TupleType.from_string("(string,string,bool,uint64,uint64,uint64,bool)")
        # Planned variant with metadata CID as trailing field.
        v2 = TupleType.from_string("(string,string,bool,uint64,uint64,uint64,bool,string)")
        for tuple_type in (v2, v1):
            try:
                decoded = tuple_type.decode(payload)
                if len(decoded) == 8:
                    return {
                        "merchant_name": str(decoded[0]),
                        "category": str(decoded[1]),
                        "is_approved": bool(decoded[2]),
                        "daily_limit": int(decoded[3]),
                        "total_spent_today": int(decoded[4]),
                        "last_update": int(decoded[5]),
                        "parent_approved": bool(decoded[6]),
                        "metadata_cid": str(decoded[7]),
                    }
                return {
                    "merchant_name": str(decoded[0]),
                    "category": str(decoded[1]),
                    "is_approved": bool(decoded[2]),
                    "daily_limit": int(decoded[3]),
                    "total_spent_today": int(decoded[4]),
                    "last_update": int(decoded[5]),
                    "parent_approved": bool(decoded[6]),
                }
            except Exception:
                continue
        raise ValueError("Unable to decode merchant attestation payload")

    def fetch_ipfs_metadata(self, cid: str) -> Dict[str, Any]:
        """Public wrapper for fetching merchant metadata from IPFS."""
        payload = self._fetch_ipfs_json(cid)
        if payload is None:
            return {"error": f"Unable to fetch metadata for CID {cid}"}
        return {"cid": cid, "metadata": payload}

    def get_allowance_state(self) -> Dict[str, Any]:
        """Read AllowanceManager global state from chain."""
        if not self.allowance_manager_app_id:
            return {"error": "Allowance manager app ID is not configured"}
        try:
            return {"app_id": self.allowance_manager_app_id, "global_state": self._app_global_state(self.allowance_manager_app_id)}
        except Exception as e:
            logger.error(f"Failed to read allowance state: {e}")
            return {"error": str(e)}

    def get_credit_profile(self, teen_address: str) -> Dict[str, Any]:
        """Read CreditJourney profile box for a teen."""
        if not self.credit_journey_app_id:
            return {"error": "CreditJourney app ID is not configured"}
        try:
            box_name = f"teen_{teen_address}".encode()
            profile_bytes = self._read_box_bytes(self.credit_journey_app_id, box_name)
            return {
                "teen_address": teen_address,
                "app_id": self.credit_journey_app_id,
                # ABI decode will be added once credit_journey.py schema is finalized
                "raw_profile_b64": base64.b64encode(profile_bytes).decode(),
            }
        except Exception as e:
            logger.error(f"Failed to read credit profile for {teen_address}: {e}")
            return {"error": str(e)}

    def get_credit_milestones(self, teen_address: str) -> Dict[str, Any]:
        """Read CreditJourney milestone box for a teen."""
        if not self.credit_journey_app_id:
            return {"error": "CreditJourney app ID is not configured"}
        try:
            box_name = f"milestones_{teen_address}".encode()
            milestone_bytes = self._read_box_bytes(self.credit_journey_app_id, box_name)
            return {
                "teen_address": teen_address,
                "app_id": self.credit_journey_app_id,
                # ABI decode will be added once credit_journey.py schema is finalized
                "raw_milestones_b64": base64.b64encode(milestone_bytes).decode(),
            }
        except Exception as e:
            logger.error(f"Failed to read milestones for {teen_address}: {e}")
            return {"error": str(e)}

    def get_merchant_attestation(self, merchant_name: str) -> Dict[str, Any]:
        """Read a merchant attestation box and enrich with IPFS metadata when available."""
        if not self.attestation_oracle_app_id:
            return {"error": "Attestation oracle app ID is not configured"}
        try:
            box_name = f"merchant_{merchant_name}".encode()
            attestation_bytes = self._read_box_bytes(self.attestation_oracle_app_id, box_name)
            decoded = self._decode_attestation_box(attestation_bytes)
            result: Dict[str, Any] = {
                **decoded,
                "app_id": self.attestation_oracle_app_id,
                "raw_attestation_b64": base64.b64encode(attestation_bytes).decode(),
            }
            metadata_cid = result.get("metadata_cid")
            if metadata_cid:
                metadata_payload = self._fetch_ipfs_json(str(metadata_cid))
                if metadata_payload is not None:
                    result["metadata"] = metadata_payload
            return result
        except Exception as e:
            logger.error(f"Failed to read merchant attestation for {merchant_name}: {e}")
            return {"error": str(e)}

    def list_merchants(self) -> Dict[str, Any]:
        """List merchant boxes from AttestationOracle and return lightweight records."""
        if not self.attestation_oracle_app_id:
            return {"error": "Attestation oracle app ID is not configured"}
        try:
            merchant_entries: List[Dict[str, Any]] = []
            for name in self._list_box_names(self.attestation_oracle_app_id):
                if not name.startswith(b"merchant_"):
                    continue
                merchant_name = name[len(b"merchant_"):].decode("utf-8", errors="replace")
                merchant_entries.append(self.get_merchant_attestation(merchant_name))
            return {"app_id": self.attestation_oracle_app_id, "merchants": merchant_entries}
        except Exception as e:
            logger.error(f"Failed to list merchant attestations: {e}")
            return {"error": str(e)}
    
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
            transactions_response = self.indexer_client.search_transactions(
                address=address,
                limit=limit
            )
            
            formatted_transactions = []
            for tx in transactions_response.get('transactions', []):
                payment_txn = tx.get('payment-transaction', {})
                formatted_tx = {
                    "id": tx.get('id'),
                    "type": tx.get('tx-type'),
                    "round": tx.get('confirmed-round'),
                    "timestamp": tx.get('round-time'),
                    "sender": tx.get('sender'),
                    "receiver": payment_txn.get('receiver'),
                    "amount": payment_txn.get('amount', 0),
                    "note": self._decode_note(tx.get('note')),
                    "confirmed": tx.get('confirmed-round') is not None
                }
                formatted_transactions.append(formatted_tx)
            
            return formatted_transactions
        except Exception as e:
            logger.error(f"Failed to get transaction history for {address}: {e}")
            return []

    def get_transaction_status(self, transaction_id: str) -> Dict[str, Any]:
        """Fetch transaction status/details from Algorand indexer."""
        try:
            tx = self.indexer_client.transaction(transaction_id).get("transaction", {})
            payment_txn = tx.get("payment-transaction", {})
            return {
                "id": tx.get("id", transaction_id),
                "type": tx.get("tx-type"),
                "round": tx.get("confirmed-round"),
                "timestamp": tx.get("round-time"),
                "sender": tx.get("sender"),
                "receiver": payment_txn.get("receiver"),
                "amount": payment_txn.get("amount", 0),
                "note": self._decode_note(tx.get("note")),
                "confirmed": tx.get("confirmed-round") is not None,
            }
        except Exception as e:
            logger.error(f"Failed to get transaction status for {transaction_id}: {e}")
            return {"error": str(e)}

    def get_parent_insights(self, teen_address: str, limit: int = 100) -> Dict[str, Any]:
        """Compute parent insights from indexer activity + on-chain profile data."""
        try:
            transactions = self.get_transaction_history(teen_address, limit=limit)
            profile = self.get_credit_profile(teen_address)
            milestones = self.get_credit_milestones(teen_address)

            spend_txs = [
                tx for tx in transactions
                if tx.get("type") == "pay" and tx.get("sender") == teen_address and tx.get("amount", 0) > 0
            ]
            incoming_txs = [
                tx for tx in transactions
                if tx.get("type") == "pay" and tx.get("receiver") == teen_address and tx.get("amount", 0) > 0
            ]

            # Build merchant/category distributions using note pattern.
            merchant_spend: Dict[str, int] = {}
            category_spend: Dict[str, int] = {}
            for tx in spend_txs:
                note = (tx.get("note") or "").strip()
                merchant_name = "unknown"
                if "ClearSpend purchase at" in note:
                    merchant_name = note.split("ClearSpend purchase at", 1)[1].strip() or "unknown"
                merchant_spend[merchant_name] = merchant_spend.get(merchant_name, 0) + int(tx.get("amount", 0))

            for merchant_name, amount in merchant_spend.items():
                merchant = self.get_merchant_attestation(merchant_name)
                category = merchant.get("category", "unknown") if not merchant.get("error") else "unknown"
                category_spend[category] = category_spend.get(category, 0) + amount

            total_spent = sum(tx.get("amount", 0) for tx in spend_txs)
            total_received = sum(tx.get("amount", 0) for tx in incoming_txs)
            savings_rate = (total_received / total_spent) if total_spent > 0 else 0.0

            return {
                "teen_address": teen_address,
                "transaction_window_count": len(transactions),
                "spending_transaction_count": len(spend_txs),
                "incoming_transaction_count": len(incoming_txs),
                "total_spent": total_spent,
                "total_received": total_received,
                "net_flow": total_received - total_spent,
                "merchant_diversity_count": len(merchant_spend),
                "merchant_spending": merchant_spend,
                "category_spending": category_spend,
                "savings_rate": round(savings_rate, 4),
                "credit_profile": profile if not profile.get("error") else None,
                "milestones": milestones if not milestones.get("error") else None,
                "profile_error": profile.get("error"),
                "milestones_error": milestones.get("error"),
            }
        except Exception as e:
            logger.error(f"Failed to compute parent insights for {teen_address}: {e}")
            return {"error": str(e)}
    
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

            logger.info("Deploying Attestation Oracle contract...")
            
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
