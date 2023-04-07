pipeline {
  agent any

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
          sh 'docker run --rm -v $(pwd):/project openpolictyagent/conftest test --policy opa-k8s-security.rego k8s_deployment_service.yaml'
        }
      }

      // stage('Kubernetes deployment - Dev') {
      //     steps {
      //       withKubeConfig([credentialsId: "kubeconfig"]){
      //         sh "sed -i 's#replace#fabz26/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
      //         sh "kubectl apply -f k8s_deployment_service.yaml"
      //       }
      //     }
      // }        
    }

    post {
      always {
        junit "target/surefire-reports/*.xml"
        pitmutation mutationStatsFile: "**/target/pit-reports/**/mutations.xml"
        jacoco execPattern: 'target/jacoco.exec'
        dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
      }

      // success {

      // }

      // failure {

      // }
    } 
}
