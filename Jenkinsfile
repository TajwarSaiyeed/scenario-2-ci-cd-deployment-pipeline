pipeline {
    agent any
    
    environment {
        APP_NAME = 'demo-app'
        DOCKER_IMAGE = "${APP_NAME}:latest"
        CONTAINER_NAME = "${APP_NAME}"
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '========================================='
                echo 'Stage: Checkout'
                echo '========================================='
                checkout scm
                sh 'ls -la'
            }
        }
        
        stage('Build') {
            steps {
                echo '========================================='
                echo 'Stage: Build Application'
                echo '========================================='
                dir('app') {
                    sh 'npm install'
                    echo '✓ Dependencies installed successfully'
                }
            }
        }
        
        stage('Test') {
            steps {
                echo '========================================='
                echo 'Stage: Running Unit Tests'
                echo '========================================='
                dir('app') {
                    sh 'npm test'
                    echo '✓ All tests passed successfully'
                }
            }
            post {
                always {
                    echo 'Test stage completed'
                }
            }
        }
        
        stage('Package') {
            steps {
                echo '========================================='
                echo 'Stage: Building Docker Image'
                echo '========================================='
                script {
                    sh '''
                        if docker ps -a --format '{{.Names}}' | grep -q "^${CONTAINER_NAME}$"; then
                            echo "Removing existing container..."
                            docker stop ${CONTAINER_NAME} || true
                            docker rm ${CONTAINER_NAME} || true
                        fi
                    '''
                    
                    sh 'docker build -t ${DOCKER_IMAGE} .'
                    echo '✓ Docker image built successfully'
                    
                    sh 'docker images | grep ${APP_NAME}'
                }
            }
        }
        
        stage('Deploy') {
            steps {
                echo '========================================='
                echo 'Stage: Deploying with Docker Compose'
                echo '========================================='
                script {
                    sh 'docker-compose down || true'
                    
                    sh 'docker-compose up -d'
                    
                    echo '✓ Application deployed successfully'
                    
                    sh 'docker ps | grep ${APP_NAME}'
                }
            }
        }
        
        stage('Health Check') {
            steps {
                echo '========================================='
                echo 'Stage: Verifying Application Health'
                echo '========================================='
                script {
                    sh 'chmod +x healthcheck.sh'
                    
                    sh './healthcheck.sh'
                    
                    echo '✓ Health check passed - Application is healthy!'
                }
            }
        }
    }
    
    post {
        success {
            echo ''
            echo '========================================='
            echo '🎉 PIPELINE COMPLETED SUCCESSFULLY! 🎉'
            echo '========================================='
            echo ''
            echo 'Summary:'
            echo '  ✓ Code checked out'
            echo '  ✓ Application built'
            echo '  ✓ Tests passed'
            echo '  ✓ Docker image created'
            echo '  ✓ Application deployed'
            echo '  ✓ Health check passed'
            echo ''
            echo 'Application is running at: http://localhost:3000'
            echo 'Health endpoint: http://localhost:3000/health'
            echo ''
        }
        failure {
            echo ''
            echo '========================================='
            echo '❌ PIPELINE FAILED'
            echo '========================================='
            echo ''
            echo 'Please check the logs above for details.'
            echo ''
            sh 'docker-compose down || true'
        }
        always {
            echo ''
            echo 'Pipeline execution completed at: ' + new Date().toString()
            echo ''
        }
    }
}
