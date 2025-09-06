# ClearSpend Project Makefile

.PHONY: help install backend ios test clean deploy docker

# Default target
help:
	@echo "ClearSpend - Teen Financial Literacy on Algorand"
	@echo ""
	@echo "Available targets:"
	@echo "  install     - Install all dependencies"
	@echo "  backend     - Start backend API server"
	@echo "  ios         - Build iOS app (requires Xcode)"
	@echo "  test        - Run all tests"
	@echo "  deploy      - Deploy smart contracts"
	@echo "  docker      - Run with Docker Compose"
	@echo "  clean       - Clean up temporary files"
	@echo "  help        - Show this help message"

# Install dependencies
install:
	@echo "Installing Python dependencies..."
	pip install -r requirements.txt
	@echo "Installing AlgoKit..."
	pipx install algokit
	@echo "Dependencies installed successfully!"

# Start backend server
backend:
	@echo "Starting ClearSpend Backend API..."
	python scripts/start_backend.py

# Build iOS app (requires Xcode)
ios:
	@echo "Building iOS app..."
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd ios-app && xcodebuild -project ClearSpendApp.xcodeproj -scheme ClearSpendApp -destination 'platform=iOS Simulator,name=iPhone 15' build; \
	else \
		echo "Xcode not found. Please install Xcode to build the iOS app."; \
	fi

# Run tests
test:
	@echo "Running backend tests..."
	cd backend && python -m pytest tests/ -v
	@echo "Running iOS tests..."
	@if command -v xcodebuild >/dev/null 2>&1; then \
		cd ios-app && xcodebuild test -project ClearSpendApp.xcodeproj -scheme ClearSpendApp -destination 'platform=iOS Simulator,name=iPhone 15'; \
	else \
		echo "Xcode not found. Skipping iOS tests."; \
	fi

# Deploy smart contracts
deploy:
	@echo "Deploying smart contracts..."
	cd backend && python deployment/deploy.py

# Run with Docker
docker:
	@echo "Starting ClearSpend with Docker Compose..."
	cd backend/deployment && docker-compose up -d

# Clean up temporary files
clean:
	@echo "Cleaning up temporary files..."
	find . -type f -name "*.pyc" -delete
	find . -type d -name "__pycache__" -delete
	find . -type f -name "*.log" -delete
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	@echo "Cleanup complete!"

# Development setup
dev-setup: install
	@echo "Setting up development environment..."
	@if [ ! -f docs/config.env ]; then \
		cp docs/config.env.example docs/config.env; \
		echo "Created config.env from template. Please edit with your credentials."; \
	fi
	@echo "Development setup complete!"

# Full project build
build: install deploy
	@echo "Full project build complete!"

# Production deployment
prod-deploy: clean install deploy docker
	@echo "Production deployment complete!"
