#!/bin/bash
dbhost=$1
dbuser=$2
dbpass=$3

cat <<EOT >> Dockerfile
FROM ubuntu

RUN apt-get update

RUN apt-get install -y software-properties-common

# Install Java.
RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# Define working directory.
WORKDIR /data

# Define commonly used JAVA_HOME variable
ENV JAVA_HOME /usr/lib/jvm/java-8-oracle

ENV DATASOURCE_URL jdbc:postgresql://$dbhost:5432/improving
ENV DATASOURCE_USERNAME $dbuser
ENV DATASOURCE_PASSWORD $dbpass

COPY acesso.jar .
COPY start-script.sh .
RUN chmod +x start-script.sh

ENTRYPOINT ["./start-script.sh"]

EOT