pipeline {
    agent any

    environment {
        IMAGE_NAME = "trivy-target:${env.BUILD_ID}"
        // Define where the Dockerfile lives
        DOCKER_DIR = "./app" 
    }

    stages {
        stage('Build Image') {
            steps {
                script {
                    echo '  Building Docker Image from app/ directory...'
                    // Point docker build to the DOCKER_DIR
                    sh "docker build -t ${IMAGE_NAME} ${DOCKER_DIR}"
                }
            }
        }

        stage('Trivy Scan (Gate)') {
            steps {
                script {
                    echo '  Scanning for CRITICAL Vulnerabilities...'
                    // Trivy scans the image
                    sh "trivy image --exit-code 1 --severity CRITICAL --no-progress ${IMAGE_NAME}"
                }
            }
        }
    }

    post {
        always {
            sh "docker rmi ${IMAGE_NAME} || true"
        }
    }
}
