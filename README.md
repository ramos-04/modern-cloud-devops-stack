# Modern-Cloud-Devops-Stack

## Introduction 

This repository hosts a URL shortener application deployed on an Amazon EKS cluster, showcasing a modern Cloud and DevOps architecture built entirely with Infrastructure as Code (Terraform). It features a pull-based GitOps CI/CD model, integration of IaC and GitOps using GitOps Dev Bridge, dynamic scaling via Karpenter, robust authentication, in-flight data encryption, comprehensive monitoring, and protection from malicious attacks using AWS WAF.


## Overview of Goals Achieved

- **Infrastructure as Code(IaC)**: We are using IaC(Terraform) to provision an Amazon EKS cluster and bootstrap GitOps in it using GitOps Dev Bridge. Beyond the cluster, Terraform also manages other critical AWS resources such as the Application Load Balancer (ALB), Cognito, VPC, DynamoDB, Elastic Container Registry (ECR), IAM, and WAF. Managing environments effectively in Infrastructure as Code (IaC) is paramount, directly impacting ***consistency, minimizing code duplication, enhancing reusability, improving collaboration, and ensuring robust Terraform state management***. Below lie different strategies to manage environments using Terraform - 

	  1. Terraform Workspaces feature
	  2. Separate Folders with Common Modules
	  3. Terragrunt

  Well, the above approaches can be compared in detail with their pros and cons and you can choose the one which best suits your requirements. In this stack, we will be choosing the second approach which is the most recommended, commonly followed and one of the best practice approaches. 

- **GitOps Dev Bridge**: It is a controller which is used to create a bridge between IAC and GitOps to automate the ***end-to-end GitOps bootstrapping without manual steps*** and ***inject configurations*** from Terraform(IaC) to Kubernetes applications(GitOps). This tool acts as a CRD-aware bridge between Terraform and ArgoCD, enabling zero-touch bootstrapping of your ArgoCD Application Resource from Git. Using this tool, you can eliminate the manual steps required in bootstrapping GitOps.

  1. Use Terraform(IaC) for below actions:
     
		 1. Provision Cloud resources like VPC, IAM, OIDC, EKS cluster, etc.
		 2. Bootstrap GitOps in the EKS cluster using GitOps Dev Bridge.

  2. Use GitOps for below actions:
     
		 1. Monitor the Git repository for the ArgoCD Applications manifest for application and cluster add-on workloads.
		 2. Automatically apply the ArgoCD applications to the cluster (no kubectl or manual action required), which results in the automatic deployment of all the applications as well as cluster add-ons workload .
     
- **Application exposed as a public endpoint**: We have containerised the application using Docker and running it in an EKS cluster in the form of containers(pods) using an orchestration platform like Kubernetes. We have installed AWS Load Balancer Controller within the cluster which helps the application to be exposed to the public Internet using an external AWS Application Load balancer(ALB). By default, AWS Load Balancer Controller itself provisions an ALB and manages it's lifecycle, however, it will be a good idea to restrict the controller from creating an ALB and instead allow Terraform to create and manage the ALB. As a result, the controller should be mapped to an existing ALB provisioned by Terraform which will help you manage the ***lifecycle of ALB*** in a better fashion and ease ***dependency management*** across IaC resources.      

- **Authentication using Cognito**: We have enabled an authentication layer on ALB by integrating it with AWS Cognito service. If a user is successfully authenticated, then only he will be able to make calls to our URL shortener application.

- **Encryption in Flight**: We have established HTTPS encryption in the communication between the Client and ALB. SSL termination will happen at the ALB level. We have used AWS ACM service to manage SSL certificates. 

- **CI/CD using GitOps**: We have set up an end to end ***pull-based*** CI/CD framework using ***GitHub Actions for CI*** and ***ArgoCD for CD***. When a pull request is merged in the 'main' branch, a CI pipeline will automatically get triggered in GitHub Actions which will build the application using Docker and upload the resulting docker image artifact to AWS ECR repository. ArgoCD residing in the EKS cluster will automatically detect the new docker image version in ECR and will automatically pull and deploy it within the EKS cluster. We have built ***authentication & authorization*** between GitHub Actions and AWS ECR using an advanced, secured, robust framework like ***Role based OIDC***. 

- **Kubernetes manifest using Kustomize**: We are leveraging a solid strategy ***templater tool namely Kustomize*** to efficiently manage kubernetes manifest yaml files across different environments like Dev, Stage and Production.

