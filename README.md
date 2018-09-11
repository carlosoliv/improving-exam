### Enunciado da prova

O objetivo desse teste é criar um ambiente na AWS para execução de uma aplicação em container Docker que se comunica com um banco de dados no RDS. Você deverá escrever um script bash para isso, que pode depender de outros arquivos para realizar os passos abaixo.

Para executar a aplicação (acesso.jar - disponibilizado na raiz do repositório) você precisará de uma instância RDS. Seu script deverá criá-la para o Postgres na versão 9.6.3 via API ou PostgreSQL 9.6.3_R1 via interface, que deverá ser do tipo db.t2.micro e executar nessa base o script acesso_init.sql (disponibilizado na raiz do repositório) para criação do esquema do banco de dados. Em seguida, para rodar a aplicação, você precisará criar um container Docker que execute a aplicação usando a instância RDS. Poderá executar o container, *em uma instância EC2 t2.micro* via Docker diretamente, ECS ou EKS. Opcionalmente, poderá usar o Fargate desde que o container consiga ser executado num hardware como de uma EC2 t2.micro.

A aplicação hoje precisa dos seguintes passos para ser executada, que deverão ser abstraídos pela imagem do seu container:

* Instalar o JDK versão 8  (http://www.oracle.com/technetwork/pt/java/javase/downloads/jdk8-downloads-2133151.html);
* Configurar as seguintes variáveis de ambiente conforme exemplo abaixo:
```
#!sh
 
DATASOURCE_URL=jdbc:postgresql://host:port/database
DATASOURCE_USERNAME=postgres
DATASOURCE_PASSWORD=passwdexemplo
```
* Executar o arquivo acesso.jar com o seguinte comando para executar a aplicação: 
```
#!java

java \
-Dspring.datasource.url=$DATASOURCE_URL \
-Dspring.datasource.username=$DATASOURCE_USERNAME \
-Dspring.datasource.password=$DATASOURCE_PASSWORD \
-jar acesso.jar
```


Ao término você deverá fazer o commit no repositório liberado da sua solução contendo o script bash e os demais arquivos necessários para sua execução.

### Regras

* As instâncias criadas devem ter o acesso mais restrito possível, apenas com as permissões necessárias para executar a aplicação.

* O script criado deve ser autossuficiente, ou seja, a prova pode ser feita como você quiser contanto que possa ser executada a partir do bash - você pode instalar o suporte a uma linguagem de programação, por exemplo - e os demais arquivos que você comitar no repositório.

* A sua solução será executada no EC2 t2.micro em uma conta nossa.

* A execução da sua solução em nosso ambiente (note, *não é o prazo de conclusão de prova*) deve finalizar em no máximo 1 hora.

* Exceto pelos serviços AWS mencionados anteriormente e pelo AWS lambda, não é permitido o uso de nenhum outro recurso da AWS.