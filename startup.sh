#!/bin/bash

set -e

#check if already configured or not
if [ -f /etc/configured ]; then
        echo 'already configured'
else
    #code that need to run only one time ....
    
    #in case Volume are empty
    if [ "$(ls -A /var/lib/mysql)" ]; then
     echo "mysql folder with data"    
    else
     cp -Rp /var/backup/mysql/. /var/lib/mysql/ 
     chown mysql:mysql /var/lib/mysql
    fi

    if [ "$(ls -A /opt/cacti/plugins)" ]; then
        echo "plugins folder with data"
    else
     cp -Rp /var/backup/plugins/. /opt/cacti/plugins/
     chown www-data:www-data /opt/cacti/plugins
    fi

    if [ -d /var/log/snmpd ]; then
     echo "log folder with data"
    else
     cp -Rp /var/backup/log/. /var/log/    
    fi
        #to fix problem with data.timezone that appear at 1.28.108 for some reason
        sed  -i "s|\;date.timezone =|date.timezone = \"${TZ:-America/New_York}\"|" /etc/php/7.2/apache2/php.ini
        sed  -i "s|\;date.timezone =|date.timezone = \"${TZ:-America/New_York}\"|" /etc/php/7.2/cli/php.ini
        sed  -i 's!memory_limit = 128M!memory_limit = 512M!' /etc/php/7.2/apache2/php.ini
        sed  -i 's!max_execution_time = 30!max_execution_time = 60!' /etc/php/7.2/apache2/php.ini
        echo 'default-time-zone = '$TZ >> /etc/mysql/my.cnf
        #needed for fix problem with ubuntu and cron
        update-locale 
        date > /etc/configured
fi