- **Scaling**: We are using ***Karpenter*** for intelligent and smart scaling of Kubernetes nodes. Furthermore, we are also leveraging ***Horizontal Pod Autoscaler(HPA)*** to achieve scaling at the application pod level. As the average CPU load on the application pods will cross a specific threshold, additional replica pods will be automatically launched. If the average resource utilization of the kubernetes nodes crosses a specific threhold, then Karpenter will automatically launch new additional kubernetes nodes. As the CPU load decreases, the scale down approach will happen automatically. We can leverage a tool like Jmeter to perform ***load testing*** and rigorously test the scaling aspect.

- **Configuration Management**: ***AWS ASCP*** add-on can be leveraged for seemless configuration management which will fetch secrets and configurations from AWS Secrets Manager and Parameter Store services respectively and inject them directly into application pods as mounted volumes. A significant advantage would be that these volumes reside in RAM, thus ensuring secrets never touch the Kubernetes node disks, thereby substantially reducing the attack surface. Other procured perks would be automatic rotation of secrets and elimination of the need for pod restarts when secret values change. In this repository, our application requires a couple of configurations namely 'AWS_REGION' and 'DYNAMODB_TABLE_NAME' during runtime. These configurations are provisioned in AWS Parameter Store service using IaC. AWS ASCP add-on then dynamically fetches them from the AWS Parameter Store service and injects them automatically into the running application pod. In this way, we have achieved a ***secured, fully automated and robust configuration management***.
  
- **WAF**: We have enabled a Web Application Firewall on the Application Load Balancer to safeguard our infrastructure and application from ***malicious hacker attacks***. We have set up multiple security rules in WAF.

- **Data layer**: We are leveraging DynamoDB database for data layer.
  
- **Kubernetes authentication using IRSA**: When application pods need to communicate with AWS cloud resources, we are using Role based authentication using kubernetes service accounts and IRSA. To exemplify, when the application pod wish to interact with DynamoDB, we are using IRSA to authenticate the application pod with DynamoDB.

- **Monitoring and Observability**:

   1. An open source monitoring solution like ***Prometheus and Grafana*** can be installed in the EKS cluster to monitor the running workloads and kubernetes infrastructure. ***Alerts*** can be enabled and configured. 

   2. Alternatively, ***EKS Container Insights*** tool can also be used but it comes with a cost. Alerts can be generated using CloudWatch alarms and events.

   3. A potential observability solution like ***Dynatrace*** can be leveraged to achieve ***observability and traceability***.

   4. ***Centralized Logging*** can be achieved using AWS Cloudwatch and FluentBit.

   5. Infrastructure Cost Monitoring solutions like ***AWS Cost Explorer and Kubecost*** can also be integrated to track, allocate, and optimize infrastructure spend and resource usage. They provide cost optimization and resource optimization recommendations for resource right-sizing and detects unused or over-provisioned resources to reduce waste.  

  Well the above cited solutions are not configured in this stack as they come with cost and extra efforts. Nevertheless, you can still monitor this stack using basic monitoring solutions like below - 

  6. If you are using ***Lens*** tool to manage EKS cluster, you can monitor the workloads using it's UI

  7. You can leverage kubectl tool by running CLI commands like ***'kubectl top'*** 

  8. You can use ***AWS CloudWatch*** service to monitor the EKS nodes as CloudWatch offers some monitoring metrics by default.



## Set up the Stack 

1. **Provisioning of IaC resources and Bootstrapping GitOps**

- Go to the path 'iac/environments/dev'
  ```bash
  cd iac/environments/dev

- Launch a S3 bucket separately using AWS console to store the ***state file in a remote storage***. Enable ***versioning, least privilege access, and continuous backups*** for this bucket. Create a file named 'backend-variables.hcl' and add input values to it to configure the S3 'backend' block which is responsible for handling the remote state file. Enable ***state locking*** to avoid corruption of the state file. Please do not commit this file to Git, as it can expose sensitive configuration data of your setup to potential leakage.

- Create a file named 'terraform.tfvars' at the current path and configure it with values for the input variables declared in 'variables.tf' file. Configure values as per your setup for the specific environment(dev in this case). Please do not commit this file to Git, as it can expose sensitive configuration data related to your setup to potential leakage.

- Initialize terraform
  ```bash
  terraform init -backend-config=backend-variables.hcl

- Validate and review the cloud resources to be launched
  ```bash
  terraform plan

- Provision the cloud resources
  ```bash
  terraform apply --auto-approve
  
