# Description
Run openmrs reference application and mysql as disposable docker containers
for demo server.


The docker image used was generated by OpenMRS SDK, and deployed to Docker hub (check <https://hub.docker.com/r/openmrs/openmrs-reference-application-distro/>

## Setup Docker and Docker Compose on Ubuntu 18.04

```
$ sudo apt update
$ curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
$ sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"
$ sudo apt update
$ apt-cache policy docker-ce
$ sudo apt install docker-ce
$ sudo systemctl status docker
$ sudo curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
$ docker-compose --version
```
## Getting the code
```
git clone https://github.com/openmrs-indianaems/openmrs-docker-indianaems.git
cd openmrs-docker-indianaems
```

## Running it locally

To start the containers in a detached mode -

```
$ docker-compose down -v
$ docker-compose up -d 
```

to see the logs you can use -

```
docker-compose logs -f
```



Application will be eventually accessible on http://localhost:8080/openmrs.
Credentials on shipped demo data:
  - Username: admin
  - Password: Admin123

To stop the instance use -

```
$ docker-compose down
```

But to make sure to destroy containers to delete any left overs volumes and data when doing changes to the docker configuration and images use:

```
$ docker-compose down -v
```


## To run SQL commands

To backup -
```
docker exec [containerId] /usr/bin/mysqldump -u openmrs --password=[password] openmrs > backup-04-08-2020.sql
```
To restore -
```
cat backup-04-08-2020.sql | docker exec -i [containerId] /usr/bin/mysql -u openmrs --password=[password] openmrs
```
