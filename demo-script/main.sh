#!/bin/bash
#
# LOG8415E - Final Project. Inspired by my team solution during the first assignment. 
# See this repo for the original code: https://github.com/chrichriGeorgie/Lab1-LOG8415E
#
# main.sh
# A bash script that will orchestrate each part of the final project demonstration.

# Setting working directory
cd "$(dirname "$0")"

# AWS credentials configuration
echo "Make sure that the AWS credentials is correctly configured. The file is ~/.aws/credentials"
read -p "Press [Enter] to continue" cont
printf "\n"

# Terraform deploying AWS Infrastructure
read -p  "Do you want to deploy the necessary AWS intances? [Y/n] " deploy
printf "\n"

if [ -z "$deploy" ];
then
    deploy="y"
fi

if [ $deploy = "y" ] || [ $deploy = "Y" ];
then
    cd ../instance-creation
    terraform init
    terraform apply -auto-approve

    # Waitng for instances set up
    echo "Waiting 3 minutes for instances start up..." 
    printf "\n"
    sleep 180

    echo "Make sure to install and configure MySQL standalone and MySQL Cluster on the right instances"
    read -p "Press [Enter] to continue" cont
    printf "\n"
else
    echo "Not creating new instances, make sure you have instances already running and configured"
    read -p "Press [Enter] to continue" cont
fi

#Execution of the benchmark
db_usr='log8415_final'
db_pwd='8415Pwd!'
read -p "Press [Enter] to start database benchmark" cont
printf "\n"

# Standalone benchmark
read -p "Enter the Standalone Instance IP adress: " standalone
printf "\n"
sudo sysbench /usr/share/sysbench/oltp_read_write.lua --table-size=1000000 --mysql-host=$standalone --mysql-db=sakila --mysql-user=$db_usr --mysql-password=$db_pwd prepare
sudo sysbench /usr/share/sysbench/oltp_read_write.lua --threads=6 --time=60 --max-requests=0 --mysql-host=$standalone --mysql-db=sakila --mysql-user=$db_usr --mysql-password=$db_pwd run
sudo sysbench /usr/share/sysbench/oltp_read_write.lua --threads=6 --time=60 --max-requests=0 --mysql-host=$standalone --mysql-db=sakila --mysql-user=$db_usr --mysql-password=$db_pwd cleanup
printf "\n"

# Cluster benchmark
read -p "Enter the Primary Node Instance IP adress: " primary
printf "\n"
sudo sysbench /usr/share/sysbench/oltp_read_write.lua --table-size=1000000 --mysql-host=$primary --mysql-db=sakila --mysql-user=$db_usr --mysql-password=$db_pwd prepare
sudo sysbench /usr/share/sysbench/oltp_read_write.lua --threads=6 --time=60 --max-requests=0 --mysql-host=$primary --mysql-db=sakila --mysql-user=$db_usr --mysql-password=$db_pwd run
sudo sysbench /usr/share/sysbench/oltp_read_write.lua --threads=6 --time=60 --max-requests=0 --mysql-host=$primary --mysql-db=sakila --mysql-user=$db_usr --mysql-password=$db_pwd cleanup
printf "\n"

#Proxy Evaluation
read -p "Press [Enter] to start cloud pattern demo" cont
printf "\n"

echo "This is the direct mode:"
printf "\n"

echo "This is the random mode:"
printf "\n"

echo "This is the smart mode:"
printf "\n"

# Terraform cleaning up instances
read -p  "Do you want to terminate the deployed AWS intances? [Y/n] " terminate
printf "\n"

if [ -z "$terminate" ];
then
    terminate="y"
fi

if [ $terminate = "y" ] || [ $terminate = "Y" ];
then
    cd ../instance-creation
    echo Cleaning instances...
    rm -f destroy.txt
    terraform destroy -auto-approve > destroy.txt
    echo Done!
else
    echo "Not removing instances, make sure to pause them when you are done working"
fi