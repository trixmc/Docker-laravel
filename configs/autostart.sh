#!/bin/bash
service ssh start
service memcached start
service supervisor start
service php7.3-fpm start
service nginx start
