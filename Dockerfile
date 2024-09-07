# Use an official Jenkins JDK 11 base image
FROM jenkins/inbound-agent:jdk11

# Switch to root to install additional tools
USER root

# Install required packages: Maven, Docker CLI, JFrog CLI, and any other tools
RUN apt-get update && \
    apt-get install -y \
        git \
        maven \
        docker.io \
        ansible \
        curl \
        unzip && \
    # Install JFrog CLI
    curl -fL https://getcli.jfrog.io | sh && \
    mv jfrog /usr/local/bin/jfrog && \
    chmod +x /usr/local/bin/jfrog && \
    # Clean up
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Switch back to the Jenkins agent user
USER jenkins

# Set the environment variable for Maven
ENV MAVEN_HOME=/usr/share/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# Set environment variables for Docker and JFrog
ENV DOCKER_HOST=tcp://docker:2375
ENV JFROG_CLI_HOME=/usr/local/bin/jfrog

# Expose Docker socket for Jenkins to access Docker
VOLUME /var/run/docker.sock

# Expose any required ports (if needed, e.g., for debugging)
# EXPOSE 8080

# Entry point for the Jenkins agent
ENTRYPOINT ["jenkins-agent"]