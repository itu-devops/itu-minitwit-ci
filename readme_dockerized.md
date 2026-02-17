# Minitwit + MySQL + Docker + `docker-compose`

> [!IMPORTANT]
> GitHub Container Registry (GHCR) and Docker require image names to be strictly lowercase. The provided CI/CD pipeline handles this automatically. For manual operations, ensure your `GITHUB_USERNAME` is lowercased.

## `docker-compose`

To run ITU-MiniTwit and the MySQL DBMS containers simply use `docker-compose up`.
Use `-d` to start as daemon, and set the user

```bash
GITHUB_USERNAME=<your_github_username_lowercase> docker-compose up -d
```

Tear it down and delete MySQL volume with -v

```bash
GITHUB_USERNAME=<your_github_username_lowercase> docker-compose down -v
```

## Dockerfiles

We have 3 Dockerfiles:

To push images locally, you need a Personal Access Token (Classic) with `write:packages` scope.

---

### `Dockerfile-minitwit`

`Dockerfile-minitwit` - on GHCR: `ghcr.io/<your_github_username_lowercase>/minitwitimage`
contains the ITU-MiniTwit Python application adapted to work with MySQL

Build with:

```bash
GITHUB_USERNAME=<your_github_username_lowercase> docker build -t ghcr.io/$GITHUB_USERNAME/minitwitimage -f Dockerfile-minitwit .
```

Push with:

```bash
docker push ghcr.io/<your_github_username_lowercase>/minitwitimage
```

---

### `Dockerfile-flagtool`

`Dockerfile-flagtool` - on GHCR: `ghcr.io/<your_github_username_lowercase>/flagtoolimage`
contains the `flagtool` adapted to work with MySQL

build with

```bash
docker build -t ghcr.io/<your_github_username_lowercase>/flagtoolimage -f Dockerfile-flagtool .
```

push with

```bash
docker push ghcr.io/<your_github_username_lowercase>/flagtoolimage
```

---

### `Dockerfile-mysql`

`Dockerfile-mysql` - on GHCR: `ghcr.io/<your_github_username_lowercase>/mysqlimage`
contains a MySQL server that initializes with all of the data from one of simulator scenarios found in `minitwit_init.sql`

build with

```bash
docker build -t ghcr.io/<your_github_username_lowercase>/mysqlimage -f Dockerfile-mysql .
```

push with

```bash
docker push ghcr.io/<your_github_username_lowercase>/mysqlimage
```

you can run the MySQL server with

```bash
docker run --rm -d --name minitwit_mysql -e MYSQL_ROOT_PASSWORD=root ghcr.io/<your_github_username_lowercase>/mysqlimage
```

If you need to connect and check that the MySQL db is working you can do something like:

```bash
docker run --rm -it mysql:5.7 mysql -u root -proot -h 172.17.0.2 -D minitwit
```

And change the IP address to be correct of course..
