# GitHub Secrets Setup

This template requires GitHub secrets for Docker Hub authentication and automated container builds.

## Required Secrets

### Docker Hub Authentication

1. **DOCKER_USERNAME** (Optional - defaults to repository owner)
   - Your Docker Hub username
   - If not set, uses GitHub repository owner (`shlapolosa`)

2. **DOCKER_PASSWORD** or **DOCKER_TOKEN** (Required)
   - Docker Hub password or access token
   - **Recommended**: Use access token for better security

## Setup Instructions

### 1. Create Docker Hub Access Token

1. Go to [Docker Hub Security Settings](https://hub.docker.com/settings/security)
2. Click "New Access Token"
3. Name: `github-actions-chat-template`
4. Permissions: `Read, Write, Delete`
5. Copy the generated token

### 2. Create Docker Hub Repositories

Create these repositories on Docker Hub:
- `shlapolosa/chat-template-rasa`
- `shlapolosa/chat-template-actions`

Or change the image names in the ComponentDefinitions to match your Docker Hub username.

### 3. Add GitHub Secrets

1. Go to your GitHub repository
2. Settings → Secrets and variables → Actions
3. Add repository secrets:

```
DOCKER_TOKEN = your_docker_hub_access_token
```

Optional (if different from repository owner):
```
DOCKER_USERNAME = your_docker_hub_username
```

### 4. Verify Setup

Push changes to trigger the workflow:

```bash
git add .
git commit -m "test: trigger Docker build"
git push origin main
```

Check the Actions tab to see if builds succeed.

## Image Naming Convention

The workflow builds:
- **Rasa Server**: `shlapolosa/chat-template-rasa:latest`
- **Actions Server**: `shlapolosa/chat-template-actions:latest`

Tags generated:
- `latest` (main branch)
- `main` (branch name)
- `main-{commit-sha}` (specific commit)

## Customizing Image Names

The ComponentDefinition requires explicit image names in Applications. Use environment variables or ConfigMaps for dynamic configuration:

1. **Environment Variables in Applications**:
   ```yaml
   # In your Application manifest
   properties:
     rasaImage: "${DOCKER_HUB_USERNAME:-socrates12345}/chat-template-rasa:${IMAGE_TAG:-latest}"
     actionsImage: "${DOCKER_HUB_USERNAME:-socrates12345}/chat-template-actions:${IMAGE_TAG:-latest}"
   ```

2. **ConfigMap-based Configuration**:
   ```bash
   kubectl create configmap chatbot-config \
     --from-literal=DOCKER_HUB_USERNAME=your_username \
     --from-literal=IMAGE_TAG=v1.0.0
   ```

3. **Update Applications**:
   ```yaml
   # See oam/environment-config.yaml for complete examples
   properties:
     rasaImage: "your_username/chat-template-rasa:v1.0.0"
     actionsImage: "your_username/chat-template-actions:v1.0.0"
   ```

## Troubleshooting

### "push access denied, repository does not exist"
- Ensure repositories exist on Docker Hub
- Check DOCKER_USERNAME matches repository owner
- Verify DOCKER_TOKEN has write permissions

### "authorization failed"
- Regenerate Docker Hub access token
- Update DOCKER_TOKEN secret in GitHub
- Ensure token hasn't expired

### "insufficient_scope"
- Token needs `Read, Write, Delete` permissions
- Don't use personal password, use access token

## Security Best Practices

1. **Use Access Tokens**: Never use Docker Hub password directly
2. **Limit Token Scope**: Only grant necessary permissions
3. **Rotate Tokens**: Regularly regenerate access tokens
4. **Repository-specific**: Use different tokens for different projects

## Local Development

For local testing without pushing to Docker Hub:

```bash
# Build images locally
docker build -f docker/Dockerfile.rasa -t local/rasa .
docker build -f docker/Dockerfile.actions -t local/actions .

# Test with docker-compose (update image names)
docker-compose up
```