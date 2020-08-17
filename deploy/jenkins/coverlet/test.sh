#!bin/bash

# this can add dynamically nuget tools...

export PATH="$PATH:/root/.dotnet/tools"

echo "Installing Tools"
dotnet tool install --global coverlet.console

echo "Adding Package"
dotnet add package coverlet.msbuild

echo "Running Tests"
dotnet test /p:CollectCoverage=true /p:CoverletOutputFormat=opencover /p:CoverletOutput='./coverage/'

# CMD [ "bash", "./build.sh" ]
# https://stackoverflow.com/questions/55759730/how-to-run-unit-test-coverage-report-using-coverlet-inside-a-container