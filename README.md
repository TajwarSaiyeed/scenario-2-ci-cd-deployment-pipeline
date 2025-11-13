# CI/CD Pipeline with Jenkins and Docker

Complete CI/CD pipeline for a Node.js Express application with automated build, test, package, deploy, and health check stages.

## Project Structure

```
├── app/
│   ├── server.js
│   ├── server.test.js
│   ├── package.json
│   └── jest.config.js
├── Jenkinsfile
├── Dockerfile
├── docker-compose.yml
├── docker-compose.jenkins.yml
├── Dockerfile.jenkins
├── setup-jenkins.sh
└── healthcheck.sh
```

## Quick Start

### Run Application

```bash
docker-compose up -d
curl http://localhost:3000/health
```

### Run with Jenkins

```bash
chmod +x setup-jenkins.sh
./setup-jenkins.sh
```

Open http://localhost:8080 and create a Pipeline job using the Jenkinsfile.

## Pipeline Stages

1. **Checkout** - Get source code
2. **Build** - Install dependencies
3. **Test** - Run unit tests
4. **Package** - Build Docker image
5. **Deploy** - Deploy with docker-compose
6. **Health Check** - Verify /health endpoint

## API Endpoints

- `GET /` - Welcome message
- `GET /health` - Health status
- `GET /api/hello?name=X` - Personalized greeting

## Technologies

- Node.js 18 + Express.js
- Jest + Supertest
- Docker + Docker Compose
- Jenkins
