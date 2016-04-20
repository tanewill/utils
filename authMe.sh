#!/bin/bash

USER=azureuser
PASS=Azure@123
cp /home/$USER/.ssh/id_rsa.pub /home/$USER/.ssh/authorized_keys
NAMES=`cat nodenames.txt` #names from names.txt file
for NAME in $NAMES; do
  echo "working on $NAME"
  sshpass -p $PASS ssh $USER@$NAME 'rm -rf /home/$USER/.ssh && mkdir /home/$USER/.ssh && chmod 750 /home/$USER/.ssh'
  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/.ssh/authorized_keys $USER@$NAME:/home/$USER/.ssh/authorized_keys
  sshpass -p $PASS ssh $USER@$NAME 'chmod 644 /home/$USER/.ssh/authorized_keys'
  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/.ssh/known_hosts $USER@$NAME:/home/$USER/.ssh/known_hosts
  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/.ssh/id_rsa $USER@$NAME:/home/$USER/.ssh/id_rsa
  sshpass -p $PASS ssh $USER@$NAME 'echo hosts *' >>  /home/$USER/.ssh/config
  sshpass -p $PASS ssh $USER@$NAME 'echo StrictHostKeyChecking no' >> /home/$USER/.ssh/config
  echo "completed $NAME"
done

