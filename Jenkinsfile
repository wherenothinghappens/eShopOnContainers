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

            when { buildingTag() }

            steps {
                    
                sh  '''

                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webspa:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/locations.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webmvc:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webshoppingagg:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/ordering.signalrhub:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/mobileshoppingagg:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/marketing.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/basket.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/payment.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/catalog.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/identity.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/ordering.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/ordering.backgroundtasks:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.client:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.api:${BRANCH_NAME}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webstatus:${BRANCH_NAME}

                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webspa:${BRANCH_NAME} webspa
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/locations.api:${BRANCH_NAME} locations.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webmvc:${BRANCH_NAME} webmvc
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webshoppingagg:${BRANCH_NAME} webshoppingagg
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.signalrhub:${BRANCH_NAME} ordering.signalrhub
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/mobileshoppingagg:${BRANCH_NAME} mobileshoppingagg
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/marketing.api:${BRANCH_NAME} marketing.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/basket.api:${BRANCH_NAME} basket.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/payment.api:${BRANCH_NAME} payment.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/catalog.api:${BRANCH_NAME} catalog.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/identity.api:${BRANCH_NAME} identity.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.api:${BRANCH_NAME} ordering.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.backgroundtasks:${BRANCH_NAME} ordering.backgroundtasks
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.client:${BRANCH_NAME} webhooks.client
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.api:${BRANCH_NAME} webhooks.api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webstatus:${BRANCH_NAME} webstatus
               
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