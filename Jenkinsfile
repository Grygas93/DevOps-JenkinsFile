pipeline {
    agent any
    environment {
        DOCKERHUB_CREDS = credentials('docker') // Twoje ID do DockerHub credentials
        GITHUB_CREDS = credentials('GitHubToken') // Twoje ID do GitHub credentials
    }
    stages {
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                git branch: 'main', credentialsId: 'GitHubToken', url: 'https://github.com/Grygas93/DevOps-JenkinsFile.git'
            }
        }
        
        stage('Docker Image Build') {
            steps {
                echo 'Building Docker Image...'
                sh 'docker build -t grygas93/cw2-server:${BUILD_NUMBER} .'
                echo 'Docker Image built successfully!'
            }
        }

        stage('Test Docker Image') {
            steps {
                echo 'Testing Docker Image...'
                sh '''
                    docker image inspect grygas93/cw2-server:${BUILD_NUMBER}
                    docker run --name test-container -p 8081:8080 -d grygas93/cw2-server:${BUILD_NUMBER}
                    docker ps
                    docker stop test-container
                    docker rm test-container
                '''
            }
        }

        stage('DockerHub Login') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker', passwordVariable: 'DOCKERHUB_CREDS_PSW', usernameVariable: 'DOCKERHUB_CREDS_USR')]) {
                        sh 'echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin'
                    }
                }
            }
        }

        stage('DockerHub Image Push') {
            steps {
                sh 'docker push grygas93/cw2-server:${BUILD_NUMBER}'
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['jenkins-ssh-key']) { // Twoje ID dla SSH credentials
                    echo 'Deploying application using Ansible playbooks...'
            sh '''
                ssh -o StrictHostKeyChecking=no -i ~/.ssh/id_ed25519 ubuntu@172.31.88.89 \
                "ansible-playbook -i /home/ubuntu/ansible_playbooks/hosts /home/ubuntu/ansible_playbooks/create_service_playbook.yml &&
                 ansible-playbook -i /home/ubuntu/ansible_playbooks/hosts /home/ubuntu/ansible_playbooks/deploy_image_playbook.yml &&
                 ansible-playbook -i /home/ubuntu/ansible_playbooks/hosts /home/ubuntu/ansible_playbooks/scale_deployment_playbook.yml"
            '''
                }
            }
        }
    }
}
