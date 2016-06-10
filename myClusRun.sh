#!/bin/bash

USER=$1
PASS=$2

NAMES=`cat nodenames.txt` #names from names.txt file
echo "launching $1"
for NAME in $NAMES; do
  #the & here will fork off a run for each node and move to the next, the wait at the end waits until all is complete
  sshpass -p $PASS ssh $USER@$NAME $3 &
done
wait
echo "completed $3"
