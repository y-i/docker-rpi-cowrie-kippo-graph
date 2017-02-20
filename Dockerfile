# from alpine linux image for arm
FROM container4armhf/armhf-alpine

COPY script /tmp/script/

# install package
RUN \
 'mkdir -p /opt/cowrie && mkdir -p /var/www/html'
RUN \
 apk update && \
 apk --no-cache add \
 cmake \
 curl \
 curl-dev \
 expat \
 expat-dev \
 git \
 g++ \
 gcc \
 gmp-dev \
 libarchive \
 libarchive-dev \
 libffi-dev \
 make \
 mpc1-dev \
 mpfr-dev \
 mysql \
 mysql-client \
 openssl \
 perl \
 php5 \
 php5-fpm \
 php5-gd \
 php5-mysql \
 py2-asn1 \
 py2-crypto \
 py2-pip \
 python2 \
 python2-dev \
 zlib \
 zlib-dev

# install h2o
RUN \
 cd /tmp && \
 git clone https://github.com/h2o/h2o.git && \
 cd h2o && \
 cmake . && make h2o && make install && \
 rm -rf h2o && \
 mkdir -p /var/log/h2o/ && chmod 777 /var/log/h2o/

# install kippo-graph
RUN \
 git clone https://github.com/ikoniaris/kippo-graph.git && \
 mv kippo-graph /var/www/html/ && \
 chmod 777 /var/www/html/kippo-graph/generated-graphs/ && \
 mv /var/www/html/kippo-graph/config.php.dist /var/www/html/kippo-graph/config.php && \
 sed -e "s/define('DB_USER'.*/define('DB_USER', 'cowrie');/" \
 -e "s/define('DB_PASS'.*/define('DB_PASS', 'cowrie');/" \
 -e "s/define('DB_NAME'.*/define('DB_NAME', 'cowrie');/" \
 -e "s/define('BACK_END_ENGINE'.*/define('BACK_END_ENGINE', 'COWRIE');/" \
 /var/www/html/kippo-graph/config.php

# install cowrie
RUN \
 git clone https://github.com/micheloosterhof/cowrie.git && \
 mv cowrie /opt && \
 cd /opt/cowrie && \
 pip --no-cache-dir install -U -r requirements.txt && \
 mv /tmp/script/cowrie.cfg /opt/cowrie/ && \
 mv /tmp/script/userdb.txt /opt/cowrie/data/ && \
 adduser -s /bin/ash -D cowrie && \
 chown -R cowrie:cowrie /opt/cowrie/*

# initialize sql
RUN \
 mkdir -p /run/mysqld && \
 chown -R mysql:mysql /var/lib/mysql/ && chown mysql:mysql /run/mysqld/

# move scripts
RUN \
 mv /tmp/script/init.sh /tmp/script/h2o.conf /tmp/script/init.sql /root/ && \
 chmod u+x /root/init.sh

VOLUME /opt/cowrie/dl /var/lib/mysql/

EXPOSE 80 2222

ENTRYPOINT /root/init.sh
