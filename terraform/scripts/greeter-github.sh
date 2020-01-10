#! /bin/bash

# install git
sudo apt install -yy git

# install Node
sudo apt install -yy npm

# cloning repo
cd ~
git clone https://github.com/akijakya/docker-jenkins-test.git
cd docker-jenkins-test
npm install
npm start