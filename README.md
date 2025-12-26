
# 🛡️ SecOps-Scanner

> **"Security as Code."**
> An automated pipeline that builds Docker images, scans them for CVEs using Trivy, and acts as a security gate to block vulnerable deployments.

---

## 📖 Overview

**SecOps-Scanner** demonstrates a "Shift Left" security approach. Instead of checking for vulnerabilities after deployment, this pipeline integrates auditing directly into the build process.

**The Logic:**
1.  **Build:** Jenkins builds the target application container.
2.  **Scan:** Trivy scans the new image for Critical vulnerabilities.
3.  **Gate:** If a Critical CVE is found, the pipeline **fails intentionally**, preventing the insecure code from progressing.

## 🛠️ Tech Stack

* **Orchestrator:** Jenkins (Running inside Docker)
* **Security Scanner:** Trivy (by Aqua Security)
* **Containerization:** Docker & Docker-in-Docker (DinD)
* **Target App:** Node.js (Express)

---

## 📂 Project Files & Source Code

This repository contains the following structure and configurations:

### 1. The Pipeline Logic (`Jenkinsfile`)
*Defines the CI/CD stages: Checkout -> Build -> Scan -> Cleanup.*

```groovy
pipeline {
    agent any

    environment {
        IMAGE_NAME = "trivy-target:${env.BUILD_ID}"
        DOCKER_DIR = "./app"
    }

    stages {
        stage('Checkout') {
            steps {
                echo 'Checkout complete'
            }
        }

        stage('Build Target') {
            steps {
                script {
                    echo 'Building the Vulnerable Image...'
                    sh "docker build -t ${IMAGE_NAME} ${DOCKER_DIR}"
                }
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                script {
                    echo 'Launching Trivy Container...'
                    sh """
                        docker run --rm \
                        -v /var/run/docker.sock:/var/run/docker.sock \
                        aquasec/trivy image \
                        --exit-code 1 \
                        --severity CRITICAL \
                        --no-progress \
                        ${IMAGE_NAME}
                    """
                }
            }
        }
    }

    post {
        always {
            script {
                sh "docker rmi ${IMAGE_NAME} || true"
            }
        }
        failure {
            echo 'SECURITY ALERT: Pipeline blocked due to CRITICAL Vulnerabilities.'
        }
        success {
            echo 'Clean Scan: Image is secure.'
        }
    }
}

```

### 2. The Target Application (`app/`)

*A simple Node.js app intentionally using an older library to trigger the scanner.*

**`app/server.js`**

```javascript
const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('Hello Secure World'));
app.listen(3000, () => console.log('App running on port 3000'));

```

**`app/Dockerfile`**

```dockerfile
FROM node:14-alpine
RUN apk add --no-cache curl
WORKDIR /usr/src/app
COPY package.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["node", "server.js"]

```

### 3. The Jenkins Infrastructure (`jenkins/Dockerfile`)

*Custom image to allow Jenkins to run Docker commands.*

```dockerfile
FROM jenkins/jenkins:lts-jdk17
USER root
RUN apt-get update && \
    apt-get install -y docker.io && \
    rm -rf /var/lib/apt/lists/*
USER jenkins

```

---

## 🚀 How to Run

### 1. Build the "Brain" (Jenkins)

Prepare the custom Jenkins environment that can talk to the host Docker daemon.

```bash
docker build -t my-jenkins -f jenkins/Dockerfile .

```

### 2. Launch the Environment

Run Jenkins on port 8080.

```bash
docker run \
  --name devsecops-jenkins \
  --rm \
  -d \
  -u root \
  -p 8080:8080 \
  -v jenkins-data:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  my-jenkins

```

### 3. Configure the Pipeline

1. Open `http://localhost:8080`.
2. Create a **New Item** -> **Pipeline**.
3. Under **Pipeline Definition**, select **Pipeline script from SCM**.
4. **SCM**: Git.
5. **Repository URL**: *(Link to this GitHub repo)*.
6. **Branch**: `*/master` (or main).
7. **Script Path**: `Jenkinsfile`.

---

## 🧪 Expected Outcome

When you click **Build Now**:

1. Jenkins builds the Node.js app.
2. Trivy detects `CVE-2025-7783` (Critical Severity) in the `form-data` library.
3. **The Build Fails.** 🛑

### Sample Output Log:

```text
Total: 1 (CRITICAL: 1)
Library: form-data (package.json)
Vulnerability: CVE-2025-7783
Severity: CRITICAL
Status: fixed in 2.5.4

ERROR: script returned exit code 1
Finished: FAILURE

```

**This failure is the success criteria.** It proves the scanner effectively blocked a vulnerable application from being deployed.
