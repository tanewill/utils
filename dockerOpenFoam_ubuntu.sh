#!/bin/bash -x
sudo su
apt-get update
apt-get install apt-transport-https ca-certificates
apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
touch /etc/apt/sources.list.d/docker.list
echo "deb https://apt.dockerproject.org/repo ubuntu-precise main" >> /etc/apt/sources.list.d/docker.list
apt-get update
apt-get purge lxc-docker
apt-cache policy docker-engine
apt-get update
apt-get install -y docker-engine
service docker start
docker run hello-world
docker search openfoam
docker run -v /home/azureuser:/home/ubuntu/ -ti jarrodsinclair/openfoam_2.3.1 /bin/bash
exit
cp -r /opt/openfoam231/tutorials/ /home/ubuntu
