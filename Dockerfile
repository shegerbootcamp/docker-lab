# Use the official Ubuntu base image
FROM ubuntu:20.04

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Update package list and install necessary packages
RUN apt-get update && apt-get install -y \
    openjdk-11-jdk \
    maven \
    wget \
    curl \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set JAVA_HOME environment variable
ENV JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64

# Verify JAVA_HOME and Java version
RUN echo "JAVA_HOME is set to $JAVA_HOME" \
    && java -version \
    && mvn -version

# Set the working directory
WORKDIR /app

# Copy the Maven project into the image
COPY ./petclinic-app /app

# Build the Maven project, skipping tests
RUN mvn clean install -DskipTests=true

# Expose the port that the application will run on
EXPOSE 8181

# Set the command to run the application
ENTRYPOINT ["java", "-jar", "/app/target/spring-petclinic-2.2.0.BUILD-SNAPSHOT.jar", "--server.port=8181"]