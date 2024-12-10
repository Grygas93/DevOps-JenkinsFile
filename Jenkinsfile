pipeline {
    agent { label 'docker-agent' }
    environment {
        DOCKERHUB_CREDS = credentials('docker') // DockerHub credentials ID
        GITHUB_CREDS = credentials('GitHubToken') // GitHub credentials ID
        JENKINS_DEBUG = 'true'
	SHELL_PATH = '/bin/bash' // Lub '/bin/sh'
    }
    stages {
        // 1. Clone the repository
        stage('Clone Repository') {
            steps {
                echo 'Cloning repository...'
                git branch: 'main', credentialsId: 'GitHubToken', url: 'https://github.com/Grygas93/DevOps-JenkinsFile.git'
            }
        }
 
        stage('Test Simple Shell') {
            steps {
                sh '#!/bin/bash\necho "Testuje shell w pipeline"'
            }
        }

        // 2. Test Docker functionality
        stage('Test Docker') {
            steps {
                echo 'Testing Docker...'
                sh 'docker run hello-world'
            }
        }

        // 3. Verify shell environment
        stage('Test Shell') {
            steps {
                echo 'Testing shell environment...'
                sh '''
                    echo "Shell test:"
                    whoami
                    echo "Current directory:"
                    pwd
                    echo "Files in directory:"
                    ls -al
                '''
            }
        }

        // 4. Debug workspace
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

        // 5. Build Docker Image
        stage('Docker Image Build') {
            steps {
                echo 'Building Docker Image...'
                sh '''
                    export DOCKER_BUILDKIT=1
                    docker build -t grygas93/cw2-server:1.0 -f Dockerfile .
                '''
            }
        }

        // 6. Test Docker Image
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

        // 7. Login to DockerHub
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

        // 8. Push Docker Image to DockerHub
        stage('DockerHub Image Push') {
            steps {
                echo 'Pushing Docker Image to DockerHub...'
                sh 'docker push grygas93/cw2-server:1.0'
            }
        }

        // 9. Deploy application using Ansible
        stage('Deploy') {
            steps {
                sshagent(['jenkins-ssh-key']) { // SSH credentials ID
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

