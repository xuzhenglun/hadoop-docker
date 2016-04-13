#!/bin/bash

: ${HADOOP_PREFIX:=/usr/local/hadoop}

$HADOOP_PREFIX/etc/hadoop/hadoop-env.sh

rm /tmp -rf

# installing libraries if any - (resource urls added comma separated to the ACP system variable)
cd $HADOOP_PREFIX/share/hadoop/common ; for cp in ${ACP//,/ }; do  echo == $cp; curl -LO $cp ; done; cd -

# altering the core-site configuration
sed s/HOSTNAME/master/ /usr/local/hadoop/etc/hadoop/core-site.xml.template > /usr/local/hadoop/etc/hadoop/core-site.xml
rm /usr/local/hadoop/etc/hadoop/slaves

SlaveNum=$2
((SlaveNum--))

for i in $(seq 0 $SlaveNum)
do
    echo slave$i >> /usr/local/hadoop/etc/hadoop/slaves
done

service sshd start

if [[ $1 == "-slave" ]]; then
  while true; do sleep 1000; done
fi

if [[ $1 == "-master" ]]; then

  for i in $(seq 0 $SlaveNum)
  do
    scp /etc/hosts slave$i:/etc/hosts
  done

  /usr/local/hadoop/bin/hdfs namenode -format

  $HADOOP_PREFIX/sbin/start-dfs.sh
  $HADOOP_PREFIX/sbin/start-yarn.sh
  while true; do sleep 1000; done
fi
