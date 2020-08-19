#!bin/bash
export PATH="$PATH:/root/.dotnet/tools"

# GO back to Tests folder
cd -

# Get project name
PROJECT_NAME="$(basename $(find . -wholename "*.csproj"))"

echo "Installing Tools to $PROJECT_NAME"
# dotnet tool install --global coverlet.console

echo "Adding Package to $PROJECT_NAME"
# dotnet add package coverlet.msbuild --version 2.9.0

echo "Running Tests to $PROJECT_NAME"

dotnet test \
--logger "trx;LogFileName=/tests/$PROJECT_NAME.trx" \
/p:CoverletOutput="/tests/$PROJECT_NAME.coverage.xml" \
/p:CoverletOutputFormat=opencover \
/p:CollectCoverage=true \
/p:Exclude="[*.Tests]*"

# command: sh -c "cd / && ./tests-entrypoint.sh"