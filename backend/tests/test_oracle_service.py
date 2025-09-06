"""
Tests for Oracle Service
"""

import pytest
from unittest.mock import Mock, patch
from backend.services.oracle_service import OracleService, MerchantAttestation, PurchaseRequest
from backend.services.blockchain_service import BlockchainService

class TestOracleService:
    """Test cases for OracleService"""
    
    @pytest.fixture
    def mock_blockchain_service(self):
        """Mock blockchain service"""
        mock_service = Mock(spec=BlockchainService)
        mock_service.attestation_oracle_app_id = 12345
        return mock_service
    
    @pytest.fixture
    def oracle_service(self, mock_blockchain_service):
        """Oracle service instance for testing"""
        return OracleService(mock_blockchain_service)
    
    def test_initialize_demo_merchants(self, oracle_service):
        """Test that demo merchants are initialized"""
        merchants = oracle_service.get_merchant_attestations()
        
        assert "Starbucks" in merchants
        assert "Target" in merchants
        assert "Gaming Store" in merchants
        assert "Bookstore" in merchants
        
        # Check Starbucks merchant
        starbucks = merchants["Starbucks"]
        assert starbucks.merchant_name == "Starbucks"
        assert starbucks.category == "Food & Beverage"
        assert starbucks.is_approved is True
        assert starbucks.daily_limit == 50000000
        assert starbucks.parent_approved is True
    
    def test_add_merchant_attestation(self, oracle_service):
        """Test adding a new merchant attestation"""
        new_merchant = MerchantAttestation(
            merchant_name="Test Store",
            category="Retail",
            is_approved=True,
            daily_limit=25000000,
            total_spent_today=0,
            last_update=1234567890,
            parent_approved=True
        )
        
        result = oracle_service.add_merchant_attestation(new_merchant)
        
        assert result["success"] is True
        assert result["merchant"] == "Test Store"
        
        # Verify merchant was added
        merchants = oracle_service.get_merchant_attestations()
        assert "Test Store" in merchants
    
    def test_verify_purchase_approved(self, oracle_service):
        """Test purchase verification for approved merchant"""
        request = PurchaseRequest(
            merchant_name="Starbucks",
            amount=5000000,  # 5 ALGO
            user_address="DEMO_USER_ADDRESS"
        )
        
        response = oracle_service.verify_purchase(request)
        
        assert response.approved is True
        assert response.transaction_id is not None
        assert response.explorer_link is not None
    
    def test_verify_purchase_merchant_not_found(self, oracle_service):
        """Test purchase verification for non-existent merchant"""
        request = PurchaseRequest(
            merchant_name="Non-existent Store",
            amount=5000000,
            user_address="DEMO_USER_ADDRESS"
        )
        
        response = oracle_service.verify_purchase(request)
        
        assert response.approved is False
        assert "not found" in response.reason.lower()
    
    def test_verify_purchase_merchant_not_approved(self, oracle_service):
        """Test purchase verification for non-approved merchant"""
        request = PurchaseRequest(
            merchant_name="Gaming Store",
            amount=5000000,
            user_address="DEMO_USER_ADDRESS"
        )
        
        response = oracle_service.verify_purchase(request)
        
        assert response.approved is False
        assert "not approved" in response.reason.lower()
    
    def test_verify_purchase_exceeds_daily_limit(self, oracle_service):
        """Test purchase verification when daily limit is exceeded"""
        # First, spend up to the limit
        request1 = PurchaseRequest(
            merchant_name="Starbucks",
            amount=50000000,  # Exactly the daily limit
            user_address="DEMO_USER_ADDRESS"
        )
        
        response1 = oracle_service.verify_purchase(request1)
        assert response1.approved is True
        
        # Try to spend more
        request2 = PurchaseRequest(
            merchant_name="Starbucks",
            amount=1000000,  # 1 ALGO more
            user_address="DEMO_USER_ADDRESS"
        )
        
        response2 = oracle_service.verify_purchase(request2)
        assert response2.approved is False
        assert "exceed" in response2.reason.lower()
    
    def test_update_merchant_limits(self, oracle_service):
        """Test updating merchant limits"""
        result = oracle_service.update_merchant_limits(
            merchant_name="Starbucks",
            new_daily_limit=75000000,  # 75 ALGO
            is_approved=True
        )
        
        assert result["success"] is True
        
        # Verify the update
        merchant = oracle_service.get_merchant_attestation("Starbucks")
        assert merchant.daily_limit == 75000000
    
    def test_parent_approve_merchant(self, oracle_service):
        """Test parent approval of merchant"""
        result = oracle_service.parent_approve_merchant(
            merchant_name="Gaming Store",
            approved=True
        )
        
        assert result["success"] is True
        
        # Verify the update
        merchant = oracle_service.get_merchant_attestation("Gaming Store")
        assert merchant.parent_approved is True
    
    def test_get_merchant_analytics(self, oracle_service):
        """Test getting merchant analytics"""
        analytics = oracle_service.get_merchant_analytics("Starbucks")
        
        assert analytics["merchant_name"] == "Starbucks"
        assert analytics["category"] == "Food & Beverage"
        assert analytics["daily_limit"] == 50000000
        assert analytics["total_spent_today"] == 0
        assert analytics["daily_usage_percent"] == 0.0
        assert analytics["is_approved"] is True
        assert analytics["parent_approved"] is True
    
    def test_sync_with_blockchain(self, oracle_service):
        """Test syncing with blockchain"""
        result = oracle_service.sync_with_blockchain()
        
        assert result["success"] is True
        assert "synced_merchants" in result