- ***The above steps will provision all the respective IaC resources for the Dev environment and bootstrap GitOps in the EKS cluster. As a part of bootstrapping GitOps process, GitOps Dev Bridge automatically installs ArgoCD software, applications workload applicationset and cluster add-ons workload applicationset in the cluster. In response to this, all the applications workload(microservices like url shortener application, etc) as well as the cluster add-ons workload(argocd image updater add-on and AWS ASCP add-on) will automatically get deployed in the cluster using GitOps. Thus, we have achieved end to end automation across the deployment of IaC and GitOps workloads***.

  

2. **Continuous Integration(CI) using GitHub Actions**

- Establish access between GitHub Actions and AWS ECR repository, so that the CI pipeline can upload the built docker images to AWS ECR. Kindly use the ECR repository launched by terraform in the previous steps. As a best practice, please avoid storing long-term AWS access/secret keys credentials in GitHub Actions. Instead, kindly leverage ***Role based Authentication using OIDC***, which uses short-term term dynamically created tokens. Kindly follow the steps in the document below to establish this sort of authentication.

  https://devopscube.com/github-actions-oidc-aws/

- CI pipelines are already provisioned and stored as ***Configuration as Code*** in the GitHub Actions workflow yaml files of this repository at the path ".github/workflows". Kindly create and configure secrets namely AWS_ACCOUNT_ID, AWS_IAM_ROLE, AWS_REGION, and ECR_REPOSITORY_NAME in GitHub Actions as per your setup. As soon as you merge a Pull Request(PR) in the 'main' branch, a CI build will automatically trigger, which will build a docker image for the application namely url-shortener and upload it to the ECR repository. Thus, kindly merge a Pull Request in the 'main' branch to build the application.


3. **Install and configure AWS load balancer controller**

- Install AWS load balancer controller in the EKS cluster. Kindly make sure this controller should not launch a new ALB, but instead should get mapped to the existing ALB which we launched earlier through Terraform.

  https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.13/deploy/installation/

- Create and deploy a target group binding object to map the 'url-shortener-service' running in the EKS cluster to the existing load balancer launched by terraform. Feel free to use the target group binding yaml at the path "aws-load-balancer-controller/target-group-binding.yaml" as a reference

  https://www.linkedin.com/pulse/use-existing-albnlb-aws-eks-cluster-mubashar-saeed-eoozf/

- Configure the security group attached to your EKS nodes to allow traffic from the ALB to the pods. If you fail to do this, then the instances/targets in your AWS Target Groups will be unhealthy.

- The installation of this cluster add-on can be automated and tracked using GitOps by configuring it in the cluster add-ons section of this repository.


4. **Installation and Configuration of the Scaling Software**

- Install Karpenter software in the EKS cluster by kindly following the instructions from the official documentation below. This documentation cites steps to install Karpenter in an already provisioned EKS cluster.

  https://karpenter.sh/docs/getting-started/migrating-from-cas/

- As a reference, please do not hesitate to use the Karpenter configuration yaml namely 'nodepool_ec2nodeclass.yaml' stored in this repository at the path 'karpenter/'. You can configure it as per your preferences.

- Install Metrics Server in the EKS cluster with high availability mode 
  ```bash
  helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
  helm upgrade --install metrics-server metrics-server/metrics-server --set replicas=2
  ```
  
  https://github.com/kubernetes-sigs/metrics-server?tab=readme-ov-file#high-availability

  https://artifacthub.io/packages/helm/metrics-server/metrics-server

- The installation of these cluster add-ons can be automated and tracked using GitOps by configuring it in the cluster add-ons section of this repository.



## Validation 

1. Access the application via HTTPS in your browser:

   Open your web browser and navigate to https://<ALB_DNS_NAME>/443

2. Self-Signed Certificate Warning:
   
   You will get the self-signed certificate warning. Kindly bypass it.

3. Cognito Redirect: 

   After bypassing the certificate warning, you should be redirected to the AWS Cognito Hosted UI login page. This confirms the ALB's authentication rule is working.

4. Create a new 'User' in Cognito:

      1. Go to the AWS Cognito console.

      2. Navigate to your User Pool (e.g., dev-url-shortener-users).

      3. Go to "Users" and click "Create user".

      4. Fill in a email address (e.g. testuser@example.com) and a temporary password (ensure it meets the password policy you defined in Terraform).

      5. Click "Create user".

