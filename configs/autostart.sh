#!/bin/bash
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
service ssh start
service mysql start
service memcached start
service supervisor start
service php7.1-fpm start
service nginx start
