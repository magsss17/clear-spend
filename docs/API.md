# ClearSpend API Documentation

## 🚀 Overview

The ClearSpend Backend API provides comprehensive endpoints for managing teen financial literacy on Algorand blockchain. Built with FastAPI, it offers real-time purchase verification, parental controls, and transaction management.

**Base URL**: `http://localhost:8000`  
**API Version**: `v1`  
**Documentation**: `http://localhost:8000/docs` (Interactive Swagger UI)

## 🔐 Authentication

Currently using demo authentication for hackathon purposes. In production, implement JWT-based authentication.

## 📡 Endpoints

### Health & Status

#### GET `/api/v1/health/`
Get system health status.

**Response:**
```json
{
  "success": true,
  "status": "healthy",
  "algorand_connection": "connected",
  "last_round": 12345678,
  "uptime": 3600.5,
  "version": "1.0.0",
  "message": "Health check completed"
}
```

#### GET `/api/v1/health/network`
Get Algorand network status.

**Response:**
```json
{
  "success": true,
  "last_round": 12345678,
  "time_since_last_round": 4,
  "catchup_time": 0,
  "network": "testnet",
  "message": "Network status retrieved successfully"
}
```

#### GET `/api/v1/health/contracts`
Get smart contract deployment status.

**Response:**
```json
{
  "success": true,
  "message": "Contract status retrieved successfully",
  "data": {
    "attestation_oracle": {
      "deployed": true,
      "app_id": 12345
    },
    "allowance_manager": {
      "deployed": true,
      "app_id": 12346
    }
  }
}
```

### Merchant Management

#### GET `/api/v1/merchants/`
Get all merchant attestations.

**Response:**
```json
{
  "Starbucks": {
    "success": true,
    "merchant_name": "Starbucks",
    "category": "Food & Beverage",
    "is_approved": true,
    "daily_limit": 50000000,
    "total_spent_today": 0,
    "parent_approved": true,
    "last_update": 1703123456
  }
}
```

#### GET `/api/v1/merchants/{merchant_name}`
Get specific merchant attestation.

**Parameters:**
- `merchant_name` (string): Name of the merchant

**Response:**
```json
{
  "success": true,
  "merchant_name": "Starbucks",
  "category": "Food & Beverage",
  "is_approved": true,
  "daily_limit": 50000000,
  "total_spent_today": 0,
  "parent_approved": true,
  "last_update": 1703123456
}
```

#### POST `/api/v1/merchants/`
Add or update merchant attestation.

**Request Body:**
```json
{
  "merchant_name": "New Store",
  "category": "Retail",
  "is_approved": true,
  "daily_limit": 25000000,
  "parent_approved": true,
  "merchant_address": "MERCHANT_ALGORAND_ADDRESS"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Merchant New Store added successfully"
}
```

#### PUT `/api/v1/merchants/{merchant_name}/limits`
Update merchant daily limits and approval status.

**Request Body:**
```json
{
  "merchant_name": "Starbucks",
  "new_daily_limit": 75000000,
  "is_approved": true
}
```

#### POST `/api/v1/merchants/{merchant_name}/parent-approval`
Update parent approval for a merchant.

**Request Body:**
```json
{
  "merchant_name": "Gaming Store",
  "approved": true
}
```

#### GET `/api/v1/merchants/{merchant_name}/analytics`
Get analytics for a specific merchant.

**Response:**
```json
{
  "success": true,
  "merchant_name": "Starbucks",
  "category": "Food & Beverage",
  "daily_limit": 50000000,
  "total_spent_today": 15000000,
  "daily_usage_percent": 30.0,
  "is_approved": true,
  "parent_approved": true,
  "last_update": 1703123456
}
```

### Purchase Management

#### POST `/api/v1/purchases/verify`
Verify if a purchase is allowed without executing it.

**Request Body:**
```json
{
  "merchant_name": "Starbucks",
  "amount": 5000000,
  "user_address": "TEEN_ALGORAND_ADDRESS"
}
```

**Response:**
```json
{
  "success": true,
  "approved": true,
  "reason": null,
  "transaction_id": "mock_tx_1703123456",
  "explorer_link": "https://testnet.algoexplorer.io/tx/mock_tx_1703123456",
  "amount": 5000000,
  "merchant_name": "Starbucks"
}
```

#### POST `/api/v1/purchases/execute`
Execute a purchase using atomic transactions.

**Request Body:**
```json
{
  "merchant_name": "Starbucks",
  "amount": 5000000,
  "user_address": "TEEN_ALGORAND_ADDRESS"
}
```

**Response:**
```json
{
  "success": true,
  "approved": true,
  "transaction_id": "ABC123DEF456",
  "explorer_link": "https://testnet.algoexplorer.io/tx/ABC123DEF456",
  "amount": 5000000,
  "merchant_name": "Starbucks"
}
```

#### GET `/api/v1/purchases/{transaction_id}/status`
Get the status of a purchase transaction.

**Response:**
```json
{
  "success": true,
  "approved": true,
  "transaction_id": "ABC123DEF456",
  "explorer_link": "https://testnet.algoexplorer.io/tx/ABC123DEF456",
  "message": "Transaction confirmed"
}
```

### Allowance Management

#### POST `/api/v1/allowances/issue`
Issue weekly allowance to teen.

**Request Body:**
```json
{
  "teen_address": "TEEN_ALGORAND_ADDRESS",
  "weekly_amount": 150000000,
  "parent_private_key": "PARENT_PRIVATE_KEY"
}
```

