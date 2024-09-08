# Base image with Ubuntu 24.04 LTS and OpenJDK 21
FROM exoplatform/ubuntu:24.04
LABEL maintainer="eXo Platform <docker@exoplatform.com>"

ENV JDK_MAJOR_VERSION 21

# Install OpenJDK Java 21 SDK
RUN apt-get -qq update && \
    apt-get -qq -y install gnupg ca-certificates curl
RUN curl -s https://repos.azul.com/azul-repo.key | gpg --dearmor -o /usr/share/keyrings/azul.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/azul.gpg] https://repos.azul.com/zulu/deb stable main" | tee /etc/apt/sources.list.d/zulu.list
RUN apt-get -qq update && \
    apt-get -qq -y install zulu${JDK_MAJOR_VERSION}-jdk
RUN apt-get -qq -y autoremove && \
    apt-get -qq -y clean && \
    rm -rf /var/lib/apt/lists/*

# Install Maven 3.9.9
RUN curl -fsSL https://archive.apache.org/dist/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz -o maven.tar.gz && \
    tar -xzf maven.tar.gz -C /opt && \
    rm maven.tar.gz && \
    ln -s /opt/apache-maven-3.9.9 /opt/maven

ENV MAVEN_HOME=/opt/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# Set JAVA_HOME
ENV JAVA_HOME /usr/lib/jvm/zulu${JDK_MAJOR_VERSION}-ca-amd64

# Create Jenkins user and group
RUN groupadd -r jenkins && useradd -r -g jenkins jenkins

# Set the working directory
WORKDIR /home/jenkins/agent/petclinic

# Copy the project files to the working directory
#COPY petclinic-app /home/jenkins/agent/petclinic

# Ensure the Jenkins user has correct permissions
RUN chown -R jenkins:jenkins /home/jenkins/agent/petclinic && \
    chmod -R 755 /home/jenkins/agent/petclinic

# Expose Docker socket for Jenkins to access Docker
VOLUME /var/run/docker.sock

# Run Maven clean install and SonarQube analysis
#RUN mvn clean install
