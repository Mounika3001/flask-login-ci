#!/bin/bash
set -e  # Exit immediately if any command fails

APP_NAME="loginapp"
DOCKER_USER="qou3kor"

# Check if version is passed as argument
if [ -z "$1" ]; then
    echo "❌ Please provide version as argument, e.g., ./deploy.sh v1.0.1"
    exit 1
fi

VERSION=$1
echo "🚀 Deploying version: $VERSION"

echo "=== Pulling latest code from GitHub ==="
git pull origin main

echo "=== Building Docker image ==="
docker build -t $APP_NAME .

echo "=== Tagging Docker image ==="
docker tag $APP_NAME $DOCKER_USER/$APP_NAME:$VERSION

echo "=== Logging into Docker Hub ==="
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "=== Pushing Docker image to Docker Hub ==="
docker push $DOCKER_USER/$APP_NAME:$VERSION

echo "=== Stopping old container if it exists ==="
docker stop flask_container || true
docker rm flask_container || true

echo "=== Running new container on port 5002 ==="
docker run -d --restart unless-stopped -p 5002:5000 --name flask_container $DOCKER_USER/$APP_NAME:$VERSION

echo "✅ Deployment complete — loginapp is running on http://localhost:5002"

