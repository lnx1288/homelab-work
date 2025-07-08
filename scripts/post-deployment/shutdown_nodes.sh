#!/bin/bash

rcmd="ssh"
cmd="sudo halt -p"

if [[ "$1" == "asrock" ]] ; then
  hosts="192.168.1.21[1-4]"
elif [[ "$1" == "pi-k8s" ]] ; then
  hosts="192.168.1.8[1-6]"
fi

pdsh -R $rcmd -l ubuntu -w $hosts -- $cmd
