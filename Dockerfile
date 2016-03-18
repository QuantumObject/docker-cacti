#name of container: docker-cacti
#version of container: 0.5.6
FROM quantumobject/docker-baseimage:15.10
MAINTAINER Angel Rodriguez  "angel@quantumobject.com"

#add repository and update the container
#Installation of nesesary package/software for this containers...
RUN rm /bin/sh && ln -s /bin/bash /bin/sh
RUN echo "deb http://archive.ubuntu.com/ubuntu `. /etc/lsb-release; echo ${DISTRIB_CODENAME/*, /}`-backports main restricted " >> /etc/apt/sources.list
RUN echo "deb http://archive.ubuntu.com/ubuntu/ `. /etc/lsb-release; echo ${DISTRIB_CODENAME/*, /}` multiverse " >> /etc/apt/sources.list
RUN apt-get update && DEBIAN_FRONTEND=noninteractive apt-get install -yq  build-essential \ 
                                                            cacti \
                                                            snmpd \
                                                            cacti-spine \
                                                            python-netsnmp \		
                                                            libnet-snmp-perl \		
                                                            snmp-mibs-downloader \
                    && mysql_install_db > /dev/null 2>&1 \ 
                    && touch /var/lib/mysql/.EMPTY_DB \
                    && apt-get clean \
                    && rm -rf /tmp/* /var/tmp/*  \
                    && rm -rf /var/lib/apt/lists/*

# Ensure cron is allowed to run
RUN sed -i 's/^\(session\s\+required\s\+pam_loginuid\.so.*$\)/# \1/g' /etc/pam.d/cron

##startup scripts  
#Pre-config scrip that maybe need to be run one time only when the container run the first time .. using a flag to don't 
#run it again ... use for conf for service ... when run the first time ...
RUN mkdir -p /etc/my_init.d
COPY startup.sh /etc/my_init.d/startup.sh
RUN chmod +x /etc/my_init.d/startup.sh

##Adding Deamons to containers
# to add apache2 deamon to runit
RUN mkdir /etc/service/apache2
COPY apache2.sh /etc/service/apache2/run
RUN chmod +x /etc/service/apache2/run

# to add mysqld deamon to runit
RUN mkdir /etc/service/mysqld
COPY mysqld.sh /etc/service/mysqld/run
RUN chmod +x /etc/service/mysqld/run

# to add mysqld deamon to runit
RUN mkdir /etc/service/snmpd
COPY snmpd.sh /etc/service/snmpd/run
RUN chmod +x /etc/service/snmpd/run

#pre-config scritp for different service that need to be run when container image is create 
#maybe include additional software that need to be installed ... with some service running ... like example mysqld
COPY pre-conf.sh /sbin/pre-conf
RUN chmod +x /sbin/pre-conf ; sync \
    && /bin/bash -c /sbin/pre-conf \
    && rm /sbin/pre-conf

##scritp that can be running from the outside using docker-bash tool ...
## for example to create backup for database with convitation of VOLUME   dockers-bash container_ID backup_mysql
COPY backup.sh /sbin/backup
COPY restore.sh /sbin/restore
RUN chmod +x /sbin/backup /sbin/restore
VOLUME /var/backups


#add files and script that need to be use for this container
#include conf file relate to service/daemon 
#additionsl tools to be use internally 
COPY snmpd.conf /etc/snmp/snmpd.conf 
COPY cacti.conf /etc/dbconfig-common/cacti.conf
COPY debian.conf /etc/cacti/debian.php
COPY spine.conf /etc/cacti/spine.conf

# to allow access from outside of the container  to the container service
# at that ports need to allow access from firewall if need to access it outside of the server. 
EXPOSE 80 161

# Use baseimage-docker's init system.
CMD ["/sbin/my_init"]
