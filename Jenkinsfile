pipeline {
    agent any

    stages {
        stage('Cloning github repo') {
            steps {
                checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[url: 'https://github.com/vishvajeetswami8-source/Terraform-Automation.git']])
            }
        }

        stage('Ensure DynamoDB table') {
            steps {
                sh 'chmod +x ./scripts/ensure-dynamodb.sh || true'
                sh "./scripts/ensure-dynamodb.sh my-dynamodb-ta us-east-1"
            }
        }
    
         stage ("terraform init") {
             steps {
                 sh ("terraform init -reconfigure") 
             }
         }
        
        stage ("terraform Plan") {
            steps {
                sh ("terraform plan") 
            }
        }

        stage ("Action") {
            steps {
                echo "Terraform action is --> ${action}"
                sh ('terraform ${action} --auto-approve') 
           }
        }
    }
}
