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

                // docker stack deploy --compose-file ./docker-compose.yml -c ./docker-compose.prod.yml -c ./docker-compose.override.yml eshop

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

                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webspa:${BRANCH_NAME} eshop_webspa
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/locations.api:${BRANCH_NAME} eshop_locations-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webmvc:${BRANCH_NAME} eshop_webmvc
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webshoppingagg:${BRANCH_NAME} eshop_webshoppingagg
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.signalrhub:${BRANCH_NAME} eshop_ordering-signalrhub
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/mobileshoppingagg:${BRANCH_NAME} eshop_mobileshoppingagg
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/marketing.api:${BRANCH_NAME} eshop_marketing-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/basket.api:${BRANCH_NAME} eshop_basket-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/payment.api:${BRANCH_NAME} eshop_payment-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/catalog.api:${BRANCH_NAME} eshop_catalog-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/identity.api:${BRANCH_NAME} eshop_identity-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.api:${BRANCH_NAME} eshop_ordering-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.backgroundtasks:${BRANCH_NAME} eshop_ordering-backgroundtasks
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.client:${BRANCH_NAME} eshop_webhooks-client
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.api:${BRANCH_NAME} eshop_webhooks-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webstatus:${BRANCH_NAME} eshop_webstatus
               
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