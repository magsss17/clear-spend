#!/usr/bin/env python3
"""
Test script to verify merchant integration between frontend and backend
"""

import requests
import json
import time

# Backend URL
BACKEND_URL = "http://localhost:8000"

def test_merchant_endpoints():
    """Test the merchant API endpoints"""
    print("🧪 Testing Merchant Integration...")
    
    # Test 1: Get all merchants
    print("\n1. Testing GET /api/v1/merchants/")
    try:
        response = requests.get(f"{BACKEND_URL}/api/v1/merchants/")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success: Found {len(data.get('merchants', []))} merchants")
            for merchant in data.get('merchants', [])[:3]:  # Show first 3
                print(f"   - {merchant['merchant_name']}: {merchant['category']} (Parent Approved: {merchant['parent_approved']})")
        else:
            print(f"❌ Failed: Status {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Test 2: Add a new merchant
    print("\n2. Testing POST /api/v1/merchants/")
    test_merchant = {
        "merchant_name": "Test Store",
        "category": "Shopping",
        "is_approved": True,
        "daily_limit": 100000000,  # 100 ALGO in microAlgos
        "parent_approved": True,
        "merchant_address": None
    }
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/v1/merchants/",
            json=test_merchant,
            headers={"Content-Type": "application/json"}
        )
        if response.status_code == 200:
            print("✅ Success: Test merchant added")
        else:
            print(f"❌ Failed: Status {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Test 3: Update parent approval
    print("\n3. Testing POST /api/v1/merchants/Test Store/parent-approval")
    approval_data = {
        "merchant_name": "Test Store",
        "approved": False
    }
    
    try:
        response = requests.post(
            f"{BACKEND_URL}/api/v1/merchants/Test Store/parent-approval",
            json=approval_data,
            headers={"Content-Type": "application/json"}
        )
        if response.status_code == 200:
            print("✅ Success: Parent approval updated")
        else:
            print(f"❌ Failed: Status {response.status_code} - {response.text}")
    except Exception as e:
        print(f"❌ Error: {e}")
    
    # Test 4: Verify the change
    print("\n4. Verifying merchant status after approval change")
    try:
        response = requests.get(f"{BACKEND_URL}/api/v1/merchants/Test Store")
        if response.status_code == 200:
            data = response.json()
            print(f"✅ Success: Test Store parent_approved = {data['parent_approved']}")
        else:
            print(f"❌ Failed: Status {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")

def test_ios_app_compatibility():
    """Test that the API response format matches what the iOS app expects"""
    print("\n📱 Testing iOS App Compatibility...")
    
    try:
        response = requests.get(f"{BACKEND_URL}/api/v1/merchants/")
        if response.status_code == 200:
            data = response.json()
            
            # Check if response has the expected structure
            if 'merchants' in data and isinstance(data['merchants'], list):
                print("✅ API response format is compatible with iOS app")
                
                # Check if merchants have required fields
                if data['merchants']:
                    merchant = data['merchants'][0]
                    required_fields = ['merchant_name', 'category', 'is_approved', 'parent_approved', 'daily_limit', 'total_spent_today', 'last_update']
                    missing_fields = [field for field in required_fields if field not in merchant]
                    
                    if not missing_fields:
                        print("✅ All required merchant fields are present")
                    else:
                        print(f"❌ Missing fields: {missing_fields}")
                else:
                    print("⚠️  No merchants found to test field structure")
            else:
                print("❌ API response format is not compatible with iOS app")
                print(f"   Expected: {{'merchants': [...]}}")
                print(f"   Got: {list(data.keys())}")
        else:
            print(f"❌ Failed to fetch merchants: Status {response.status_code}")
    except Exception as e:
        print(f"❌ Error: {e}")

if __name__ == "__main__":
    print("🚀 Starting Merchant Integration Tests")
    print("=" * 50)
    
    # Check if backend is running
    try:
        response = requests.get(f"{BACKEND_URL}/docs")
        if response.status_code == 200:
            print("✅ Backend is running")
        else:
            print("⚠️  Backend health check failed, but continuing tests...")
    except:
        print("❌ Backend is not running. Please start the backend first:")
        print("   python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000")
        exit(1)
    
    test_merchant_endpoints()
    test_ios_app_compatibility()
    
    print("\n" + "=" * 50)
    print("🎉 Merchant integration tests completed!")
    print("\nNext steps:")
    print("1. Start the iOS app and navigate to Parent Controls")
    print("2. Verify that merchants are loaded from the backend")
    print("3. Test adding a new merchant")
    print("4. Test toggling parent approval for existing merchants")
