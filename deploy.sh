#!/bin/bash
set -e

APP_NAME="loginapp"
DOCKER_USER="qou3kor"

# Check if version is passed as argument
if [ -z "$1" ]; then
    echo "❌ Please provide version as argument, e.g., ./deploy.sh v1.0.1"
    exit 1
fi

VERSION=$1
echo "Deploying version: $VERSION"

echo "=== Pulling latest code ==="
git pull origin main

echo "=== Building Docker image ==="
docker build -t $APP_NAME .

echo "=== Tagging Docker image ==="
docker tag $APP_NAME $DOCKER_USER/$APP_NAME:$VERSION

echo "=== Logging into Docker Hub ==="
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "=== Pushing Docker image ==="
docker push $DOCKER_USER/$APP_NAME:$VERSION

echo "=== Stopping old container if running ==="
docker stop flask_container || true
docker rm flask_container || true

echo "=== Running new container ==="
docker run -d --restart unless-stopped -p 5002:5000 --name flask_container $DOCKER_USER/$APP_NAME:$VERSION

echo "✅ Deployment complete with version $VERSION"
