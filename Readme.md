## 🛠️ TeamAvailTest – Employee Availability Tracker (Serverless & DevOps Project)
TeamAvailTest is a modern web application designed to track employee availability across the week, offering managers and teams a clear view of workforce availability. This project demonstrates end-to-end DevOps practices, cloud-native serverless deployment, and infrastructure as code using Terraform, showcasing advanced skills in AWS, Docker, and cloud engineering.

## Project Highlights
- Serverless deployment: Backend runs as a containerized AWS Lambda function using Docker

- External database integration: Connects to your existing PostgreSQL database with secure environment variables

- Infrastructure as Code: Terraform module to provision AWS resources including Lambda, ECR, and IAM roles

- Containerized application: Docker-based deployment with Lambda-compatible runtime

- CI/CD Pipelines: Automated deployment with GitHub Actions and Terraform Cloud

- State Management: Remote state storage with Terraform Cloud/HCP

---
```
## Tech Stack & Key Features

| Layer                 | Technology / Service                                  |
|----------------------|--------------------------------------------------------|
| Backend              | Node.js, Express, AWS Lambda (containerized)           |
| Database             | PostgreSQL (external/your existing database)           |
| Cloud Provider       | AWS (Lambda, ECR, IAM, CloudWatch)                     |
| Infrastructure (IaC) | Terraform (modular structure)                          |
| Containerization     | Docker, Dockerfile                                     |
| Secrets Management   | Terraform variables (sensitive)                        |
```


---

### Key Features

- **Dynamic Availability Tracking**: Employee status management across the week.
- **Serverless Architecture**: Node.js backend runs as Lambda container image.
- **Scalable & Cost-efficient**: Pay-per-use Lambda pricing model.
- **Secure Database Connections**: Environment variable-based configuration.
- **Infrastructure as Code**: Reproducible deployments with Terraform.


## Architecture Overview
```
text
[Frontend Client] 
       ↓
[AWS Lambda (Docker Container)]
       ↓
[External PostgreSQL Database]
Project Structure
text
TeamavailTest/
├── server.js                 # Your Express application
├── package.json              # Node.js dependencies
├── Dockerfile                # Lambda container definition
└── terraform/                # Terraform module
    ├── main.tf               # Primary resource definitions
    ├── variables.tf          # Input variables
    ├── outputs.tf            # Output values (function URL)
    └── provider.tf           # AWS provider configuration
```
# CI/CD Pipeline Overview
## Terraform Apply Pipeline (.github/workflows/terraform-apply.yml)
Automatically deploys infrastructure on push to main branch:
```
yaml
name: CI/CD

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build-and-test:
    if: startsWith(github.event.head_commit.message, 'apply')
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: 18

      - name: Install dependencies
        run: |
          if [ -f package-lock.json ]; then npm ci; else npm install; fi

      - name: Lint
        if: ${{ hashFiles('**/package.json') }}
        run: |
          if grep -q "\"lint\"" package.json; then npm run lint; else echo "No lint script"; fi

      - name: Run tests
        run: |
          if grep -q "\"test\"" package.json; then npm test; else echo "No test script"; fi

  
  build-and-push-on-ECR:
    runs-on: ubuntu-latest
    needs: build-and-test
    env:
      AWS_REGION: us-east-1
      ECR_REPOSITORY: 654654545585.dkr.ecr.us-east-1.amazonaws.com/mario/konecta
      IMAGE_TAG: latest

    steps:
      
      - name: Checkout repository
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Login to Amazon ECR
        id: ecr-login
        run: |
          aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY

      - name: Build Docker image
        run: |
          docker build -f Dockerfile.lambda -t $ECR_REPOSITORY:$IMAGE_TAG .

      - name: Push Docker image
        run: |
          docker push $ECR_REPOSITORY:$IMAGE_TAG

  trivy-scan:
    name: Trivy Security Scan
    needs: build-and-push-on-ECR
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Set up Trivy
        uses: aquasecurity/trivy-action@master
        with:
          scan-type: fs   # options: fs (filesystem), image, repo
          severity: CRITICAL,HIGH
          format: table
          # exit-code: 1    # fail if vulnerabilities found
          ignore-unfixed: true

  terraform:
    # if: startsWith(github.event.head_commit.message, 'terraform apply')
    runs-on: ubuntu-latest
    needs: trivy-scan
    defaults:
      run:
        working-directory: terraform

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.7.5
          cli_config_credentials_token: ${{ secrets.TFC_TOKEN }}

      - name: Terraform Init & Apply
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          TF_API_TOKEN_app_terraform_io: ${{ secrets.TFC_TOKEN }}
        run: |
          terraform init
          terraform apply --auto-approve
```

