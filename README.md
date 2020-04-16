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

NOTE: environment files for staging and production are encrypted using `git-crypt`. Your public gpg key must be 
registered within the repository before you can access these encrypted files.

## Running the dev environment locally in a single instance

To start the containers in a detached mode:

```
$ cd app
$ docker-compose up -d 
```

To see the logs:

```
$ docker logs -f app_openmrs-reference-application_1
```

Application will be eventually accessible on http://localhost:8080/openmrs.

Credentials on shipped demo data:
  - Username: admin
  - Password: Admin123

To stop the instance use:

```
$ docker-compose down
```

But to make sure to destroy containers to delete any left overs volumes and data when doing changes to the docker configuration and images use:

```
$ docker-compose down -v
```


## Database backup

To backup:

```
docker exec [containerId] /usr/bin/mysqldump -u openmrs --password=[password] openmrs > backup.sql
```

To restore:

```
cat backup.sql | docker exec -i [containerId] /usr/bin/mysql -u openmrs --password=[password] openmrs

```


## Installation in the production environment in a two environment setup

### 1. Start the Database on db server

```
$ cd db
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 2. Prepare database on db server

```
$ docker exec -it openmrs-mysql bash
# mysql -u openmrs -p
> use openmrs;
> -- remove all synonyms
> update concept_name set voided=1, date_voided=now(), voided_by=1 where concept_name_type=null;
> -- create temp table of fully specified, active concept names
> create temporary table foo (
    select t2.concept_name_id from openmrs.concept_name t1 
      join concept_name t2
      on t1.concept_name_id != t2.concept_name_id and t1.name = t2.name and t1.concept_name_type = "FULLY_SPECIFIED"
      join concept t3 on t1.concept_id=t3.concept_id
      join concept t4 on t2.concept_id=t4.concept_id
    where
      t1.voided=0 and t2.voided=0 and t3.retired=0 and t4.retired=0
  );
> -- void all existing concepts
> update concept_name set voided=1, date_voided=now(), voided_by=1
  where concept_name_id in (select concept_name_id from foo);
```

### 3. Start OpenMRS

```
$ cd app
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

### 4. Initialize Metadata

First, start monitoring logs in a terminal:

```
docker logs -f openmrs
```

After the OpenMRS Reference application is available, log in and load the initializer module (available in this 
repository under app/modules/) through OpenMRS manage modules feature.

NOTE: the CIEL dictionary import (concepts) is importing ~52000 concepts and will take around 45 minutes or so to 
load all the concepts the first time.


