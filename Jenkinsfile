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
        stage('Test kubectl') {
            withKubeConfig([credentialsId: 'k8sConfig', serverUrl: "https://192.168.0.10:6443"]) {
                sh 'kubectl get all'
            }
        }
    }
}