**Response:**
```json
{
  "success": true,
  "teen_address": "TEEN_ALGORAND_ADDRESS",
  "weekly_amount": 150000000,
  "total_issued": 600000000,
  "last_allowance_time": 1703123456,
  "is_paused": false,
  "can_issue": true,
  "message": "Weekly allowance issued successfully"
}
```

#### POST `/api/v1/allowances/emergency`
Issue emergency allowance to teen.

**Request Body:**
```json
{
  "teen_address": "TEEN_ALGORAND_ADDRESS",
  "amount": 50000000,
  "parent_private_key": "PARENT_PRIVATE_KEY"
}
```

#### GET `/api/v1/allowances/{teen_address}/status`
Get current allowance status for a teen.

**Response:**
```json
{
  "success": true,
  "teen_address": "TEEN_ALGORAND_ADDRESS",
  "weekly_amount": 150000000,
  "total_issued": 600000000,
  "last_allowance_time": 1703037056,
  "is_paused": false,
  "can_issue": true,
  "message": "Allowance status retrieved successfully"
}
```

#### POST `/api/v1/allowances/{teen_address}/pause`
Pause allowance for a teen.

**Response:**
```json
{
  "success": true,
  "message": "Allowance for TEEN_ALGORAND_ADDRESS paused successfully"
}
```

#### POST `/api/v1/allowances/{teen_address}/resume`
Resume allowance for a teen.

#### POST `/api/v1/allowances/savings/lock`
Lock teen savings until specified time.

**Request Body:**
```json
{
  "teen_address": "TEEN_ALGORAND_ADDRESS",
  "amount": 100000000,
  "unlock_time": 1703209856,
  "teen_private_key": "TEEN_PRIVATE_KEY"
}
```

**Response:**
```json
{
  "success": true,
  "teen_address": "TEEN_ALGORAND_ADDRESS",
  "amount_locked": 100000000,
  "unlock_time": 1703209856,
  "can_unlock": false,
  "message": "Savings locked successfully"
}
```

#### POST `/api/v1/allowances/savings/unlock`
Unlock teen savings if time has passed.

### Transaction History

#### GET `/api/v1/transactions/{user_address}`
Get transaction history for a user.

**Parameters:**
- `user_address` (string): User's Algorand address
- `limit` (int, optional): Maximum number of transactions (default: 50)

**Response:**
```json
{
  "success": true,
  "transactions": [
    {
      "id": "ABC123DEF456",
      "type": "pay",
      "round": 12345678,
      "timestamp": 1703123456,
      "sender": "TEEN_ALGORAND_ADDRESS",
      "receiver": "MERCHANT_ALGORAND_ADDRESS",
      "amount": 5000000,
      "note": "ClearSpend purchase at Starbucks",
      "confirmed": true,
      "explorer_link": "https://testnet.algoexplorer.io/tx/ABC123DEF456"
    }
  ],
  "total_count": 1,
  "user_address": "TEEN_ALGORAND_ADDRESS",
  "message": "Transaction history retrieved successfully"
}
```

#### GET `/api/v1/transactions/{user_address}/analytics`
Get transaction analytics for a user.

**Response:**
```json
{
  "success": true,
  "user_address": "TEEN_ALGORAND_ADDRESS",
  "analytics": {
    "total_spent": 25000000,
    "total_received": 600000000,
    "transaction_count": 5,
    "merchant_spending": {
      "Starbucks": 15000000,
      "Target": 10000000
    },
    "net_balance": 575000000
  },
  "message": "Analytics retrieved successfully"
}
```

#### GET `/api/v1/transactions/account/{address}/info`
Get account information.

**Response:**
```json
{
  "success": true,
  "address": "TEEN_ALGORAND_ADDRESS",
  "balance": 575000000,
  "balance_algo": 575.0,
  "assets": [],
  "created_apps": [],
  "created_assets": [],
  "message": "Account information retrieved successfully"
}
```

## 🔧 Error Handling

All endpoints return structured error responses:

```json
{
  "success": false,
  "error": "Error message",
  "status_code": 400
}
```

### Common HTTP Status Codes

- `200 OK`: Request successful
- `400 Bad Request`: Invalid request data
- `404 Not Found`: Resource not found
- `500 Internal Server Error`: Server error
- `503 Service Unavailable`: Service not available

## 📊 Rate Limiting

API endpoints are rate-limited to prevent abuse. Default limits:
- 100 requests per minute per IP
- 1000 requests per hour per IP

## 🔒 Security Considerations

- All requests are validated using Pydantic models
- Private keys are handled securely (not logged)
- CORS is configured for cross-origin requests
- Input sanitization prevents injection attacks

## 🧪 Testing

Use the interactive documentation at `http://localhost:8000/docs` to test endpoints, or use curl:

```bash
# Health check
curl http://localhost:8000/api/v1/health/

# Get merchants
curl http://localhost:8000/api/v1/merchants/

# Verify purchase
curl -X POST http://localhost:8000/api/v1/purchases/verify \
  -H "Content-Type: application/json" \
  -d '{"merchant_name": "Starbucks", "amount": 5000000, "user_address": "DEMO_ADDRESS"}'
```

## 📈 Performance

- Average response time: < 200ms
- Concurrent request handling: 100+ requests/second
- Database connection pooling for efficiency
- Redis caching for frequently accessed data

---

For more information, visit the interactive API documentation at `http://localhost:8000/docs`.
