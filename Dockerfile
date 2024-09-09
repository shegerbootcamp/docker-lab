# Use a specific version of Alpine Linux as the base image
ARG ALPINE_VERSION=3.18
FROM alpine:${ALPINE_VERSION}

# Set environment variables
ARG TERRAFORM_VERSION="1.6.5"
ARG ANSIBLE_VERSION="2.15.0"
ARG PACKER_VERSION="1.9.4"
ARG MAVEN_VERSION="3.9.9"
ARG JAVA_VERSION="17"

LABEL maintainer="cloudsheger <cloudsheger@gmail.com>"
LABEL terraform_version=${TERRAFORM_VERSION}
LABEL ansible_version=${ANSIBLE_VERSION}
LABEL packer_version=${PACKER_VERSION}
LABEL maven_version=${MAVEN_VERSION}
LABEL java_version=${JAVA_VERSION}

ENV TERRAFORM_VERSION=${TERRAFORM_VERSION}
ENV PACKER_VERSION=${PACKER_VERSION}
ENV MAVEN_VERSION=${MAVEN_VERSION}
ENV JAVA_VERSION=${JAVA_VERSION}

# Install required dependencies and tools
RUN apk --no-cache add \
    ansible \
    aws-cli \
    curl \
    git \
    python3 \
    py3-pip \
    unzip \
    gcc \
    libffi-dev \
    musl-dev \
    openssl-dev \
    openjdk${JAVA_VERSION}-jdk \
    docker \
    docker-compose

# Download and install Maven
RUN curl -LO https://archive.apache.org/dist/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz \
    && tar -xzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /usr/local \
    && ln -s /usr/local/apache-maven-${MAVEN_VERSION} /usr/local/maven \
    && rm apache-maven-${MAVEN_VERSION}-bin.tar.gz

# Set Maven environment variables
ENV MAVEN_HOME=/usr/local/maven
ENV PATH=$MAVEN_HOME/bin:$PATH

# Install JFrog CLI
RUN curl -fL https://getcli.jfrog.io | sh \
    && mv jfrog /usr/local/bin/jfrog \
    && chmod +x /usr/local/bin/jfrog

# Create and activate a virtual environment
RUN python3 -m venv /venv
ENV PATH="/venv/bin:$PATH"

# Upgrade pip within the virtual environment
RUN pip install --upgrade pip setuptools wheel

# Download and install Terraform and Packer
RUN curl -LO https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip \
    && curl -LO https://releases.hashicorp.com/packer/${PACKER_VERSION}/packer_${PACKER_VERSION}_linux_amd64.zip \
    && unzip '*.zip' -d /usr/local/bin \
    && rm *.zip

# Create a non-root user with a home directory and add it to the wheel group
RUN addgroup -S jenkins && adduser -S -G jenkins -G wheel jenkins

# Create a working directory and give ownership to the jenkins user
RUN mkdir -p /home/jenkins \
    && chown -R jenkins:jenkins /home/jenkins \
    && chmod 755 /home/jenkins

# Set the working directory
WORKDIR /home/jenkins

COPY petclinic-app  /home/jenkins
# Switch to the non-root user
#USER jenkins

# Define the default command to run when the container starts
CMD ["/bin/sh"]