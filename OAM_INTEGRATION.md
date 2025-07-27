# OAM Integration for Rasa Chatbot

This template includes Open Application Model (OAM) integration for deploying Rasa chatbots in Kubernetes environments with KubeVela.

## Overview

The `rasa-chatbot` ComponentDefinition provides a declarative way to deploy Rasa applications with:
- Rasa server container for NLU/dialogue processing
- Actions server container for custom actions
- Automatic service discovery and networking
- Optional ingress configuration
- Health checks and resource management

## Quick Start

### 1. Install ComponentDefinition

```bash
kubectl apply -f oam/rasa-chatbot-componentdef.yaml
```

### 2. Deploy a Simple Chatbot

```bash
kubectl apply -f oam/sample-application.yaml
```

## ComponentDefinition Parameters

### Required Parameters
- `rasaImage`: Container image for Rasa server (default: `socrates12345/health-service-chat-template-rasa:latest`)
- `actionsImage`: Container image for actions server (default: `socrates12345/health-service-chat-template-actions:latest`)

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

## Generated Resources

The ComponentDefinition creates:

1. **Deployment**: Contains both Rasa server and actions server containers
2. **Rasa Service**: ClusterIP service on port 5005 for the Rasa server
3. **Actions Service**: ClusterIP service on port 5055 for the actions server
4. **Ingress** (optional): External access to the Rasa server

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