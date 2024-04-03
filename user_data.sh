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
sudo mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport <id-efs>.efs.us-east-1.amazonaws.com:/ mnt/efs
sudo sh -c 'echo "<id-efs>.efs.us-east-1.amazonaws.com:/ mnt/efs nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab'
sudo usermod -aG docker ec2-user
sudo chmod 666 /var/run/docker.sock

services:
  wordpress:
    image: Wordpress:latest
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: <Endpoint DB>
      WORDPRESS_DB_USER: <Master user DB>
      WORDPRESS_DB_PASSWORD: <Master password DB>
      WORDPRESS_DB_NAME: <Name DB>
      WORDPRESS_TABLE_CONFIG: wp_" | sudo tee /mnt/efs/docker-compose.yaml
cd /mnt/efs && sudo docker-compose up -d
