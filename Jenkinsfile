pipeline {
  agent any

  environment {
    deploymentName = "devsecops"
    containerName = "devsecops-container"
    serviceName = "devsecops-svc"
    imageName = "fabz26/numeric-app:${GIT_COMMIT}"
    applicationURL="http://192.168.18.154"
    aplicationURI="/increment/99"
  }
  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }

      stage('Unit Test') {
            steps {
              sh "mvn test"
            }
        }

      stage('Mutation Test - PIT ') {
        steps {
          sh 'mvn org.pitest:pitest-maven:mutationCoverage'
        }
      }

      stage('Sonarqube Test - SAST') {
        steps {
          withSonarQubeEnv('SonarQube'){
            sh "mvn clean verify sonar:sonar -Dsonar.projectKey=devsecops-numeric-application -Dsonar.projectName='devsecops-numeric-application' -Dsonar.host.url=http://localhost:9000"
          }
          timeout(time: 2, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
        }
      }

      stage('Dependency check'){
        steps {
          parallel(
            "Dependency Scan" : {
                sh 'mvn dependency-check:check' 
            },
            "Trivy Scan": {
              sh "bash trivy-docker-image-scan.sh"
            },
            "OPA conftest": {
              sh 'docker run --rm -v $(pwd):/project openpolicyagent/conftest test --policy opa-docker-security.rego Dockerfile'
            }
          )
        }
      }

      stage('Docker build and push') {
          steps {
            withDockerRegistry([credentialsId: "docker-hub", url: ""]){
              sh 'printenv'
              sh 'sudo docker build -t fabz26/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push fabz26/numeric-app:""$GIT_COMMIT""'
            }
          }
      }

      stage('Vulnerability Scan - Kubernetes') {
        steps {
          parallel(
            "OPA Scan": {
              sh 'docker run --rm -v $(pwd):/project openpolictyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
            },
            "Kubesec scan": {
              sh "bash kubesec-scan.sh"
            },
            "Trivy Scan": {
              sh "bash trivy-k8s-scan.sh"
            }
          )
        }
      }

      // stage('OWASP ZAP - DAST'){
      //   steps {
      //     withKubeConfig([credentialsId: 'kubeconfig']){
      //       sh 'bash zap.sh'
      //     }
      //   }
      // }

      // stage('Kubernetes deployment - Dev') {
      //     steps {
      //        parallel(
                  // "Deployment": {
            //       withKubeConfig([credentialsId: "kubeconfig"]){
                      //  sh "bash k8s-deployment.sh"
                      //  }
                  // }, 
                  // "Rollout Status" : {
                  //   withKubeConfig([credentialsId: "kubeconfig"]) {
                  //     sh "bash k8s-deployment-rollout-status.sh"
                  //   }
                  // }

      )
      //     }
      // }        
    }

    post {
      always {
        junit "target/surefire-reports/*.xml"
        pitmutation mutationStatsFile: "**/target/pit-reports/**/mutations.xml"
        jacoco execPattern: 'target/jacoco.exec'
        dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        publishHTML([allowMissing: false, alwaysLinkToLastBuild: true, keepAll: true, reportDir: 'owasp-zap-report', reportFiles: 'zap_report.html', reportName: 'OWASP ZAP HTML Report', reportTitles: 'OWASP ZAP HTML Report'])
      }

      // success {

      // }

      // failure {

      // }
    } 
}
