#! /bin/bash
sudo apt update

# install git
sudo apt install -yy git
git config --global user.email "jakyandras@gmail.com"
git config --global user.name "akijakya"

# install Node
sudo apt install -yy npm

# cloning repo
mkdir ~/greeter
cd greeter
git clone https://github.com/akijakya/docker-jenkins-test.git
cd docker-jenkins-test
npm install
npm start