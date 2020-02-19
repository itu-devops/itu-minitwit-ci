#!/usr/bin/env bash

echo "Building Minitwit Images"
docker build -t $DOCKER_USERNAME/minitwitimage -f Dockerfile-minitwit .
docker build -t $DOCKER_USERNAME/flagtoolimage -f Dockerfile-flagtool .
docker build -t $DOCKER_USERNAME/mysqlimage -f Dockerfile-mysql .
docker build -t $DOCKER_USERNAME/minitwittestimage -f Dockerfile-minitwit-tests .

echo "Login to Dockerhub, provide your password below..."
read -s DOCKER_PASSWORD
echo $DOCKER_PASSWORD | docker login -u "$DOCKER_USERNAME" --password-stdin

echo "Pushing Minitwit Images to Dockerhub..."
docker push $DOCKER_USERNAME/minitwitimage:latest
docker push $DOCKER_USERNAME/mysqlimage:latest
docker push $DOCKER_USERNAME/flagtoolimage:latest
