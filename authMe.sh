#!/bin/bash -xv

USER=azureuser
PASS=Azure@123
nmap -sn 10.0.0.* | grep 10.0.0. | awk '{print $5}' > nodeips.txt
for NAME in `cat nodeips.txt`; do sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'hostname';done
for NAME in `cat nodeips.txt`; do sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'hostname' >> nodenames.txt;done

HOSTIP=`hostname`
cp /home/$USER/.ssh/id_rsa.pub /home/$USER/.ssh/authorized_keys
NAMES=`cat nodenames.txt` #names from names.txt file
for NAME in $NAMES; do
  echo "working on $NAME"
#  if [ $NAME != $HOSTIP ]
#    then
#        echo $NAME is not headnode
                sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'rm -rf /home/'$USER'/.ssh && mkdir /home/'$USER'/.ssh && chmod 750 /home/'$USER'/.ssh'
                sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=1 /home/$USER/.ssh/authorized_keys $USER@$NAME:/home/$USER/.ssh/authorized_keys
                sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=2 /home/$USER/.ssh/known_hosts $USER@$NAME:/home/$USER/.ssh/known_hosts
                sshpass -p $PASS scp -o "StrictHostKeyChecking no" -o ConnectTimeout=2 /home/$USER/.ssh/id_rsa $USER@$NAME:/home/$USER/.ssh/id_rsa
#      continue
#  fi

  sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'chmod 644 /home/$USER/.ssh/authorized_keys'
  sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'touch /home/'$USER'/.ssh/config'
  sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'echo "Host *" >  /home/'$USER'/.ssh/config'
  sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'echo StrictHostKeyChecking no >> /home/'$USER'/.ssh/config'
  sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'chmod 400 /home/'$USER'/.ssh/config'
  echo "completed $NAME"
done


