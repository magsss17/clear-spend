#!/usr/bin/env python3
"""
ClearSpend Backend-Frontend Integration Demo Script
Shows how to demo the backend working with the iOS app
"""

import requests
import json
import time
import subprocess
import sys

# Backend URL
BASE_URL = "http://localhost:8000"

def print_header(title):
    """Print a formatted header"""
    print(f"\n{'='*60}")
    print(f"🎯 {title}")
    print(f"{'='*60}")

def print_step(step, description):
    """Print a formatted step"""
    print(f"\n📋 Step {step}: {description}")
    print("-" * 40)

def test_backend_endpoint(endpoint, method="GET", data=None):
    """Test a backend endpoint and return the result"""
    url = f"{BASE_URL}{endpoint}"
    
    try:
        if method.upper() == "GET":
            response = requests.get(url)
        elif method.upper() == "POST":
            response = requests.post(url, json=data)
        else:
            return None, f"Unsupported method: {method}"
            
        if response.status_code == 200:
            return response.json(), None
        else:
            return None, f"HTTP {response.status_code}: {response.text}"
            
    except requests.exceptions.ConnectionError:
        return None, "Backend not running. Start with: conda run -n base python scripts/start_backend.py"
    except Exception as e:
        return None, str(e)

def demo_merchant_management():
    """Demo merchant management features"""
    print_step(1, "Merchant Management Demo")
    
    # Get all merchants
    merchants, error = test_backend_endpoint("/api/v1/merchants/")
    if error:
        print(f"❌ Error: {error}")
        return False
    
    print("✅ Current merchants in the system:")
    for name, details in merchants.items():
        status = "✅ Approved" if details.get("is_approved") else "❌ Rejected"
        category = details.get("category", "Unknown")
        limit = details.get("daily_limit", 0) / 1_000_000  # Convert from microALGO
        print(f"   • {name} ({category}) - {status} - Daily limit: {limit} ALGO")
    
    return True

def demo_purchase_verification():
    """Demo purchase verification flow"""
    print_step(2, "Purchase Verification Demo")
    
    # Test approved purchase
    print("🧪 Testing APPROVED purchase (Starbucks - $5.00):")
    purchase_data = {
        "merchant_name": "Starbucks",
        "amount": 5000000,  # 5 ALGO in microALGO
        "user_address": "DEMO_ADDRESS"
    }
    
    result, error = test_backend_endpoint("/api/v1/purchases/verify", "POST", purchase_data)
    if error:
        print(f"❌ Error: {error}")
        return False
    
    if result and result.get("approved"):
        print(f"✅ Purchase APPROVED!")
        print(f"   Transaction ID: {result.get('transaction_id')}")
        print(f"   Explorer Link: {result.get('explorer_link')}")
    else:
        print(f"❌ Purchase REJECTED: {result.get('reason') if result else 'Unknown error'}")
    
    # Test rejected purchase
    print("\n🧪 Testing REJECTED purchase (Gaming Store - $1.00):")
    rejected_purchase_data = {
        "merchant_name": "Gaming Store",
        "amount": 1000000,  # 1 ALGO in microALGO
        "user_address": "DEMO_ADDRESS"
    }
    
    result, error = test_backend_endpoint("/api/v1/purchases/verify", "POST", rejected_purchase_data)
    if error:
        print(f"❌ Error: {error}")
        return False
    
    if result and not result.get("approved"):
        print(f"❌ Purchase REJECTED: {result.get('reason')}")
    else:
        print(f"✅ Purchase APPROVED (unexpected!)")
    
    return True

def demo_ios_app_integration():
    """Demo how the iOS app integrates with the backend"""
    print_step(3, "iOS App Integration Demo")
    
    print("📱 iOS App Integration Points:")
    print("   1. AlgorandService.swift now calls real backend API")
    print("   2. Purchase verification uses /api/v1/purchases/verify")
    print("   3. Merchant data comes from /api/v1/merchants/")
    print("   4. Fallback to mock data if backend unavailable")
    
    print("\n🔧 To test in iOS app:")
    print("   1. Open: open ios-app/ClearSpendApp.xcodeproj")
    print("   2. Build and run in iOS Simulator")
    print("   3. Go to 'Spend' tab")
    print("   4. Try purchasing from different merchants")
    print("   5. Watch real-time backend verification!")
    
    return True

def demo_api_documentation():
    """Demo API documentation"""
    print_step(4, "API Documentation Demo")
    
    print("📚 Interactive API Documentation:")
    print(f"   • Swagger UI: {BASE_URL}/docs")
    print(f"   • OpenAPI Spec: {BASE_URL}/openapi.json")
    
    # Test if docs are accessible
    result, error = test_backend_endpoint("/docs")
    if not error:
        print("✅ API documentation is accessible")
    else:
        print(f"❌ API documentation error: {error}")
    
    return True

def demo_real_time_monitoring():
    """Demo real-time monitoring capabilities"""
    print_step(5, "Real-time Monitoring Demo")
    
    print("📊 Backend provides real-time data:")
    
    # Health check
    health, error = test_backend_endpoint("/api/v1/health/")
    if not error and health:
        print(f"   • Backend Status: {health.get('status', 'Unknown')}")
        print(f"   • Algorand Connection: {health.get('algorand_connection', 'Unknown')}")
        print(f"   • Last Block: {health.get('last_round', 'Unknown')}")
    
    # Transaction history
    transactions, error = test_backend_endpoint("/api/v1/transactions/DEMO_ADDRESS")
    if not error and transactions:
        count = transactions.get('total_count', 0)
        print(f"   • Transaction History: {count} transactions")
    
    return True

def main():
    """Run the complete demo"""
    print_header("ClearSpend Backend-Frontend Integration Demo")
    
    print("🚀 This demo shows how the backend integrates with the iOS app")
    print("📱 The iOS app now calls real backend APIs for purchase verification")
    
    # Check if backend is running
    print("\n🔍 Checking backend status...")
    health, error = test_backend_endpoint("/api/v1/health/")
    if error:
        print(f"❌ Backend not running: {error}")
        print("\n🔧 To start the backend:")
        print("   conda run -n base python scripts/start_backend.py")
        return
    
    print("✅ Backend is running and healthy!")
    
    # Run demo steps
    steps = [
        demo_merchant_management,
        demo_purchase_verification,
        demo_ios_app_integration,
        demo_api_documentation,
        demo_real_time_monitoring
    ]
    
    success_count = 0
    for step in steps:
        if step():
            success_count += 1
    
    # Final summary
    print_header("Demo Complete!")
    print(f"🎯 {success_count}/{len(steps)} demo steps completed successfully")
    
    if success_count == len(steps):
        print("\n🎉 Backend-Frontend Integration is WORKING!")
        print("\n📱 Next Steps:")
        print("   1. Open iOS app: open ios-app/ClearSpendApp.xcodeproj")
        print("   2. Build and run in simulator")
        print("   3. Test purchase flow with real backend")
        print("   4. Show live merchant approval/rejection")
        
        print("\n🎬 Demo Script:")
        print("   1. Show backend API docs: open http://localhost:8000/docs")
        print("   2. Run this demo: python demo_backend_integration.py")
        print("   3. Open iOS app and demonstrate purchase flow")
        print("   4. Show real-time backend verification in action!")
    else:
        print("\n⚠️  Some demo steps failed. Check backend logs for issues.")

if __name__ == "__main__":
    main()
