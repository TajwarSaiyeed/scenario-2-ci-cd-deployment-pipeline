#!/bin/bash

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "========================================="
echo "Health Check for Demo Application"
echo "========================================="

MAX_RETRIES=30
RETRY_INTERVAL=2
HEALTH_ENDPOINT="http://localhost:3000/health"
CONTAINER_NAME="demo-app"

check_container() {
    if docker ps --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
        echo -e "${GREEN}✓${NC} Container '${CONTAINER_NAME}' is running"
        return 0
    else
        echo -e "${RED}✗${NC} Container '${CONTAINER_NAME}' is not running"
        return 1
    fi
}

check_health_endpoint() {
    local response=$(curl -s -o /dev/null -w "%{http_code}" ${HEALTH_ENDPOINT} 2>/dev/null)
    
    if [ "$response" = "200" ]; then
        return 0
    else
        return 1
    fi
}

echo ""
echo "Step 1: Checking if container is running..."
if ! check_container; then
    echo -e "${RED}FAILED: Container is not running${NC}"
    exit 1
fi

echo ""
echo "Step 2: Waiting for application to be ready..."
COUNTER=0
while [ $COUNTER -lt $MAX_RETRIES ]; do
    if check_health_endpoint; then
        echo -e "${GREEN}✓${NC} Health endpoint responded successfully"
        break
    fi
    
    COUNTER=$((COUNTER + 1))
    if [ $COUNTER -lt $MAX_RETRIES ]; then
        echo -e "${YELLOW}⟳${NC} Attempt $COUNTER/$MAX_RETRIES - Waiting ${RETRY_INTERVAL}s..."
        sleep $RETRY_INTERVAL
    fi
done

if [ $COUNTER -eq $MAX_RETRIES ]; then
    echo -e "${RED}✗${NC} Health check failed after $MAX_RETRIES attempts"
    echo ""
    echo "Container logs:"
    docker logs --tail 20 ${CONTAINER_NAME}
    exit 1
fi

echo ""
echo "Step 3: Fetching health status details..."
HEALTH_RESPONSE=$(curl -s ${HEALTH_ENDPOINT})
echo -e "${GREEN}Health Status Response:${NC}"
echo "$HEALTH_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$HEALTH_RESPONSE"

echo ""
echo "Step 4: Testing main endpoint..."
MAIN_RESPONSE=$(curl -s http://localhost:3000/)
echo -e "${GREEN}Main Endpoint Response:${NC}"
echo "$MAIN_RESPONSE" | python3 -m json.tool 2>/dev/null || echo "$MAIN_RESPONSE"

echo ""
echo "========================================="
echo -e "${GREEN}✓ ALL HEALTH CHECKS PASSED${NC}"
echo "========================================="
echo ""
echo "Application is healthy and ready to serve requests!"
echo "Access the app at: http://localhost:3000"
echo ""

exit 0
