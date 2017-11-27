#!/bin/bash


if [[ -z ${1} ]]
then 
  echo "Need listname as argument"
  exit 1
fi

listname=$1

if [[ -z $2 ]]
then
  backlog=12
else
  backlog=$2
fi


for i in `seq 1 ${backlog}`
do
  # http://post-office.corp.redhat.com/archives/openshift-sme/2017-November.txt.gz
  yearmonth=`date -v-${i}m +%Y-%B`
  url="http://post-office.corp.redhat.com/archives/${listname}/${yearmonth}.txt.gz"
  cd ~/mail
  echo 
  curl -O ${url}
  gunzip ${yearmonth}.txt.gz
  cat ${yearmonth}.txt ${listname} | sponge > ${listname} && rm ${yearmonth}.txt
done
