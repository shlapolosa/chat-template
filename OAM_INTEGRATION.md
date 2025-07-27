# OAM Integration for Rasa Chatbot

This template includes Open Application Model (OAM) integration for deploying Rasa chatbots in Kubernetes environments with KubeVela.

## Overview

The `rasa-chatbot` ComponentDefinition provides:

- **Architecture**: Separate Knative services (microservices)
- **Containers**: Independent Rasa server + Actions server 
- **Scaling**: Independent auto-scaling per service
- **Auto-scaling**: Scale-to-zero, target-based scaling
- **Istio Gateway**: Advanced routing and traffic management
- **External Exposure**: Configurable via parameters
- **Use case**: Production workloads, cost optimization, high availability

## Architecture Overview

```
Rasa Chatbot (rasa-chatbot):
┌─────────────────┐    ┌─────────────────┐
│  Rasa Service   │    │ Actions Service │
│ ┌─────────────┐ │    │ ┌─────────────┐ │
│ │ Rasa Server │ │    │ │   Actions   │ │
│ │   :5005     │ │    │ │   :5055     │ │
│ └─────────────┘ │    │ └─────────────┘ │
└─────────────────┘    └─────────────────┘
        │                       │
   Auto-scaling             Auto-scaling
   Scale-to-zero           Scale-to-zero
        │                       │
  ┌─────────────────────────────────┐
  │        Istio Gateway            │
  │     Advanced Routing            │
  └─────────────────────────────────┘
```

## Quick Start

```bash
# Install ComponentDefinition
kubectl apply -f oam/rasa-chatbot-componentdef.yaml

# Deploy sample chatbot applications
kubectl apply -f oam/sample-applications.yaml

# Deploy with environment-based configuration
kubectl apply -f oam/environment-config.yaml
```

## ComponentDefinition Parameters

### Required Parameters
- `rasaImage`: Container image for Rasa server (e.g., `socrates12345/chat-template-rasa:latest`)
- `actionsImage`: Container image for actions server (e.g., `socrates12345/chat-template-actions:latest`)

### Optional Parameters

#### Resource Configuration
- `rasaMemory`: Memory request for Rasa server (default: `1Gi`)
- `rasaCpu`: CPU request for Rasa server (default: `500m`)
- `actionsMemory`: Memory request for actions server (default: `512Mi`)
- `actionsCpu`: CPU request for actions server (default: `250m`)
- `replicas`: Number of replicas (default: `1`)

#### Networking
- `enableIngress`: Enable ingress for external access (default: `false`)
- `ingressHost`: Hostname for ingress (optional)

#### Versions
- `rasaVersion`: Rasa version (default: `3.6.21`)
- `rasaSdkVersion`: Rasa SDK version (default: `3.6.2`)

## Usage Examples

### Basic Deployment
```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: my-chatbot
spec:
  components:
    - name: chatbot
      type: rasa-chatbot
      properties:
        replicas: 1
```

### Production Deployment with Ingress
```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: production-chatbot
spec:
  components:
    - name: chatbot
      type: rasa-chatbot
      properties:
        rasaImage: "myregistry/custom-rasa:v1.0.0"
        actionsImage: "myregistry/custom-actions:v1.0.0"
        replicas: 3
        rasaMemory: "2Gi"
        rasaCpu: "1000m"
        actionsMemory: "1Gi"
        actionsCpu: "500m"
        enableIngress: true
        ingressHost: "chatbot.mycompany.com"
      traits:
        - type: scaler
          properties:
            replicas: 3
```

### Development Environment
```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: dev-chatbot
spec:
  components:
    - name: chatbot
      type: rasa-chatbot
      properties:
        rasaMemory: "512Mi"
        rasaCpu: "250m"
        actionsMemory: "256Mi"
        actionsCpu: "100m"
        replicas: 1
```

## External Exposure Patterns

### Standard Kubernetes (`rasa-chatbot`)
**Generated Resources:**
1. **Deployment**: Both containers in single pod
2. **ClusterIP Services**: Internal communication only
3. **Ingress** (optional): External access to Rasa server only

**Exposure:**
- **Rasa**: `https://your-domain.com/` (via Ingress)
- **Actions**: Internal only (actions server not exposed externally)

