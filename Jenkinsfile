def SERVICE_NAME = "test-app"
pipeline {
    agent any
    environment {
        QA_URL = 'http://localhost:3020' 
        DOCKER_REGISTRY = 'registry.example.com' 
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
                    
                    // Rama develop
                    if(env.BRANCH_NAME == 'develop') {
                        IMAGE_TAG = "develop-${SHORT_COMMIT_HASH}"
                    }
                    // Rama main
                    else if(env.BRANCH_NAME == 'main') {
                        // TODO: IMAGE_TAG según TAG_NAME
                        // IMAGE_TAG = "main-${SHORT_COMMIT_HASH}"
                    } else {
                        // Ramas de feature, release, hotfix, bugfix, support
                        def matcher = (env.BRANCH_NAME =~ /(?:feature|release|hotfix|bugfix|support)\/(\S+)/)
                        def branch_suffix = matcher ? matcher[0][1] : null
                        if (branch_suffix != null) {
                            IMAGE_TAG = branch_suffix
                        }
                    }
                    
                    IMAGE_NAME_AND_TAG = "${SERVICE_NAME}:${IMAGE_TAG}"
                    IMAGE_FULL_NAME = "${DOCKER_REGISTRY}/${IMAGE_NAME_AND_TAG}"
                }

                // Notificar inicio de Pipeline, la rama, la imagen de Docker, y el commit message
                slackSend message: "Pipeline started: <${env.BUILD_URL}|${SERVICE_NAME} #${env.BUILD_NUMBER}> for branch *${env.BRANCH_NAME}* \nDocker Image: \t${IMAGE_FULL_NAME}\n\n${env.GIT_COMMIT_MSG}"
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
                echo "Crear y taguear imagen de Docker: ${IMAGE_FULL_NAME}"
                echo "Subir imagen de Docker a Registry..."
            }
            // post {
            //     success {
            //         slackSend color: "#0db7ed", message: "Docker Image published: ${IMAGE_FULL_NAME}"
            //     }
            // }
        }
        stage("Deploy QA") {
            when { branch 'develop' }
            steps {
                slackSend message: "Branch ${env.BRANCH_NAME} deployed to <${env.QA_URL}|QA env>"
            }
        }
    }
}