pipeline {
    
    agent none

    environment {
        COMPOSE_PROJECT_NAME = "${env.JOB_NAME}-${env.BUILD_ID}"
    }
    stages {
      
        stage('Build') {

            agent any

            steps {
                
                echo sh(script: 'env|sort', returnStdout: true)

                sh  '''
                    cd ./src && docker-compose -f ./docker-compose.yml -f ./docker-compose.prod.yml -f ./docker-compose.override.yml build 
               
                '''

            }

        }

        stage('Publish') {

            agent any

            // when { buildingTag() }

            steps {
                    
                sh  '''

                    docker push proget.valterbarbosa.com.br/docker-private-registry/eshop_on_containers:${BRANCH_NAME}

                    docker service update --image proget.valterbarbosa.com.br/docker-private-registry/eshop_on_containers:${BRANCH_NAME} eshop_on_containers
               
                '''

            }

        }


 
    }
    post {

        always {
            node('master'){
                
                sh  '''
               
                '''
            }
        }
    }
}