[![Build and Deploy to Azure Web App](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/main.yml/badge.svg)](https://github.com/YOUR_USERNAME/YOUR_REPO/actions/workflows/main.yml)

# End-to-End CI/CD Pipeline for a Containerized Python App on Azure

**Live Application URL:** [https://YOUR_WEBAPP_HOSTNAME](https://YOUR_WEBAPP_HOSTNAME)

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