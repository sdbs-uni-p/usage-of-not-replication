[![CC BY 4.0][cc-by-shield]][cc-by]
# "Usage of Not" Replication Package 
This repository provides a replication package for the empirical study
on the [usage of the operator "not"](https://arxiv.org/abs/2107.08677) in JSON Schema.

## Cititation
To refer to this replication package in a publication, please use these BibTeX entries.
```BibTeX
@misc{Baazizi_Usage_of_Not_2021,
  author = {Baazizi, Mohamed Amine and Colazzo, Dario and Ghelli, Giorgio and Sartiani, Carlo and Scherzinger, Stefanie},
  doi    = {10.5281/zenodo.5141378},
  month  = {8},
  title  = {{"Usage of Not" Replication Package }},
  url    = {https://github.com/sdbs-uni-p/usage-of-not-replication},
  year   = {2021}
}
``` 

```BibTeX
@inproceedings{Baazizi:2021:usageofnot,
  author    = {Mohamed Amine Baazizi and
               Dario Colazzo and
               Giorgio Ghelli and
               Carlo Sartiani and
               Stefanie Scherzinger},
  title     = {An Empirical Study on the "Usage of Not" in Real-World JSON Schema Documents},
  booktitle = {Proc.\ ER},
  year      = {2021}
}
```

## Table of Contents
- ["Usage of Not" Replication Package](#usage-of-not-replication-package)
  - [Cititation](#cititation)
  - [Table of Contents](#table-of-contents)
  - [Getting started](#getting-started)
    - [Pre-built docker image](#pre-built-docker-image)
    - [Build image yourself](#build-image-yourself)
  - [First steps](#first-steps)
    - [Get shell-access to container](#get-shell-access-to-container)
    - [Start psql](#start-psql)
    - [Run SQL-script](#run-sql-script)
    - [Useful tools and commands](#useful-tools-and-commands)
  - [Using pgAdmin](#using-pgadmin)
    - [Use your local pgAdmin installation](#use-your-local-pgadmin-installation)
      - [Isolated network stacks](#isolated-network-stacks)
      - [Host networking](#host-networking)
    - [Use pgAdmin container](#use-pgadmin-container)
  - [Pattern queries](#pattern-queries)
  - [Initialization process](#initialization-process)
  - [Image content](#image-content)
  - [Image customization](#image-customization)
  - [Known issues](#known-issues)
  - [Download](#download)
  - [Acknowledgements](#acknowledgements)
  - [License](#license)

## Getting started
### Pre-built docker image
The fastest way to get up and running is to download and run the pre-built docker image from [Zenodo (DOI: 10.5281/zenodo.5141378)](https://doi.org/10.5281/zenodo.5141378) and load the docker image from the tarball.

```bash
# Download tarball from Zenodo first, then load image
# Please note: the image has a considerable size of 20.4GB (uncompressed) therefore this will take some time
docker load < sds_usage-of-not-replication_v1-0.tar.gz

# Start a container from the pre-built image
docker run --name <container-name> -d sds/usage-of-not-replication:1.0
```
> **Hint**: the --name option is optional but allows you to identify the container easily.

After running aforementioned commands the container with the Postgres database server will be running in the background and already contain all the data, so you can now take your [first steps](#first-steps). 

### Build image yourself
You can also build the image yourself. To do so follow the steps below:
```bash
# Clone git repository
git clone https://github.com/sdbs-uni-p/usage-of-not-replication.git

# Go to repository root
cd usage-of-not-replication

# Download SQL-dump file (git lfs only stores pointer file for large files)
# Pre-requisite: git lfs must be installed (See https://git-lfs.github.com/)
git lfs pull --include "jsonschemacorpus_dump.sql.gz"

# Build docker image 
# This image was built with "docker build -t sds/usage-of-not-replication:1.0 ."
# Note: If <container-registry> is omitted docker.io is used as container-registry
docker build -t <container-registry>/<repository>/<image-name>:<tag> .

# Start a container from your own image
# This image is run with "docker run --name <container-name> -d sds/usage-of-not-replication:1.0"
docker run --name <container-name> -d <container-registry>/<repository>/<image-name>:<tag>
```
The build process will take a considerable amount of time as not only some dependencies must be pulled in and installed but the [initialization process](#initialization-process) will be performed.
As soon as the build is finished you can run the image as in [Pre-built docker image (OPTION 1)](#pre-built-docker-image).

> **Important:**</br> 
> [jsonschemacorpus_dump.sql.gz](/jsonschemacorpus_dump.sql.gz) **MUST** be downloaded from [git lfs](https://git-lfs.github.com/), otherwise decompressing the file will fail since the stored pointer file is not in the correct format. [jsonschemacorpus_dump.sql.gz](/jsonschemacorpus_dump.sql.gz) will be 1.5GB in size whereas the pointer file only occupies a few bytes. A SHA256-sum will be computed during the build process to verify the SQL-dump is valid. If it is not, the build process will fail.

## First steps
Make sure you have completed all the steps in [Getting Started](#getting-started) and then continue here.
To be able to work with the container you will have to perform the following steps:
### Get shell-access to container
As the container is now running in background you have to get shell access as user root to the container to be able to connect to the database and run queries.
```bash
# Start bash as root within the container
docker exec -u root -it <container-name> bash

# OR: Combine Steps "Get shell-access to container" and "Start psql" into one command to get dropped into the psql console immediately
docker exec -u root -it <container-name> psql jsonschemacorpus
```
> **Important**
> In case you change the name of the database (i.e. modify $POSTGRES_DB when building the image) from default value "jsonschemacorpus" make sure to change the psql command above.

### Start psql
You are now dropped into a shell within */json-schema-corpus* directory inside the container, which contains all relevant files ([See Image content](#image-content)). A connection to the database $POSTGRES_DB ([Default: jsonschemacorpus](#image-customization)) can be established with *psql* CLI-client.

```bash
# Start psql client connecting to database $POSTGRES_DB
psql $POSTGRES_DB

# Expected result: psql console (Assuming $POSTGRES_DB=jsonschemacorpus)
psql (12.7 (Ubuntu 12.7-1.pgdg18.04+1))
Type "help" for help.

jsonschemacorpus=# 
```

### Run SQL-script
The psql console will now be displayed (as indicated above) and you can start to write your own queries or execute the queries outlined in the paper. To do so please use the following command:

```bash
# In general
\i path/to/file

# E.g.: Run query_02.sql
\i ./sql-queries/query_02.sql
```
Alternatively you can also execute a SQL-script directly from bash:
```bash
# In general
psql $POSTGRES_DB -f /path/to/file
# OR
psql $POSTGRES_DB < /path/to/file

# E.g.: Run query_02.sql
psql $POSTGRES_DB -f ./sql-queries/query_02.sql
# OR
psql $POSTGRES_DB < ./sql-queries/query_02.sql
```
### Useful tools and commands
Here some hints on what you may find helpful to work with the provided container image: 
- Using [vi](https://www.vim.org/) or [nano](https://www.nano-editor.org/) which are provided inside the container you may build your own queries or view and adjust the provided queries.
- You can create SQL-scripts on your host machine and copy them into the container or the other way round using [docker cp](https://docs.docker.com/engine/reference/commandline/cp/) command.
- You may find it useful to define a [volume mapping](https://docs.docker.com/storage/volumes/) between a directory on your host machine and a directory inside the container to share data. To do so you have to start the container with -v option and define which directorys you would like to map.
E.g.: Defining a mapping between [sql-queries](sql-queries) folder on host and */json-schema-corpus/sql-scripts* directory inside the container will give you a convenient way to view/ edit queries on your host machine and have them available inside your container for execution. Of course this is also possible with any other directory (except those relevant for the container to work properly). 
- Use *\pset pager off* in psql console to disable pagination of query results

## Using pgAdmin
You may be more comfortable using a (web) GUI such as pgAdmin as a client application instead of psql as provided in the container.
Two general approaches on how to connect from pgAdmin are described here.

### Use your local pgAdmin installation
If you have pgAdmin already installed as your default Postgres client you can simply add a new database server in pgAdmin. Of course this requires you to know the IP address of the container and there are 2 general network setups which will result in different IP addresses.
On one hand there are [isolated network stacks](#isolated-network-stacks) provided by docker (default) and on the other hand there is the possibility to not have isolated networks for container and host which might be more convenient (See [host-networking](#host-networking)).
#### Isolated network stacks
By default your container will be started in an isolated network called "bridge" which is created by Docker for you. To obtain the IP address (and port) from the container in this case you may choose one of the following alternatives:
1. Using docker inspect
```bash
docker inspect <container-name>
```
This will return a JSON document which at the end contains the networking details and of course the IP address. Here is an excerpt of the relevant section of the JSON document. 
```javascript
"NetworkSettings": {
    "Bridge": "",
            "SandboxID": "758e7f97f36d2fb6892e3ad73eb23d33b51faa606184483db2fef47e4e4d0d15",
            "HairpinMode": false,
            "LinkLocalIPv6Address": "",
            "LinkLocalIPv6PrefixLen": 0,

            // Here you will find all the ports that are exposed on this container
            "Ports": {
                "5432/tcp": null
            },

            "SandboxKey": "/var/run/docker/netns/758e7f97f36d",
            "SecondaryIPAddresses": null,
            "SecondaryIPv6Addresses": null,
            "EndpointID": "938340b699e72dce8facae69e27fd7de6fc837efd56b44d43108ec35d8d1f053",
            "Gateway": "172.17.0.1",
            "GlobalIPv6Address": "",
            "GlobalIPv6PrefixLen": 0,
            "IPAddress": "172.17.0.3",
            "IPPrefixLen": 16,
            "IPv6Gateway": "",
            "MacAddress": "02:42:ac:11:00:03",
            "Networks": {


              // Find the "bridge" network
                "bridge": {
                    "IPAMConfig": null,
                    "Links": null,
                    "Aliases": null,
                    "NetworkID": "68e507252eda2dd44c72977272ee4e0c1a6da0bcbf6acca47cce178e5268a06f",
                    "EndpointID": "938340b699e72dce8facae69e27fd7de6fc837efd56b44d43108ec35d8d1f053",
                    "Gateway": "172.17.0.1",

                    // Here you will find the relevant IP address
                    "IPAddress": "172.17.0.3",


                    "IPPrefixLen": 16,
                    "IPv6Gateway": "",
                    "GlobalIPv6Address": "",
                    "GlobalIPv6PrefixLen": 0,
                    "MacAddress": "02:42:ac:11:00:03",
                    "DriverOpts": null
                }
            }
        }
```
2. Using standard UNIX utilities
   
By running *docker exec* command you can execute commands within the container and can therefore use utilitites installed to get the IP address. 
```bash
docker exec <contaner-name> hostname -I
``` 

#### Host networking
> Please be aware that docker only provides host networking for Linux hosts.

If you dont want the network stack of the container to be isolated from your host you can attach the container to the so called "host" network. This is only possible when starting a container. You cannot change this afterwards.  
```bash
# Use --network flag to connect the container to the "host" network
docker run --name <container-name> -d --network host sds/usage-of-not-replication:1.0
```
You can now reach the container using the IP address of your host system.

### Use pgAdmin container
In case you dont have pgAdmin installed already or you dont want to use your local installation a convenient way to use pgAdmin is Docker. There is an [offical pgAdmin Docker image](https://hub.docker.com/r/dpage/pgadmin4/) available at DockerHub and [offical documentation on how to use the image](https://www.pgadmin.org/docs/pgadmin4/latest/container_deployment.html) on pgadmin.org. You may use this image and [user-defined docker networks](https://docs.docker.com/network/network-tutorial-standalone/) to setup the two containers in their own isolated network or you might go further and use [Docker Compose](https://docs.docker.com/compose/) to deploy everything conveniently using a yaml configuration file. 

## Pattern queries
The following is an excerpt (Section 2.1 Pattern Queries) from the paper "An Empirical Study on the “Usage of Not” in Real-World JSON Schema Documents" explaining the pattern language used to analyse JSON Schema Documents.

As part of our analysis, we will study which keywords occur below an instance</br>
of the not operator. To this aim, we introduce a simple path language, where a</br>
path such as <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">.∗∗.not.required</span> matches any path that ends with an object field</br>
named required found inside an object field whose name is not.</br>
Paths are expressed using the following language.¹ Pattern matching is de-</br>
fined as in JSONPath², so we only give an informal introduction.</br>
</br>
<span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">
p ::= step | step p</br>
step ::= .key | . ∗ | [∗] | .∗∗</br>
filtered p ::= p ? p</br>
</span>
</br>
The step <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">.∗</span> retrieves all member values of an object, <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">[∗]</span> retrieves all items of</br>
an array, and <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">.∗∗</span> is the reflexive and transitive closure of the union of <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">.∗</span> and <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">[∗]</span>,</br>
navigating to all nodes of the JSON tree to which it is applied.</br>
We use the conditional form <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">p1 ? p2</span> to denote nodes *n* that are reached by</br>
a path <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">p1</span>, such that if we follow a path <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">p2</span> starting from *n* we will arrive at</br>
some node. For example, if we have one subtree reached by <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">. ∗ ∗.anyOf</span> that</br>
contains three nodes with name <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">not</span>, then we count one instance of the path</br>
<span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">.∗∗.anyOf ? .∗∗.not</span>, but three instances of the path <span style="font-family: Consolas, monospace; font-size: 1.05rem; font-weight: 800;">.∗∗.anyOf.∗∗.not.</span>

<span stlye="font-size: 0.6rem;">
[1] We introduce this simple pattern language, as we found the semantics of the</br>
PostgreSQL-internal implementation of JSONPath underspecified for our purposes.</br>
[2] Friesen J.: Extracting JSON Values with JsonPath, pp. 299–322. Apress, Berkeley, CA (2019)
</span>

## Initialization process
The [init.sh](./scripts/init.sh) script will do the following three steps to initialize the database:
- Configure psql
- Decompress SQL-dump
- Restore database from SQL-dump
- Delete SQL-dump to keep Docker image size as small as possible

## Image content
The image is based on [Ubuntu 18.04](https://hub.docker.com/layers/ubuntu/library/ubuntu/18.04/images/sha256-ceed028aae0eac7db9dd33bd89c14d5a9991d73443b0de24ba0db250f47491d2?context=explore) and does run a postgres server listening at *0.0.0.0:5432* when started. Therefore, you may connect to the database server inside the container from another PostgreSQL client e.g. [pgAdmin](https://www.pgadmin.org/) if you please. Furthermore it contains [wget](https://www.gnu.org/software/wget/), [gzip](https://www.gnu.org/software/gzip/), [nano](https://www.nano-editor.org/) and [vi](vim.org) to provide a more convenient way to interact with the system.
You can of course at any time pull in more packages as you desire.
Apart from those packages the [SQL queries](./sql-queries) presented in the paper and some administrative [scripts](./scripts) are provided within the $WORKDIR ([Default: /json-schema-corpus](#image-customization)).

```bash
# Structure of working directory $WORKDIR
|–– json-schema-corpus
|  |–– scripts
|  |      |–– check_queries.sh
|  |      |–– entrypoint.sh
|  |      |–– init.sh
|  |–– sql-queries
|  |      |–– query_01.sql
|  |      |–– query_02.sql
|  |      |–– ...
|  |      |–– query_49.sql

```

## Image customization
Certain environment variables are available to customize the image. Commands outlined in the README may need to be adjusted accordingly when default values are changed.

| Name              | Default value             | Description                                                                          | Note                                                                                                    |
| ----------------- | ------------------------- | ------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------- |
| POSTGRES_USER     | root                      | Postgres super user to be created                                                    | TRUST authentication (in PostgreSQL) is enabled, so if changed an appropiate linux user must be created |
| POSTGRES_PASSWORD | password                  | Postgres super user password                                                         | Should not be required as TRUST authentication is enabled                                               |
| POSTGRES_DB       | jsonschemacorpus          | Name of created database                                                             |
| POSTGRES_PORT     | 5432                      | Port Postgres listens on                                                             | Port will be exposed by the container                                                                   |
| PG_MAJOR_VERSION  | 12                        | Major version of PostgreSQL                                                          | do not change to ensure everything works as expected                                                    |
| SQL_DUMP_FNAME    | jsonschemacorpus_dump.sql | Name of SQL-dump file (when decompressed)                                            | When decompressed -> no ".gz" file extension                                                            |
| WORKDIR           | /json-schema-corpus       | Working directory within the container containing all artifacts provided in the repo |

## Known issues
Due to the layered architecture of Docker and copy-on-write you might encounter performance issues when you perform write operations on the data within the database. Details on those key Docker concepts can be found in the [offical Docker documentation on storage drivers](https://docs.docker.com/storage/storagedriver/) especially in the section ["Copying makes containers efficient"](https://docs.docker.com/storage/storagedriver/#copying-makes-containers-efficient).
There you will also find detailed documentation on how to resolve those issues with write-heavy applications using [Docker volumes](https://docs.docker.com/storage/volumes/). By making use of volumes and [backup, restore and migration features](https://docs.docker.com/storage/volumes/#backup-restore-or-migrate-data-volumes) of Docker you can easily create your own volume which contains all the data stored in the database (Path /var/lib/postgresql/$PG_MAJOR_VERSION/main within the container) and resolve those performance issues.

## Download
Download the pre-built docker image as tarball:
- [Zenodo, DOI: 10.5281/zenodo.5141378](https://doi.org/10.5281/zenodo.5141378) (Size: 5.2GB)

## Acknowledgements
This work was partly funded by Deutsche Forschungsgemeinschaft (DFG, German Research Foundation) grant #385808805. 
The schema corpus was retrieved using Google BigQuery, supported by Google Cloud.

## License
This work is licensed under a
[Creative Commons Attribution 4.0 International License][cc-by].

[![CC BY 4.0][cc-by-image]][cc-by]

[cc-by]: http://creativecommons.org/licenses/by/4.0/
[cc-by-image]: https://i.creativecommons.org/l/by/4.0/88x31.png
[cc-by-shield]: https://img.shields.io/badge/License-CC%20BY%204.0-lightgrey.svg