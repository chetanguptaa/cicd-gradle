pipeline {
    agent any
    environment {
        VERSION="${env.BUILD_ID}"
    }
    stages {
        stage("Sonar Quality Check") {
            agent {
                docker {
                    image 'openjdk:11'
                }
            }
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'sonar-password') {
                        sh 'chmod +x gradlew'
                        sh './gradlew sonarqube'
                    }
                    timeout(time: 5, units: 'MINUTES') {
                        def qg = waitForQualityGate()
                        if ( qg.status != 'OK' ) {
                            error "Pipeline aborted due to quality gate failure: ${qg.status}"
                        }
                    }
                }
            }
        }
        stage("docker build && docker push") {
            steps {
                withCredentials([string(credentialsId: 'docker_password', variable: 'docker_password')]) {
                    sh '''
                    docker build -t chetanguptaa/springapp:${VERSION}
                    docker login -u chetanguptaa -p $docker_password       
                    docker push chetanguptaa/springapp:${VERSION}
                    docker rmi chetanguptaa/springapp:${VERSION}         
                    '''
                }
            }
        }
    }
    stage('identifying misconfigs using datree in helm charts') {
        steps {
            script {
                dir('kubernetes/') {
                    withEnv(['DATREE_TOKEN=fjelk48t43ejhge95gedf']) {
                        sh 'helm datree test myapp/'
                    }
                }
            }
        }
    }
}