5. Log in via Cognito Hosted UI:

      1. On the Cognito Hosted UI page in your browser, enter the username and temporary password you just created.

      2. You will be prompted to change the temporary password. Kindly change it.

      3. After successful login and password change, Cognito will redirect you back to your application's root URL (https://<ALB_DNS_NAME>/). You will see the below output in the browser. 
         ```bash
         "URL Shortener is running! Use /shorten to create short URLs and / to redirect."
         ```
         This confirms that you have been successfully authenticated and was able to access the 'URL Shortener Application'

6. Copy the authentication cookies from the browser

   1. Curl cannot easily handle the interactive Cognito login flow. To test the /shorten endpoint after authentication, you'd typically need to manually get the session cookies from your browser after logging in via the browser, and then include them in your curl request.

   2. Chrome browser: Right-click anywhere on the page and select "Inspect" or "Inspect Element". Go to the "Application" tab.

   3. Locate the Cookies:

   4. In the Developer Tools, expand "Cookies" under the "Storage" or "Application" section.

   5. Find the cookies associated with your ALB's DNS name (e.g. a123...elb.amazonaws.com).

   6. You are looking for cookies that typically start with AWSELBAuthSessionCookie-0 (or similar, sometimes with a number suffix like -1, -2, etc.). There might be more than one.

        For each AWSELBAuthSessionCookie-* cookie, copy its Name and Value.

        For example, if you find AWSELBAuthSessionCookie-0 with value abcdef123..., copy both.

        Kindly copy all the AWSELBAuthSessionCookie-* cookies you find for that domain.


7. Use the copied authentication cookies in curl requests to test the other application endpoints

     1. Set the ALB DNS Name:
        Replace <ALB_DNS_NAME> with your actual ALB DNS name in the commands below.

     2. Test the Root Endpoint (/) with Authentication:
        First, verify that curl can access the authenticated root endpoint.

        Replace ***COOKIE_NAME_1*** and ***COOKIE_VALUE_1*** with the actual cookie name and value you copied
        If you have multiple cookies, add more -b flags: -b ***"COOKIE_NAME_2=COOKIE_VALUE_2"***
        Kindly use all the cookies which you have copied by adding multiple -b flags. 
        
        ```bash
        curl -k -b "AWSELBAuthSessionCookie-0=abcdef123..." https://<ALB_DNS_NAME>/
        ```
        
        The -k flag is necessary because you're using a self-signed certificate.

        The -b flag sends the cookie(s) with your request.
 
        Expected Output: 
        ```bash
        You should see the "URL Shortener is running! Use /shorten to create short URLs and /
        ```

     3. Test the Shorten Endpoint (/shorten) with Authentication:

        Replace ***COOKIE_NAME_1*** and ***COOKIE_VALUE_1*** with the actual cookie name and value
   
        ```bash
        curl -k -X POST \
        -H "Content-Type: application/json" \
        -b "AWSELBAuthSessionCookie-0=abcdef123..." \
        -d '{"originalUrl": "[https://www.google.com](https://www.google.com)"}' \
        https://<ALB_DNS_NAME>/shorten
        ```
   
        Expected Output: 
        ```bash
        {"shortUrl":"http://<ALB_DNS_NAME>/<short_code>"}
        ```

     4. Test the Redirect Endpoint (/<short_code>) with Authentication:

        Replace ***SHORT_CODE*** with the actual value(<short_code>) obtained from the previous json output of the '/shorten' endpoint
        Replace ***COOKIE_NAME_1*** and ***COOKIE_VALUE_1*** with the actual cookie name and value. The -L flag tells curl to follow redirects.

        ```bash
        curl -k -L -b "AWSELBAuthSessionCookie-0=abcdef123..." https://<ALB_DNS_NAME>/<SHORT_CODE>
        ```

        Expected Output: 
        ```bash
        curl will follow the redirect to your original URL (e.g. https://www.google.com) and display its content.
        ```
        

8. Testing of WAF rules which we have set up on AWS ALB to safeguard our application from malicious attacks

      - Let us test a Custom Rule named "BlockSpecificIP". Before testing kindly ensure the "aws_wafv2_ip_set.blocked_ips" configuration in your "modules/waf/main.tf" file contains the public IP address of the machine you are using to run curl(or another IP you control for testing). Remember to change this back or remove your IP after testing.
        ```bash
        curl -k -L https://<ALB_DNS_NAME>/
        ```

        Expected Output: 
        ```bash
        You should immediately get a 403 Forbidden response. Your request should not even reach the Cognito login page or your application.
        ```
     - For further verification, you can go to the AWS WAF console, select your Web ACL, go to "Rules", and check the "Metrics" or "Sampled requests" for the BlockSpecificIP rule. You should see a BLOCK action.



