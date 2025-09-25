🛠️ TeamAvail – Employee Availability Tracker (Serverless & DevOps Project)

TeamAvail is a modern web application designed to track employee availability across the week, offering managers and teams a clear view of workforce availability. Beyond a simple web app, this project demonstrates end-to-end DevOps practices, cloud-native serverless deployment, and CI/CD automation, showcasing advanced skills in AWS, Terraform, Docker, and GitHub Actions.

This project serves both as a practical employee tracking solution and a demonstration of professional DevOps and cloud engineering capabilities.

Project Highlights

Full-stack web application: Front-end served via Express, back-end powered by Node.js and PostgreSQL.

Serverless deployment: Backend runs as a containerized AWS Lambda function, accessible via API Gateway HTTP API.

Cloud database integration: PostgreSQL hosted on NeonDB, leveraging SSL and secure connection strings.

Infrastructure as Code: Terraform used to provision AWS resources, including Lambda, ECR, API Gateway, and IAM roles.

CI/CD automation: GitHub Actions builds the Docker image, pushes it to AWS ECR, and deploys the infrastructure using Terraform Cloud.

Modular, maintainable code: Terraform modules separate Lambda, API, and ECR resources for clean and reusable infrastructure code.

Output-driven infrastructure: Terraform provides API endpoint outputs, enabling seamless integration with front-end apps.

Tech Stack & Tools
Layer	Technology / Service
Frontend	HTML, CSS, JavaScript
Backend	Node.js, Express, AWS Lambda (containerized)
Database	PostgreSQL (NeonDB cloud-hosted)
Cloud Provider	AWS (Lambda, API Gateway, ECR, IAM)
Infrastructure IaC	Terraform (modular structure, Terraform Cloud backend)
CI/CD	GitHub Actions, Docker, Terraform Cloud
Containerization	Docker, Dockerfile.lambda
Secrets Management	GitHub Secrets, Terraform Cloud variables
Logging & Monitoring	AWS CloudWatch
Key Features

Dynamic Availability Tracking

Employees can select a status for each day of the week.

Front-end validates input and ensures historical data integrity.

Persistent History

History is saved to PostgreSQL with structured JSON data per employee and week.

Provides retrieval of latest availability data via /get-history endpoint.

Serverless Architecture

Node.js backend runs as a Lambda container image.

Fully scalable and cost-efficient.

Exposed via AWS API Gateway HTTP API.

CI/CD Pipeline

GitHub Actions automates Docker image build and push to AWS ECR.

Terraform provisions or updates Lambda and API Gateway automatically.

Optional destroy pipeline ensures safe teardown of all infrastructure.

Security & Best Practices

Database connections are secured via SSL and environment variables.

Terraform Cloud stores state remotely with locking for team-safe deployments.

GitHub Actions secrets used for sensitive data like AWS keys and database credentials.

Architecture Overview
[Frontend JS/HTML/CSS]
       |
       v
[Express API] -> [AWS Lambda (container)]
       |
       v
[PostgreSQL NeonDB]
       |
       v
[API Gateway HTTP API] -> Exposes Lambda endpoints


CI/CD triggers from GitHub Actions automatically build Docker images, push to AWS ECR, and deploy infrastructure with Terraform Cloud.

Terraform outputs the API Gateway URL, which the front-end uses to access Lambda.

Setup Instructions
1. Clone the repository
git clone https://github.com/mariomafdyhabib/teamavail.git
cd teamavail

2. Configure environment variables

Locally:

export AWS_ACCESS_KEY_ID=<your_aws_access_key>
export AWS_SECRET_ACCESS_KEY=<your_aws_secret_key>
export DATABASE_URL=postgresql://user:password@host:port/dbname
export TFC_TOKEN=<terraform_cloud_token>


In GitHub Actions, store the same as repository secrets.

3. Run locally
cd app
npm install
npm run start


Open http://localhost:3000 to interact with the app locally.

4. Build & Push Lambda Docker Image
docker build -t teamavail-lambda -f Dockerfile.lambda .
docker tag teamavail-lambda:latest <aws_account_id>.dkr.ecr.<region>.amazonaws.com/mario/konecta:latest
docker push <aws_account_id>.dkr.ecr.<region>.amazonaws.com/mario/konecta:latest

5. Deploy Infrastructure via Terraform Cloud
terraform init
terraform apply --auto-approve


Lambda, API Gateway, ECR repository, and IAM roles are provisioned.

Terraform outputs the API Gateway URL:

lambda_api_url = "https://abcd1234.execute-api.us-east-1.amazonaws.com/"


Use this URL in your front-end to call the Lambda function.

6. CI/CD Pipelines

Build & Push: Dockerfile.lambda → AWS ECR

Terraform Apply: Deploy Lambda and API Gateway using Terraform Cloud

Terraform Destroy: Tear down resources safely using GitHub Actions workflow

Pipelines are fully automated and integrated with Terraform Cloud CLI-driven execution mode.

7. Project Structure
teamavail/
├── app/                       # Backend + frontend
│   ├── Dockerfile.lambda
│   ├── public/                # HTML, JS, CSS
│   ├── input/                 # JSON input files
│   ├── output/                # Optional output files
│   └── script.js
├── terraform/
│   ├── backend.tf             # Terraform Cloud backend
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── modules/
│       └── lambda/            # Lambda module
│           ├── main.tf
│           ├── variables.tf
│           └── outputs.tf
├── .github/workflows/         # CI/CD pipelines
│   ├── build-and-push-ecr.yml
│   ├── terraform-apply.yml
│   └── terraform-destroy.yml
└── README.md

8. Achievements & Learning Outcomes

Designed modular Terraform infrastructure, reusable for other serverless projects.

Implemented serverless Lambda container deployment with API Gateway integration.

Automated Docker build and deployment pipelines with GitHub Actions.

Learned best practices for secure secrets management and remote Terraform state.

Gained hands-on experience in AWS Cloud, Terraform, ECR, Lambda, API Gateway, PostgreSQL, and CI/CD automation.

9. Future Improvements

Add user authentication & role-based access.

Integrate React or Vue.js front-end for dynamic UI.

Add CloudWatch alarms & metrics for Lambda monitoring.

Enhance CI/CD with multi-environment support (staging, production).