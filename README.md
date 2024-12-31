# Open Source Big Data Educational Toolkit (OSBDET)
OSBDET is a test environment creation tool which facilitates the build of sandboxes containing a bunch of open source technologies altogether. This test environment is targeting people who want to take their first steps with Big Data technologies easily.

The following are some of the Big Data frameworks included in OSBDET:

- Hadoop 3
- Spark 3
- Kafka 3
- ...

OSBDET's architecture encourages the extension of the toolkit by introducing new frameworks with very little effort.
## How to use OSBDET
OSBDET can be controlled with one single script, `osbdet_builder.sh`, which brings the following options:
```root@osbdet:~/osbdet# ./osbdet_builder.sh
Usage: osbdet_builder.sh [OPTION] [comma separated list of modules/recipes]

Available options for osbdet_builder:
  ## environment related options ##
  status              display the current status of OSBDET's modules
  modules             list available modules
  recipes             list available recipes
  currentconf         display the current configuration of osbdet_builder
  setup               change the current configuration of osbdet_builder

  ## operational options ##
  build               build environment by installing available modules
  remove              remove installed modules from current environment
  cook                'cook' all the recipes passed as an argument
```
Before being able to use the script, it has to be configured to pull the right versions
of the frameworks. This is accomplished by using the `setup` option as follows:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh setup
Let's setup your OSBDET 25r1 builder:
  Log level (DEBUG*): DEBUG
  Target Operating System (deb12*): deb12
  Target Architecture (amd64*|arm64): amd64
  OSBDET recipes home (/root/osbdet-recipes*): 
  OSBDET repository (https://github.com/raulmarinperez/osbdet-recipes.git*): 
Persisting changes in /root/osbdet/shared/osbdet_builder.conf... [Done]
```
As you can see, OSBDET 2025R1 is compatible with amd64 and arm64 architectures and the Debian 12 GNU/Linux operating system.
The current configuration can be always checked by invoking the `currentconf` option:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh currentconf
This is the current configuration of OSBDET 25r1:
  OSBDET_HOME: /root/osbdet
  LOGLEVEL: DEBUG
  OSBDET_TARGETOS: deb12
  OSBDET_ARCHITECTURE: arm64
  OSBDETRECIPES_HOME: /root/osbdet-recipes
  OSBDETRECIPES_REPO: https://github.com/raulmarinperez/osbdet-recipes.git
```
The `osbdet.log` file tracks all the steps taken by the script; tail this file while building or removing modules to get all the information about the process.
### Listing available modules
The `modules` option lists all the available modules:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh modules
These are the modules available in OSBDET v25r1:
  - superset: Superset installation, depends on: foundation
  - labbuilder: Lab builder installation, depends on: foundation,hadoop3
  - spark3: Spark 3 installation, depends on: foundation
  - grafana: Grafana installation, depends on: foundation
  - openmetadata: Open Metadata installation, depends on: foundation
  - truckssim: Truck fleet simulator, depends on: foundation
  - nifi: NiFi installation, depends on: foundation
  - jupyter: Jupyter Notebook installation, depends on: foundation
  - hadoop3: Hadoop 3 installation, depends on: foundation
  - osbdetweb: OSBDET web installation, depends on: foundation
  - mariadb: MariaDB installation, depends on: foundation
  - foundation: Configurations and dependencies to satisfy the installation of other modules, depends on: no_dependencies
  - kestra: Kestra installation, depends on: foundation
  - kafka3: Kafka 3 installation, depends on: foundation
  - minio: MinIO (object store) installation, depends on: foundation
  - mongodb8: MongoDB 8 installation, depends on: foundation
```
### Listing available recipes
The `recipes` option lists all the available recipes:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh recipes
These are the recipes available for OSBDET v25r1:
  - terraform[25r1]: Install Terraform on this OSBDET release (Debian 12), depends on: no_dependencies
  - vscodetunnel[25r1]: Setup a VS Code tunnel to use OSBDET from an external VS Code, depends on: no_dependencies
  - helloworld[25r1]: Hello world recipe, depends on: no_dependencies
  - hugo0.140.1[25r1]: Install a recent go-lang version and a recent hugo version, depends on: no_dependencies
```
### Displaying the status of available modules
The `status` option lists the status of all the available modules:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh status
The folowing list shows the status of all available modules:
  - superset: Module is installed [OK]
  - labbuilder: Module is not installed [KO]
  - spark3: Module is installed [OK]
  - grafana: Module is installed [OK]
  - openmetadata: Module is installed [OK]
  - truckssim: Module is installed [OK]
  - nifi: Module is installed [OK]
  - jupyter: Module is installed [OK]
  - hadoop3: Module is installed [OK]
  - osbdetweb: Module is installed [OK]
  - mariadb: Module is installed [OK]
  - foundation: Module is installed [OK]
  - kestra: Module is installed [OK]
  - kafka3: Module is installed [OK]
  - minio: Module is installed [OK]
  - mongodb8: Module is installed [OK]
```
### Building modules
The `build` option tells OSBDET to install the modules provided as arguments:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh build mariadb
Building some modules into OSBDET:
[install_module] Skipping 'foundation'  module is already installed
  Installing module 'mariadb' ... [Done]
```
### Removing modules
The `remove` option tells OSBDET to remove the modules provided as arguments:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh remove mariadb
Removing modules from OSBDET:
  Uninstalling module 'mariadb' ... [Done]
```
### Cooking recipes
The `cook` option tells OSBDET to 'cook' some recipes on the OSBDET environment:
```
root@osbdet:~/osbdet# ./osbdet_builder.sh cook helloworld
Cooking some recipes for OSBDET:
This is the helloworld recipe!
If you manage to see this message, it means that the recipe was properly cooked on your OSBDET environment.
```
## Some recommendations
Bear in mind that **you're dealing with an undersized Big Data environment**, and you should only start those frameworks you're going to use and keep the rest stopped to have enough hardware resources. Regarding the hardware specifications:
- *2 modern CPUs/vCPUS* are recommended to have decent performance.
- *4GB is the minimun amount of RAM* to make some frameworks work together (ex. NiFi + Hadoop, Hadoop + Spark, ...)
- If you're going to install all the frameworks (default setup I shared with my students), *you should have at least 50GB of free space* to comfortably work with the environment. Even though you can make it work with less disk space, you'll run out of disk space very quickly as soon as you start adding jobs and datasets to play around with.
The following table outlines the different frameworks TCP ports, and the TCP port mapping I usually configure in virtual environments:

   |**Framework/Tool** |**Original TCP port** |**Mapped TCP port**   |
   |-------------------|----------------------|----------------------|
   |SSH server         |22                    |2222                  |
   |Next.js Web App    |2024                  |2025                  |
   |Jupyter Notebook   |8888                  |28888                 |
   |HDFS UI            |50070                 |50070                 |
   |HDFS Data Node     |50075                 |50075                 |
   |YARN UI            |8088                  |28088                 |
   |NiFi UI            |9090                  |29090                 |
   |Spark UI           |4040                  |24040                 |
   |Superset UI        |8880                  |28880                 |
   |MinIO Console      |9001                  |29001                 |
   |Kestra UI          |8080                  |28080                 |
   |Grafana UI         |3000                  |23000                 |
   |Open Metadata UI   |8585                  |28585                 |

