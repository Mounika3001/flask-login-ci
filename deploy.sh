#!/bin/bash
set -e  # Exit on error

APP_NAME="loginapp"
DOCKER_USER="qou3kor"

# Read version from VERSION file
if [ ! -f VERSION ]; then
  echo "❌ VERSION file not found!"
  exit 1
fi

VERSION=$(cat VERSION)
echo "🚀 Deploying version: $VERSION"

echo "=== Building Docker image ==="
docker build --no-cache -t $APP_NAME .

echo "=== Tagging Docker image ==="
docker tag $APP_NAME $DOCKER_USER/$APP_NAME:$VERSION

echo "=== Logging into Docker Hub ==="
echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USER" --password-stdin

echo "=== Pushing Docker image to Docker Hub ==="
docker push $DOCKER_USER/$APP_NAME:$VERSION

echo "=== Stopping old container if it exists ==="
docker stop flask_container || true
docker rm flask_container || true

echo "=== Running new container on port 5002 ==="
docker run -d --restart unless-stopped -p 5002:5000 --name flask_container $DOCKER_USER/$APP_NAME:$VERSION

echo "✅ Deployment complete — $DOCKER_USER/$APP_NAME:$VERSION is running on http://localhost:5002"
