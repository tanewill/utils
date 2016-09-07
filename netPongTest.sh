#!/bin/bash
#for centos user must first install epel-release, sshpass, and nmap (sshpass and nmap are available from epel-release for CENTOS)

#usage ./netPongTest.sh OPTIONAL([username] [password] [internalIP prefix])
# ./authMe2.sh azureuser password 10.2.1
USER=$1
PASS=$2
IPPRE=$3
HEADNODE=`hostname`



if [ ! -f nodenames.txt ]; then
        nmap -sn $IPPRE.* | grep $IPPRE. | awk '{print $5}' > nodeips.txt
        for NAME in `cat nodeips.txt`; do sshpass -p $PASS ssh -o ConnectTimeout=2 $USER@$NAME 'hostname' >> nodenames.txt;done
fi

for NAME in `cat nodenames.txt`; do for NAME2 in `cat nodenames.txt`; do echo -n $NAME,$NAME2; mpirun -hosts $NAME,$NAME2 -ppn 1 -n 2 -env I_MPI_FABRICS=dapl -env I_MPI_DAPL_PROVIDER=ofa-v2-ib0 -env I_MPI_DYNAMIC_CONNECTION=0 IMB-MPI1 pingpong|grep 1048576|awk '{ print " ",$4 }'; done; done
