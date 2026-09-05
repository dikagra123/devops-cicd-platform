pipeline {

    agent any

    environment {

        IMAGE_NAME = "devops-app"
        VERSION = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {

            steps {
                checkout scm
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

                bat '''
                    trivy image --severity HIGH,CRITICAL --exit-code 1 %IMAGE_NAME%:%VERSION%
                '''
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

        stage('Deploy DEV') {

            steps {

                bat '''
                    cd terraform
                    terraform apply -auto-approve -var="app_version=%VERSION%"
                '''
            }
        }

        stage('Health Check DEV') {

            steps {

                powershell '''
                    .\\scripts\\health-check.ps1 `
                        -Url "http://localhost:3001"
                '''
            }
        }

        stage('Deploy GREEN') {

            steps {

                powershell '''
                    $env:BUILD_NUMBER = "$env:BUILD_NUMBER"
                    .\\scripts\\deploy-green.ps1
                '''
            }
        }

        stage('Health Check GREEN') {

            steps {

                powershell '''
                    .\\scripts\\health-check.ps1 `
                        -Url "http://localhost:3002"
                '''
            }
        }

        stage('Production Approval') {

            steps {

                input message: 'GREEN is healthy. Switch production traffic?'
            }
        }

        stage('Switch Traffic') {

            steps {

                powershell '''
                    .\\scripts\\switch-green.ps1
                '''
            }
        }
    }

    post {

        failure {

            echo 'Deployment failed. Rolling back...'

            powershell '''
                .\\scripts\\rollback.ps1
            '''
        }
    }
}