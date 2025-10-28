[![Build and Deploy to Azure Web App](https://github.com/rustamrustamv/flask-cicd-azure/actions/workflows/main.yml/badge.svg)](https://github.com/rustamrustamv/flask-cicd-azure/actions/workflows/main.yml)

# End-to-End CI/CD Pipeline for a Containerized Python App on Azure

**Live Application URL:** [https://YOUR_WEBAPP_HOSTNAME](https://app-flaskapp-s3r7gh.azurewebsites.net/)

This project demonstrates a complete, end-to-end DevOps workflow. A Python Flask application is containerized with Docker, its infrastructure is provisioned on Microsoft Azure using Terraform (IaC), and the entire build-and-deploy process is automated with a GitHub Actions CI/CD pipeline.

## Project Goal

The objective was to build a production-style, "hands-off" pipeline. A developer can push a code change to the `main` branch, and GitHub Actions automatically builds the new container, pushes it to a private registry, and deploys it to the Azure App Service with zero downtime or manual intervention.

## Architecture Diagram

This diagram shows the flow of code from the developer's machine to the live application in Azure.

```mermaid
graph TD
    A[Developer] -- 1. git push --> B(GitHub Repo);
    B -- 2. Triggers --> C{GitHub Actions CI/CD};
    C -- 3. Builds Image --> D[Docker];
    C -- 4. Pushes Image --> E(Azure Container Registry);
    C -- 5. Runs Terraform --> F(Azure Infrastructure);
    F -- Creates/Updates --> G(Azure App Service);
    F -- Creates/Updates --> E;
    C -- 6. Deploys App --> G;
    G -- 7. Pulls Image --> E;
    H(User) -- 8. Accesses App --> G;

    subgraph "Infrastructure as Code"
    F
    end

    subgraph "CI/CD Pipeline"
    C
    D
    end

    subgraph "Cloud Platform (Azure)"
    E
    G
    end




    Core Technologies & Skills Demonstrated
Cloud: Microsoft Azure

Containerization: Docker

Infrastructure as Code (IaC): Terraform

CI/CD: GitHub Actions

Container Registry: Azure Container Registry (ACR)

Hosting: Azure Web App for Containers

Scripting: Bash, Python

Security: Azure Managed Identity, RBAC, GitHub Secrets

Project Screenshots
1. Successful CI/CD Pipeline
This shows the automated GitHub Actions workflow successfully building and deploying the application.

2. Live Deployed Application
This is the final result: the containerized application running live on its Azure public URL.

How It Works
Infrastructure (/terraform):

Terraform code defines all necessary Azure resources: a Resource Group, Container Registry, App Service Plan, and the App Service itself.

It securely configures the App Service to use a Managed Identity with AcrPull rights, allowing it to securely pull images from the registry without storing passwords.

The WEBSITES_PORT is set to 8000 to match the container's Gunicorn server.

Application (/app.py, Dockerfile):

A simple Python Flask app.

A multi-stage Dockerfile builds the application into a lightweight, production-ready container.

CI/CD Pipeline (.github/workflows/main.yml):

Trigger: The workflow runs on every push to the main branch.

Job 1: Build & Push:

Logs into Azure Container Registry using repository secrets.

Builds the Docker image from the Dockerfile.

Tags the image with :latest and the ACR login server.

Pushes the new image to ACR.

Job 2: Deploy:

Logs into Azure using a Service Principal (stored as a GitHub Secret).

Uses the Azure CLI (az webapp config container set) to forcefully update the App Service to use the new container image.

Uses az webapp config appsettings set to ensure the WEBSITES_PORT is correctly configured, preventing deployment fallbacks.

How to Run Locally
Clone the repository.

Ensure you have Docker Desktop installed.

Run the following commands:

Bash

# Build the image
docker build -t flask-app-local .

# Run the container
docker run -d -p 8080:8000 --name flask-test flask-app-local
Access the application at http://localhost:8080.

Future Improvements
Implement Monitoring: Integrate Azure Monitor or Prometheus/Grafana to track application uptime and performance.

Tagging Strategy: Use Git tags or commit hashes for Docker image versions instead of just :latest for better version control.

Staging Environment: Create a second Terraform environment for staging to test changes before deploying to prod.