## Future Improvements/Best Practices

- Leverage **AWS Organization** service to create separate unique AWS accounts for different projects or environments(Dev, Stage, Production).

- Avoid using long-term static credentials(AWS secret/access keys) to establish authentication between AWS CLI/Terraform and AWS Cloud. Instead, it will be a good idea to use token-based **AWS Single Sign On(SSO)** authentication, which would dynamically generate temporary short-term credentials.
  
- Compute layer(EKS nodes) and Data layer(Databases) should reside in ***private subnets***. ***Cluster Access Mode*** of the EKS cluster can be set to private, so that no one from public internet can remotely access your EKS cluster.

- ***VPC Endpoint*** can be configured to connect the EKS pods to the Dynamodb database or other AWS resources to improve security and save cost. 

- ***Unit test cases*** can be written for the terraform IaC code and the application code.

- ***CICD using GitOps*** can be constructed for Terraform IAC deployments as well.
  
- ***High Availability*** can be configured for the applications, cluster add-ons, AWS services and EKS nodes. ***Pod Disruption Budget*** can be explored.

- Scaling to ***Millions*** of Users - 
   
  When we think about scaling to millions of users, usually the first thing that pops in our mind is scaling of the compute(EC2 instances, Lambda, Containers, etc). But that's not really the complete game. It is just a part of the game. We need to consider other different layers of the product architecture as well in terms of scaling. To exemplify, we should consider scaling the other layers namely network, load balancer, Database, etc. We need to widen our horizon to covers other scaling areas like below - 

     1. Ensure ***DNS and other networking layers*** are automatic scalable and highly available.
     2. Ensure ***Load Balancer*** supports out of the box scaling.
     3. ***Offload static frontend caching data*** from the web instance tier to some object storage like S3 and then set up a CDN like CloudFront on top of it to achieve global caching and other perks.
     4. Establishing a data caching layer using ***AWS Elastic Cache***.
     5. Leverage ***read replicas and multi AZ*** automatic scalable databases like AWS RDS, DynamoDB and MongoDB Atlas.
     6. Setting up ***observability and monitoring*** suites using tools like Prometheus, Grafana, Dynatrace or AWS Xray. Monitor the metrics like ***response times*** to identify high latency areas so that you can rectify application slowness and improve the speed of your application.
     7. Leverage ***AI and ML based solutions*** like AWS DevOps Guru and AWS CodeGuru which can monitor your infrastructure and application code respectively and provide insightful recommendations on how can you reduce application slowness, improve scaling, etc.

- Tools like ***Kubecost and AWS Compute Optimizer*** can be used to right-size the Kubernetes nodes and resource limits for pods to avoid under-utilization or over-utilization of resources, which will further result in ***cost-saving***.

- ***AWS EKS Auto Mode*** service can be explored which automates the management of your Kubernetes clusters, including provisioning and scaling compute, storage, and networking resources. However, it is important to note that it comes with a cost.

- Deployment strategy like ***Blue Green*** can be practiced for zero downtime and quicker rollback.

- Security can be enforced using ***Policy as Code*** framework leveraging tools like ***Open Policy Agent(OPA) or Kyverno***.

- ***DevSecOps*** practices like SAST, DAST and others can be adopted to fortify the security of the product.

- Container security can be boosted by hardening the host at the Docker container and Kubernetes levels by establishing robust ***user management at the container level*** and leveraging kubernetes offerings like ***Pod Security Standards(PSS) and Pod Security Admission(PSA)***

- If required, Service Mesh frameworks like ***Istio*** can be explored.

- CICD can be integrated with ***Jira*** tool to improve collaboration, visibility, release planning, management and deployments.

- Dockerfile can be developed in ***Multi-Stage*** format. Docker image size can be kept minimal. Build time can be optimized.

- Compare and analyze the different ***scaling metrics*** like CPU, Memory, Request Count, considering your product requirements, setup & future vision, and then choose a metric for scaling that fits the best for you, so that you can achieve the best scaling results.

- Kindly take a look at the following references to educate around ***best practice folder and repository structure for GitOps***

  https://codefresh.io/blog/how-to-model-your-gitops-environments-and-promote-releases-between-them/
  
  https://codefresh.io/blog/how-to-structure-your-argo-cd-repositories-using-application-sets/

  https://youtu.be/_G_RY5trQao?si=Dupnw8yiKpzBmdjZ

- Manual steps observed in this setup can be further automated end to end.
