pipeline {
    agent any

    environment {
        IMAGE_NAME = "trivy-target:${env.BUILD_ID}"
        DOCKER_DIR = "./app"
    }

    stages {
        stage('Checkout') {
            steps {
                // In a real repo, this happens automatically. 
                // For local testing, we assume files are present.
                echo ' Checkout complete'
            }
        }

        stage('Build Target') {
            steps {
                script {
                    echo ' Building the Vulnerable Image...'
                    sh "docker build -t ${IMAGE_NAME} ${DOCKER_DIR}"
                }
            }
        }

        stage('Security Scan (Trivy)') {
            steps {
                script {
                    echo ' Launching Trivy Container...'
                    
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
                echo ' Cleaning up Docker artifacts...'
                sh "docker rmi ${IMAGE_NAME} || true"
            }
        }
        failure {
            echo ' SECURITY ALERT: Pipeline blocked due to CRITICAL Vulnerabilities.'
        }
        success {
            echo ' Clean Scan: Image is secure.'
        }
    }
}

