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
        string(name: 'IMAGE_NAME', defaultValue: 'jhagrolia/web', description: 'Container Image name to build and push')
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
                    tagsString: '${ params.IMAGE_NAME }:${BUILD_NUMBER}'])
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
            steps {
                dir("App") {
                    sh "terraform init"
                    sh "terraform apply --auto-approve -var '${ params.IMAGE_NAME }:${BUILD_NUMBER}'"
                }                
            }
        }
    }
}
