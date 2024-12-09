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
              sh 'ls -al'
              sh 'pwd'
              sh 'docker build -t grygas93/cw2-server:1.0 -f Dockerfile .'
    }
}

        stage('Test Docker Image') {
            steps {
                echo 'Testing Docker Image...'
                sh '''
                    docker image inspect grygas93/cw2-server:1.0
                    docker run --name test-container -p 8081:8080 -d grygas93/cw2-server:1.0
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
                sh 'docker push grygas93/cw2-server:1.0'
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['jenkins-ssh-key']) { // Twoje ID dla SSH credentials
                    sh '''
                        ansible-playbook -i /home/ubuntu/ansible_playbooks/hosts create_service_playbook.yml
                        ansible-playbook -i /home/ubuntu/ansible_playbooks/hosts deploy_image_playbook.yml
                        ansible-playbook -i /home/ubuntu/ansible_playbooks/hosts scale_deployment_playbook.yml
                    '''
                }
            }
        }
    }
}
