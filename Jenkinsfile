pipeline {
    
    agent none

    environment {
        COMPOSE_PROJECT_NAME = "${env.JOB_NAME}-${env.BUILD_ID}"
        REGISTRY = "proget.valterbarbosa.com.br/e-shop-on-containers"
        SONARQUBE_URL = "http://sonarqube.valterbarbosa.com.br"
    }

    stages {

        stage('Running Tests') {
            
            agent any

            steps{

                dir('./src/') {
                    
                    script {
                                    
                        def composeFiles = "-f ./docker-compose-tests.yml -f ./docker-compose-tests.override.yml";

                        sh "docker-compose $composeFiles -p test down --remove-orphans"
                        //"unit", "functional"
                        ["ordering-api-unit-test"].each{ type ->
                            
                            println "Searching for services..."

                            def tests = sh(script: "docker-compose $composeFiles --log-level ERROR config --services | grep $type", returnStdout: true).trim().split('\n')
                            tests.each { test ->
                                println "$test"
                            }

                            tests.each { test ->
                                sh "docker-compose $composeFiles -p test run $test"
                            }
                        }

                        sh "docker-compose $composeFiles -p test down --remove-orphans"
                    }      
                }
            }
            post {

                always {

                    xunit(
                        [MSTest(deleteOutputFiles: true,
                                failIfNotNew: false,
                                pattern: "*/tests-results/*.trx",
                                skipNoTestFiles: false,
                                stopProcessingIfError: false)
                        ])
                }
            }
        }

        stage('Static Analysis') {

            agent {
                dockerfile {
                    filename 'Dockerfile.SonarQube'
                    args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }

            steps {

                 withCredentials([usernamePassword(credentialsId: 'SonarQube', passwordVariable: 'SONARQUBE_KEY', usernameVariable: 'DUMMY' )]) {

                    dir('./src/') {

                        sh  """

                            export PATH="$PATH:/root/.dotnet/tools"
                            
                            dotnet sonarscanner begin \
                                /k:"eShop-On-Containers" \
                                /d:sonar.host.url="$SONARQUBE_URL" \
                                /d:sonar.login="$SONARQUBE_KEY" \
                                /d:sonar.cs.opencover.reportsPaths="tests-results/*.coverage.xml" \
                                /d:sonar.cs.vstest.reportsPaths="tests-results/*.trx" \
                                /d:sonar.coverage.exclusions="*/*/*Tests/*,*/*/*/*/*igrations/*" \
                                    /d:sonar.test.exclusions="*/*/*Tests/*,*/*/*/*/*igrations/*" \
                                         /d:sonar.exclusions="*/*/*Tests/*,*/*/*/*/*igrations/*"
                            
                            dotnet build ./eShopOnContainers-ServicesAndWebApps.sln
                            
                            dotnet sonarscanner end /d:sonar.login="$SONARQUBE_KEY"

                            """
                    }
                }
            }
        }

        stage('Build') {

            agent any

            when { buildingTag() }

            steps {
                // echo sh(script: 'env|sort', returnStdout: true)
                sh  'chmod +x -R ./deploy/jenkins/deploy-envsubst.sh'

                dir('./src/') {
                    sh '../deploy/jenkins/deploy-envsubst.sh'
                }
            }
        }

        stage('Publish') {

            agent any

            when { buildingTag() }

            steps {
                    
                sh  '''

                    docker push ${REGISTRY}/webspa:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/locations.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/webmvc:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/webshoppingagg:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/ordering.signalrhub:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/mobileshoppingagg:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/marketing.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/basket.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/payment.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/catalog.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/identity.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/ordering.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/ordering.backgroundtasks:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/webhooks.client:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/webhooks.api:${PLATFORM:-linux}-${TAG:-latest}
                    docker push ${REGISTRY}/webstatus:${PLATFORM:-linux}-${TAG:-latest}
                   
                '''
                    // docker push ${REGISTRY}/webmarketing.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push ${REGISTRY}/webshopping.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push ${REGISTRY}/mobilemarketing.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push ${REGISTRY}/mobileshopping.apigw:${PLATFORM:-linux}-${TAG:-latest}
            }
        }

        stage('Deploy') {

            agent any

            when { buildingTag() }

            steps {
                    
                sh  '''

                    docker service update --image ${REGISTRY}/webspa:${PLATFORM:-linux}-${TAG:-latest} eshop_webspa
                    docker service update --image ${REGISTRY}/locations.api:${PLATFORM:-linux}-${TAG:-latest} eshop_locations-api
                    docker service update --image ${REGISTRY}/webmvc:${PLATFORM:-linux}-${TAG:-latest} eshop_webmvc
                    docker service update --image ${REGISTRY}/webshoppingagg:${PLATFORM:-linux}-${TAG:-latest} eshop_webshoppingagg
                    docker service update --image ${REGISTRY}/ordering.signalrhub:${PLATFORM:-linux}-${TAG:-latest} eshop_ordering-signalrhub
                    docker service update --image ${REGISTRY}/mobileshoppingagg:${PLATFORM:-linux}-${TAG:-latest} eshop_mobileshoppingagg
                    docker service update --image ${REGISTRY}/marketing.api:${PLATFORM:-linux}-${TAG:-latest} eshop_marketing-api
                    docker service update --image ${REGISTRY}/basket.api:${PLATFORM:-linux}-${TAG:-latest} eshop_basket-api
                    docker service update --image ${REGISTRY}/payment.api:${PLATFORM:-linux}-${TAG:-latest} eshop_payment-api
                    docker service update --image ${REGISTRY}/catalog.api:${PLATFORM:-linux}-${TAG:-latest} eshop_catalog-api
                    docker service update --image ${REGISTRY}/identity.api:${PLATFORM:-linux}-${TAG:-latest} eshop_identity-api
                    docker service update --image ${REGISTRY}/ordering.api:${PLATFORM:-linux}-${TAG:-latest} eshop_ordering-api
                    docker service update --image ${REGISTRY}/ordering.backgroundtasks:${PLATFORM:-linux}-${TAG:-latest} eshop_ordering-backgroundtasks
                    docker service update --image ${REGISTRY}/webhooks.client:${PLATFORM:-linux}-${TAG:-latest} eshop_webhooks-client
                    docker service update --image ${REGISTRY}/webhooks.api:${PLATFORM:-linux}-${TAG:-latest} eshop_webhooks-api
                    docker service update --image ${REGISTRY}/webstatus:${PLATFORM:-linux}-${TAG:-latest} eshop_webstatus
                   
                '''
                    // docker service update --image ${REGISTRY}/webmarketing.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_webmarketingapigw
                    // docker service update --image ${REGISTRY}/webshopping.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_webshoppingapigw
                    // docker service update --image ${REGISTRY}/mobilemarketing.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_mobilemarketingapigw
                    // docker service update --image ${REGISTRY}/mobileshopping.apigw:${PLATFORM:-linux}-${TAG:-latest} eshop_mobileshoppingapigw
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