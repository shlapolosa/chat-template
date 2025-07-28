# Chat Template

A minimal GitHub template repository for creating Rasa chatbot services with Docker support, Kubernetes/OAM deployment, and CI/CD integration.

## 🚀 Quick Start

### 1. Use This Template
Click "Use this template" to create a new repository.

### 2. Choose Your Deployment Method

## 🐳 Docker Compose (Recommended for Development)

### Prerequisites
- Docker and Docker Compose installed
- Git

### Steps
```bash
# Clone your repository
git clone https://github.com/your-org/your-chat-service.git
cd your-chat-service

# Start the chatbot (builds containers automatically)
docker-compose up --build

# The services will start:
# - Rasa server: http://localhost:5005
# - Actions server: http://localhost:5055 (internal)
```

### Test Your Chatbot
```bash
# Health check
curl http://localhost:5005/api/status

# Send a message to your bot
curl -X POST http://localhost:5005/webhooks/rest/webhook \
  -H "Content-Type: application/json" \
  -d '{"sender": "user123", "message": "hello"}'

# Expected response:
# [{"recipient_id":"user123","text":"Hello! How can I help you?"}]
```

### Stop the Services
```bash
docker-compose down
```

## ☸️ Kubernetes/OAM Deployment (Production)

### Prerequisites
- Kubernetes cluster with KubeVela installed
- kubectl configured
- Container images built and pushed (see CI/CD section)

### Steps

#### 1. Install the ComponentDefinition
```bash
kubectl apply -f oam/chat-template-componentdef.yaml
```

#### 2. Deploy Your Chatbot
```bash
# Basic internal deployment
kubectl apply -f oam/sample-applications.yaml

# Or with custom configuration
kubectl apply -f oam/environment-config.yaml
```

#### 3. Access Your Chatbot

**Internal Access (within cluster):**
```bash
# Forward port for testing
kubectl port-forward svc/chatbot-rasa 5005:80

# Test the API
curl -X POST http://localhost:5005/webhooks/rest/webhook \
  -H "Content-Type: application/json" \
  -d '{"sender": "user123", "message": "hello"}'
```

**External Access (with Istio Gateway):**
```yaml
# In your Application manifest
spec:
  components:
    - name: chatbot
      type: rasa-chatbot
      properties:
        rasaImage: "socrates12345/chat-template-rasa:latest"
        actionsImage: "socrates12345/chat-template-actions:latest"
        enableIstioGateway: true
        chatbotHost: "chat.yourdomain.com"
        enableTLS: true
```

Then access via: `https://chat.yourdomain.com/webhooks/rest/webhook`

## 🛠️ Local Development (Native)

For development without Docker:

```bash
# Install dependencies
pip install -r requirements.txt

# Train the model
rasa train

# Terminal 1: Start actions server
rasa run actions --port 5055

# Terminal 2: Start Rasa server
rasa run --enable-api --cors "*" --port 5005 --endpoints endpoints.local.yml

# Terminal 3: Test
curl -X POST http://localhost:5005/webhooks/rest/webhook \
  -H "Content-Type: application/json" \
  -d '{"sender": "test", "message": "hello"}'
```

## 🔧 Configuration & Customization

### Environment Configuration

**Docker Compose (automatic):**
- Rasa automatically connects to actions server via `http://actions:5055/webhook`

**Kubernetes (automatic):**
- Rasa automatically connects to actions server via service discovery
- Environment variables injected: `ACTION_ENDPOINT_URL`, `ACTIONS_SERVER_HOST`, `ACTIONS_SERVER_PORT`

### Custom Environment Variables
```yaml
# In OAM Application
properties:
  environment:
    LOG_LEVEL: "DEBUG"
    CUSTOM_SETTING: "value"
```

### Database Integration
Update your OAM Application or docker-compose.yml:
```yaml
environment:
  DATABASE_URL: "postgresql://user:pass@host:5432/rasa"
```

## 📁 Project Structure

