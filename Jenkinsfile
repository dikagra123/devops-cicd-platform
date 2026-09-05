pipeline {

    agent any

    environment {
        IMAGE_NAME = "devops-app"
        VERSION = "${BUILD_NUMBER}"
    }

    stages {

        stage('Check Workspace') {
            steps {
                bat 'dir'
                bat 'dir app'
            }
        }

        stage('Install Dependencies') {
            steps {
                bat 'cd app && npm install'
            }
        }

        stage('Run Tests') {
            steps {
                bat 'cd app && npm test'
            }
        }

        stage('Docker Build') {
            steps {
                bat 'docker build -t %IMAGE_NAME%:%VERSION% .'
            }
        }

        stage('Security Scan') {
    steps {
       bat 'C:\\Tools\\trivy\\trivy.exe image --severity HIGH,CRITICAL %IMAGE_NAME%:%VERSION%'
    }
}

        stage('Terraform Validate') {
            steps {
                bat '''
                    cd terraform
                    terraform init
                    terraform validate
                '''
            }
        }

        stage('Terraform Plan') {
            steps {
                bat '''
                    cd terraform
                    terraform plan -var="app_version=%VERSION%"
                '''
            }
        }

        stage('Deploy') {
            steps {
                bat '''
                    cd terraform
                    terraform apply -auto-approve -var="app_version=%VERSION%"
                '''
            }
        }

        stage('Health Check Blue') {
            steps {
                bat '''
                    C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe ^
                    -ExecutionPolicy Bypass ^
                    -File terraform\\scripts\\health-check.ps1 ^
                    -Url "http://localhost:3001"
                '''
            }
        }

        stage('Health Check Green') {
            steps {
                bat '''
                    C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe ^
                    -ExecutionPolicy Bypass ^
                    -File terraform\\scripts\\health-check.ps1 ^
                    -Url "http://localhost:3002"
                '''
            }
        }
    }

    post {
        success {
            echo 'Deployment completed successfully!'
        }

        failure {
            echo 'Pipeline failed.'
        }
    }
}