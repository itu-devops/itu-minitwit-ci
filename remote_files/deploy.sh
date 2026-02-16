source ~/.bash_profile

cd /minitwit

docker compose -f docker-compose.yml pull
docker compose -f docker-compose.yml up -d
docker pull ghcr.io/$GITHUB_USERNAME/flagtoolimage:latest
