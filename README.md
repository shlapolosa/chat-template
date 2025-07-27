# Chat Template

A minimal GitHub template repository for creating Rasa chatbot services with Docker support and CI/CD integration.

## 🚀 Quick Start

### 1. Use This Template
Click "Use this template" to create a new repository.

### 2. Local Development
```bash
# Clone your repository
git clone https://github.com/your-org/your-chat-service.git
cd your-chat-service

# Install dependencies
pip install -r requirements.txt

# Train the model
rasa train

# Run the Rasa server (use local endpoints)
rasa run --enable-api --cors "*" --port 5005 --endpoints endpoints.local.yml

# In another terminal, start the actions server
rasa run actions --port 5055
```

### 3. Docker Development
```bash
# Build and run with Docker Compose
docker-compose up --build

# Test the API
curl -X POST http://localhost:5005/webhooks/rest/webhook \
  -H "Content-Type: application/json" \
  -d '{"sender": "test", "message": "hello"}'
```

## 📁 Project Structure

```
chat-template/
├── README.md                          # This file
├── .github/workflows/                 # CI/CD automation
├── config.yml                         # Rasa configuration
├── domain.yml                         # Bot responses and slots
├── credentials.yml                    # Channel configurations  
├── endpoints.yml                      # External service endpoints
├── data/                              # Training data
│   ├── nlu.yml                        # User message examples
│   ├── rules.yml                      # Conversation rules
│   └── stories.yml                    # Conversation flows
├── actions/                           # Custom Python actions
├── tests/                             # Test files
├── docker/                            # Docker configurations
├── requirements.txt                   # Python dependencies
└── docker-compose.yml                # Local development setup
```

## 🐳 Docker Support

The template includes:
- `Dockerfile.rasa` - Rasa server container
- `Dockerfile.actions` - Custom actions server
- `docker-compose.yml` - Development environment

## 🔧 Configuration

### Minimal Setup
The template provides basic Rasa configuration:
- Simple NLU pipeline
- Basic dialogue policies  
- REST API enabled
- Health check endpoints

### Environment Variables
- `RASA_PORT` - Server port (default: 5005)
- `ACTION_PORT` - Actions port (default: 5055)

### Database Integration
For production, update `endpoints.yml`:
```yaml
tracker_store:
  type: SQL
  dialect: "postgresql"
  url: "your-database-url"
  db: "rasa"
```

## 🧪 Testing

```bash
# Test conversations
rasa test

# Validate data
rasa data validate
```

## 📦 GitHub Actions

Automatic workflows for:
- Container builds on push
- Pushing to container registry
- Optional deployment triggers

## 🤝 Contributing

1. Fork the template
2. Make your changes
3. Test thoroughly
4. Submit a pull request

## 📄 License

MIT License - see LICENSE file for details.