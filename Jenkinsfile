def SERVICE_NAME = "test-app"
pipeline {
    agent any
    environment {
        QA_URL = 'http://localhost:3020' 
        DOCKER_REGISTRY = 'registry.example.com' 
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
                    TRIGGER_SOURCE = env.TAG_NAME ? "tag *${env.TAG_NAME}*" : "branch *${env.BRANCH_NAME}*"
                    SHORT_COMMIT_HASH = "${env.GIT_COMMIT[0..7]}"

                    // Git tags
                    if(env.TAG_NAME != null) {
                        IMAGE_TAG = "${env.TAG_NAME}"
                    }
                    // Rama develop
                    else if(env.BRANCH_NAME == 'develop') {
                        IMAGE_TAG = "develop-${SHORT_COMMIT_HASH}"
                    }
                    // Rama main
                    else if(env.BRANCH_NAME == 'main') {
                        IMAGE_TAG = "main-${SHORT_COMMIT_HASH}"
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
            // Solo se construyen imagenes de Docker para las ramas de git-flow (main, develop, feature, release, hotfix, bugfix, release, support)
            // Y para todas las Git Tags.
            when { 
                anyOf { 
                    branch pattern: "main";
                    branch pattern: "develop";
                    branch pattern: "feature/*";
                    branch pattern: "hotfix/*";
                    branch pattern: "bugfix/*";
                    branch pattern: "release/*";
                    branch pattern: "support/*";
                    tag pattern: "[\\w][\\w.-]{0,127}", comparator: "REGEXP" // Todas las tags de git, que cumplan las convenciones de nombre para Docker Image tag.
                } 
            }
            steps {
                echo "Crear y taguear imagen de Docker: ${IMAGE_FULL_NAME}"
                echo "Subir imagen de Docker a Registry..."
            }
            post {
                success {
                    // #0db7ed = Color insignia de Docker
                    slackSend color: "#0db7ed", message: "Docker Image published:\t${IMAGE_FULL_NAME}"
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