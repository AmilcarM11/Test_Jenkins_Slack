def SERVICE_NAME = "test-app"
pipeline {
    agent any
    stages {
        stage("Init") {
            steps {
                slackSend message: "Pipeline started: <${env.BUILD_URL}|${SERVICE_NAME} #${env.BUILD_NUMBER}> for branch <${env.GIT_URL}|${env.BRANCH_NAME}>"
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
                script {
                    IMAGE_TAG = 'unknown'
                    def matcher = (env.BRANCH_NAME =~ /feature\/(\S+)/)
                    def feature = matcher ? matcher[0][1] : "not-found"
                    echo "Feature: ${feature}"
                    if (feature != null) {
                        IMAGE_TAG = feature
                    }
                    echo "Valor interno es : ${IMAGE_TAG}"

                    IMAGE_NAME_AND_TAG = "${SERVICE_NAME}:${IMAGE_TAG}"
                }
                echo "Crear y taguear imagen de Docker: ${SERVICE_NAME}:${IMAGE_TAG}"
                echo "Subir imagen de Docker a Registry..."
            }
            post {
                success {
                    slackSend color: "#0db7ed", message: "Docker Image published: ${IMAGE_NAME_AND_TAG}"
                }
            }
        }
        // stage("Deploy Feature") {
        //     when { branch pattern: "feature/", comparator: "REGEXP" }
        //     // when { branch pattern: "/^feature/(\S+)$/i", comparator: "REGEXP" }
        //     steps {
        //         echo "Este Pipeline es de la Feature: ${env.BRANCH_NAME}"
        //     }
        // }
        stage("Deploy QA") {
            when { branch 'develop' }
            steps {
                echo "Este Pipeline es de Develop."
            }
        }
    }
}