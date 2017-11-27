#!/bin/bash

source ~/.vboxrc
golden_image="rhel7-golden"
pw=${portal_pw}
domain='.example.com'
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

echo "Waiting for ${golden_image}.example.com to come up"
while ! nc -w 1 "${golden_image}.example.com" 22 > /dev/null 2>&1
do
  sleep 2
  echo -n '#'
done

echo "Setting hostname to ${1}"
ssh -o StrictHostKeyChecking=false root@${golden_image}${domain} hostnamectl set-hostname ${1}${domain} && \
echo "reboot"
ssh  -o StrictHostKeyChecking=false root@${golden_image}${domain} reboot 
echo "Waiting for ${1}.example.com to come up"
while ! nc -w 1 "${1}.example.com" 22 > /dev/null 2>&1
do
  sleep 2
  echo -n '#'
done
ssh_cmd="ssh  -o StrictHostKeyChecking=false root@${1}${domain}"
echo "subscribe"
${ssh_cmd} subscription-manager register --username jbjorgee@redhat.com --password $pw --auto-attach --force
#rhel-7-server-rh-common-rpms 
#echo "disable all repos" 
#${ssh_cmd} subscription-manager repos --disable='*'
#echo "enable rhel-7-server-rpms repo"
${ssh_cmd} subscription-manager repos --enable=rhel-7-server-rpms --enable rhel-7-server-optional-rpms --enable rhel-7-server-extras-rpms --enable=rhel-7-server-rh-common-rpms --enable=rhel-7-fast-datapath-rpms --enable=rhel-7-server-ose-3.6-rpms

# product update stuff (PCP)
#${ssh_cmd} yum -y install pcp-zeroconf pcp-webapi cockpit rhel-system-roles ansible httpd policycoreutls-python pcp-webjs
#${ssh_cmd} firewall-cmd --permanent --zone=public --add-service=pmcd
#${ssh_cmd} firewall-cmd --permanent --zone=public --add-port=44323/tcp
#${ssh_cmd} firewall-cmd --permanent --zone=public --add-port=9090/tcp
#${ssh_cmd} firewall-cmd --reload
#${ssh_cmd} systemctl start pmwebd
#${ssh_cmd} systemctl enable pmwebd
#${ssh_cmd} systemctl start cockpit
#${ssh_cmd} systemctl enable cockpit
#scp -r ~/bin/files/ansible-demo-templates root@${1}${domain}:/root/templates
#

