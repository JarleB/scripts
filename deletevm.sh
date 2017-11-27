#!/bin/bash 

if [[ -n ${1} ]]
then
  if VBoxManage showvminfo ${1} > /dev/null 2>&1
  then
    ssh  -o StrictHostKeyChecking=false root@${1}.example.com subscription-manager unregister 
    VBoxManage controlvm ${1} poweroff
    sleep 4
    VBoxManage unregistervm ${1} --delete
  else
    echo "No such VM"
  fi
else
  echo "Need a name" 
fi

