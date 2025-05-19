# Using Terraform to Create a Data Pipeline in GCP

## Overview
This project consists of centralizing data from 3 different sources in a storage environment that makes it possible to query the data easily and use it as a source for data analysis and machine learning algorithms.

**Data Source**
- A database table
- CSV files
- Google Sheets

## Solution Architecture
In order to build a simple and robust solution, we will use the resources of the Google Cloud Platform (GCP). This choice is due to the fact that GCP has dozens of features that make it possible to create a simple, robust and scalable data pipeline. All the provisioning and management of the GCP infrastructure will be carried out via Terraform. By integrating Terraform with GitHub, we will have a project with automated, versionable resource creation, reduced manual work and the possibility of rolling back previous versions of the project if necessary.

**Solution Design**
![alt text](documentacao/Arquiteura_Projeto_Uncover.drawio.png)

**Main Components**

- Google Cloud Storage (GCS): To store CSV files. New CSV files will have to be added to the bucket via the GCP interface by the user whenever necessary. We will also have a bucket to store the parquet file that gives rise to a table in Bigquey.
- Google Cloud BigQuery: Used for centralized data storage and performing SQL queries on this data. We will also use External Tables to query data directly from buckets and Google Sheets without initially loading it (raw layer) into Bigquey's storage.
- Google Cloud Dataproc: Used to run PySpark jobs to extract, transform and load the data into BigQuery. There will be 4 jobs, each responsible for carrying out the process on each table.
- Google Cloud Scheduler: Will be used to schedule the execution of Jobs every day at 03:00 Hours by Dataproc.

**Data flow**
- CSV files: 
   - CSV files are sent to a GCS bucket via the interface; new files can be added whenever necessary.
   - An external Bigquey table is created based on the files in the bucket. This table will belong to the raw layer of the data pipeline.
   - The Cloud Scheduler triggers Dataproc jobs on a daily basis, which use PySpark to process the data obtained in a query to the bucket before loading it into BigQuery in the prep layer.

- Google Sheet: 
   - Google Sheet files are stored on an external drive. The Google Sheet file must have a sharing option that allows anyone with the spreadsheet link to read it;
   - The Google Sheet file contains two tabs, each tab will give rise to a different table.
   - Two Bigquey External Tables are created based on the shared Google Sheet files containing the two tabs. These tables will belong to the raw layer of the data pipeline.
   - The Cloud Scheduler triggers Dataproc jobs on a daily basis, which use PySpark to process the data obtained from a Google Sheet query before loading it into BigQuery in the prep layer.

- Database table: 
   - Parquets files containing data from a database table are sent to a GCS bucket via the interface, new files can be added whenever necessary;
   - An external Bigquey table is created based on the files in the bucket. This table will belong to the raw layer of the data pipeline.
   - The Cloud Scheduler triggers Dataproc jobs on a daily basis, which use PySpark to process the data obtained in a query to the bucket where the parquet file is stored, before loading it into BigQuery in the prep layer that will be made available for queries.

## Configuration instructions
**Prerequisites**
- A GCP account and a project configured with the necessary services enabled
- A GCP bucket to store the status of changes applied to the terraform
- A GitHub repository with terraform workflow configured.
- A GCP service account with the necessary permissions to access, create, modify and delete the required resources.
- For this project we have 3 dependencies:
    - The gspread library used to access the Google Sheets spreadsheet: This library is not pre-installed in pyhton, so it is necessary that in a bucket we have the necessary packages so that when creating the Dataproc cluster, it can read and install the gspread library.
    - Authentication key for a service account: Below we'll show you how to create this access key. As well as being used on github, it should also be in a GCP bucket so that it can be read and used to connect to the gspread library.
    - Spark dependencies: A .jar file containing the connectors needed for Spark to access and interact with BigQuery. This file must be somewhere that the cluster can see it, such as a bucket.

