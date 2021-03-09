    pipeline {
        
        agent none

        environment {
            COMPOSE_PROJECT_NAME = "${env.JOB_NAME}-${env.BUILD_ID}"
            // REGISTRY = [“Manage Jenkins -> Configure System -> Global properties option”]
            // SONARQUBE_URL = [“Manage Jenkins -> Configure System -> Global properties option”]
        }

        stages {

            stage('Running Tests') {
                    
                agent any

                steps{

                    echo sh(script: 'env|sort', returnStdout: true)

                    dir('./src/') {

                        script {

                            def composeFiles = "-f ./docker-compose-tests.yml -f ./docker-compose-tests.override.yml -f ./docker-compose-tests.override.jenkins.yml";

                            // TODO: 
                            println "Prevent any port conflicts. Need to open machine firewall at range 7000-7002..."

                            sh """
                                sed -i 's;"5433:1433";"1433";' ./docker-compose-tests.override.yml
                                sed -i 's;"6379:6379";"6379";' ./docker-compose-tests.override.yml
                                sed -i 's;"27017:27017";"27017";' ./docker-compose-tests.override.yml
                                sed -i 's;"6379:6379";"6379";' ./docker-compose-tests.override.yml
                                sed -i 's;"15672:15672";"15672";' ./docker-compose-tests.override.yml
                                sed -i 's;"5672:5672";"5672";' ./docker-compose-tests.override.yml
                                sed -i 's;5105;7000;' ./docker-compose-tests.override.yml
                                sed -i 's;5120;7001;' ./docker-compose-tests.override.yml
                                sed -i 's;5112;7002;' ./docker-compose-tests.override.yml
                            """

                            // Clean environment
                            sh "docker-compose $composeFiles -p test down -v --remove-orphans"

                            // Up test infrastructure
                            sh "docker-compose $composeFiles -p test up -d sql-data-test nosql-data-test basket-data-test rabbitmq-test identity-api-test payment-api-test"

                            // Parallel tests
                            ["unit", "functional"].each{ type ->
                                
                                def tests = sh(script: "docker-compose $composeFiles --log-level ERROR config --services | grep $type", returnStdout: true).trim().split('\n')
                                
                                println "Searching for services..."
                                
                                def stepsForParallel = [:]

                                tests.each { test ->
                                    stepsForParallel["testing $test"] = {
                                        //EventBusConnection=rabbitmq-test:: In Production we use stack prefix "eshop_"...
                                        sh "docker-compose $composeFiles -p test run -e EventBusConnection=rabbitmq-test $test"
                                    }
                                }

                                parallel stepsForParallel 
                            }

                            sh "docker-compose $composeFiles -p test down -v --remove-orphans"
                        }      
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
                        args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock' //Coverlet hotfix (OPTION 1): -v ${WORKSPACE}:/app :: ISN'T WORKING (https://issues.jenkins-ci.org/browse/JENKINS-42369)
                    }
                }

                steps {

                    withCredentials([usernamePassword(credentialsId: 'SonarQube', passwordVariable: 'SONARQUBE_KEY', usernameVariable: 'DUMMY' )]) {

                        //Coverlet hotfix (OPTION 2)
                        //https://github.com/coverlet-coverage/coverlet/pull/828/commits/8ca6a5901ddfb527d4274518be76b468356b011e
                        script {

                            def CONTAINER_ROOT = "/src";
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
                    
                    dir('./src/') {

                        script {

                            def composeFiles = "-f ./docker-compose.yml -f ./docker-compose.override.yml";
                            
                            sh "docker-compose $composeFiles build"
                        }
                    }
                }
            }

            /*
            
            REMOTE PULL AND PUSH
            
                stage('Publish') {

                    agent any

                    when { buildingTag() }


                    steps {
                        
                        sh  '''

                            docker tag registry.oragon.io/jornada_gago_io/jornada-webapp:${BRANCH_NAME:-master} registry.oragon.io/jornada_gago_io/jornada-webapp:latest

                            docker push registry.oragon.io/jornada_gago_io/jornada-webapp:${BRANCH_NAME:-master} 
                            
                            docker push registry.oragon.io/jornada_gago_io/jornada-webapp:latest
                    
                        '''

                        withCredentials(bindings: [sshUserPrivateKey(credentialsId: 'SERVER_ADMIN', \
                                                    keyFileVariable: 'SERVER_ADMIN_KEY', \
                                                    passphraseVariable: 'SERVER_ADMIN_PWD', \
                                                    usernameVariable: 'SERVER_ADMIN_USER')]) {
                            sh  '''
                            
                            ssh -p 7777 -i $SERVER_ADMIN_KEY $SERVER_ADMIN_USER@oragon02.oragon.io docker pull registry.oragon.io/jornada_gago_io/jornada-webapp:${BRANCH_NAME:-master}

                            ssh -p 7777 -i $SERVER_ADMIN_KEY $SERVER_ADMIN_USER@oragon02.oragon.io docker service update --image registry.oragon.io/jornada_gago_io/jornada-webapp:${BRANCH_NAME:-master}  --env-add NODE_ID="{{.Node.ID}}" --env-add APP_VERSION=${BRANCH_NAME:-master} jornada_jornada_gago_io

                            '''
                        }                

                    }

                }

            */

            stage('Publish Images to Registry') {

                agent any

                steps {

                    dir('./src/') {

                        script {

                            println "Searching for images..."

                            def composeFiles = "-f ./docker-compose.yml -f ./docker-compose.override.yml";
                            
                            def images = sh(script: "docker-compose $composeFiles --log-level ERROR config | grep 'image: $REGISTRY' | awk '{print \$2}'", returnStdout: true).trim().split('\n')
                            
                            def stepsForParallel = [:]

                            images.each { image ->
                                stepsForParallel["pushing $image"] = {
                                    sh "docker push $image"
                                }
                            }

                            parallel stepsForParallel 
                        }
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