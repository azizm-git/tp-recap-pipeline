pipeline {
    agent any

    environment {
        DOCKERHUB_IMAGE = "azizmjd/helloworld-recap"
        DOCKER_TAG = "${BUILD_NUMBER}"
    }

    stages {
        stage('1 - Checkout') {
            steps {
                echo '=== Récupération du code source ==='
                checkout scm
            }
        }

        stage('2 - Build Maven') {
            steps {
                echo '=== Compilation Maven ==='
                sh '/var/jenkins_home/tools/hudson.tasks.Maven_MavenInstallation/Maven-3.9/bin/mvn clean package'
            }
        }

        stage('3 - Build Docker') {
            steps {
                echo '=== Construction de l image Docker ==='
                sh "docker build -t ${DOCKERHUB_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKERHUB_IMAGE}:${DOCKER_TAG} ${DOCKERHUB_IMAGE}:latest"
            }
        }

        stage('4 - Push Docker Hub') {
            steps {
                echo '=== Push vers Docker Hub ==='
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo ${DOCKER_PASS} | docker login -u ${DOCKER_USER} --password-stdin"
                    sh "docker push ${DOCKERHUB_IMAGE}:${DOCKER_TAG}"
                    sh "docker push ${DOCKERHUB_IMAGE}:latest"
                    sh "docker logout"
                }
            }
        }

        stage('5 - Deploy Ansible') {
            steps {
                echo '=== Déploiement sur les nodes via Ansible ==='
                sh """
                /opt/ansible-venv/bin/ansible all \
                  -i /var/jenkins_home/ansible/hosts \
                  -m shell \
                  -a "docker pull ${DOCKERHUB_IMAGE}:${DOCKER_TAG} && \
                      docker rm -f helloworld-app || true && \
                      docker run -d --name helloworld-app ${DOCKERHUB_IMAGE}:${DOCKER_TAG}"
                """
            }
        }

        stage('6 - Verify') {
            steps {
                echo '=== Vérification du déploiement ==='
                sh "/opt/ansible-venv/bin/ansible all -i /var/jenkins_home/ansible/hosts -m shell -a 'docker ps | grep helloworld'"
            }
        }
    }

    post {
        success {
            echo '✅ Pipeline complet : Git → Maven → Docker → Ansible → SUCCÈS !'
        }
        failure {
            echo '❌ Pipeline échoué — vérifier les logs.'
        }
    }
}
