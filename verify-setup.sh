#!/bin/bash

# Quick test script to verify everything works before running full pipeline

echo "🔍 Quick Verification Test"
echo "=========================="
echo ""

# Test 1: Check files
echo "1. Checking project files..."
FILES=("Jenkinsfile" "Dockerfile" "docker-compose.yml" "healthcheck.sh" "app/server.js" "app/package.json")
for file in "${FILES[@]}"; do
    if [ -f "$file" ]; then
        echo "   ✓ $file exists"
    else
        echo "   ✗ $file missing"
        exit 1
    fi
done
echo ""

# Test 2: Check Docker
echo "2. Checking Docker..."
if command -v docker &> /dev/null; then
    echo "   ✓ Docker installed"
    if docker ps &> /dev/null; then
        echo "   ✓ Docker daemon running"
    else
        echo "   ✗ Docker daemon not running"
        exit 1
    fi
else
    echo "   ✗ Docker not installed"
    exit 1
fi
echo ""

# Test 3: Check Node.js
echo "3. Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "   ✓ Node.js installed ($NODE_VERSION)"
else
    echo "   ✗ Node.js not installed"
    exit 1
fi
echo ""

# Test 4: Install and test app locally
echo "4. Testing application locally..."
cd app
npm install --silent > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ Dependencies installed"
else
    echo "   ✗ Failed to install dependencies"
    cd ..
    exit 1
fi

npm test -- --silent > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo "   ✓ Tests passed"
else
    echo "   ✗ Tests failed"
    cd ..
    exit 1
fi
cd ..
echo ""

# Summary
echo "✅ All checks passed!"
echo ""
echo "You can now run:"
echo "  • ./run-pipeline-demo.sh    - Run full pipeline demo"
echo "  • ./setup-jenkins.sh        - Setup Jenkins in Docker"
echo "  • docker-compose up -d      - Just run the app"
echo ""
