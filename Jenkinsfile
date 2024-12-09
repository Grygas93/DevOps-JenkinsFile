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
stage('Test Shell') {
    steps {
        sh '''
            #!/bin/bash
            echo "Shell test:"
            whoami
            echo "Current directory:"
            pwd
            echo "Files in directory:"
            ls -al
        '''
    }
}
 
        stage('Debug Workspace') {
            steps {
                echo 'Checking workspace environment...'
                sh '''
                    echo "Current directory:"
                    pwd
                    echo "Files in the directory:"
                    ls -al
                '''
            }
        }
        
         stage('Docker Image Build') {
            steps {
                echo 'Building Docker Image...'
                sh '''
                    export DOCKER_BUILDKIT=1
                    docker build -t grygas93/cw2-server:1.0 -f Dockerfile .
                '''
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
                         sh '''
                            echo "Logging into DockerHub..."
                            echo $DOCKERHUB_CREDS_PSW | docker login -u $DOCKERHUB_CREDS_USR --password-stdin
                        '''
                    }
                }
            }
        }

        stage('DockerHub Image Push') {
            steps {
                echo 'Pushing Docker Image to DockerHub...'
                sh 'docker push grygas93/cw2-server:1.0'
            }
        }

        stage('Deploy') {
            steps {
                sshagent(['jenkins-ssh-key']) { // Twoje ID dla SSH credentials
                    echo 'Deploying application using Ansible playbooks...'
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
