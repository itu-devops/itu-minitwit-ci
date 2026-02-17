#!/usr/bin/env bash

GITHUB_USERNAME=$(echo "$GITHUB_USERNAME" | tr '[:upper:]' '[:lower:]')
echo "Note: Normalizing GITHUB_USERNAME to lowercase for Docker compatibility."

echo "Building Minitwit Images"
docker build -t ghcr.io/$GITHUB_USERNAME/minitwitimage -f Dockerfile-minitwit .
docker build -t ghcr.io/$GITHUB_USERNAME/flagtoolimage -f Dockerfile-flagtool .
docker build -t ghcr.io/$GITHUB_USERNAME/mysqlimage -f Dockerfile-mysql .
docker build -t ghcr.io/$GITHUB_USERNAME/minitwittestimage -f Dockerfile-minitwit-tests .

echo "Login to GitHub Container Registry, provide your GitHub Personal Access Token (PAT) below..."
read -s GHCR_PAT
echo $GHCR_PAT | docker login ghcr.io -u "$GITHUB_USERNAME" --password-stdin

echo "Pushing Minitwit Images to GHCR..."
docker push ghcr.io/$GITHUB_USERNAME/minitwitimage:latest
docker push ghcr.io/$GITHUB_USERNAME/mysqlimage:latest
docker push ghcr.io/$GITHUB_USERNAME/flagtoolimage:latest
docker push ghcr.io/$GITHUB_USERNAME/minitwittestimage:latest
