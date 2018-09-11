#!/bin/bash

dbuser="improving"
dbpass="seg54g34gn"

secgroup=$(aws ec2 create-security-group --group-name improving-sg --description "improving sec-group" --output text)
echo "Criado security group $secgroup."

secgroupOwner=$(aws ec2 describe-security-groups --group-names improving-sg --query 'SecurityGroups[0].OwnerId' --output text)

aws ec2 authorize-security-group-ingress --group-name default --protocol tcp --port 5432 --source-group improving-sg
aws ec2 authorize-security-group-ingress --group-name improving-sg --protocol tcp --port 9095 --cidr 0.0.0.0/0
aws ec2 authorize-security-group-ingress --group-name improving-sg --protocol tcp --port 22 --cidr 0.0.0.0/0
echo "Liberada conexao ssh para o security group $secgroup."

rm -rf improving-key.pem
aws ec2 create-key-pair --key-name improving-key --query 'KeyMaterial' --output text > improving-key.pem
chmod 400 improving-key.pem
echo "Criada chave improving-key.pem."

instanceid=$(aws ec2 run-instances --image-id ami-0bdb828fd58c52235 --security-group-ids $secgroup --count 1 --instance-type t2.micro --key-name improving-key --query 'Instances[0].InstanceId' --output text --user-data file://initial-setup.sh)
echo "Criada instancia $instanceid."

echo "Esperando 5 min pra maquina subir e rodar o script inicial..."
sleep 300

instanceip=$(aws ec2 describe-instances --instance-ids $instanceid --query 'Reservations[0].Instances[0].PublicIpAddress' --output text)
echo "Ip da maquina: $instanceip."

echo "Copiando banco para a maquina..."
scp -i improving-key.pem acesso_init.sql ec2-user@$instanceip:~/

echo "Copiando app para a maquina..."
scp -i improving-key.pem acesso.jar ec2-user@$instanceip:~/

echo "Criando instancia RDS..."
aws rds create-db-instance --db-instance-identifier improving-db \
--allocated-storage 10 --db-instance-class db.t2.micro --engine postgres \
--master-username $dbuser --master-user-password $dbpass --engine-version "9.6.3" > /dev/null

echo "Esperando 10 min pro db subir..."
sleep 600

dbhost=$(aws rds describe-db-instances --query "DBInstances[0].Endpoint.Address" --output text)
echo "Endpoint do DB: $dbhost."

### Tive que alterar pelo aws console o security group default para permitir que a instancia ec2 pudesse acessar o banco
### Tambem tive que popular o banco usando o pgAdmin, pois nao consegui automatizar essa tarefa

rm -rf Dockerfile
echo "Criando dockerfile..."
./create-dockerfile.sh $dbhost $dbuser $dbpass

echo "Copiando Dockerfile para a maquina..."
scp -i improving-key.pem Dockerfile ec2-user@$instanceip:~/

# Permitir que o ec2-user rode comandos docker
ssh -i improving-key.pem ec2-user@$instanceip "sudo usermod -a -G docker ec2-user"

echo "Fazendo build da imagem..."
ssh -i improving-key.pem ec2-user@$instanceip "docker build -t improvingapp:v1 ."

echo "Rodando app..."
ssh -i improving-key.pem ec2-user@$instanceip "docker run -d -it --rm --name improving-run improvingapp:v1"
