pipeline {
    agent any
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
    }
}