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
                    chmod +x -R ./deploy/jenkins/deploy-envsubst.sh
                    cd ./src
                    ../deploy/jenkins/deploy-envsubst.sh
                '''

            }

        }

        stage('Publish') {

            agent any

            // when { buildingTag() }

            steps {
                    
                sh  '''

                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webspa:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/locations.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webmvc:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webshoppingagg:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/ordering.signalrhub:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/mobileshoppingagg:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/marketing.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/basket.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/payment.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/catalog.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/identity.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/ordering.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/ordering.backgroundtasks:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.client:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push proget.valterbarbosa.com.br/e-shop-on-containers/webstatus:${PLATFORM:-linux}-${TAG:-latest}

                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webspa:${PLATFORM:-linux}-${TAG:-latest} eshop_webspa
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/locations.api:${PLATFORM:-linux}-${TAG:-latest} eshop_locations-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webmvc:${PLATFORM:-linux}-${TAG:-latest} eshop_webmvc
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webshoppingagg:${PLATFORM:-linux}-${TAG:-latest} eshop_webshoppingagg
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.signalrhub:${PLATFORM:-linux}-${TAG:-latest} eshop_ordering-signalrhub
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/mobileshoppingagg:${PLATFORM:-linux}-${TAG:-latest} eshop_mobileshoppingagg
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/marketing.api:${PLATFORM:-linux}-${TAG:-latest} eshop_marketing-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/basket.api:${PLATFORM:-linux}-${TAG:-latest} eshop_basket-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/payment.api:${PLATFORM:-linux}-${TAG:-latest} eshop_payment-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/catalog.api:${PLATFORM:-linux}-${TAG:-latest} eshop_catalog-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/identity.api:${PLATFORM:-linux}-${TAG:-latest} eshop_identity-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.api:${PLATFORM:-linux}-${TAG:-latest} eshop_ordering-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/ordering.backgroundtasks:${PLATFORM:-linux}-${TAG:-latest} eshop_ordering-backgroundtasks
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.client:${PLATFORM:-linux}-${TAG:-latest} eshop_webhooks-client
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webhooks.api:${PLATFORM:-linux}-${TAG:-latest} eshop_webhooks-api
                    docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webstatus:${PLATFORM:-linux}-${TAG:-latest} eshop_webstatus
                   
                '''
                    // docker push proget.valterbarbosa.com.br/e-shop-on-containers/webmarketing.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push proget.valterbarbosa.com.br/e-shop-on-containers/webshopping.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push proget.valterbarbosa.com.br/e-shop-on-containers/mobilemarketing.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push proget.valterbarbosa.com.br/e-shop-on-containers/mobileshopping.apigw:${PLATFORM:-linux}-${TAG:-latest}

                    // docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webmarketing.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_webmarketingapigw
                    // docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/webshopping.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_webshoppingapigw
                    // docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/mobilemarketing.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_mobilemarketingapigw
                    // docker service update --image proget.valterbarbosa.com.br/e-shop-on-containers/mobileshopping.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_mobileshoppingapigw
                    

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