### Knative Serverless (`rasa-chatbot-knative`)
**Generated Resources:**
1. **Knative Services**: Separate auto-scaling services
2. **Istio Gateway**: Advanced traffic management
3. **VirtualServices**: Path-based routing

**Exposure Options:**
- **Rasa Only** (default): `https://chat.example.com/api/*`
- **Both Services** (dev mode): 
  - Rasa: `https://dev-chat.example.com/api/*`
  - Actions: `https://dev-actions.example.com/webhook`

### URLs and Endpoints

#### Rasa Server (External)
- Chat API: `POST /webhooks/rest/webhook`
- Status: `GET /api/status`
- Model info: `GET /api/version`

#### Actions Server (Usually Internal)
- Webhook: `POST /webhook`
- Health: `GET /health`

**Internal Service Discovery:**
```bash
# Rasa server
curl http://chatbot-rasa.default.svc.cluster.local/api/status

# Actions server  
curl http://chatbot-actions.default.svc.cluster.local/health
```

## Service Discovery

- Rasa server: `{component-name}-rasa.{namespace}.svc.cluster.local:5005`
- Actions server: `{component-name}-actions.{namespace}.svc.cluster.local:5055`

## Health Checks

Both containers include:
- **Liveness probes**: Ensure containers restart if unhealthy
- **Readiness probes**: Ensure traffic only routes to ready containers

### Rasa Server
- Endpoint: `/api/status`
- Initial delay: 30 seconds
- Check interval: 10 seconds

### Actions Server
- Endpoint: `/health`
- Initial delay: 10 seconds
- Check interval: 10 seconds

## Integration with Existing Services

### Adding Chat to Multi-Component Applications

```yaml
apiVersion: core.oam.dev/v1beta1
kind: Application
metadata:
  name: full-stack-app
spec:
  components:
    - name: frontend
      type: webservice
      properties:
        image: "myapp/frontend:latest"
        port: 3000
    
    - name: backend-api
      type: webservice
      properties:
        image: "myapp/backend:latest"
        port: 8080
    
    - name: chatbot
      type: rasa-chatbot
      properties:
        enableIngress: false
        replicas: 1
        
    - name: database
      type: postgres
      properties:
        version: "13"
```

### Cross-Component Communication

The chatbot can communicate with other services in the same application:

```yaml
# In your Rasa endpoints.yml
action_endpoint:
  url: "http://chatbot-actions.default.svc.cluster.local:5055/webhook"

# Custom action can call backend API
backend_api_url: "http://backend-api.default.svc.cluster.local:8080"
```

## Customization

### Custom Container Images

Build your own images using this template as a base:

```dockerfile
FROM socrates12345/health-service-chat-template-rasa:latest
COPY ./custom-model /app/models/
COPY ./custom-config.yml /app/config.yml
```

### Environment-Specific Configuration

Use KubeVela environments for different deployments:

```bash
# Development
vela env init dev --namespace dev-chatbots

# Production  
vela env init prod --namespace prod-chatbots
```

## Monitoring and Observability

The component integrates with standard Kubernetes monitoring:

- **Metrics**: Prometheus metrics via Rasa's built-in endpoints
- **Logs**: Container logs available via `kubectl logs`
- **Traces**: Configure tracing in Rasa configuration

## Troubleshooting

### Common Issues

1. **Container startup failures**
   - Check resource requests vs. cluster capacity
   - Verify image availability and credentials

2. **Health check failures**
   - Ensure model is trained and available
   - Check container logs for startup errors

3. **Service communication issues**
   - Verify service names and ports
   - Check network policies and DNS resolution

### Debug Commands

```bash
# Check component status
kubectl get applications

# Check pods
kubectl get pods -l app.oam.dev/component=chatbot

# Check services
kubectl get svc -l app.oam.dev/component=chatbot

# Check logs
kubectl logs -l app.oam.dev/component=chatbot -c rasa-server
kubectl logs -l app.oam.dev/component=chatbot -c actions-server
```

## Next Steps

1. Customize the Rasa model and actions for your use case
2. Build and push custom container images
3. Deploy using OAM Application manifests
4. Integrate with your existing service mesh and monitoring
5. Set up CI/CD pipelines for automated deployments