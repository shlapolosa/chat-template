#!/bin/bash

# Test script for Docker Compose deployment

echo "🧪 Testing Chat Template Deployment"
echo "=================================="

# Function to wait for service to be ready
wait_for_service() {
    local url=$1
    local service_name=$2
    local max_attempts=30
    local attempt=1
    
    echo -n "⏳ Waiting for $service_name to be ready"
    
    while [ $attempt -le $max_attempts ]; do
        if curl -s -f "$url" > /dev/null 2>&1; then
            echo " ✅"
            return 0
        fi
        echo -n "."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    echo " ❌"
    echo "❌ $service_name failed to start after $((max_attempts * 2)) seconds"
    return 1
}

# Test function
test_endpoint() {
    local url=$1
    local description=$2
    local expected_pattern=$3
    
    echo -n "🔍 Testing $description... "
    
    response=$(curl -s "$url" 2>/dev/null)
    exit_code=$?
    
    if [ $exit_code -eq 0 ]; then
        if [ -n "$expected_pattern" ] && echo "$response" | grep -q "$expected_pattern"; then
            echo "✅ ($response)"
        elif [ -z "$expected_pattern" ]; then
            echo "✅"
        else
            echo "⚠️  (unexpected response: $response)"
        fi
    else
        echo "❌ (connection failed)"
        return 1
    fi
}

# Test chat function
test_chat() {
    echo -n "💬 Testing chat conversation... "
    
    response=$(curl -s -X POST http://localhost:5005/webhooks/rest/webhook \
        -H "Content-Type: application/json" \
        -d '{"sender": "test-user", "message": "hello"}' 2>/dev/null)
    
    if [ $? -eq 0 ] && echo "$response" | grep -q "recipient_id"; then
        echo "✅"
        echo "   Response: $response"
    else
        echo "❌"
        echo "   Response: $response"
        return 1
    fi
}

# Main test sequence
echo "🚀 Starting Docker Compose services..."
docker-compose up -d --build

if [ $? -ne 0 ]; then
    echo "❌ Failed to start Docker Compose services"
    exit 1
fi

echo ""
echo "⏳ Waiting for services to initialize..."

# Wait for actions server
if wait_for_service "http://localhost:5055/health" "Actions Server"; then
    test_endpoint "http://localhost:5055/health" "Actions Server Health" "ok"
else
    echo "❌ Actions server startup failed"
    docker-compose logs actions
    exit 1
fi

# Wait for Rasa server (takes longer due to model loading)
if wait_for_service "http://localhost:5005/api/status" "Rasa Server"; then
    test_endpoint "http://localhost:5005/api/status" "Rasa Server Status" "ready"
else
    echo "❌ Rasa server startup failed"
    docker-compose logs rasa
    exit 1
fi

echo ""
echo "🧪 Running integration tests..."

# Test chat functionality
test_chat

echo ""
echo "📊 Service Summary:"
echo "   • Rasa Server: http://localhost:5005"
echo "   • Actions Server: http://localhost:5055"
echo "   • Chat API: http://localhost:5005/webhooks/rest/webhook"

echo ""
echo "🎉 All tests completed!"
echo ""
echo "💡 To interact with your chatbot:"
echo "   curl -X POST http://localhost:5005/webhooks/rest/webhook \\"
echo "     -H \"Content-Type: application/json\" \\"
echo "     -d '{\"sender\": \"user123\", \"message\": \"hello\"}'"
echo ""
echo "🛑 To stop services: docker-compose down"