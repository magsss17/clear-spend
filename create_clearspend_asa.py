#!/usr/bin/env python3
"""
Create ClearSpend Dollar (CSD) ASA on Algorand Testnet
For hackathon demo - creates the ASA token that will be used for allowances
"""

import json
from algosdk import transaction
from algosdk.v2client.algod import AlgodClient

# Testnet configuration
ALGOD_URL = "https://testnet-api.algonode.cloud"
ALGOD_TOKEN = ""

# Demo account mnemonic (same as in iOS app) - valid testnet wallet
DEMO_MNEMONIC = "first canvas energy brass base lamp trouble fee soda first voyage panic giggle differ palace kitchen empty sword palm treat warfare artefact rib absent midnight"

def create_clearspend_asa():
    """Create the ClearSpend Dollar ASA token"""
    
    # Initialize client
    algod_client = AlgodClient(ALGOD_TOKEN, ALGOD_URL)
    
    # Import account from mnemonic
    from algosdk.mnemonic import to_private_key
    from algosdk.account import address_from_private_key
    
    private_key = to_private_key(DEMO_MNEMONIC)
    address = address_from_private_key(private_key)
    
    print(f"Creator address: {address}")
    
    try:
        # Check account balance
        account_info = algod_client.account_info(address)
        balance = account_info['amount'] / 1_000_000
        print(f"Account balance: {balance:.3f} ALGO")
        
        if balance < 0.1:
            print("⚠️  Low balance! Fund this address with testnet ALGOs:")
            print(f"   https://testnet.algoexplorer.io/address/{address}")
            print("   Use testnet dispenser: https://testnet.algoexplorer.io/dispenser")
            return None
        
        # Get suggested parameters
        params = algod_client.suggested_params()
        
        # Create asset transaction
        txn = transaction.AssetConfigTxn(
            sender=address,
            sp=params,
            total=1000000,  # 10,000 CSD with 2 decimal places
            default_frozen=False,
            unit_name="CSD",
            asset_name="ClearSpend Dollar",
            manager=address,
            reserve=address,
            freeze=address,
            clawback=address,
            url="https://clearspend.app",
            decimals=2,
            strict_empty_address_check=False
        )
        
        # Sign transaction
        signed_txn = txn.sign(private_key)
        
        # Submit transaction
        txid = algod_client.send_transaction(signed_txn)
        print(f"Transaction ID: {txid}")
        
        # Wait for confirmation
        confirmed_txn = transaction.wait_for_confirmation(algod_client, txid, 4)
        asset_id = confirmed_txn["asset-index"]
        
        print("\n🎉 ClearSpend Dollar ASA Created Successfully!")
        print(f"Asset ID: {asset_id}")
        print(f"Transaction: https://testnet.algoexplorer.io/tx/{txid}")
        print(f"Asset: https://testnet.algoexplorer.io/asset/{asset_id}")
        
        # Save configuration
        config = {
            "network": "testnet",
            "creator_address": address,
            "clearspend_asa_id": asset_id,
            "transaction_id": txid,
            "asset_details": {
                "name": "ClearSpend Dollar",
                "unit_name": "CSD",
                "decimals": 2,
                "total_supply": 10000,
                "url": "https://clearspend.app"
            }
        }
        
        with open('clearspend_asa_config.json', 'w') as f:
            json.dump(config, f, indent=2)
        
        print(f"\n💾 Configuration saved to clearspend_asa_config.json")
        print(f"📝 Update your iOS app AlgorandService.swift:")
        print(f"   private let clearSpendAsaId: UInt64 = {asset_id}")
        
        return asset_id
        
    except Exception as e:
        print(f"❌ Error creating ASA: {e}")
        return None

if __name__ == "__main__":
    print("🚀 Creating ClearSpend Dollar ASA on Algorand Testnet\n")
    create_clearspend_asa()