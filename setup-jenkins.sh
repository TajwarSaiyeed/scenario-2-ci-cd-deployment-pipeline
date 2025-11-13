#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}=========================================${NC}"
echo -e "${BLUE}   Jenkins Docker Setup Script${NC}"
echo -e "${BLUE}=========================================${NC}"
echo ""

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo -e "${YELLOW}Docker is not installed. Please install Docker first.${NC}"
    exit 1
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo -e "${YELLOW}Docker Compose is not installed. Please install Docker Compose first.${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Docker and Docker Compose are installed"
echo ""

# Stop and remove existing Jenkins container if it exists
echo "Checking for existing Jenkins container..."
if docker ps -a --format '{{.Names}}' | grep -q "^jenkins-cicd$"; then
    echo "Stopping and removing existing Jenkins container..."
    docker stop jenkins-cicd
    docker rm jenkins-cicd
fi

echo ""
echo -e "${BLUE}Starting Jenkins with Docker-in-Docker support...${NC}"
docker-compose -f docker-compose.jenkins.yml up -d

echo ""
echo "Waiting for Jenkins to start (this may take 30-60 seconds)..."
sleep 30

# Check if Jenkins is running
if docker ps --format '{{.Names}}' | grep -q "^jenkins-cicd$"; then
    echo -e "${GREEN}✓${NC} Jenkins is running!"
    echo ""
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Jenkins Information${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
    echo "Jenkins URL: http://localhost:8080"
    echo ""
    echo "Getting initial admin password..."
    sleep 5
    ADMIN_PASSWORD=$(docker exec jenkins-cicd cat /var/jenkins_home/secrets/initialAdminPassword 2>/dev/null)
    
    if [ ! -z "$ADMIN_PASSWORD" ]; then
        echo ""
        echo -e "${GREEN}Initial Admin Password:${NC}"
        echo -e "${YELLOW}${ADMIN_PASSWORD}${NC}"
        echo ""
    else
        echo ""
        echo "To get the admin password, run:"
        echo "docker exec jenkins-cicd cat /var/jenkins_home/secrets/initialAdminPassword"
        echo ""
    fi
    
    echo -e "${BLUE}=========================================${NC}"
    echo -e "${BLUE}   Next Steps${NC}"
    echo -e "${BLUE}=========================================${NC}"
    echo ""
    echo "1. Open http://localhost:8080 in your browser"
    echo "2. Enter the admin password shown above"
    echo "3. Install suggested plugins"
    echo "4. Create your first admin user"
    echo "5. Create a new Pipeline job:"
    echo "   - Click 'New Item'"
    echo "   - Enter a name (e.g., 'demo-app-pipeline')"
    echo "   - Select 'Pipeline' and click OK"
    echo "   - In Pipeline section, select 'Pipeline script from SCM'"
    echo "   - Choose 'Git' and enter your repository URL"
    echo "   - Or select 'Pipeline script' and paste the Jenkinsfile content"
    echo "   - Save and click 'Build Now'"
    echo ""
    echo -e "${GREEN}Setup complete!${NC}"
else
    echo -e "${YELLOW}Jenkins container failed to start. Check logs with:${NC}"
    echo "docker logs jenkins-cicd"
    exit 1
fi
