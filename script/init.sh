#!/bin/ash

php-fpm 
h2o -m daemon -c /root/h2o.conf &
mysql_install_db --datadir=/var/lib/mysql --user=mysql
su mysql -s /bin/ash -c "mysqld &"
while :
do
	netstat -apn | grep 3306 > /dev/null
	if [ $? -eq 0 ]; then
		break
	fi
	sleep 1
done
mysql -u root < /root/init.sql
su cowrie -s /bin/ash -c "cd /opt/cowrie && ./start.sh"
