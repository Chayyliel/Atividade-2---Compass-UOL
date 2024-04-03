<h1 align="center"> Atividade 2 - DOCKER </h1>

# Índice

* [Objetivos](#objetivos)
* [Documentação](#-documenta%C3%A7%C3%A3o-)
* [Criação da VPC (Virtual Private Cloud)](#criação-da-vpc-virtual-private-cloud)
* [Criação dos SG (Security Groups)](#criação-dos-sg-security-groups)
* [Criação do EP (EndPoint)](#criação-do-ep-endpoint)
* [Criação do RDS (Relational Database Service)](#criação-do-rds-relational-database-service)
* [Criação do EFS (Elastic File System)](#criação-do-efs-elastic-file-system)
* [Criação do template da EC2 (Elastic Compute Cloud)](#criação-do-template-da-ec2-elastic-compute-cloud)
* [Criação do LB (Load Balancer)](#criação-do-lb-load-balancer)
* [Criação do AS (Auto Scaling)](#criação-do-as-auto-scaling)
#
# Objetivos
- Instalação e configuração do DOCKER ou CONTAINERD no host EC2;
     (Ponto adicional para o trabalho utilizar a instalação via script de Start Instance (user_data.sh))
- Efetuar Deploy de uma aplicação Wordpress com:
     Container de aplicação;
     RDS database Mysql;
- Configuração da utilização do serviço EFS AWS para estáticos do container de aplicação Wordpress;
- Configuração do serviço de Load Balancer AWS para a aplicação Wordpress;

> [!CAUTION]
> - Não utilizar ip público para saída do serviços WP (Evitem publicar o serviço WP via IP Público);
> - Sugestão para o tráfego de internet sair pelo LB (Load Balancer Classic);
> - Pastas públicas e estáticos do wordpress sugestão de utilizar o EFS (Elastic File Sistem);
> - Fica a critério de cada integrante usar Dockerfile ou Dockercompose;
> - Necessário demonstrar a aplicação wordpress funcionando (tela de login);
> - Aplicação Wordpress precisa estar rodando na porta 80 ou 8080;
> - Utilizar repositório git para versionamento;
> - Criar documentação.

#
<h1 align="center"> DOCUMENTAÇÃO </h1>

## Criação da VPC (Virtual Private Cloud)
- Acessar o serviço de VPC e na paginá inicial entrar em "Create VPC".
- Na aba de criação deixamos a maioria das opções no padrão, VPC and more, 2 AZs, 2 Public subnets, 2 Private subnets, mudando apenas o nome, se quiser, e alterando o NAT gateway para "1 per AZ".

![Route Table](https://github.com/Chayyliel/Atividade-2---Compass-UOL/assets/142858638/12588d60-b0e3-4434-addc-9695bd473a39)

#
## Criação dos SG (Security Groups)
- Acessar o serviço de EC2, na aba lateral ir ate o grupo "Network & Security" e selecionar "Security Groups".
- Na parte superior direita acessar "Create security group".
- Criaremos o seguintes grupos:

**SG-PUBLIC**
| Tipo  | Protocolo | Porta | Origem    |
|-------|-----------|-------|-----------|
| HTTP  | TCP       | 80    | 0.0.0.0/0 |
| HTTPS | TCP       | 443   | 0.0.0.0/0 |
#
**SG-PRIVATE**
| Tipo  | Protocolo | Porta | Origem    |
|-------|-----------|-------|-----------|
| SSH   | TCP       | 22    | SG-PUBLIC |
| HTTP  | TCP       | 80    | SG-PUBLIC |
| HTTPS | TCP       | 443   | SG-PUBLIC |
#
**SG-EFS**
| Tipo  | Protocolo | Porta | Origem     |
|-------|-----------|-------|------------|
| NFS   | TCP       | 2049  | SG-PRIVATE |
#
**SG-RDS**
| Tipo          | Protocolo | Porta | Origem     |
|---------------|-----------|-------|------------|
| MYSQL/AURORA  | TCP       | 3306  | SG-PRIVATE |
#
## Criação do EP (EndPoint)
- Acessar o serviço de VPC e no menu lateral ir ate "Virtual private cloud" e acessar Endpoint.
- No canto superior direito acessar "Create endpoint".
- De um nome, se quiser, e selecione "EC2 Instance Connect Endpoint".
- Selecione a VPC cirada anteriormente, em Security group selecione a SG pública e por fim uma subnet privada.
#
## Criação do RDS (Relational Database Service)
- Acessar o serviço do RDS e na página inicial acessar "Create database".
- Deixar padrão exceto:
  - "Engine options" = MySQL
  - "Templates" = Free tier
  - "Settings" = Mudar "DB cluster identifier" e "Master username" para um de sua preferência, selecionar "Self Managed" e criar um "Master password".
  - "Connectivity" = Selecionar a VPC e o SG que criou para o RDS.
#
## Criação do EFS (Elastic File System)
- Acessar o serviço EFS e na página inicial acessar "Create a file system".
- Acesse "Customize" no final da página.
- Criar um nome, se quiser, em "Network access" selecionar a VPC criada anteriormente, as subnets privadas e o SG criado para o EFS.
#
## Criação do template da EC2 (Elastic Compute Cloud)
- Acessar o serviço EC2 e na aba lateral ir no grupo "instances" e selecionar "Launch Templates".
- Na página inicial acessar "Create launch template".
- Daremos o nome ao template, uma descrição e escolheremos as seguintes opções:
  - "OS Images" = Amazon Linux 2;
  - "Instance type" = t3.micro;
  - Criar uma "Key Pair" e salvar;
  - "Network settings > Subnet" = Don't include in launch template;
    - "Network settings > Firewall" = Select existing security group;
      - "Network settings > Security groups" = Selecionar o SG-PRIVATE.
  - "Storage" = Adicionar novo volume Size = 8 Volume type = gp2;
  - "Resource tags" = Adiconar as tags do PB da Compass;
  - "Advanced details" = Adicionar um User data com as seguintes configurações:
    - ```bash
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
              image: wordpress:latest
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
                WORDPRESS_TABLE_CONFIG: wp_ | sudo tee /mnt/efs/docker-compose.yaml
      
          docker-compose -f /mnt/efs/docker-compose.yaml up -d
      ```
#
## Criação do LB (Load Balancer)
- Acessar o serviço EC2, no menu lateral ir até "Load Balancing" e acessar "Load Balancers".
- No canto superior direito acesse "Create load balancer".
- Selecione o "Classic Load Balancer".
- De um nome ao LB e escolha as seguintes opções:
  - Selecione a VPC criada anteriormente;
  - Em "Mappings" selecione as duas AZs e selecione as duas subnets públicas;
  - Selecione o SG Público criado anteriormente;
  - Em "Listeners and routing" adicione um listener com protocolo tcp e porta 22;
  - Em "Health check" altere para tcp e porta 22;
  - Crie a LB.
#
## Criação do AS (Auto Scaling)
- Acessar o serviço EC2, no menu lateral ir até "Auto Scaling" e acessar "Auto Scaling group".
- Na página inicial acessar "Create Auto Scaling group".
- Em "Choose lauch template" de um nome ao AS e selecione o template de EC2 criado anteriormente.
- Em "Choose instance lauch options" seleciopne a VPC criada e as duas subnets privadas. 
- Em "Configuere advanced options" selecione "Attach to an existing load balancer" e selecione o LB criado.
- Selecione "Turn on Elastic Load Balancing health checks".
- Em "Scaling":
  - "Scaling limits" = Min 2 - Max 4
  - "Automatic scaling" = "Target tracking scaling policy"
  - "Target value" = 80
