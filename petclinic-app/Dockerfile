# Alpine Linux with OpenJDK JRE
FROM openjdk:8-jre-alpine

EXPOSE 8081

# copy jar into image
COPY target/spring-petclinic-2.2.0.BUILD-SNAPSHOT.jar /usr/bin/spring-petclinic-2.2.0.BUILD-SNAPSHOT.jar

# run application with this command line 
ENTRYPOINT ["java","-jar","/usr/bin/spring-petclinic-2.2.0.BUILD-SNAPSHOT.jar", "--server.port=8081"]