# Minitwit + MySQL + Docker + `docker-compose`

## `docker-compose`

To run ITU-MiniTwit and the MySQL DBMS containers simply use `docker-compose up`.
Use `-d` to start as daemon, and set the user

```bash
DOCKER_USERNAME=<your_dockerhub_username> docker-compose up -d
```

Tear it down and delete MySQL volume with -v

```bash
DOCKER_USERNAME=<your_dockerhub_username> docker-compose down -v
```

## Dockerfiles

We have 3 Dockerfiles:

---

### `Dockerfile-minitwit`
`Dockerfile-minitwit` - on docker hub: ` <your_dockerhub_username>/minitwitimage`
contains the ITU-MiniTwit Python application adapted to work with MySQL

Build with:

```bash
DOCKER_USERNAME=<your_dockerhub_username> docker build -t $DOCKER_USERNAME/minitwitimage -f Dockerfile-minitwit .
```

Push with:

```bash
docker push <your_dockerhub_username>/minitwitimage
```

---
### `Dockerfile-flagtool`

`Dockerfile-flagtool` - on Docker Hub: ` <your_dockerhub_username>/flagtoolimage`
contains the `flagtool adapted to work with MySQL

build with
```bash
docker build -t <your_dockerhub_username>/flagtoolimage -f Dockerfile-flagtool .
```

push with
```bash
docker push <your_dockerhub_username>/flagtoolimage
```

---
### `Dockerfile-mysql`

`Dockerfile-mysql` - on Docker Hub: ` <your_dockerhub_username>/itusqlimage`
contains a MySQL server that initializes with all of the data from one of simulator scenarios found in `minitwit_init.sql`

build with
```bash
docker build -t <your_dockerhub_username>/itusqlimage -f Dockerfile-mysql .
```

push with
```bash
docker push <your_dockerhub_username>/itusqlimage
```

you can run the MySQL server with
```bash
docker run --rm -d --name minitwit_mysql -e MYSQL_ROOT_PASSWORD=root <your_dockerhub_username>/itusqlimage
```

If you need to connect and check that the MySQL db is working you can do something like:

```bash
docker run --rm -it mysql:5.7 mysql -u root -proot -h 172.17.0.2 -D minitwit
```
And change the IP address to be correct of course..
