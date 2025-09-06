# ClearSpend Backend

A comprehensive backend system for ClearSpend - Teen Financial Literacy on Algorand, built with FastAPI and AlgoKit.

## 🏗 Architecture

### Smart Contracts
- **Attestation Oracle** (`contracts/attestation_oracle.py`): Manages merchant attestations and purchase verification
- **Allowance Manager** (`contracts/allowance_manager.py`): Handles teen allowances with parental controls

### Backend Services
- **Blockchain Service** (`services/blockchain_service.py`): Algorand blockchain interactions
- **Oracle Service** (`services/oracle_service.py`): Merchant attestation management
- **FastAPI Application** (`main.py`): REST API with comprehensive endpoints

### Key Features
- ✅ **Atomic Transfer Verification**: Pre-purchase verification through atomic transaction groups
- ✅ **Merchant Attestation System**: On-chain merchant approval and daily limits
- ✅ **Parental Controls**: Parent approval for merchants and spending limits
- ✅ **Real-time Purchase Processing**: Instant verification and execution
- ✅ **Comprehensive API**: Full REST API for iOS app integration
- ✅ **Smart Contract Integration**: Direct blockchain interaction using AlgoKit

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- AlgoKit installed (`pipx install algokit`)
- Algorand Testnet account
- Environment variables configured

### Installation

1. **Clone and setup**:
```bash
cd backend
pip install -r requirements.txt
```

2. **Configure environment**:
```bash
cp ../config.env.example ../config.env
# Edit config.env with your Algorand credentials
```

3. **Deploy contracts**:
```bash
python deployment/deploy.py
```

4. **Start the API**:
```bash
python -m uvicorn backend.main:app --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000` with interactive docs at `http://localhost:8000/docs`.

## 📡 API Endpoints

### Health & Status
- `GET /api/v1/health/` - Health check
- `GET /api/v1/health/network` - Algorand network status
- `GET /api/v1/health/contracts` - Smart contract status

### Merchant Management
- `GET /api/v1/merchants/` - Get all merchants
- `GET /api/v1/merchants/{name}` - Get specific merchant
- `POST /api/v1/merchants/` - Add merchant attestation
- `PUT /api/v1/merchants/{name}/limits` - Update merchant limits
- `POST /api/v1/merchants/{name}/parent-approval` - Parent approval
- `GET /api/v1/merchants/{name}/analytics` - Merchant analytics

### Purchase Flow
- `POST /api/v1/purchases/verify` - Verify purchase (no execution)
- `POST /api/v1/purchases/execute` - Execute atomic purchase
- `GET /api/v1/purchases/{tx_id}/status` - Transaction status

### Allowance Management
- `POST /api/v1/allowances/issue` - Issue weekly allowance
- `POST /api/v1/allowances/emergency` - Issue emergency allowance
- `GET /api/v1/allowances/{address}/status` - Allowance status
- `POST /api/v1/allowances/{address}/pause` - Pause allowance
- `POST /api/v1/allowances/{address}/resume` - Resume allowance
- `POST /api/v1/allowances/savings/lock` - Lock savings
- `POST /api/v1/allowances/savings/unlock` - Unlock savings

### Transaction History
- `GET /api/v1/transactions/{address}` - Transaction history
- `GET /api/v1/transactions/{address}/analytics` - Spending analytics
- `GET /api/v1/transactions/account/{address}/info` - Account info

## 🔧 Configuration

### Environment Variables
```bash
# Algorand Network
ALGOD_TOKEN=your_algod_token
ALGOD_ADDRESS=https://testnet-api.algonode.cloud
INDEXER_ADDRESS=https://testnet-idx.algonode.cloud

# Demo Accounts (for testing)
DEMO_PARENT_MNEMONIC=your_parent_mnemonic
DEMO_TEEN_MNEMONIC=your_teen_mnemonic
DEMO_ORACLE_MNEMONIC=your_oracle_mnemonic
ORACLE_PRIVATE_KEY=your_oracle_private_key

# API Configuration
HOST=0.0.0.0
PORT=8000
DEBUG=false
```

## 🧪 Testing

Run the test suite:
```bash
# Install test dependencies
pip install pytest pytest-asyncio pytest-cov

# Run tests
pytest backend/tests/ -v

# Run with coverage
pytest backend/tests/ --cov=backend --cov-report=html
```

## 🐳 Docker Deployment

### Using Docker Compose
```bash
cd backend/deployment
docker-compose up -d
```

### Manual Docker Build
```bash
cd backend
docker build -f deployment/Dockerfile -t clearspend-backend .
docker run -p 8000:8000 --env-file ../config.env clearspend-backend
```

## 🔒 Security Features

- **Input Validation**: Comprehensive Pydantic models for all requests
- **Error Handling**: Structured error responses with proper HTTP status codes
- **CORS Configuration**: Configurable cross-origin resource sharing
- **Rate Limiting**: Built-in FastAPI rate limiting (configurable)
- **Private Key Management**: Secure handling of Algorand private keys
- **Transaction Verification**: Atomic transaction groups for secure purchases

## 📊 Monitoring & Logging

- **Structured Logging**: JSON-formatted logs with correlation IDs
- **Health Checks**: Comprehensive health monitoring endpoints
- **Performance Metrics**: Request timing and blockchain interaction metrics
- **Error Tracking**: Detailed error logging with stack traces

## 🔄 Atomic Transfer Flow

The core purchase verification uses Algorand's atomic transfers:

```
1. App Call → Attestation Oracle (verify merchant & limits)
2. App Call → Allowance Manager (check allowance status)
3. Payment → Execute transfer to merchant
```

All three transactions must succeed or all fail, ensuring atomicity.

## 🏗 Smart Contract Features

### Attestation Oracle
- **Box Storage**: Scalable merchant attestation storage
- **Daily Limits**: Automatic daily spending limit enforcement
- **Category Restrictions**: Parent-configurable category blocking
- **Real-time Verification**: Instant purchase approval/denial

### Allowance Manager
- **Parental Controls**: Parent-only allowance management
- **Timelock Savings**: Teen savings with time-based unlocking
- **Emergency Allowances**: Bypass weekly limits for emergencies
- **Pause/Resume**: Instant allowance control

## 🚀 Production Deployment

### Prerequisites
- Algorand Mainnet access
- Production-grade infrastructure
- SSL certificates
- Database setup (PostgreSQL + Redis)

### Deployment Steps
1. **Environment Setup**: Configure production environment variables
2. **Contract Deployment**: Deploy to Algorand Mainnet
3. **Database Migration**: Set up production databases
4. **SSL Configuration**: Configure HTTPS endpoints
5. **Monitoring Setup**: Deploy monitoring and alerting
6. **Load Testing**: Verify performance under load

## 📈 Performance Optimization

- **Connection Pooling**: Efficient database connections
- **Caching Layer**: Redis for frequently accessed data
- **Async Operations**: Non-blocking I/O for better throughput
- **Batch Processing**: Efficient bulk operations
- **Smart Contract Optimization**: Minimal opcode usage

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add tests for new functionality
4. Ensure all tests pass
5. Submit a pull request

## 📄 License

MIT License - See LICENSE file for details

## 🔗 Links

- [Algorand Developer Portal](https://developer.algorand.org/)
- [AlgoKit Documentation](https://developer.algorand.org/docs/get-started/algokit/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [ClearSpend iOS App](../ios-app/)

---

Built with 💜 for teen financial literacy on Algorand
