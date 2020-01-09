#! /bin/bash
apt update

# install git
apt install -yy git

# install Node
apt install -yy npm

# cloning repo
cd ~
git clone https://github.com/akijakya/docker-jenkins-test.git
cd docker-jenkins-test
npm install
npm start