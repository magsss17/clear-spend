#!/usr/bin/env python3
"""
ClearSpend Backend-Frontend Integration Test Script
Tests all major API endpoints to verify backend functionality
"""

import requests
import json
import time

# Backend URL
BASE_URL = "http://localhost:8000"

def test_endpoint(method, endpoint, data=None, expected_status=200):
    """Test a single API endpoint"""
    url = f"{BASE_URL}{endpoint}"
    
    try:
        if method.upper() == "GET":
            response = requests.get(url)
        elif method.upper() == "POST":
            response = requests.post(url, json=data)
        elif method.upper() == "PUT":
            response = requests.put(url, json=data)
        else:
            print(f"❌ Unsupported method: {method}")
            return False
            
        if response.status_code == expected_status:
            print(f"✅ {method} {endpoint} - Status: {response.status_code}")
            if response.content:
                try:
                    result = response.json()
                    print(f"   Response: {json.dumps(result, indent=2)[:200]}...")
                except:
                    print(f"   Response: {response.text[:200]}...")
            return True
        else:
            print(f"❌ {method} {endpoint} - Expected: {expected_status}, Got: {response.status_code}")
            print(f"   Error: {response.text}")
            return False
            
    except requests.exceptions.ConnectionError:
        print(f"❌ {method} {endpoint} - Connection failed (backend not running?)")
        return False
    except Exception as e:
        print(f"❌ {method} {endpoint} - Error: {str(e)}")
        return False

def main():
    """Run all integration tests"""
    print("🚀 ClearSpend Backend-Frontend Integration Tests")
    print("=" * 60)
    
    # Test results
    tests_passed = 0
    tests_total = 0
    
    # Test 1: Root endpoint
    print("\n📋 Test 1: Root Endpoint")
    tests_total += 1
    if test_endpoint("GET", "/"):
        tests_passed += 1
    
    # Test 2: Health check
    print("\n🏥 Test 2: Health Check")
    tests_total += 1
    if test_endpoint("GET", "/api/v1/health/"):
        tests_passed += 1
    
    # Test 3: Get merchants
    print("\n🏪 Test 3: Get Merchants")
    tests_total += 1
    if test_endpoint("GET", "/api/v1/merchants/"):
        tests_passed += 1
    
    # Test 4: Get specific merchant
    print("\n🏪 Test 4: Get Specific Merchant")
    tests_total += 1
    if test_endpoint("GET", "/api/v1/merchants/Starbucks"):
        tests_passed += 1
    
    # Test 5: Purchase verification (approved)
    print("\n💳 Test 5: Purchase Verification (Approved)")
    tests_total += 1
    purchase_data = {
        "merchant_name": "Starbucks",
        "amount": 5000000,
        "user_address": "DEMO_ADDRESS"
    }
    if test_endpoint("POST", "/api/v1/purchases/verify", purchase_data):
        tests_passed += 1
    
    # Test 6: Purchase verification (rejected)
    print("\n💳 Test 6: Purchase Verification (Rejected)")
    tests_total += 1
    rejected_purchase_data = {
        "merchant_name": "Gaming Store",
        "amount": 1000000,
        "user_address": "DEMO_ADDRESS"
    }
    if test_endpoint("POST", "/api/v1/purchases/verify", rejected_purchase_data):
        tests_passed += 1
    
    # Test 7: Issue allowance
    print("\n💰 Test 7: Issue Allowance")
    tests_total += 1
    allowance_data = {
        "teen_address": "DEMO_TEEN_ADDRESS",
        "weekly_amount": 150000000
    }
    if test_endpoint("POST", "/api/v1/allowances/issue", allowance_data):
        tests_passed += 1
    
    # Test 8: Get transaction history
    print("\n📊 Test 8: Get Transaction History")
    tests_total += 1
    if test_endpoint("GET", "/api/v1/transactions/DEMO_ADDRESS"):
        tests_passed += 1
    
    # Test 9: Add new merchant
    print("\n➕ Test 9: Add New Merchant")
    tests_total += 1
    new_merchant_data = {
        "merchant_name": "Test Store",
        "category": "Shopping",
        "is_approved": True,
        "daily_limit": 100000000
    }
    if test_endpoint("POST", "/api/v1/merchants/", new_merchant_data):
        tests_passed += 1
    
    # Test 10: API Documentation
    print("\n📚 Test 10: API Documentation")
    tests_total += 1
    if test_endpoint("GET", "/docs"):
        tests_passed += 1
    
    # Results
    print("\n" + "=" * 60)
    print(f"🎯 Integration Test Results: {tests_passed}/{tests_total} passed")
    
    if tests_passed == tests_total:
        print("🎉 ALL TESTS PASSED! Backend is ready for frontend integration.")
        print("\n📱 Next Steps:")
        print("1. Open ios-app/ClearSpendApp.xcodeproj in Xcode")
        print("2. Update AlgorandService.swift to use http://localhost:8000")
        print("3. Build and run the iOS app")
        print("4. Test the purchase flow with real backend data")
    else:
        print("❌ Some tests failed. Check the backend logs for issues.")
        print("\n🔧 Troubleshooting:")
        print("1. Make sure backend is running: conda run -n base python scripts/start_backend.py")
        print("2. Check if port 8000 is available: lsof -ti:8000")
        print("3. Verify all dependencies are installed: pip install -r requirements.txt")

if __name__ == "__main__":
    main()
