def SERVICE_NAME = "test-app"
pipeline {
    agent any
    environment {
        IMAGE_TAG = 'unknown'
    }
    stages {
        stage("Init") {
            steps {
                echo "Pipeline started: <${env.BUILD_URL}|${env.JOB_NAME} #${env.BUILD_NUMBER}> for branch <${env.GIT_URL}|${env.BRANCH_NAME}>"
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
                    def feature = env.BRANCH_NAME =~ /feature\/(\S+)/
                    if (feature[0][1]) {
                        env.IMAGE_TAG = feature
                    }
                }
                echo "Crear y taguear imagen de Docker: ${SERVICE_NAME}:${IMAGE_TAG}"
                echo "Subir imagen de Docker a Registry..."
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