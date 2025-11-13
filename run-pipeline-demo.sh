#!/bin/bash

# Demo Script - Simulates the full CI/CD pipeline locally
# This script runs all the stages that Jenkins would execute

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Function to print stage header
print_stage() {
    echo ""
    echo -e "${BLUE}${BOLD}=========================================${NC}"
    echo -e "${BLUE}${BOLD}$1${NC}"
    echo -e "${BLUE}${BOLD}=========================================${NC}"
    echo ""
}

# Function to print success
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Function to print error
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to print info
print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Start timestamp
START_TIME=$(date +%s)

echo ""
echo -e "${CYAN}${BOLD}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}${BOLD}║                                                       ║${NC}"
echo -e "${CYAN}${BOLD}║         CI/CD PIPELINE EXECUTION DEMO                 ║${NC}"
echo -e "${CYAN}${BOLD}║         Demo App Build → Test → Deploy                ║${NC}"
echo -e "${CYAN}${BOLD}║                                                       ║${NC}"
echo -e "${CYAN}${BOLD}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${YELLOW}Started: $(date '+%Y-%m-%d %H:%M:%S')${NC}"
echo ""

# Check prerequisites
print_info "Checking prerequisites..."
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed"
    exit 1
fi
if ! command -v docker-compose &> /dev/null; then
    print_error "Docker Compose is not installed"
    exit 1
fi
if ! command -v node &> /dev/null; then
    print_error "Node.js is not installed"
    exit 1
fi
print_success "All prerequisites found"

# Stage 1: Checkout
print_stage "Stage 1: Checkout"
print_info "Verifying project structure..."
if [ -f "Jenkinsfile" ] && [ -f "Dockerfile" ] && [ -f "docker-compose.yml" ] && [ -d "app" ]; then
    print_success "Project structure verified"
    ls -la
else
    print_error "Missing project files"
    exit 1
fi

# Stage 2: Build
print_stage "Stage 2: Build"
print_info "Installing dependencies..."
cd app
npm install --silent
if [ $? -eq 0 ]; then
    print_success "Dependencies installed successfully"
else
    print_error "Failed to install dependencies"
    exit 1
fi
cd ..

# Stage 3: Test
print_stage "Stage 3: Test"
print_info "Running unit tests..."
cd app
npm test 2>&1
if [ $? -eq 0 ]; then
    print_success "All tests passed successfully"
else
    print_error "Tests failed"
    cd ..
    exit 1
fi
cd ..

# Stage 4: Package
print_stage "Stage 4: Package (Build Docker Image)"
print_info "Cleaning up existing containers..."
docker stop demo-app 2>/dev/null || true
docker rm demo-app 2>/dev/null || true

print_info "Building Docker image..."
docker build -t demo-app:latest . --quiet
if [ $? -eq 0 ]; then
    print_success "Docker image built successfully"
    docker images | grep demo-app | head -1
else
    print_error "Failed to build Docker image"
    exit 1
fi

# Stage 5: Deploy
print_stage "Stage 5: Deploy"
print_info "Deploying with Docker Compose..."
docker-compose down 2>/dev/null || true
docker-compose up -d
if [ $? -eq 0 ]; then
    print_success "Application deployed successfully"
    docker ps | grep demo-app
else
    print_error "Deployment failed"
    exit 1
fi

# Stage 6: Health Check
print_stage "Stage 6: Health Check"
chmod +x healthcheck.sh
./healthcheck.sh
if [ $? -eq 0 ]; then
    print_success "Health check passed - Application is healthy!"
else
    print_error "Health check failed"
    docker logs demo-app
    exit 1
fi

# Calculate execution time
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

# Final Summary
echo ""
echo -e "${GREEN}${BOLD}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}${BOLD}║                                                       ║${NC}"
echo -e "${GREEN}${BOLD}║         🎉 PIPELINE COMPLETED SUCCESSFULLY! 🎉        ║${NC}"
echo -e "${GREEN}${BOLD}║                                                       ║${NC}"
echo -e "${GREEN}${BOLD}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""
echo -e "${CYAN}${BOLD}Pipeline Summary:${NC}"
echo -e "${GREEN}  ✓ Stage 1: Checkout       - PASSED${NC}"
echo -e "${GREEN}  ✓ Stage 2: Build          - PASSED${NC}"
echo -e "${GREEN}  ✓ Stage 3: Test           - PASSED${NC}"
echo -e "${GREEN}  ✓ Stage 4: Package        - PASSED${NC}"
echo -e "${GREEN}  ✓ Stage 5: Deploy         - PASSED${NC}"
echo -e "${GREEN}  ✓ Stage 6: Health Check   - PASSED${NC}"
echo ""
echo -e "${CYAN}${BOLD}Execution Time:${NC} ${DURATION} seconds"
echo -e "${CYAN}${BOLD}Completed:${NC} $(date '+%Y-%m-%d %H:%M:%S')"
echo ""
echo -e "${CYAN}${BOLD}Application URLs:${NC}"
echo -e "  • Main:    ${YELLOW}http://localhost:3000${NC}"
echo -e "  • Health:  ${YELLOW}http://localhost:3000/health${NC}"
echo -e "  • API:     ${YELLOW}http://localhost:3000/api/hello${NC}"
echo ""
echo -e "${CYAN}${BOLD}Quick Commands:${NC}"
echo -e "  • View logs:    ${YELLOW}docker logs demo-app${NC}"
echo -e "  • Stop app:     ${YELLOW}docker-compose down${NC}"
echo -e "  • Test health:  ${YELLOW}curl http://localhost:3000/health${NC}"
echo ""
echo -e "${GREEN}${BOLD}✓ Application is live and healthy!${NC}"
echo ""