```
chat-template/
├── README.md                          # This file
├── .github/workflows/                 # CI/CD automation
├── oam/                               # Kubernetes OAM definitions
│   ├── chat-template-componentdef.yaml # Main ComponentDefinition
│   ├── sample-applications.yaml      # Example deployments
│   └── environment-config.yaml       # ConfigMap examples
├── scripts/                           # Utility scripts
│   └── generate-endpoints.sh         # Dynamic endpoint configuration
├── config.yml                         # Rasa NLU/Core configuration
├── domain.yml                         # Bot responses and slots
├── credentials.yml                    # Channel configurations
├── endpoints.yml                      # Service endpoints (Docker)
├── endpoints.local.yml               # Local development endpoints
├── data/                              # Training data
│   ├── nlu.yml                        # User message examples
│   ├── rules.yml                      # Conversation rules
│   └── stories.yml                    # Conversation flows
├── actions/                           # Custom Python actions
│   ├── __init__.py
│   ├── actions.py                     # Custom action implementations
│   └── requirements.txt               # Actions server dependencies
├── tests/                             # Test files
├── docker/                            # Docker configurations
│   ├── Dockerfile.rasa               # Rasa server container
│   └── Dockerfile.actions            # Actions server container
├── requirements.txt                   # Python dependencies
├── docker-compose.yml                # Local development setup
└── devbox.json                       # Devbox development environment
```

## 🧪 Testing & Validation

### Validate Your Configuration
```bash
# Validate training data
rasa data validate

# Run tests
rasa test

# Check endpoints configuration
docker-compose config
```

### Integration Testing
```bash
# Test Docker Compose setup
./test-deployment.sh

# Test Kubernetes deployment
kubectl get pods -l app.kubernetes.io/name=chatbot
kubectl logs -l app.kubernetes.io/component=rasa-server
```

## 📦 CI/CD & Container Registry

### GitHub Secrets Required
Set these in your repository settings:
```
DOCKER_TOKEN=your_docker_hub_access_token
```

### Automatic Builds
The GitHub Actions workflow automatically:
1. Builds containers on push to main
2. Pushes to `socrates12345/chat-template-rasa:latest` and `socrates12345/chat-template-actions:latest`
3. Runs integration tests

### Custom Registry
To use your own Docker registry, update:
1. `.github/workflows/docker-build.yml` - Change image names
2. `oam/sample-applications.yaml` - Update `rasaImage` and `actionsImage`

## 🔒 Production Considerations

### Security
```yaml
# Use secrets for sensitive data
apiVersion: v1
kind: Secret
metadata:
  name: chatbot-secrets
data:
  DATABASE_PASSWORD: base64-encoded-password
```

### Scaling
```yaml
# In your OAM Application
properties:
  minScale: 2              # Always-on instances
  maxScale: 20            # Maximum scale
  targetConcurrency: 10   # Requests per instance
```

### Monitoring
```yaml
# Health check endpoints available:
# Rasa: GET /api/status
# Actions: GET /health
```

## 🐛 Troubleshooting

### Common Issues

**Actions server not reachable:**
```bash
# Check service discovery
kubectl get svc
kubectl describe svc chatbot-actions

# Check environment variables
kubectl exec deployment/chatbot-rasa -- env | grep ACTION
```

**Container startup failures:**
```bash
# Check logs
docker-compose logs rasa
docker-compose logs actions

# Or in Kubernetes
kubectl logs -l app.kubernetes.io/component=rasa-server
kubectl logs -l app.kubernetes.io/component=actions-server
```

**Port conflicts:**
```bash
# Change ports in docker-compose.yml
ports:
  - "5006:5005"  # Use port 5006 locally
```

### Getting Help

1. Check logs first: `docker-compose logs` or `kubectl logs`
2. Verify endpoints: `curl http://localhost:5005/api/status`
3. Test actions server: `curl http://localhost:5055/health`
4. Validate configuration: `rasa data validate`

## 🤝 Contributing

1. Fork the template
2. Make your changes
3. Test with Docker Compose: `docker-compose up --build`
4. Test OAM deployment: `kubectl apply -f oam/sample-applications.yaml`
5. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.