#cloud-boothook
#!/bin/bash

sudo yum update -y
sudo yum install -y docker
sudo usermod -a -G docker ec2-user
sudo service docker start
sudo chkconfig docker on
