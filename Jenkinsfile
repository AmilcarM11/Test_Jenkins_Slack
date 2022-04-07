def SERVICE_NAME = "test-app"
pipeline {
    agent any
    environment {
        QA_URL = 'http://localhost:3020' 
        DOCKER_REGISTRY = 'harbor.tallerdevops.com/tfm-grupo5' 
    }
    // Buscar cambios en el Repositorio de Git cada 5 mins.
    triggers { pollSCM('H/5 * * * *') }
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
                    IMAGE_TAG_ALT = null
                    TRIGGER_SOURCE = env.TAG_NAME ? "tag *${env.TAG_NAME}*" : "branch *${env.BRANCH_NAME}*"
                    SHORT_COMMIT_HASH = "${env.GIT_COMMIT[0..7]}"

                    // Git tags
                    if(env.TAG_NAME != null) {
                        IMAGE_TAG = "${env.TAG_NAME}"
                    }
                    // Rama develop
                    else if(env.BRANCH_NAME == 'develop') {
                        IMAGE_TAG = "develop-${SHORT_COMMIT_HASH}"
                        IMAGE_TAG_ALT = "develop"
                    }
                    // Rama main
                    else if(env.BRANCH_NAME == 'main') {
                        IMAGE_TAG = "main-${SHORT_COMMIT_HASH}"
                        IMAGE_TAG_ALT = 'latest'
                    } else {
                        // Ramas de feature, release, hotfix, bugfix, support
                        def matcher = (env.BRANCH_NAME =~ /(feature|release|hotfix|bugfix|support)\/(\S+)/)
                        def branch_suffix = matcher ? matcher[0] : null
                        if (branch_suffix != null) {
                            def branch_type = branch_suffix[1] == 'release' ? 'pre' : branch_suffix[1]
                            IMAGE_TAG = branch_type + "-" + branch_suffix[2]
                        }
                    }
                    
                    // Definir el nombre completo de la imagen de Docker.
                    IMAGE_FULL_NAME = "${DOCKER_REGISTRY}/${SERVICE_NAME}:${IMAGE_TAG}"
                }

                // Notificar inicio de Pipeline, la rama, la imagen de Docker, y el commit message
                slackSend message: "Pipeline started: *<${env.BUILD_URL}|${SERVICE_NAME} #${env.BUILD_NUMBER}>* for ${TRIGGER_SOURCE} \n\n${env.GIT_COMMIT_MSG}"
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
            // Se construye imagen de Docker para las ramas de git-flow (main, develop, feature, release, hotfix, bugfix, release, support)
            // y para las tags de git, siempre que cumplan las convenciones de nombre para Docker Image tag.
            when { 
                anyOf { 
                    branch "main";
                    branch "develop";
                    branch pattern: "(feature|release|hotfix|bugfix|support)/(\\S+)", comparator: "REGEXP";
                    tag pattern: "[\\w][\\w.-]{0,127}", comparator: "REGEXP";
                } 

            }
            steps {
                echo "Crear y taguear imagen de Docker: ${IMAGE_FULL_NAME}"
                script {
                    withDockerRegistry([credentialsId: 'harbor-amilcar', url: "https://harbor.tallerdevops.com/"]) {
                        // Crear y publicar la imagen de Docker
                        def image = docker.build "${IMAGE_FULL_NAME}"
                        image.push()
                        
                        // La misma imagen puede ser publicada bajo otro nombre también (ej. 'develop', o 'latest')
                        if(IMAGE_TAG_ALT != null) [
                            image.push(IMAGE_TAG_ALT)
                        ]
		            }
	            }
            }
            post {
                success {
                    // #0db7ed = Color insignia de Docker
                    slackSend color: "#0db7ed", message: "Docker Image: \n```${IMAGE_FULL_NAME}```"
                }
                failure {
                    slackSend color: "error", message: "Error con la imagen :\n${IMAGE_FULL_NAME}"
                }
            }
        }
        stage("Deploy QA") {
            when { branch 'develop' }
            steps {
                slackSend message: "Branch ${env.BRANCH_NAME} deployed to <${env.QA_URL}|QA env>"
                // TODO: Desplegar a QA
            }
        }
        stage("Deploy Prod") {
            when { branch 'feature/test-manual-step' }
            options {
                timeout(time: 3, unit: "MINUTES")
            }
            steps {
                script {
                    withCredentials([string(credentialsId: 'webhook_secret', variable: 'SECRET')]) { 
                        // Registrar el Webhook
                        hook = registerWebhook(authToken: SECRET)
                        echo "Waiting for POST to ${hook.url}\n"

                        // Notificar Slack
                        slackSend message: "To deploy, run: \n```curl -X POST -d 'OK' -H \"Authorization: ${SECRET}\" ${hook.url}```"
                        
                        // Obtener respuesta
                        data = waitForWebhook hook
                        echo "Webhook called with data: ${data}"
                    }
                }
                // TODO: Desplegar a Producción
            }
        }
    }
}