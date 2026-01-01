# Docker Commands Reference

## Analysis Summary

### Angular Version
- **Version**: Angular 20.3.0
- **Build Output Path**: `dist/docker-learn-app/browser`
- **Builder**: `@angular/build:application` (Angular 17+ new application builder)

## Docker Image Tagging Strategy

### Recommended Tags:
```bash
# Latest development version
docker build -t docker-learn-app:latest .

# Version tag
docker build -t docker-learn-app:v1 .

# Production tag
docker build -t docker-learn-app:prod .

# Build with multiple tags at once
docker build -t docker-learn-app:latest -t docker-learn-app:v1 -t docker-learn-app:prod .
```

## Docker Commands

### 1. Build the Docker Image

```bash
# Build with default tag (latest)
docker build -t docker-learn-app:latest .

# Build with specific tag
docker build -t docker-learn-app:v1 .

# Build with production tag
docker build -t docker-learn-app:prod .

# Build with all tags
docker build -t docker-learn-app:latest -t docker-learn-app:v1 -t docker-learn-app:prod .
```

### 2. Push to Docker Hub (Docker Repository)

#### Prerequisites
1. Create a Docker Hub account at [hub.docker.com](https://hub.docker.com)
2. Create a repository on Docker Hub (or use your username as the repository name)

#### Step-by-Step Push Process

```bash
# Step 1: Login to Docker Hub
docker login
# Enter your Docker Hub username and password when prompted

# Step 2: Tag your image with Docker Hub format
# Format: docker tag <local-image> <dockerhub-username>/<repository-name>:<tag>
# Example (replace 'yourusername' with your Docker Hub username):
docker tag docker-learn-app:latest yourusername/docker-learn-app:latest
docker tag docker-learn-app:latest yourusername/docker-learn-app:v1
docker tag docker-learn-app:latest yourusername/docker-learn-app:prod

# Step 3: Push the image to Docker Hub
docker push yourusername/docker-learn-app:latest
docker push yourusername/docker-learn-app:v1
docker push yourusername/docker-learn-app:prod

# Or push all tags at once
docker push yourusername/docker-learn-app --all-tags
```

#### Build and Push in One Command

```bash
# Build directly with Docker Hub tag
docker build -t yourusername/docker-learn-app:latest .

# Push immediately after build
docker push yourusername/docker-learn-app:latest
```

#### Complete Example Workflow

```bash
# 1. Login to Docker Hub
docker login

# 2. Build with Docker Hub tag
docker build -t yourusername/docker-learn-app:latest \
             -t yourusername/docker-learn-app:v1 \
             -t yourusername/docker-learn-app:prod .

# 3. Push all tags
docker push yourusername/docker-learn-app:latest
docker push yourusername/docker-learn-app:v1
docker push yourusername/docker-learn-app:prod

# 4. Verify on Docker Hub
# Visit: https://hub.docker.com/r/yourusername/docker-learn-app
```

#### Pull and Run from Docker Hub

```bash
# Pull the image
docker pull yourusername/docker-learn-app:latest

# Run the pulled image
docker run -d -p 8080:80 --name angular-app yourusername/docker-learn-app:latest
```

#### Alternative: Build and Push with Different Registry

```bash
# For other registries (e.g., GitHub Container Registry, AWS ECR, etc.)
# Tag with full registry URL
docker tag docker-learn-app:latest ghcr.io/yourusername/docker-learn-app:latest
docker push ghcr.io/yourusername/docker-learn-app:latest

# For AWS ECR
docker tag docker-learn-app:latest <account-id>.dkr.ecr.<region>.amazonaws.com/docker-learn-app:latest
docker push <account-id>.dkr.ecr.<region>.amazonaws.com/docker-learn-app:latest
```

### 3. Run the Angular Container Locally

```bash
# Run on port 8080
docker run -d -p 8080:80 --name angular-app docker-learn-app:latest

# Run on default port 80 (requires sudo on Linux)
docker run -d -p 80:80 --name angular-app docker-learn-app:latest

# Run with custom name and port
docker run -d -p 3000:80 --name my-angular-app docker-learn-app:prod
```

**Access the app**: Open `http://localhost:8080` (or your chosen port) in your browser.

**Note**: If you get a "container name already in use" error, see the Troubleshooting section below.

### 4. Start a Separate Nginx Container

```bash
# Start a standalone nginx container
docker run -d -p 8081:80 --name nginx-server nginx:alpine

# Start nginx with custom config (if you have one)
docker run -d -p 8081:80 --name nginx-server \
  -v /path/to/your/nginx.conf:/etc/nginx/conf.d/default.conf \
  nginx:alpine
```

### 5. Access/Ping Nginx Container from Angular Container

```bash
# Method 1: Using Docker network (Recommended)
# Create a custom network
docker network create app-network

# Run Angular app on the network
docker run -d -p 8080:80 --name angular-app --network app-network docker-learn-app:latest

# Run nginx on the same network
docker run -d -p 8081:80 --name nginx-server --network app-network nginx:alpine

# Execute ping from inside Angular container
docker exec angular-app ping -c 4 nginx-server

# Method 2: Using container name (if on default bridge network)
# First, find nginx container IP
docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' nginx-server

# Then ping from Angular container (replace <nginx-ip> with actual IP)
docker exec angular-app ping -c 4 <nginx-ip>

# Method 3: Using wget/curl to test HTTP connectivity
docker exec angular-app wget -O- http://nginx-server:80
# OR
docker exec angular-app curl http://nginx-server:80
```

### 6. Useful Management Commands

```bash
# View running containers
docker ps

# View all containers (including stopped)
docker ps -a

# Stop container
docker stop angular-app

# Start stopped container
docker start angular-app

# Remove container
docker rm angular-app

# Remove image
docker rmi docker-learn-app:latest

# View container logs
docker logs angular-app

# Follow container logs
docker logs -f angular-app

# Execute shell in container
docker exec -it angular-app sh

# View container resource usage
docker stats angular-app

# Clean up unused resources
docker system prune -a
```

### 7. Network Testing Commands

```bash
# List Docker networks
docker network ls

# Inspect network
docker network inspect app-network

# Remove network
docker network rm app-network

# Test connectivity between containers
docker exec angular-app ping nginx-server
docker exec angular-app wget -O- http://nginx-server:80
docker exec angular-app curl -I http://nginx-server:80
```

## Validation Checklist

✅ **Dockerfile Validation**:
- ✅ Multi-stage build with `FROM node:20-alpine AS builder`
- ✅ Correct `COPY --from=builder` path: `/app/dist/docker-learn-app/browser`
- ✅ Base images are valid (`node:20-alpine`, `nginx:alpine`)
- ✅ All stages properly defined
- ✅ Production build configuration used
- ✅ Minimal final image size (nginx:alpine ~23MB)

✅ **nginx.conf Validation**:
- ✅ Supports Angular routing with `try_files $uri $uri/ /index.html`
- ✅ Uses port 80
- ✅ Placed in `/etc/nginx/conf.d/default.conf`
- ✅ Includes performance optimizations (gzip, caching)
- ✅ Security headers included

## Image Size Optimization

The multi-stage build ensures:
- **Builder stage**: ~500MB+ (includes Node.js and dependencies)
- **Final stage**: ~50-60MB (only nginx:alpine + Angular build artifacts)
- **Size reduction**: ~90% smaller than single-stage build

## Troubleshooting

### Container Name Already in Use

**Error**: `Error response from daemon: Conflict. The container name "/angular-app" is already in use`

**Solution**: Remove the existing container first, then run again.

```bash
# Option 1: Remove the existing container (if stopped)
docker rm angular-app

# Option 2: Force remove (even if running)
docker rm -f angular-app

# Option 3: Use a different container name
docker run -d -p 8080:80 --name angular-app-v2 docker-learn-app:latest

# Option 4: Check and remove all stopped containers
docker ps -a
docker container prune -f
```

### Port Already in Use

**Error**: `Error: bind: address already in use` or `port is already allocated`

**Solution**: Use a different port or stop the container using that port.

```bash
# Find which container is using the port
docker ps

# Stop the container using the port
docker stop <container-id-or-name>

# Or use a different port
docker run -d -p 8081:80 --name angular-app docker-learn-app:latest
```

### Network Already Exists

**Error**: `Error response from daemon: network with name app-network already exists`

**Solution**: Remove the existing network or use a different name.

```bash
# Remove existing network
docker network rm app-network

# Or use a different network name
docker network create my-app-network
```

### Quick Cleanup Commands

```bash
# Stop all running containers
docker stop $(docker ps -q)

# Remove all stopped containers
docker container prune -f

# Remove all unused networks
docker network prune -f

# Remove all unused images
docker image prune -a -f

# Complete cleanup (removes everything unused)
docker system prune -a --volumes
```

