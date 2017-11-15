#!/bin/zsh

while true
do;
  echo `cat $1 | awk '{sum+=$1 ;} END{print sum}'`
  sleep 10
done
