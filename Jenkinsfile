pipeline {
    
    agent none

    environment {
        COMPOSE_PROJECT_NAME = "${env.JOB_NAME}-${env.BUILD_ID}"
        REGISTRY = "proget.valterbarbosa.com.br/e-shop-on-containers"
    }

    stages {

        // stage('Build-Solution') {

        //     agent {
        //         dockerfile {
        //             // alwaysPull false
        //             // image 'microsoft/dotnet:2.2-sdk'
        //             // reuseNode false
        //             args '-u root:root'
        //         }
        //     }

        //     steps {
                
        //         echo sh(script: 'env|sort', returnStdout: true)

        //         sh 'dotnet build ./src/eShopOnContainers-ServicesAndWebApps.sln'

        //     }

        // }

      
        stage('Test') {

            agent {
                dockerfile {
                    // alwaysPull false
                    // image 'microsoft/dotnet:2.2-sdk'
                    // reuseNode false
                    args '-u root:root -v /var/run/docker.sock:/var/run/docker.sock'
                }
            }

            steps {

                 withCredentials([usernamePassword(credentialsId: 'SonarQube', passwordVariable: 'SONARQUBE_KEY', usernameVariable: 'DUMMY' )]) {

                    dir('./src/') {

                    def projetcs = [
                        './Services/Basket/Basket.UnitTests/Basket.UnitTests.csproj',
                        './Services/Catalog/Catalog.UnitTests/Catalog.UnitTests.csproj',
                        './Services/Ordering/Ordering.UnitTests/Ordering.UnitTests.csproj',
                        // './Services/Basket/Basket.FunctionalTests/Basket.FunctionalTests.csproj',
                        // './Services/Catalog/Catalog.FunctionalTests/Catalog.FunctionalTests.csproj',
                        // './Services/Location/Locations.FunctionalTests/Locations.FunctionalTests.csproj',
                        // './Services/Marketing/Marketing.FunctionalTests/Marketing.FunctionalTests.csproj',
                        // './Services/Ordering/Ordering.FunctionalTests/Ordering.FunctionalTests.csproj',
                        // './Tests/Services/Application.FunctionalTests/Application.FunctionalTests.csproj',
                    ]

                    sh  'export PATH="$PATH:/root/.dotnet/tools"'

                    for (int i = 0; i < projetcs.size(); ++i) {
                        sh """
                            dotnet test ${projetcs[i]} \
                                --configuration Debug \
                                --output ../output-tests  \
                                /p:CollectCoverage=true \
                                /p:CoverletOutputFormat=opencover \
                                /p:CoverletOutput='/output-coverage/coverage.xml' \
                                /p:Exclude="[*.Tests]*"
                        """
                    }

                    sh  '''
                        #docker-compose up -d
                        
                        #sleep 190

                        export PATH="$PATH:/root/.dotnet/tools"
                        
                        dotnet sonarscanner begin /k:"eShop-Basket-Service" \
                            /d:sonar.host.url="http://sonarqube.valterbarbosa.com.br" \
                            /d:sonar.login="$SONARQUBE_KEY" \
                            /d:sonar.cs.opencover.reportsPaths="/output-coverage/coverage.xml" \
                            /d:sonar.coverage.exclusions="tests/**/*,Examples/**/*,**/*.CodeGen.cs" \
                            /d:sonar.test.exclusions="tests/**/*,Examples/**/*,**/*.CodeGen.cs" \
                            /d:sonar.exclusions="tests/**/*,Examples/**/*,**/*.CodeGen.cs"
                        
                        dotnet build ./eShopOnContainers-ServicesAndWebApps.sln
                        
                        dotnet sonarscanner end /d:sonar.login="$SONARQUBE_KEY"
                        '''
                    }

                }
                
            }

        }

        stage('Build') {

            agent any

            steps {
                
                echo sh(script: 'env|sort', returnStdout: true)

                sh  'chmod +x -R ./deploy/jenkins/deploy-envsubst.sh'

                dir('./src/') {
                    sh '../deploy/jenkins/deploy-envsubst.sh'
                }

            }

        }

        stage('Publish') {

            agent any

            // when { buildingTag() }

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
                    // docker push ${REGISTRY}/webmarketing.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push ${REGISTRY}/webshopping.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push ${REGISTRY}/mobilemarketing.apigw:${PLATFORM:-linux}-${TAG:-latest}
                    // docker push ${REGISTRY}/mobileshopping.apigw:${PLATFORM:-linux}-${TAG:-latest}

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