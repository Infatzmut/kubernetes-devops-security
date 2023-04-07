PORT=$(kubectl -n default get svc ${serviceName} -o json | jq .spec.ports[].nodePort)

chmod 777 $(pwd)
echo $(id -u):$(id -g)
docker run -v $(pwd):/zap/wrk/:rw -t owasp/zap2docker-weekly zap-api-scan.py -t $applicationURL:$PORT/v3/api-docs -f openapi -r zap_report.html

# HTML Report 
sudo mkdir -p owasp-zap-report 
sudo mv zap_report.html owasp_zap_report.html

exit_code=$?
echo "Exit code: $exit_code"

if [[ $exit_code -ne 0 ]];then
    echo "OWASP ZAP report has either Low,Medium/High Risk. Please check html report"
else 
    echo "OWASP ZAP did not report any risk "
fi;