**Implementation Steps**
- Creating a Github workflow: To create a workflow, go to the Actions tab in the Github repository and search for Terraform. If you don't have a workflow set up, the option to configure Terraform will appear. When you select the Configure Terraform option, a window will appear with an integration template like the one in the following image
![alt text](documentacao/imagem%202.PNG)

- Creating a GCP Service Account: In order for GitHub Terraform Workflow to interact with Google Cloud, you need to have a Google service account. Let's create one in the IAM panel. Fill in the form with a service account name and click continue. In the service account function, you should only give the necessary access to the services you are going to create, but if they are running, give them Editor access.
![alt text](documentacao/imagem%203.PNG)

- Generate JSON key for service account: In the list table of service accounts, access the Manage Keys option in the Actions column. Then create a JSON key for your Service Account. The browser will ask you to download a JSON file. Download it to use as a service account integration on GitHub.
![alt text](documentacao/imagem%204.PNG)

- Create the GOOGLE_CREDENTIALS secret on GitHub: The next step is to use the JSON credentials key from the service account and create a secret called GOOGLE_CREDENTIALS in your GitHub project.
![alt text](documentacao/imagem%205.PNG)

- Setting up Terraform: To create terraform files you can clone the repository on your machine via an SSH connection and edit and create .tf files (terraform files) using an IDE such as Visual Code. It is recommended to create a tf file for each resource to be created in the cloud. For this project, the following files were created (to see the configurations and resources created in each file in detail, visit them in the repository):
   - bigquery.tf: Manage BigQuery resources.
   - buckets.tf: Manage storage buckets.
   - dataproc.tf: Manage Dataproc resources.
   - main.tf: Terraform's main configuration file, which includes the primary infrastructure definitions and resource configurations
   - scheduler.tf: Manage Cloud Scheduler resources.
   - variables.tf: Define variables used throughout Terraform's configurations. It is possible to integrate repository variables in the GitHUb project with the Terraform workflow. For example, by having these variables declared in the GitHub project, you can use them as values for Terraform variables. By default, GitHub Workflow looks for a variables.tf file to find out about values to fill in the variables. 
   ![alt text](documentacao/imagem%206.PNG)

