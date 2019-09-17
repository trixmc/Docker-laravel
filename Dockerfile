FROM      ubuntu:18.04
MAINTAINER Olexander Vdovychenko  <farmazin@gmail.com>

#Create docker user
RUN mkdir -p /var/www
RUN mkdir -p /home/docker
RUN useradd -d /home/docker -s /bin/bash -M -N -G www-data,sudo,root docker
RUN echo docker:docker | chpasswd
RUN usermod -G www-data,users www-data
RUN chown -R docker:www-data /var/www
RUN chown -R docker:www-data /home/docker

#install Software
RUN apt-get update && apt-get upgrade -y
RUN apt-get install -y git git-core vim nano mc nginx screen curl unzip wget software-properties-common
RUN apt-get install -y supervisor memcached htop tmux zip
COPY configs/supervisor/cron.conf /etc/supervisor/conf.d/cron.conf
COPY configs/nginx/default /etc/nginx/sites-available/default

#Install PHP
RUN apt-get install -y language-pack-en-base
RUN add-apt-repository ppa:ondrej/php
RUN apt-get update
ENV TZ=Europe/Kiev
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y php7.2 php7.2-cli php7.2-common php-cgi php-curl php-imap php-pgsql
RUN apt-get install -y php-sqlite3 php-mysql php-fpm php-intl php-gd php-json
RUN apt-get install -y php-memcached php-memcache php-imagick php-xml php-mbstring php7.2-ctype
#RUN rm /etc/php/7.2/cgi/php.ini
#RUN rm /etc/php/7.2/cli/php.ini
#RUN rm /etc/php/7.2/fpm/php.ini
#RUN rm /etc/php/7.2/fpm/pool.d/www.conf
COPY configs/php/www.conf /etc/php/7.2/fpm/pool.d/www.conf
COPY configs/php/php.ini  /etc/php/7.2/cgi/php.ini
COPY configs/php/php.ini  /etc/php/7.2/cli/php.ini
COPY configs/php/php.ini  /etc/php/7.2/fpm/php.ini
COPY configs/php/xdebug.ini /etc/php/7.2/mods-available/xdebug.ini

#Install Percona Mysql 5.6 server
#RUN wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb
#RUN dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
#RUN apt-get update
#RUN echo "percona-server-server-5.7 percona-server-server/root_password password root" | sudo debconf-set-selections
#RUN echo "percona-server-server-5.7 percona-server-server/root_password_again password root" | sudo debconf-set-selections
#RUN apt-get install -y --allow-unauthenticated percona-server-server-5.7
#COPY configs/mysql/my.cnf /etc/mysql/my.cnf
#RUN chown -R mysql:mysql /var/lib/mysql /var/run/mysqld

# SSH service
RUN apt-get install -y openssh-server openssh-client
RUN mkdir /var/run/sshd
RUN echo 'root:root' | chpasswd
#change 'pass' to your secret password
RUN sed -i 's/PermitRootLogin without-password/PermitRootLogin yes/' /etc/ssh/sshd_config
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

#configs bash start
COPY configs/autostart.sh /root/autostart.sh
RUN  chmod +x /root/autostart.sh
COPY configs/bash.bashrc /etc/bash.bashrc
COPY configs/.bashrc /root/.bashrc
COPY configs/.bashrc /home/docker/.bashrc

#Install locale
RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales


#Composer
RUN cd /home
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin/ --filename=composer
RUN chmod 777 /usr/local/bin/composer

#Code standart
RUN composer global require "squizlabs/php_codesniffer=*"
RUN composer global require "sebastian/phpcpd=*"
RUN composer global require "phpmd/phpmd=@stable"
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpcpd
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpmd
RUN cd /usr/bin && ln -s ~/.composer/vendor/bin/phpcs

#open ports
EXPOSE 80 22
