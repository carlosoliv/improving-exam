#!/bin/bash

java \
-Dspring.datasource.url=$DATASOURCE_URL \
-Dspring.datasource.username=$DATASOURCE_USERNAME \
-Dspring.datasource.password=$DATASOURCE_PASSWORD \
-jar acesso.jar
