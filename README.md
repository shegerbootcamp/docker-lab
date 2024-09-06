## **DevOps CI/CD Pipeline with Jenkins, SonarQube, Docker, JFrog Artifactory, X-Ray, and Slack Integration**

This project demonstrates a complete CI/CD pipeline using Jenkins for continuous integration and deployment. The pipeline includes building, testing, code scanning, and containerization with Docker. It also integrates artifact storage using JFrog Artifactory, security scanning with JFrog X-Ray, and Slack notifications for alerting.

### **Pipeline Architecture Overview**

![Pipeline Architecture](ci-cd-architecture.png)

### **Components Used**
1. **Jenkins:** Orchestrates the entire pipeline from build to deployment.
2. **SonarQube:** Performs static code analysis to ensure code quality and security.
3. **Maven:** Handles the build process for Java applications.
4. **Docker:** Builds, tests, and deploys containerized applications.
5. **JFrog Artifactory:** Stores build artifacts (e.g., JAR/WAR files) and Docker images.
6. **JFrog X-Ray:** Scans Docker images for vulnerabilities.
7. **Slack:** Sends notifications for successful or failed pipeline stages.
8. **QA, UAT, and Prod:** Represents different deployment environments (Quality Assurance, User Acceptance Testing, and Production).

### **Pipeline Flow**
1. **Code Commit:** Developer commits code to the repository (GitHub).
2. **Jenkins Build:** Jenkins pulls the code, builds it using Maven, and generates JAR/WAR files.
3. **Testing:** Unit tests and integration tests are executed as part of the Jenkins pipeline.
4. **Code Scan:** SonarQube analyzes the code for bugs, vulnerabilities, and code smells.
5. **Docker Build:** The Docker image is built and pushed to JFrog Artifactory for storage.
6. **Docker Image Scan:** JFrog X-Ray scans the Docker image for security vulnerabilities.
7. **Deploy to Environments:** After scanning, the image is deployed to QA, UAT, and Production environments.
8. **Notifications:** Slack sends real-time notifications on the pipeline status.

---

### **Setup Instructions**

1. **Clone the repository:**
   ```bash
   git clone https://github.com/shegerbootcamp/docker-lab/tree/ansible-deploy-branch-shegerlab
   ```

2. **Navigate to the project directory:**
   ```bash
   cd docker-lab
   ```

3. **Jenkins Configuration:**
   - Set up Jenkins with the required plugins: Maven, Docker, SonarQube, JFrog CLI, and Slack Integration.
   - Configure JFrog Artifactory and JFrog X-Ray credentials.
   - Ensure the Slack token is configured for notifications.
   
4. **SonarQube Configuration:**
   - Install and configure SonarQube to scan the codebase in the Jenkins pipeline.
   - Use the SonarQube dashboard to review the scan results.

5. **Docker and JFrog Artifactory:**
   - Ensure Docker is installed on your Jenkins server.
   - Configure JFrog Artifactory to store Docker images and JAR/WAR artifacts.
   - Integrate JFrog X-Ray to scan Docker images for security vulnerabilities.

6. **Slack Integration:**
   - Configure Slack with a dedicated channel for DevOps notifications.
   - Set up a Slack bot with appropriate permissions and integrate it with Jenkins.

---

### **How to Create a New Jenkins Job for the Project**

1. **Step 1: Access Jenkins Dashboard**
   - Open your Jenkins dashboard by accessing its URL (e.g., `http://<your-jenkins-server>:8080`).
   
2. **Step 2: Create a New Item**
   - Click on "New Item" on the Jenkins dashboard.
   - Provide a name for the job (e.g., `petclinic-pipeline`).
   - Select **Pipeline** as the type of project, then click **OK**.

3. **Step 3: Configure the Pipeline**
   - In the job configuration, scroll down to the **Pipeline** section.
   - Select **Pipeline script from SCM** under **Definition**.
   - In the **SCM** dropdown, select **Git**.

4. **Step 4: Set the Repository Details**
   - In the **Repository URL**, enter the URL of the GitHub repository:
     ```bash
     https://github.com/shegerbootcamp/docker-lab.git
     ```
   - Set the **Branch to build** to `master`.

5. **Step 5: Specify Jenkinsfile Location**
   - Under **Script Path**, enter:
     ```bash
     ci/Jenkinsfile.dev
     ```

