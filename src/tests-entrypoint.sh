#!bin/bash
export PATH="$PATH:/root/.dotnet/tools"

# GO back to Tests folder
cd -

# Get project name
PROJECT_NAME="$(basename $(find . -wholename "*.csproj"))"

# Sonarqube .coverage.xml results
if ! grep -q '"coverlet.msbuild" Version="2.9.0"' $PROJECT_NAME; then
    echo "Adding [coverlet.msbuild 2.9.0] Package to $PROJECT_NAME"
    dotnet add package coverlet.msbuild --version 2.9.0
fi

echo "Running Tests to $PROJECT_NAME"

dotnet test \
--logger "trx;LogFileName=/tests/$PROJECT_NAME.trx" \
/p:CoverletOutput="/tests/$PROJECT_NAME.coverage.xml" \
/p:CoverletOutputFormat=opencover \
/p:CollectCoverage=true \
/p:Exclude="[*.Tests]*"