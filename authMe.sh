#!/bin/bash

USER=azureuser
PASS=Azure@123

NAMES=`cat nodenames.txt` #names from names.txt file
for NAME in $NAMES; do
  echo "working on $NAME"

  sshpass -p $PASS ssh $USER@$NAME 'rm -rf /home/$USER/.ssh && mkdir /home/$USER/.ssh && chmod 750 /home/$USER/.ssh'
  cp /home/$USER/.ssh/id_rsa.pub /home/$USER/.ssh/authorized_keys
  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/.ssh/authorized_keys $USER@$NAME:/home/$USER/.ssh/authorized_keys
  sshpass -p $PASS ssh $USER@$NAME 'chmod 644 /home/$USER/.ssh/authorized_keys'
  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/.ssh/known_hosts $USER@$NAME:/home/$USER/.ssh/known_hosts
  sshpass -p $PASSscp -o "StrictHostKeyChecking no" /home/$USER/.ssh/id_rsa $USER@$NAME:/home/$USER/.ssh/id_rsa
  echo "completed $NAME"
done

