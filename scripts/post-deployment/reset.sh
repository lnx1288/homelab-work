#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none

hold_apps="openssh-server snapd salt-minion byobu rsync ubuntu-release-upgrader-core git"

sudo -E apt-get update
sudo -E apt-get -y install aptitude ubuntu-minimal
sudo -E aptitude markauto '~i!~nubuntu-minimal'
sudo -E apt-mark hold ${hold_apps}
sudo -E apt-get -yq autoremove
dpkg -l | grep ^rc | awk '{print $2}' | xargs -i sudo -E dpkg --force-all -P "{}"
sudo -E apt-mark unhold ${hold_apps}
sudo -E apt-get -y install ${hold_apps}
sudo -E apt-get update
sudo -E apt-get -y upgrade
sudo -E salt-call state.highstate
