
echo $imageName

docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 image --exit-code 0 --severity LOW,MEDIUM,HIGH --light $imageName
docker run --rm -v $WORKSPACE:/root/.cache/ aquasec/trivy:0.17.2 image --exit-code 1 --severity CRITICAL --light $imageName

exit_code=$?
echo "Exit code: $exit_code"

# Check scan results 
if [[ "{$exit_code}" == 1 ]];then
    echo "Image scanning failed. Vulnerabilities found"
    exit 1 
else 
    echo "Image scannning passed. No CRITICAL vulnerabilites found"
fi;