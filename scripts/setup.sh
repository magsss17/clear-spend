#!/bin/bash

# ClearSpend Project Setup Script
# This script sets up the development environment for ClearSpend

set -e

echo "🚀 ClearSpend Project Setup"
echo "=========================="

# Check if Python 3.11+ is installed
check_python() {
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
        echo "✓ Python $PYTHON_VERSION found"
        
        # Check if version is 3.11 or higher
        if python3 -c 'import sys; exit(0 if sys.version_info >= (3, 11) else 1)'; then
            echo "✓ Python version is compatible"
        else
            echo "❌ Python 3.11+ is required. Current version: $PYTHON_VERSION"
            exit 1
        fi
    else
        echo "❌ Python 3 not found. Please install Python 3.11+"
        exit 1
    fi
}

# Check if pip is installed
check_pip() {
    if command -v pip &> /dev/null; then
        echo "✓ pip found"
    else
        echo "❌ pip not found. Please install pip"
        exit 1
    fi
}

# Check if AlgoKit is installed
check_algokit() {
    if command -v algokit &> /dev/null; then
        echo "✓ AlgoKit found"
    else
        echo "⚠️  AlgoKit not found. Installing..."
        if command -v pipx &> /dev/null; then
            pipx install algokit
            echo "✓ AlgoKit installed"
        else
            echo "❌ pipx not found. Please install pipx first:"
            echo "   python -m pip install --user pipx"
            echo "   python -m pipx ensurepath"
            exit 1
        fi
    fi
}

# Install Python dependencies
install_dependencies() {
    echo "📦 Installing Python dependencies..."
    pip install -r requirements.txt
    echo "✓ Dependencies installed"
}

# Setup environment file
setup_env() {
    if [ ! -f "docs/config.env" ]; then
        echo "📝 Creating environment configuration..."
        cp docs/config.env.example docs/config.env
        echo "✓ Created docs/config.env from template"
        echo "⚠️  Please edit docs/config.env with your Algorand credentials"
    else
        echo "✓ Environment file already exists"
    fi
}

# Create necessary directories
create_directories() {
    echo "📁 Creating project directories..."
    mkdir -p logs
    mkdir -p backend/logs
    echo "✓ Directories created"
}

# Main setup function
main() {
    echo "Checking system requirements..."
    check_python
    check_pip
    check_algokit
    
    echo ""
    echo "Setting up project..."
    install_dependencies
    setup_env
    create_directories
    
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Edit docs/config.env with your Algorand credentials"
    echo "2. Run 'make deploy' to deploy smart contracts"
    echo "3. Run 'make backend' to start the API server"
    echo "4. Open ios-app/ClearSpendApp.xcodeproj in Xcode to build the iOS app"
    echo ""
    echo "For more commands, run 'make help'"
}

# Run main function
main "$@"
