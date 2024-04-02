#!/bin/bash
sudo su
yum update -y
yum install docker -y
systemctl start docker
systemctl enable docker
usermod -aG docker ec2-user
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose
mv /usr/local/bin/docker-compose /bin/docker-compose
yum install nfs-utils -y
mkdir /mnt/efs/
chmod +rwx /mnt/efs/
mount -t nfs4 -o nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport <id_do_efs>.efs.<região_de_montagem_do_efs>.amazonaws.com:/ <diretorio_de_montagem_do_nfs>
echo "<id_do_efs>.efs.<região_de_montagem_do_efs>.amazonaws.com:/ <diretorio_de_montagem_do_nfs> nfs defaults 0 0" >> /etc/fstab

echo "version: '3.8'
services:
  wordpress:
    image: wordpress:lastest
    volumes:
      - /mnt/efs/wordpress:/var/www/html
    ports:
      - 80:80
    restart: always
    environment:
      WORDPRESS_DB_HOST: atividade2.cpiskoe4u286.us-east-1.rds.amazonaws.com
      WORDPRESS_DB_USER: atividade2
      WORDPRESS_DB_PASSWORD: 123teste456
      WORDPRESS_DB_NAME: atividade2
      WORDPRESS_TABLE_CONFIG: wp_" | sudo tee /mnt/efs/docker-compose.yml 
cd /mnt/efs && sudo docker-compose up -d