6. **Step 6: Update Parameters**
   - Scroll down to the **Pipeline Syntax** and select **This project is parameterized**.
   - Add the following parameters with their respective default values:
     - **ProjectKey**: `petclinic`
     - **ProjectName**: `petclinic`
     - **SonarHostUrl**: `http://192.168.92.182:9000`
     - **SlackChannel**: `#jenkins-build-sonar`
     - **SlackTokenCredentialId**: `SLACK-TOKEN`
     - **AppPort**: `8081`

7. **Step 7: Save the Job**
   - Once all the details are filled in, click **Save**.

8. **Step 8: Build the Pipeline**
   - Click on **Build Now** to trigger the Jenkins job.
   - Monitor the console output for the status of each stage, including code cloning, testing, SonarQube analysis, Docker image build and push, and deployment.

---

### **Jenkinsfile Overview**
Below is a sample Jenkinsfile that can be found in the `docker-lab/ci/Jenkinsfile`:

```groovy
pipeline {
    agent any
    tools {
        jfrog 'jfrog-cli'
    }
    parameters {
        string(name: 'ProjectKey', defaultValue: 'petclinic', description: 'SonarQube project key')
        string(name: 'ProjectName', defaultValue: 'petclinic', description: 'SonarQube project name')
        string(name: 'SonarHostUrl', defaultValue: 'http://192.168.92.182:9000', description: 'SonarQube server URL')
        string(name: 'SlackChannel', defaultValue: '#jenkins-build-sonar', description: 'Slack channel to send notifications')
        string(name: 'SlackTokenCredentialId', defaultValue: 'SLACK-TOKEN', description: 'Slack token credential ID')
        string(name: 'AppPort', defaultValue: '8081', description: 'Port to run the application')
    }
    environment {
        DOCKER_IMAGE_NAME = "shegerlab2024.jfrog.io/petclinic/petclinic:${env.BUILD_NUMBER}"
    }
    stages {
        stage('Clone') {
            steps {
                git branch: 'master', url: "https://github.com/shegerbootcamp/docker-lab.git"
            }
        }
        stage('Unit Test') {
            steps {
                dir('petclinic-app') {
                    sh 'mvn test'
                }
            }
        }
        stage('Sonar Static Code Analysis') {
            steps {
                dir('petclinic-app') {
                    withCredentials([string(credentialsId: 'jenkins-sonar-token', variable: 'SONAR_TOKEN')]) {
                        sh """
                        mvn sonar:sonar \
                            -Dsonar.projectKey=${params.ProjectKey} \
                            -Dsonar.projectName='${params.ProjectName}' \
                            -Dsonar.host.url=${params.SonarHostUrl} \
                            -Dsonar.login=${SONAR_TOKEN}
                        """
                    }
                }
            }
        }
        stage('Build Package') {
            steps {
                dir('petclinic-app') {
                    sh 'mvn clean install -DskipTests=true'
                }
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("$DOCKER_IMAGE_NAME", 'petclinic-app')
                }
            }
        }
        stage('Scan and Push Docker Image') {
            steps {
                dir('petclinic-app/') {
                    jf 'docker scan $DOCKER_IMAGE_NAME'
                    jf 'docker push $DOCKER_IMAGE_NAME'
                }
            }
        }
        stage('Remove Local Docker Image') {
            steps {
                script {
                    sh "docker rmi $DOCKER_IMAGE_NAME"
                }
            }
        }
        stage('Docker Pull & Deploy') {
            steps {
                script {
                    sh """
                    docker ps -q --filter "name=petclinic" | grep -q . && docker stop petclinic && docker rm petclinic || true
                    docker pull $DOCKER_IMAGE_NAME
                    docker run -d --name petclinic -p ${params.AppPort}:8081 $DOCKER_IMAGE_NAME
                    """
                }
            }
        }
    }
    post {
        success {
            dir('petclinic-app') {
                junit '**/target/surefire-reports/TEST-*.xml'
                archiveArtifacts 'target/*.jar'
            }
        }
        always {
            slackSend (
                channel: params.SlackChannel,
                color: currentBuild.result == 'SUCCESS' ? 'good' : 'danger',
                tokenCredentialId: params.SlackTokenCredentialId,
                message: "Pipeline Status: ${currentBuild.currentResult} - ${env.JOB_NAME} #${env.BUILD_NUMBER} - ${env