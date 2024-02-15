#!/bin/bash

#Instalacion paquetes necesarios
sudo apt-get update
sudo apt-get install -y curl unzip 

#Instalacion aws cli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

#Iniciamos sesion en AWS Cli
#aws configure (se usan credenciales)

#Instalamos docker
sudo apt-get -y install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg
echo \
  "deb [arch="$(dpkg --print-architecture)" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  "$(. /etc/os-release && echo "$VERSION_CODENAME")" stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

#generamos docker dompose
cat > /home/ubuntu/docker-compose.yml <<EOF
version: "3"
services:
 merge-sort:
  image: elliotmtz12/merge-sort 
  container_name: merge-sort-app
  ports:
   - "${app_port}:3000"
  environment:
   - TZ=America/Tijuana  
  network_mode: bridge
EOF
#desplegamos docker-compose
sudo docker compose -f /home/ubuntu/docker-compose.yml up -d