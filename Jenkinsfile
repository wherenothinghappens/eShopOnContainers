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

                    script {
                                    
                        def composeFiles = "-f ./src/docker-compose-tests.yml -f ./src/docker-compose-tests.override.yml";

                        sh "docker-compose $composeFiles -p test down -v --remove-orphans"

                        ["unit", "functional"].each{ type ->
                            
                            def tests = sh(script: "docker-compose $composeFiles --log-level ERROR config --services | grep $type", returnStdout: true).trim().split('\n')
                            
                            println "Searching for services..."
                            
                            def stepsForParallel = [:]

                            tests.each { test ->
                                stepsForParallel["testing $test"] = {
                                    node {
                                        stage ("tests") {
                                            sh "docker-compose $composeFiles -p test run $test"
                                        }
                                    }
                                }
                            }

                            parallel stepsForParallel 
                            
                            // tests.each { test ->
                            //     println "$test"
                            // }

                            // tests.each { test ->
                            //     sh "docker-compose $composeFiles -p test run $test"
                            // }
                        }

                        sh "docker-compose $composeFiles -p test down -v --remove-orphans"
                    }      
                }
                post {

                    always {
                            
                        xunit(
                            [MSTest(deleteOutputFiles: false,
                                    failIfNotNew: false,
                                    pattern: "*/tests-results/*.trx",
                                    skipNoTestFiles: false,
                                    stopProcessingIfError: true)
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

                        script{

                            //Coverlet hotfix

                            //https://github.com/coverlet-coverage/coverlet/pull/828/commits/8ca6a5901ddfb527d4274518be76b468356b011e

                            def CONTAINER_ROOT = "/app";
                            
                            sh """
        
                                sed -i 's#fullPath="$CONTAINER_ROOT#fullPath="$WORKSPACE/src#' */tests-results/*.coverage.xml

                            """
                        }

                        dir('./src/') {

                            sh  """

                                export PATH="$PATH:/root/.dotnet/tools"
                                
                                dotnet sonarscanner begin \
                                    /k:"eShop-On-Containers" \
                                    /d:sonar.host.url="$SONARQUBE_URL" \
                                    /d:sonar.login="$SONARQUBE_KEY" \
                                    /d:sonar.cs.opencover.reportsPaths="tests-results/*.coverage.xml" \
                                    /d:sonar.cs.vstest.reportsPaths="tests-results/*.trx" \
                                    /d:sonar.verbose=true \
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

            stage('Build Docker Images') {

                agent any

                steps {

                    script {

                        def composeFiles = "-f ./src/docker-compose.yml -f ./src/docker-compose.override.yml";
                        
                        sh "docker-compose $composeFiles build"
                    }
                }
            }

            stage('Publish Images to Registry') {

                agent any

                steps {

                    script {

                        println "Searching for images..."

                        def composeFiles = "-f ./src/docker-compose.yml -f ./src/docker-compose.override.yml";
                        
                        def images = sh(script: "docker-compose $composeFiles --log-level ERROR config | grep 'image: $REGISTRY' | awk '{print \$2}'", returnStdout: true).trim().split('\n')
                        
                        def stepsForParallel = [:]

                        images.each { image ->
                            stepsForParallel["pushing $image"] = {
                                node {
                                    stage ("tests") {
                                        sh "docker push $image"
                                    }
                                }
                            }
                        }

                        parallel stepsForParallel 
                    }
                }
            }

            stage('Update Service Images') {

                when { buildingTag() }

                agent any

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