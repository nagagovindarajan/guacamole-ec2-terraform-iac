#!/bin/bash
#includedir /etc/sudoers.d
exec > /var/log/user-data.log 2>&1
set -ex 
# export guacamole_version=1.5.2
cd /home/ubuntu

echo "ubuntu ALL=(ALL) NOPASSWD:ALL" | tee /etc/sudoers.d/ubuntu
chmod 0440 /etc/sudoers.d/ubuntu

echo "installing prerequesties.."
apt install build-essential libcairo2-dev libjpeg-turbo8-dev \
    libpng-dev libtool-bin libossp-uuid-dev libvncserver-dev \
    freerdp2-dev libssh2-1-dev libtelnet-dev libwebsockets-dev \
    libpulse-dev libvorbis-dev libwebp-dev libssl-dev \
    libpango1.0-dev libswscale-dev libavcodec-dev libavutil-dev \
    libavformat-dev -y

echo "Downloading and installing guacamole server.."
wget https://downloads.apache.org/guacamole/${guacamole_version}/source/guacamole-server-${guacamole_version}.tar.gz
tar -xvf guacamole-server-${guacamole_version}.tar.gz
cd guacamole-server-${guacamole_version}
./configure --with-init-dir=/etc/init.d --enable-allow-freerdp-snapshots
make
make install

ldconfig
systemctl daemon-reload
systemctl start guacd
systemctl enable guacd

echo "Downloading and installing tomacat server.."
mkdir -p /etc/guacamole/{extensions,lib}
apt install tomcat9 tomcat9-admin tomcat9-common tomcat9-user --no-install-recommends -y
wget https://downloads.apache.org/guacamole/${guacamole_version}/binary/guacamole-${guacamole_version}.war
mv guacamole-${guacamole_version}.war /var/lib/tomcat9/webapps/guacamole.war
systemctl restart tomcat9 guacd

echo "Configuring DB coonnection.."
# apt install mariadb-server
# mysql_secure_installation
wget https://repo1.maven.org/maven2/com/mysql/mysql-connector-j/8.0.31/mysql-connector-j-8.0.31.jar
cp mysql-connector-j-8.0.31.jar /etc/guacamole/lib/

# Download the JDBC auth plugin for Apache Guacamole. This file can be found on http://guacamole.apache.org/releases/ by selecting the release version and then locate the “jdbc” file.
wget https://downloads.apache.org/guacamole/${guacamole_version}/binary/guacamole-auth-jdbc-${guacamole_version}.tar.gz
tar -xf guacamole-auth-jdbc-${guacamole_version}.tar.gz
mv guacamole-auth-jdbc-${guacamole_version}/mysql/guacamole-auth-jdbc-mysql-${guacamole_version}.jar /etc/guacamole/extensions/

echo "Update guacamole properties.."
#  MySQL properties
bash -c 'echo "mysql-hostname: mariadb.awscname.ap-southeast-1.rds.amazonaws.com" >> /etc/guacamole/guacamole.properties' # MariaDb Url
bash -c 'echo "mysql-port: 3306" >> /etc/guacamole/guacamole.properties'
bash -c 'echo "mysql-database: guacamole_db" >> /etc/guacamole/guacamole.properties'
bash -c 'echo "mysql-username: guacamole_user" >> /etc/guacamole/guacamole.properties'
bash -c 'echo "mysql-password: {DBPassword}" >> /etc/guacamole/guacamole.properties' # DB password 

echo "Restart services.."
systemctl restart tomcat9 guacd

echo "Configuring cloudwatch.."
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb
dpkg -i -E ./amazon-cloudwatch-agent.deb

echo '{
    "agent": {
        "run_as_user": "root"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/syslog",
                        "log_group_name": "guacamole-log",
                        "log_stream_name": "{instance_id}-syslog",
                        "timestamp_format": "%Y-%m-%d %H:%M:%S"
                    },
                    {
                        "file_path": "/var/log/auth.log",
                        "log_group_name": "guacamole-log",
                        "log_stream_name": "{instance_id}-auth",
                        "timestamp_format": "%Y-%m-%d %H:%M:%S"
                    },
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "guacamole-log",
                        "log_stream_name": "{instance_id}-user-data",
                        "timestamp_format": "%Y-%m-%d %H:%M:%S"
                    }
                ]
            }
        }
    }
}' > /opt/aws/amazon-cloudwatch-agent/bin/config.json

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status