#!/bin/bash
NAMES=`cat nodenames.txt` #names from names.txt file
for NAME in $NAMES; do
  echo "working on $NAME"
# copy the file to the remote server and don’t ask to check each fingerprint!

  sshpass -p 'Azure@123' ssh azureuser@$NAME 'rm -rf /home/azureuser/.ssh && mkdir /home/azureuser/.ssh && chmod 750 /home/azureuser/.ssh'
  cp /home/azureuser/.ssh/id_rsa.pub authorized_keys
  sshpass -p 'Azure@123' scp -o "StrictHostKeyChecking no" /home/azureuser/authorized_keys azureuser@$NAME:/home/azureuser/.ssh/authorized_keys

#cat the fingerprint into the proper file without overwriting anything that is already there.
#ssh -o "StrictHostKeyChecking no" azureuser@$NAMES cat somekey.txt >> ~/.ssh/authorized_keys
#sshpass -p 'Azure@123' ssh azureuser@$NAMES cat /home/azureuser/somekey.txt >> /home/azureuser/authorized_keys
#remove the somekey.txt file from the remote server
  sshpass -p 'Azure@123' ssh azureuser@$NAME 'chmod 644 /home/azureuser/.ssh/authorized_keys'
  sshpass -p 'Azure@123' scp -o "StrictHostKeyChecking no" /home/azureuser/.ssh/known_hosts azureuser@$NAME:/home/azureuser/.ssh/known_hosts
  sshpass -p 'Azure@123' scp -o "StrictHostKeyChecking no" /home/azureuser/.ssh/id_rsa azureuser@$NAME:/home/azureuser/.ssh/id_rsa
  echo "completed $NAME"
done
