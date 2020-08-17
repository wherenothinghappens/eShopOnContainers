docker run -it -v $(pwd):/app \
-u root:root \
--network src_default \
-e ASPNETCORE_ENVIRONMENT=Development \
-e ASPNETCORE_URLS=http://0.0.0.0:80 \
-e ConnectionString="Server=sql-data-test;Database=Microsoft.eShopOnContainers.Services.OrderingDb;User Id=sa;Password=Pass@word" \
-e identityUrl=http://identity-api-test \
-e IdentityUrlExternal=http://localhost:5105 \
-e EventBusConnection=rabbitmq-test \
-e EventBusUserName=a4pEQTjbY8aKtNBGLKRdbd91Fpp \
-e EventBusPassword=NzCNF1oJ6zQYqIKPM2E46LY$L54OP%s \
-e UseCustomizationData=True \
-e AzureServiceBusEnabled=False \
-e CheckUpdateTime=30000 \
-e UseLoadTest=False \
mcr.microsoft.com/dotnet/core/sdk:3.1