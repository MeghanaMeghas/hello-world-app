pipeline {
  agent {
    kubernetes {
      label 'docker-agent'
      defaultContainer 'docker'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins
spec:
  containers:
  - name: docker
    image: docker:19.03.12-dind
    command:
    - cat
    tty: true
    volumeMounts:
    - name: docker-socket
      mountPath: /var/run/docker.sock
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
      type: Socket
"""
    }
  }

  environment {
    GCP_PROJECT = 'phrasal-verve-447910-d9'
    IMAGE_NAME = 'hello-world-app'
    IMAGE_TAG = 'latest'
    GCR_PATH = "gcr.io/${GCP_PROJECT}/${IMAGE_NAME}:${IMAGE_TAG}"
  }
  stages {
        stage('Authenticate with GCP') {
            steps {
                withCredentials([file(credentialsId: 'gcp-json-key', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh 'gcloud auth activate-service-account --key-file=$GOOGLE_APPLICATION_CREDENTIALS'
                }
            }
        }
  }

  stages {
    stage('Clone Repo') {
      steps {
        git 'https://github.com/MeghanaMeghas/hello-world-app.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          docker.build("${IMAGE_NAME}:${IMAGE_TAG}")

        }
      }
    }

    stage('Push to GCR') {
      steps {
        script {
          sh """
            docker tag ${IMAGE_NAME}:${IMAGE_TAG} ${GCR_PATH}
            docker push ${GCR_PATH}
          """
        }
      }
    }

    stage('Deploy to GKE') {
      steps {
        script {
          sh """
            gcloud container clusters get-credentials jenkins-cd --zone us-central1-a --project ${GCP_PROJECT}
            kubectl apply -f k8s/deployment.yaml
          """
        }
      }
    }
  }
}
