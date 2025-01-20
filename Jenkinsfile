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
    - name: workspace
      mountPath: /home/jenkins/agent
  volumes:
  - name: docker-socket
    hostPath:
      path: /var/run/docker.sock
      type: Socket
  - name: workspace
    emptyDir: {}
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
    stage('Clone Repo') {
      steps {
        git 'https://github.com/MeghanaMeghas/hello-world-app.git'
      }
    }

    stage('List Workspace Files') {
      steps {
        sh 'echo "Current directory: $(pwd)"'
        sh 'ls -alh $(pwd)'
      }
    }

    stage('Build Docker Image') {
      steps {
        script {
          // Explicitly set Dockerfile path and context
          sh """
            DOCKER_BUILDKIT=0 docker build --no-cache --progress=plain -t ${IMAGE_NAME}:${IMAGE_TAG} -f /home/jenkins/agent/Dockerfile /home/jenkins/agent
          """
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
