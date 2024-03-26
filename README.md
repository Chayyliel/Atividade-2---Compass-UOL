<h1 align="center"> Atividade 2 - DOCKER </h1>

# Índice

* [Objetivos](#objetivos)
* [Documentação](#-documenta%C3%A7%C3%A3o-)
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