![Description of image](photos/8.png)
## Terraform Destroy Pipeline (.github/workflows/terraform-destroy.yml)
Safely destroys infrastructure on demand:
```
yaml
name: Terraform Destroy

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  terraform-destroy:
    if: startsWith(github.event.head_commit.message, 'destroy')
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: terraform

    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2
        with:
          terraform_version: 1.7.5
          cli_config_credentials_token: ${{ secrets.TFC_TOKEN }}

      - name: Terraform Destroy
        env:
          AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
          AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          DATABASE_URL: ${{ secrets.DATABASE_URL }}
          TF_API_TOKEN_app_terraform_io: ${{ secrets.TFC_TOKEN }}
        run: |
          terraform init
          terraform destroy --auto-approve

```
![Description of image](photos/7.png)
## Terraform Cloud/HCP Configuration
backend.tf
```
hcl
terraform {
  backend "remote" {
    organization = "your-organization-name"

    workspaces {
      name = "teamavailtest-prod"
    }
  }
}
```
## Terraform Cloud Workspace Setup
- Create Terraform Cloud Account

- Sign up at https://app.terraform.io

- Create an organization

- Create Workspace

- Choose "Version Control Workflow"

- Connect your GitHub repository

- Set workspace name: teamavailtest-prod

- Configure Variables in Terraform Cloud

![Description of image](photos/5.png)

![Description of image](photos/6.png)

## Terraform Variables:

- region = "us-east-1"

- function_name = "teamavail-lambda"

- Environment Variables (Sensitive):

- AWS_ACCESS_KEY_ID = your_aws_access_key

- AWS_SECRET_ACCESS_KEY = your_aws_secret_key

- DATABASE_HOST = your-database-host

- DATABASE_USER = your-database-user

- DATABASE_PASSWORD = your-database-password

## Generate API Token

- Go to User Settings > Tokens

- Create a new API token

- Store in GitHub Secrets as TF_API_TOKEN

# GitHub Secrets Configuration
## Configure these secrets in your GitHub repository settings:
```
Secret Name	Value	Description
AWS_ACCESS_KEY_ID	your_aws_access_key	AWS IAM user access key
AWS_SECRET_ACCESS_KEY	your_aws_secret_key	AWS IAM user secret key
TF_API_TOKEN	your_terraform_cloud_token	Terraform Cloud API token
TF_CLOUD_ORGANIZATION	your_org_name	Your Terraform Cloud organization
DATABASE_URL	postgresql://user:pass@host/db	Database connection string
```
![Description of image](photos/4.png)
# Pipeline Execution Triggers
## Automatic Triggers
- Push to main branch: Triggers terraform-apply.yml

- Pull request to main: Runs terraform plan for validation

## Manual Triggers
- Terraform Apply: Manual trigger via GitHub Actions UI

- Terraform Destroy: Manual trigger for cleanup (requires approval)

## Pipeline Stages
- Validation: Terraform format and validate

- Planning: Generate execution plan

- Approval: Manual approval (for apply/destroy)

- Execution: Apply or destroy infrastructure

- Notification: Slack/email on completion

## Prerequisites
- AWS Account with appropriate permissions

- Terraform installed locally

- Docker installed locally

- Existing PostgreSQL database (external, Neon)

- Node.js and npm

