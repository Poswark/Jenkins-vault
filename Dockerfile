FROM jenkins/jenkins:2.479.1-lts-jdk21

USER root

COPY plugins.txt /usr/share/jenkins/plugins.txt

#COPY certs/server-cert.crt /usr/local/share/ca-certificates/server-cert.crt


RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --no-install-recommends \
    wget \
    curl \
    jq \
    python3-dev \
    python3-distutils \
    python3-pip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* 
    # Actualizar los certificados del sistema
    # update-ca-certificates && \
    # keytool -importcert -noprompt -trustcacerts -alias server-cert \
    #         -file /usr/local/share/ca-certificates/server-cert.crt \
    #         -keystore $JAVA_HOME/lib/security/cacerts -storepass changeit

RUN pip3 install pyyaml --break-system-packages

RUN jenkins-plugin-cli --plugin-file /usr/share/jenkins/plugins.txt

USER jenkins
