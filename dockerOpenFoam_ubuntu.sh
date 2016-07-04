#!/bin/bash -x
sudo apt-get update
sudo apt-get install apt-transport-https ca-certificates
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
touch /etc/apt/sources.list.d/docker.list
sudo echo "deb https://apt.dockerproject.org/repo ubuntu-precise main" >> /etc/apt/sources.list.d/docker.list
sudo apt-get update
sudo apt-get purge lxc-docker
apt-cache policy docker-engine
sudo apt-get update
sudo apt-get install docker-engine
sudo service docker start
sudo docker run hello-world
sudo docker search openfoam
sudo docker run -v /home/azureuser:/home/ubuntu/ -ti jarrodsinclair/openfoam_2.3.1 /bin/bash
cp -r /opt/openfoam231/tutorials/ /home/ubuntu
