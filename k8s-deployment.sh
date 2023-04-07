#!/bin/bash

sh "sed -i 's#replace#${imageName}#g' k8s_deployment_service.yaml"
# kubectl -n default get deployment ${deployment} > /dev/null

# if [[ $? -ne 0 ]]; then
#     echo "deployment ${deploymentName} does not exist"
#     sh "kubectl -n default apply -f k8s_deployment_service.yaml"
# else
#     echo "deployment ${deploymentName} exist"
#     echo "image name - ${imageName}"
#     kubectl -n default set image deploy ${deploymentName} ${containerName}=${imageName} --record=true
# fi

sh "kubectl -n default apply -f k8s_deployment_service.yaml"