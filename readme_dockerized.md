# Minitwit + mysql + docker + docker-compose

## docker-compose

to run minitwit and the mysql db containers simply use docker-compose up
use -d to start as daemon
```bash
docker-compose up -d
```

tear it down and delete mysql volume with -v
```bash
docker-compose down -v
```

## dockerfiles

we have 3 dockerfiles:

---
### minitwit
`Dockerfile-minitwit` - on docker hub: `devopsitu/minitwitimage`
contains the minitwit python application adapted to work with mysql

build with
```bash
docker build -t devopsitu/minitwitimage -f Dockerfile-minitwit .
```

push with
```bash
docker push devopsitu/minitwitimage
```

---
### flagtool
`Dockerfile-flagtool` - on docker hub: `devopsitu/flagtoolimage`
contains the flagtool adapted to work with mysql

build with
```bash
docker build -t devopsitu/flagtoolimage -f Dockerfile-flagtool .
```

push with
```bash
docker push devopsitu/flagtoolimage
```

---
### mysql
`Dockerfile-mysql` - on docker hub: `devopsitu/itusqlimage`
contains a mysql server that initializes with all of the data from one of simulator scenarios found in `minitwit_init.sql`

build with
```bash
docker build -t devopsitu/itusqlimage -f Dockerfile-mysql .
```

push with
```bash
docker push devopsitu/itusqlimage
```

you can run the mysql server with
```bash
docker run --rm -d --name minitwit_mysql -e MYSQL_ROOT_PASSWORD=root devopsitu/itusqlimage
```

If you need to connect and check that the mysql db is working you can do something like:
```bash
docker run --rm -it mysql:5.7 mysql -u root -proot -h 172.17.0.2 -D minitwit
```
And change the ip address to be correct of course..
