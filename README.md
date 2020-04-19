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

First clone the code:
```
git clone https://github.com/openmrs-indianaems/openmrs-docker-indianaems.git
cd openmrs-docker-indianaems
```

Next, perform one-time install of client-side git hooks and trigger merge hook to keep encrypted files safe:
```
conf/install-hooks.sh
.git/hooks/post-merge
```

NOTE: environment files for staging and production are encrypted using `git-crypt`. Your public gpg key must be 
registered within the repository before you can see the content of these encrypted files. We use two git hooks:
(1) to issue warning to prevent accidentally pushing encrypted files in unencrypted state and (2) to make sure 
encrypted file permissions are limited to current user (removing read access for group or others).


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

### 2. Start OpenMRS on app server

```
$ cd app
$ docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

There are convenience scripts for staging & production, so you don't have to remember to invoke two docker-compose files:

```
$ ./staging up -d
```

and

```
$ ./production up -d
```

### 3. Clear out concepts on db server

```
$ docker exec -it openmrs bash
# mysql -u openmrs -p
```

```
use openmrs;
```

Remove all synonyms

```
update concept_name set voided=1, date_voided=now(), voided_by=1 where concept_name_type=null;
```

Create temp table of fully specified, active concept names

```
create temporary table foo (
    select t2.concept_name_id from openmrs.concept_name t1 
      join concept_name t2
      on t1.concept_name_id != t2.concept_name_id and t1.name = t2.name and t1.concept_name_type = "FULLY_SPECIFIED"
      join concept t3 on t1.concept_id=t3.concept_id
      join concept t4 on t2.concept_id=t4.concept_id
    where
      t1.voided=0 and t2.voided=0 and t3.retired=0 and t4.retired=0
  );
```

Void all existing concepts

```
update concept_name set voided=1, date_voided=now(), voided_by=1
  where concept_name_id in (select concept_name_id from foo);
```

### 4. Initialize Metadata

First, start monitoring logs in a terminal on app server:

```
docker logs -f openmrs
```

Log in through the Reference Application user interface, navigate to System Administration > Manage Module, and 
load the initializer module (available in this repository under app/modules/) through OpenMRS manage modules feature.

NOTE: the CIEL dictionary import (concepts) is importing ~52000 concepts and will take around 45 minutes or so to 
load all the concepts the first time.

### 5. Manual Steps

#### 5.1 Remove Locations 
Go to System Administration > Advanced Administration > Manage Locations 
Select the locations as shown in the image and click on Delete Locations

<img width="279" alt="Screen Shot 2020-04-17 at 8 31 29 AM" src="https://user-images.githubusercontent.com/1560244/79569871-74192780-8086-11ea-8dd1-8e837f0e8d56.png">

**Note:** This action may result in an error, just click on back on your browser and you should see the locations to be updated appropriately

#### 5.2 Change Identifier 
**NOTE:** This should happen before adding any patients or it might lead to inconsistent behaviour

Go to System Administration > Advanced Administration > Manage Patient Identifier Sources

Click on Configure

Change First Identifier Source to 100

Suffix - CE

Min Length 3

#### 5.3 Add HTML Form 
Go to System Administration > Advanced Administration > Manage HTML Forms 

Click on New HTML Form

Select Name as COVID-19 NOTE 

Version is the one highlighted in the

https://github.com/openmrs-indianaems/openmrs-indianaems-config/blob/master/htmlform/COVID-19%20Note.html

Replace the default HTML with the above HTML in the form and save

#### 5.4 Roles (A Standard User)
#### 5.5 Manage Apps (Stop apps and copy Burke's Register APP)