- Final Workflow configuration: Having created GOOGLE_CREDENTIALS and also the variables, it's time to use them in our workflow.yml file. In the end, it will have the following settings:
```ruby
# This workflow installs the latest version of Terraform CLI and configures the Terraform CLI configuration file
# with an API token for Terraform Cloud (app.terraform.io). On pull request events, this workflow will run
# `terraform init`, `terraform fmt`, and `terraform plan` (speculative plan via Terraform Cloud). On push events
# to the "main" branch, `terraform apply` will be executed.
#
# Documentation for `hashicorp/setup-terraform` is located here: https://github.com/hashicorp/setup-terraform
#
# To use this workflow, you will need to complete the following setup steps.
#
# 1. Create a `main.tf` file in the root of this repository with the `remote` backend and one or more resources defined.
#   Example `main.tf`:
#     # The configuration for the `remote` backend.
#     terraform {
#       backend "remote" {
#         # The name of your Terraform Cloud organization.
#         organization = "example-organization"
#
#         # The name of the Terraform Cloud workspace to store Terraform state files in.
#         workspaces {
#           name = "example-workspace"
#         }
#       }
#     }
#
#     # An example resource that does nothing.
#     resource "null_resource" "example" {
#       triggers = {
#         value = "A example resource that does nothing!"
#       }
#     }
#
#
# 2. Generate a Terraform Cloud user API token and store it as a GitHub secret (e.g. TF_API_TOKEN) on this repository.
#   Documentation:
#     - https://www.terraform.io/docs/cloud/users-teams-organizations/api-tokens.html
#     - https://help.github.com/en/actions/configuring-and-managing-workflows/creating-and-storing-encrypted-secrets
#
# 3. Reference the GitHub secret in step using the `hashicorp/setup-terraform` GitHub Action.
#   Example:
#     - name: Setup Terraform
#       uses: hashicorp/setup-terraform@v1
#       with:
#         cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

name: 'Terraform'

on:
  push:
    branches: [ "main" ]
  pull_request:

permissions:
  contents: read

jobs:
  terraform:
    name: 'Terraform'
    runs-on: ubuntu-latest
    environment: production

    # Use the Bash shell regardless whether the GitHub Actions runner is ubuntu-latest, macos-latest, or windows-latest
    defaults:
      run:
        shell: bash
        #Inform a working directory if .tf files are not in root folder
        #working-directory: ./terraform 

    steps:
    # Checkout the repository to the GitHub Actions runner
    - name: Checkout
      uses: actions/checkout@v4

    # Install the latest version of Terraform CLI and configure the Terraform CLI configuration file with a Terraform Cloud user API token
    - name: Setup Terraform
      uses: hashicorp/setup-terraform@v1
      #with:
      #  cli_config_credentials_token: ${{ secrets.TF_API_TOKEN }}

    - name: Setup terraform variables
      id: vars
      run: |-
        cat > pipeline.auto.tfvars <<EOF
        region="${{ vars.GCP_REGION }}" 
        project="${{ vars.GCP_PROJECT }}" 
        data-project="${{ vars.GCP_DATA_PROJECT }}"
        bk_csv="${{ vars.BK_CSV }}"
        bk_parquet="${{ vars.BK_PARQUET}}"
        EOF

    # Initialize a new or existing Terraform working directory by creating initial files, loading any remote state, downloading modules, etc.
    - name: Terraform Init
      run: terraform init
      env:
        GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }}

    # Checks that all Terraform configuration files adhere to a canonical format
    #- name: Terraform Format
    #  run: terraform fmt -check

    # Generates an execution plan for Terraform
    - name: Terraform Plan
      run: terraform plan -input=false
      env:
        GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }}

      # On push to "main", build or change infrastructure according to Terraform configuration files
      # Note: It is recommended to set up a required "strict" status check in your repository for "Terraform Cloud". See the documentation on "strict" required status checks for more information: https://help.github.com/en/github/administering-a-repository/types-of-required-status-checks
    - name: Terraform Apply
      if: github.ref == 'refs/heads/main' && github.event_name == 'push'
      run: terraform apply -auto-approve -input=false
      env:
        GOOGLE_CREDENTIALS: ${{ secrets.GOOGLE_CREDENTIALS }}
```

After creating all the resources and settings in the Terraform files, push them to github and watch the resources being created in GCP. Use the following commands:
```
git add .
git commit -m "Comentário desejado"
git push
```
Take a look at the actions created in the git hub: 
![alt text](documentacao/imagem%207.PNG) 
If the action turns green, the resources have been created/changed and can be seen in the GCP.

## Opportunity for Improvement
- Implementation of medallion architecture: Given the needs of the case, the architecture implemented is simple. However, when dealing with a large volume of data, with specific needs, robust and scalable architectures should be adopted, such as the Medallion architecture, which has 3 layers representing different stages of data processing.
- Avoid using external tables as a data source: External tables should be avoided when there is a need for high performance (large volumes of data), low cost, and the need to execute DML commands.
- Data ETL: For this project there was no need to perform data transformations, only extraction and loading. However, in real projects, the use of data transformation steps is essential, especially in order to guarantee the quality of the information contained in the data.
- Reusable modules: It is possible to create Terraform modules to reuse common configurations in various projects, facilitating standardization and maintenance. Therefore, if terraform is implemented in new projects, it should be used to facilitate their creation.
- Restructuring the development environment: In the current project, there is only one development environment. Aiming for a robust solution, a minimum of two environments (dev and prod) should be adopted, thus ensuring that all tests are carried out and validated in a non-productive environment.
- Use of Cloud Functions: Use cloud functions to query the Google Sheet and store the data in a bucket, thus avoiding the use of APIs, which are slow.
