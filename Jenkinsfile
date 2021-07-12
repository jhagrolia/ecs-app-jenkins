pipeline {

    //By default, Use any Available Agent
    agent any

    //Specifying Triggers for Pipeline
    triggers {
        githubPush()
    }

    //Declaring Parameters for Pipeline
    parameters {
        booleanParam(name: 'SETUP_ECS_INFRA', defaultValue: true, description: 'Need to setup ECS Infrastructure again?')
    }

    stages {
        // Downloads Code from Github
        stage('GitPull'){
            steps{
                git branch: 'stable-1.0', url: 'https://github.com/jhagrolia/ecs-app-jenkins.git', credentialsId: 'GitECSRepoCreds'
            }
        }

        // Setup ECS Infrastructure
        stage('Setup ECS') {
            when {
                expression { params.SETUP_ECS_INFRA }
            }
            steps {
                dir("Infrastructure") {
                    sh "terraform init"
                    sh "terraform apply --auto-approve"
                }
            }
        }

        // Deploy App on ECS
        stage('Deploy App') {
            when {
                expression { params.SETUP_ECS_INFRA }
            }
            steps {
                echo "Hello!"
            }
        }
    }
}
