#!/usr/bin/env python3
"""
Generate a valid testnet wallet for ClearSpend hackathon
"""

from algosdk.account import generate_account
from algosdk.mnemonic import from_private_key

# Generate a new account
private_key, address = generate_account()

# Get the mnemonic
mnemonic = from_private_key(private_key)

print("ClearSpend Testnet Wallet Generated:")
print(f"Address: {address}")
print(f"Mnemonic: {mnemonic}")
print(f"\n⚠️  Fund this address with testnet ALGOs:")
print(f"https://testnet.algoexplorer.io/address/{address}")
print("Use dispenser: https://testnet.algoexplorer.io/dispenser")
print(f"\n📝 Update both iOS and Python scripts with this mnemonic")