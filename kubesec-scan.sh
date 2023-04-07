#!/bin/bash

#using kubesec v2 api 
scan_result=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan)
#echo "$scan_result"
scan_message=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].message -r )
scan_score=$(curl -sSX POST --data-binary @"k8s_deployment_service.yaml" https://v2.kubesec.io/scan | jq .[0].score )

# using kubesec docker image for scanning 
# scan_result=$(docker run -i kubesec/kubesec:512c5e0 scan /dev/stdin < k8s_deployment_service.yaml)
# scan_message=$($scan_result | jq .[0].message -r )
# scan_score=$($scan_result | jq .[0].score )

# kubesec scan result process 

if [[ $scan_score -ge 5 ]];then
    echo "Score is $scan_score"
    echo "Kubesec scan $scan_message"
else
    echo "Score is $scan_score, which is less or equal than 5"
    echo "Scanning kubernetes resource has failed"
    exit 1;
fi