#!/bin/bash

source ~/.vboxrc
golden_image="rhel6-golden"
pw=${portal_pw}
domain='.example.com'
snapshot='2ab5ddae-f5c1-44c7-9f24-af1695497ff3'
snapshot=${vbox_rhel7_snapshot_id}


if [[ -z ${portal_pw} ]]
then 
  echo "please set environment var: portal_pw"
  exit 1 
fi

if [[ -z ${snapshot} ]]
then
  echo "please set environment var: snapshot"
  exit 1
fi



if [[ -n ${1} ]]
then
  VBoxManage clonevm ${golden_image} --options link --name ${1} --snapshot ${snapshot} --register --mode machine && \
  VBoxManage startvm ${1} --type headless
else
  echo "Need a name"
  exit 1
fi


echo "Waiting for vm to come up"
while ! nc -w 1 "${golden_image}.example.com" 22 > /dev/null 2>&1
do
  sleep 2
  echo -n '#'
done

cmd="ssh -o StrictHostKeyChecking=false root@${golden_image}${domain} perl -pi -e 's/rhel6-golden.example.com/${1}${domain}/g;' /etc/sysconfig/network"
echo "Setting hostname to ${1}" && \
echo ${cmd} && \
${cmd} && \
ssh -o StrictHostKeyChecking=false root@${golden_image}${domain} hostname ${1}${domain} && \
echo "subscribe" && \
ssh  -o StrictHostKeyChecking=false root@${golden_image}${domain} subscription-manager register --username jbjorgee@redhat.com --password $pw --auto-attach && \
echo "disable all repos" && \
ssh  -o StrictHostKeyChecking=false root@${golden_image}${domain} subscription-manager repos --disable='*' && \
echo "enable rhel-6-server-rpms repo" && \
ssh  -o StrictHostKeyChecking=false root@${golden_image}${domain} subscription-manager repos --enable=rhel-6-server-rpms --enable rhel-6-server-optional-rpms --enable rhel-6-server-extras-rpms && \
ssh  -o StrictHostKeyChecking=false root@${golden_image}${domain} yum -y install httpd libselinux-python && \
echo "reboot" && \
ssh  -o StrictHostKeyChecking=false root@${golden_image}${domain} reboot 

