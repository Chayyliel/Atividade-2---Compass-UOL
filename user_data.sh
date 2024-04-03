#!/bin/bash
sudo yum update -y
sudo yum install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo mkdir /mnt/efs
sudo chmod +rwx /mnt/efs
sudo yum install amazon-efs-utils -y
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport fs-05f757969c22d65b4.efs.us-east-1.amazonaws.com:/ mnt/efs
sudo sh -c 'echo "fs-05f757969c22d65b4.efs.us-east-1.amazonaws.com:/ mnt/efs nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab'
sudo usermod -aG docker ec2-user
sudo chmod 666 /var/run/docker.sock

cat <<EOL > /mnt/efs/docker-compose.yml
version: '3.8'
services:
  wordpress:
    image: wordpress:latest
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: atv2.cpiskoe4u286.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: admin
      WORDPRESS_DB_PASSWORD: teste123
      WORDPRESS_DB_NAME: atv2
      WORDPRESS_TABLE_CONFIG: wp_
EOL

docker-compose -f /mnt/efs/docker-compose.yml up -d
