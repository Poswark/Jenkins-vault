#!/bin/bash 

apt-get update

apt-get install -yq \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
    
    
curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

add-apt-repository \
   "deb [arch=aarch64 signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/debian \
   bookworm stable" 
   tee /etc/apt/sources.list.d/docker.list > /dev/null
   
   
apt-get update

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin


# Add jenkins user to docker group

usermod -aG docker jenkins