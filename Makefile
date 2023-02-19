.DEFAULT_GOAL := login

login:
	docker login -u $(DOCKER_USERNAME) -p $(DOCKER_PASSWORD)

deploy: login
	docker-compose pull 
	docker-compose up -d
	docker pull $(DOCKER_USERNAME)/flagtoolimage:latest