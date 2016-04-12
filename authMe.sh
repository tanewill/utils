#!/bin/bash

USER=azureuser
PASS=Azure@123

NAMES=`cat nodenames.txt` #names from names.txt file
for NAME in $NAMES; do
  echo "working on $NAME"
# copy the file to the remote server and don’t ask to check each fingerprint!

  sshpass -p $PASS ssh $USER@$NAME 'rm -rf /home/$USER/.ssh && mkdir /home/$USER/.ssh && chmod 750 /home/$USER/.ssh'
  cp /home/$USER/.ssh/id_rsa.pub authorized_keys
  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/authorized_keys $USER@$NAME:/home/$USER/.ssh/authorized_keys

#cat the fingerprint into the proper file without overwriting anything that is already there.
#ssh -o "StrictHostKeyChecking no" azureuser@$NAMES cat somekey.txt >> ~/.ssh/authorized_keys
#sshpass -p 'Azure@123' ssh azureuser@$NAMES cat /home/azureuser/somekey.txt >> /home/azureuser/authorized_keys
#remove the somekey.txt file from the remote server
  sshpass -p $PASS ssh $USER@$NAME 'chmod 644 /home/$USER/.ssh/authorized_keys'
  sshpass -p $PASS scp -o "StrictHostKeyChecking no" /home/$USER/.ssh/known_hosts $USER@$NAME:/home/$USER/.ssh/known_hosts
  sshpass -p $PASSscp -o "StrictHostKeyChecking no" /home/$USER/.ssh/id_rsa $USER@$NAME:/home/$USER/.ssh/id_rsa
  echo "completed $NAME"
done

