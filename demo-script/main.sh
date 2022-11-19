#
# The current script is inspired by the solution created by my team during the first assignment of LOG8415E. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#

#!/bin/bash
# Setting working directory
cd "$(dirname "$0")"

# AWS credentials configuration
echo AWS Access Key ID:
read aws_access_key_id

echo AWS Secret Access Key:
read aws_secret_access_key

echo AWS Session Token:
read aws_session_token

aws configure set aws_access_key_id $aws_access_key_id
aws configure set aws_secret_access_key $aws_secret_access_key
aws configure set aws_session_token $aws_session_token

# Terraform deploying AWS Infrastructure
cd ../instance-creation
terraform init
terraform apply -auto-approve
cd ..

# Terraform cleaning up instances
cd ../instance-creation
echo Cleaning instances...
rm -f destroy.txt
terraform destroy -auto-approve > destroy.txt
echo Done!
cd ..