FROM jenkins/jenkins:lts

USER root

# Instalar paquetes adicionales
RUN apt-get update \
    && apt-get install -y wget curl sudo\
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
    
RUN jenkins-plugin-cli --plugins kubernetes workflow-aggregator git configuration-as-code

# Instalar Docker
RUN curl -fsSL https://get.docker.com -o get-docker.sh \
    && sh get-docker.sh \
    && usermod -aG docker jenkins

USER jenkins
