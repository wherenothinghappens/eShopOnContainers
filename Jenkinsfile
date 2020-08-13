pipeline {
    
    agent none

    environment {
        COMPOSE_PROJECT_NAME = "${env.JOB_NAME}-${env.BUILD_ID}"
        REGISTRY = "proget.valterbarbosa.com.br/e-shop-on-containers"
        SONARQUBE_URL = "http://sonarqube.valterbarbosa.com.br"
    }

    stages {

        stage('Unit and Functional Tests ') {

            agent {

                docker {
                    image 'mcr.microsoft.com/dotnet/core/sdk:3.1'
                    args '-u root:root' 
                }
            }

            steps {

                sh 'find . -wholename "**/TestResults/*.trx" -delete'
                sh 'find . -wholename "**/TestResults/*.xml" -delete'
                sh 'find . -wholename "/output-coverage/*.coverage.xml" -delete'
                        
                dir('./src/') {

                    script {

                        def projetcs = [
                            './Services/Basket/Basket.UnitTests/Basket.UnitTests.csproj',
                            './Services/Catalog/Catalog.UnitTests/Catalog.UnitTests.csproj',
                            './Services/Ordering/Ordering.UnitTests/Ordering.UnitTests.csproj',
                        ]

                        for (int i = 0; i < projetcs.size(); ++i) {

                            //--results-directory /TestResults/
                            //--verbosity=normal 

                            // using trx for xUnit and MSTest and coverage to SonarQube

                            PROJECT_NAME = sh (
                                script: "basename ${projetcs[i]}", // | tr '.' _
                                returnStdout: true
                            ).trim()

                            echo "*************************** Gen ${PROJECT_NAME}.trx *********************************"

                            echo "*************************** Gen ${PROJECT_NAME}.coverage.xml ************************"
                            
                            sh """
                                dotnet test ${projetcs[i]} \
                                    --configuration Debug \
                                    --logger 'trx;LogFileName=log_${PROJECT_NAME}.trx' \
                                    --output ${WORKSPACE}/output-tests  \
                                    /p:CoverletOutput='${WORKSPACE}/output-coverage/${PROJECT_NAME}.coverage.xml' \
                                    /p:CoverletOutputFormat=opencover \
                                    /p:CollectCoverage=true \
                                    /p:Exclude="[*.Tests]*"
                            """
                        }
                    }
                }
            }
            post {

                always {

                    xunit(
                        [MSTest(deleteOutputFiles: true,
                                failIfNotNew: true,
                                pattern: '**/TestResults/*.trx',
                                skipNoTestFiles: false,
                                stopProcessingIfError: true)
                        ])
                }
            }
        }

        stage('Functional Tests ') {

            agent any

            when { buildingTag() }

            // agent {

            //     docker {
            //         image 'mcr.microsoft.com/dotnet/core/sdk:3.1'
            //         args '-u root:root' 
            //     }
            // }

            steps {
                
                dir('./src/') {

                    script {

                        def projetcs = [
                            //'./Services/Basket/Basket.FunctionalTests/Basket.FunctionalTests.csproj',
                            //'./Services/Catalog/Catalog.FunctionalTests/Catalog.FunctionalTests.csproj',
                            //'./Services/Location/Locations.FunctionalTests/Locations.FunctionalTests.csproj',
                            //'./Services/Marketing/Marketing.FunctionalTests/Marketing.FunctionalTests.csproj',
                            //'./Services/Ordering/Ordering.FunctionalTests/Ordering.FunctionalTests.csproj',
                            //'./Tests/Services/Application.FunctionalTests/Application.FunctionalTests.csproj',
                        ]

                        for (int i = 0; i < projetcs.size(); ++i) {

                            //--results-directory /TestResults/
                            //--verbosity=normal 

                            // using trx for xUnit and MSTest and coverage to SonarQube

                            PROJECT_NAME = sh (
                                script: "basename ${projetcs[i]}",
                                returnStdout: true
                            ).trim()

                            echo "*************************** Gen ${PROJECT_NAME}.trx *********************************"

                            echo "*************************** Gen ${PROJECT_NAME}.coverage.xml ************************"
                            
                            sh """
                                dotnet test ${projetcs[i]} \
                                    --configuration Debug \
                                    --logger 'trx;LogFileName=log_${PROJECT_NAME}.trx' \
                                    --output ${WORKSPACE}/output-tests  \
                                    /p:CoverletOutput='${WORKSPACE}/output-coverage/${PROJECT_NAME}.coverage.xml' \
                                    /p:CoverletOutputFormat=opencover \
                                    /p:CollectCoverage=true \
                                    /p:Exclude="[*.Tests]*"
                            """
                        }
                    }
                }
            }
            post {

                always {

                    xunit(
                        [MSTest(deleteOutputFiles: true,
                                failIfNotNew: true,
                                pattern: '**/TestResults/*.trx',
                                skipNoTestFiles: false,
                                stopProcessingIfError: true)
                        ])
                }
            }
        }
      
        stage('Static Analysis') {

            agent {
                dockerfile {
                    filename 'Dockerfile'
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
                                /d:sonar.cs.opencover.reportsPaths="${WORKSPACE}/output-coverage/*.coverage.xml" \
                                /d:sonar.coverage.exclusions="tests/**/*,Examples/**/*,**/*.CodeGen.cs" \
                                /d:sonar.test.exclusions="tests/**/*,Examples/**/*,**/*.CodeGen.cs" \
                                /d:sonar.exclusions="tests/**/*,Examples/**/*,**/*.CodeGen.cs"
                            
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