<img src="https://raw.githubusercontent.com/jhagdu/images/main/Jenkins%20ECS.jpg" height=400 width=600 alt="Jenkins ECS" /> 

# Deploy ECS App

Jenkins Pipeline to build and deploy a containerized application on ECS Cluster  
Here terraform is used for provisioning the ECS Infrastructure

### The 3 Stages of Pipeline -  

**S.No.** | **Stage Name** | **Stage Description**
------------- | -------------------- | --------------------------------------
**1** | **Build** | Downloads the code from GitHub, Builds a containerized application, Publish it to centralised container registry
**2** | **Setup ECS** | Setup/Provision the ECS Cluster
**3** | **Deploy App** | Deploy application on ECS Cluster i.e. creates Task defination, ECS Service, Loadbalancers, etc

## Prerequisites   
- Jenkins should be installed and configured
- Docker and Git should be installed and configured to work with Jenkins

## Pipeline Workflow
- Triggers: For triggering the pipeline GitHub Webhooks are used i.e. Pipeline will be triggered as soon as developers commits/push new code
- Downloads the pipeline and infrastructure code from github repository
- Builds an container image using Dockerfile and push it to centerlised container registry (i.e. Dockerhub by default)
- Launchs and Amazon ECS Cluster
- Create Task definations and ECS Service and deploy that containerized application
- Create Security Groups and Public Loadbalancer for the application service

## Variables Used

### Jenkinsfile Parameters
- SETUP_ECS_INFRA - It is a boolean parameter asking weather to deploy ECS Cluster again or not. By default it's 'true'. If cluster is already launched and in pipeline run we only need to update the website then we can set it to 'false'.  
- IMAGE_NAME - Container Image name to build and push. Must include registery/repo url.

### Terraform ECS Infrastructure Variables

**Variable Name** | **Type** | **Default Value** | **Variable Description**
--------------------- | ----------- | ------------------- | ----------------------------------------------
**cluster_name** | String | cluster1 | Name of the ECS Cluster
**vpc_id** | String | Default VPC ID | Pass ID of VPC to be used
**task_family** | String | webtask | ECS Task Family Name
**image_name** | String | IMAGE_NAME Jenkinsfile Parameter | Container Image Name to deploy
**port** | Number | 80 | Exposed Container Port, Loadbalancer/Service port
**lb_protocol** | String | HTTP | Loadbalancer Protocol 
**task_mem** | Number | 2048 | Memory for Task
**task_cpu** | Number | 1024 | CPU for Task
**desired_count** | Number | 3 | Desired Replicas of Task to run

### For any other needs
- Directly do the changes in terraform codes  
- Variables values can be changed in variable.tf file or can be overridden by passing variable value using -var option to 'terraform apply' command in Jenkinsfile

## How to Use  
- Create a Pipeline Job in Jenkins  
- Update the Jenkinsfile and Terraform variables and code according to requirement
- For adding new services/infrastructure add more resources to terraform code
- Also add custom Dockerfile to build image as per requirements
- Add credentials in Jenkins and update ID of them in Jenkinsfile (Container Repository creds are required to push image)
- Configure it with Jenkinsfile Code or directly with this Github Repository  
- For automatic triggering of Pipeline, Configure Github Webhooks  

## Contribute
- Improve documentation  
- Review code and feature proposals  
- Add New features  

# Further Reference and Contact  

[Also See: Jenkins Pipeline to provide an End to End Automation i.e. Build, Test, Deploy, Monitor, Analyze and Auto Scale the Web Infrastructure](https://github.com/jhagdu/project-devops-al)

***Feel free to Contact if any issue!!***

<a href="https://www.linkedin.com/in/amanjhagrolia143" target="_blank"> <img src="https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white" /> </a>
