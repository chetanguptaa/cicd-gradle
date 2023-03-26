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
    stage("docker build && docker push") {
        steps {
            withCredentials([string(credentialsId: 'docker_password', variable: 'docker_password')]) {
                dir('kubernetes/') {
                    sh '''
                        helmversion=$( helm show chart myapp | grep version | cut -d: -f 2 | tr -d ' ')
                        tar -czvf myapp-${helmversion}.tgz myapp/
                        curl -u admin:$docker_password http://24.178.223.55:8081/repository/helm-hosted/ --upload-file myapp-${helmversion}.tgz -v
                    '''
                }
            }
        }
    }
    stage('Deploying application on kubernetes cluster') {
        steps {
            script {
                withCredentials([kubeconfigFile(credentialsId: 'kubernetes-config', variable: 'KUBECONFIG')]) {
                    dir('kubernetes/') {
                        sh 'helm upgrade --install --set image.repository="chetanguptaa/springapp" --set image.tag="${VERSION}" myjavaapp myapp/ '
                    }
                }
            }
        }
    }
}