#!bin/bash

# this can add dynamically nuget tools... dotnet add package coverlet.msbuild --version 2.9.0

export PATH="$PATH:/root/.dotnet/tools"

echo "Installing Tools"
dotnet tool install --global coverlet.console

echo "Adding Package"
dotnet add package coverlet.msbuild --version 2.9.0

echo "Running Tests"
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:CoverletOutput='./coverage/'

        # - dotnet
        # - test
        # - --configuration Debug
        # - --logger
        # - trx;LogFileName=/tests/basket-unit-test-results.trx
        # - /p:CoverletOutput=/tests/basket-unit-test-results.coverage.xml
        # - /p:CoverletOutputFormat=opencover
        # - /p:CollectCoverage=true
        # - /p:Exclude="[*.Tests]*"
# CMD [ "bash", "./build.sh" ]
# https://stackoverflow.com/questions/55759730/how-to-run-unit-test-coverage-report-using-coverlet-inside-a-container