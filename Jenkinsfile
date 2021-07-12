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
        //Downloads the code from GitHub then builds a Containerazied Application
        stage('Build') {
            steps {
                git branch: 'main', url: 'git@github.com:jhagrolia/ecs-app-jenkins.git', credentialsId: 'GitECSRepoCreds'

                step([$class: 'DockerBuilderPublisher', 
                    cleanImages: false,
                    cloud: 'docker',
                    dockerFileDirectory: 'Docker', 
                    pushCredentialsId: 'DockerhubCreds', 
                    pushOnSuccess: true, 
                    tagsString: 'jhagrolia/web:${BUILD_NUMBER}'])
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
                    //sh "terraform apply --auto-approve"
                }
            }
        }

        // Deploy App on ECS
        stage('Deploy App') {
            steps {
                dir("App") {
                    echo "hello"
                    //sh "terraform init"
                    //sh "terraform apply --auto-approve"
                }                
            }
        }
    }
}
