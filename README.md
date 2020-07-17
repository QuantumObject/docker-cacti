# docker-cacti

Docker container for [cacti 1.2.12][3]

"Cacti is a complete network graphing solution designed to harness the power of [RRDTool's][6] data storage and graphing functionality. Cacti provides a fast poller, advanced graph templating, multiple data acquisition methods, and user management features out of the box. All of this is wrapped in an intuitive, easy to use interface that makes sense for LAN-sized installations up to complex networks with hundreds of devices."

## Install dependencies

  - [Docker][2]

To install docker in Ubuntu 18.04 use the commands:

    $ sudo apt-get update
    $ sudo wget -qO- https://get.docker.com/ | sh

 To install docker in other operating systems check [docker online documentation][4]

## Usage

To run container use the command below:

    $ docker run -d -p 80  quantumobject/docker-cacti

** -p 161:161  ==> remove to make sure you can monitor container and server running the container , this second more important to be able to monitoring all network interface of the server.

## Set the timezone per environment variable:

    -e TZ=Europe/London
  
or in yml:

  environment:
  
     - TZ=Europe/London
   
Default value is America/New_York . 

# Added Volume for peristent data :

  /opt/cacti/plugins
  
  /var/log
  
  /opt/cacti/templates
  
  /var/lib/mysql
  
  /rra

## Accessing the Cacti applications:

After that check with your browser at addresses plus the port assigined by docker:

  - **http://host_ip:port/cacti/**

Them you can log-in admin/admin, Please change the password and when installing double check the path to Spine binary that suppose to be /usr/local/spine/bin/spine. 

## Configuring Spine :

Go to Configuration -> Settings and click on the Paths tab.

Under the Alternate Poller Path, set the following:


    Spine Binary File Location = /usr/local/spine/bin/spine
    Spine Config File Path = /usr/local/spine/etc/spine.conf

Click Save at the bottom right.

Last is to make spine the active poller. Switch to the Poller tab and click on the drop down menu for Poller Type.Select spine and click save in the bottom right.


## To install plugins on cacti :

To access the container from the server that the container is running

     $ docker exec -it container_id /bin/bash

change directory to plugins directory of the cacti  

     $ cd /opt/cacti/plugins

download and unpack plugins

     $ wget https://github.com/Cacti/plugin_flowview/archive/develop.zip
     $ unzip develop.zip
     $ mkdir -p /var/netflow/flows/completed
     $ chmod 777 /var/netflow/flows/completed

and them access to cacti console/plugin management and install it and enable it. This is only for an example, to install and configured flowview you need to check its documentation.  [https://github.com/Cacti/plugin_flowview/blob/develop/README.md][8]

## More Info

About Cacti [www.cacti.net][1]

To help improve this container [quantumobject/docker-cacti][5]

For additional info about us and our projects check our site [www.quantumobject.org][7]

[1]:http://www.cacti.net/
[2]:https://www.docker.com
[3]:http://www.cacti.net/
[4]:http://docs.docker.com
[5]:https://github.com/QuantumObject/docker-cacti
[6]:http://oss.oetiker.ch/rrdtool
[7]:https://www.quantumobject.org/
[8]:https://github.com/Cacti/plugin_flowview/blob/develop/README.md