## Quick Start
## 1. Clone the Repository
```
bash
git clone https://github.com/mariomafdyhabib/TeamavailTest.git
cd TeamavailTest
```
## 2. Prepare Your Application
Ensure your server.js is configured for Lambda:

- Export a handler function that takes event and context parameters

- Use environment variables for database configuration

## 3. Configure Database Connection
Update the Terraform variables with your database details:
```
bash
cd terraform
Create a terraform.tfvars file (add to .gitignore for security):

hcl
region = "us-east-1"
function_name = "teamavail-lambda"
database_host = "your-database-host"
database_user = "your-database-username"
database_password = "your-database-password"
```
![Description of image](photos/1.png)

![Description of image](photos/2.png)


## 4. Deploy Infrastructure
```
bash
# Initialize Terraform
terraform init

# Plan deployment
terraform plan

# Apply configuration
terraform apply
```
Terraform will:

- Create an ECR repository for your Docker image

- Build and push the Docker image to ECR

 ![Description of image](photos/3.png)

- Deploy the Lambda function with your database environment variables

- Create necessary IAM roles and permissions

- Output the Lambda Function URL

## 5. Access Your Application
After deployment, Terraform will output the Lambda Function URL:
```
text
lambda_function_url = "https://abcd1234.lambda-url.us-east-1.on.aws/"
```
Use this URL to access your application.

![Description of image](photos/image.png)

## Manual Docker Build (Optional)
```
bash
# Build the Docker image
docker build -t teamavail-lambda .

# Test locally (if your Lambda handler is configured for local testing)
docker run -p 9000:8080 teamavail-lambda
```
# Terraform Module Details
## Input Variables
- region: AWS region (default: us-east-1)

- function_name: Lambda function name

- database_host: External database hostname

- database_user: Database username

- database_password: Database password

## Outputs
- lambda_function_url: HTTP endpoint for your Lambda function

- ecr_repository_url: ECR repository URL for your Docker image

# Application Requirements
Your server.js should be structured for Lambda execution:
```

exports.handler = async (event, context) => {
    // Your application logic here
    return {
        statusCode: 200,
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ message: "Hello from Lambda!" })
    };
};
```
## Security Notes
- Database credentials are stored as sensitive Terraform variables

- IAM roles follow principle of least privilege

- Consider using AWS Secrets Manager for production database credentials

- Use AWS_IAM authorization for Lambda Function URL in production

## Monitoring & Logging
- Lambda execution logs are available in AWS CloudWatch

- Monitor function metrics (invocations, errors, duration) in CloudWatch

- Set up CloudWatch alarms for error rates and throttling

## Clean Up
To destroy all created resources:
```
bash
git add .
git commit -am "destroy"
git push # run destroy pipeline
```
# Customization
## Modify Lambda Configuration
Edit terraform/main.tf to adjust:

- Memory size and timeout settings

- Environment variables

- VPC configuration (if needed)

## Add API Gateway
Extend the Terraform configuration to add API Gateway for advanced routing and authentication.

# Troubleshooting
## Common Issues
1. Docker build fails: Check your Dockerfile and ensure all files are in the correct paths

2. Lambda timeout: Increase the timeout value in Lambda configuration

3. Database connection issues: Verify database credentials and network accessibility

4. Permission errors: Check IAM role policies in AWS Console

## Debugging Steps
1. Check CloudWatch logs for Lambda execution errors

2. Verify environment variables in Lambda configuration

3. Test database connectivity from your local environment

4. Use terraform plan to preview changes before apply

## Future Enhancements
- Add CI/CD pipeline with GitHub Actions

- Implement API Gateway for advanced routing

- Add CloudFront distribution for caching

- Set up database connection pooling

- Add monitoring and alerting with CloudWatch

- Implement authentication and authorization

- Add frontend deployment to S3 + CloudFront

# Contributing
1- Fork the repository

2- Create a feature branch

3- Make your changes

4- Test Terraform deployment

5- Submit a pull request

## License
This project is open source and available under the MIT License.

## Support
For issues and questions:

- Create an issue in the GitHub repository

- Check Terraform and AWS documentation

- Review AWS Lambda container image guidelines
