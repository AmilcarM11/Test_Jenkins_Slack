def SERVICE_NAME = "test-app"
pipeline {
    agent any
    environment {
        QA_URL = 'http://localhost:3020' 
    }
    stages {
        stage("Init") {
            steps {
                // Obtener el commit message.
                script {
                    env.GIT_COMMIT_MSG = sh (script: "git log -1 --pretty=%B ${env.GIT_COMMIT}", returnStdout: true).trim()
                }

                // Determinar tag de la imagen de Docker
                script {
                    IMAGE_TAG = 'unknown'
                    SHORT_COMMIT_HASH = "${env.GIT_COMMIT[0..7]}"
                    // Ramas de features
                    def matcher = (env.BRANCH_NAME =~ /feature\/(\S+)/)
                    def feature = matcher ? matcher[0][1] : null
                    if (feature != null) {
                        IMAGE_TAG = feature
                    }
                    // Ramas de release
                    matcher = (env.BRANCH_NAME =~ /release\/(\S+)/)
                    def release = matcher ? matcher[0][1] : null
                    if (release != null) {
                        IMAGE_TAG = release
                    }
                    // Rama develop
                    if(env.BRANCH_NAME == 'develop') {
                        IMAGE_TAG = "develop-${SHORT_COMMIT_HASH}"
                    }
                    
                    IMAGE_NAME_AND_TAG = "${SERVICE_NAME}:${IMAGE_TAG}"
                }

                // Notificar inicio de Pipeline, la rama, la imagen de Docker, y el commit message
                // TODO: URL de la branch o del cambio. 
                slackSend message: "Pipeline started: <${env.BUILD_URL}|${SERVICE_NAME}> for branch <${env.GIT_URL}|${env.BRANCH_NAME} #${env.BUILD_NUMBER}>\nDocker Image: \t${IMAGE_NAME_AND_TAG}\n\n${env.GIT_COMMIT_MSG}"
            }
        }
        stage("Compile") {
            steps {
                echo "Compilar código..."
            }
        }
        stage("Unit Tests") {
            steps {
                echo "Correr pruebas automáticas..."
            }
        }
        stage("Docker Image") {
            steps {
                echo "Crear y taguear imagen de Docker: ${SERVICE_NAME}:${IMAGE_TAG}"
                echo "Subir imagen de Docker a Registry..."
            }
            post {
                success {
                    slackSend color: "#0db7ed", message: "Docker Image published: ${IMAGE_NAME_AND_TAG}"
                }
            }
        }
        stage("Deploy QA") {
            when { branch 'develop' }
            steps {
                echo "Este Pipeline es de Develop."

                slackSend message: "Branch ${env.BRANCH_NAME} deployed to <${env.QA_URL}|QA env> \nDocker Image:\t ${IMAGE_NAME_AND_TAG}"
            }
        }
    }
}