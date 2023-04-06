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
            post {
              always {
                junit "target/surefire-reports/*.xml"
                jacoco execPattern: 'target/jacoco.exec'
              }
            }
        }

      stage('Mutation Test - PIT ') {
        steps {
          sh 'mvn org.pitest:pitest-maven:mutationCoverage'
        }
        post {
          always {
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
          }
        }
      }

      stage('Sonarqube Test - SAST') {
        steps {
          sh "mvn clean verify sonar:sonar -Dsonar.projectKey=devsecops-numeric-application -Dsonar.projectName='devsecops-numeric-application' -Dsonar.host.url=http://localhost:9000 -Dsonar.token=sqp_d51393f0240351954da2dbbc030d01501792fb15"
        }
      }
      stage('Docker build and push') {
          steps {
            withDockerRegistry([credentialsId: "docker-hub", url: ""]){
              sh 'printenv'
              sh 'docker build -t fabz26/numeric-app:""$GIT_COMMIT"" .'
              sh 'docker push fabz26/numeric-app:""$GIT_COMMIT""'
            }
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
}
