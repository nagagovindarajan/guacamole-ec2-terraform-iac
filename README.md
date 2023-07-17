##Guacamole Terraform IAC

Secure Infrastructre of Apache Guacamole in AWS t2.micro ec2 with Auto stop/start with Lambda, Cloudwatch, VPCFlowlogs

#######DB Scripts#########
mysql -u root -p
mysql -h mariadb.awscname.ap-southeast-1.rds.amazonaws.com -P 3306 -u root -p

CREATE DATABASE guacamole_db;
CREATE USER 'guacamole_user' IDENTIFIED BY 'ChangeIt';
GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user';
FLUSH PRIVILEGES;

cd /home/ubuntu/guacamole-server-1.5.2/guacamole-auth-jdbc-1.5.2/mysql/schema
cat *.sql | mysql -h mariadb.awscname.ap-southeast-1.rds.amazonaws.com -P 3306 -u root -p guacamole_db

systemctl restart tomcat9 guacd mysql