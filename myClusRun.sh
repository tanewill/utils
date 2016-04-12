#!/bin/bash

USER=azureuser
PASS=Azure@123

NAMES=`cat nodenames.txt` #names from names.txt file
for NAME in $NAMES; do
  echo "working on $NAME"

#the & here will fork off a run for each node and move to the next, the wait at the end waits until all is complete
  sshpass -p $PASS ssh $USER@$NAME $1 &
#  cp /home/$USER/.ssh/id_rsa.pub authorized_keys
#  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/authorized_keys $USER@$NAME:/home/$USER/.ssh/authorized_keys

  echo "completed $NAME"
done
wait
