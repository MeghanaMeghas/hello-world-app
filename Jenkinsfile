pipeline {
    agent {
        kubernetes {
            label 'jenkins-agent-with-docker'  // The label for the Kubernetes pod
            defaultContainer 'jnlp'            // The default container used for Jenkins agent
            yaml '''
apiVersion: v1
kind: Pod
metadata:
  name: jenkins-agent-with-docker
spec:
  containers:
  - name: jnlp
    image: jenkins/inbound-agent
    args: ${computer.jnlpmac} ${computer.name}
  - name: docker
    image: docker:19.03.12  // Docker image for Docker commands
    command:
      - cat
    tty: true
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
      type: Socket  // Mount the Docker socket to allow Docker commands
'''
        }
    }

    environment {
        GCP_PROJECT = 'phrasal-verve-447910-d9'
        IMAGE_NAME = 'hello-world-app'
        IMAGE_TAG = 'latest'
        GCR_PATH = "gcr.io/${GCP_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/MeghanaMeghas/hello-world-app.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                container('docker') {  // Use the container with Docker installed
                    script {
                        sh 'docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .'  // Build Docker image
                    }
                }
            }
        }

        stage('Push to GCR') {
            steps {
                container('docker') {  // Again, use the Docker container
                    script {
                        sh """
                            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${GCR_PATH}
                            docker push ${GCR_PATH}  // Push the image to Google Container Registry (GCR)
                        """
                    }
                }
            }
        }

        stage('Deploy to GKE') {
            steps {
                script {
                    sh """
                        gcloud container clusters get-credentials jenkins-cd --zone us-central1-a --project ${GCP_PROJECT}
                        kubectl apply -f k8s/deployment.yaml  // Apply the Kubernetes deployment
                    """
                }
            }
        }
    }
}
