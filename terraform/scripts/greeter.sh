#! /bin/bash

# Installing Node
curl -sL https://deb.nodesource.com/setup_10.x | sudo -E bash -
sudo apt install -yy nodejs
sudo apt install -yy npm
sudo apt install -yy build-essential

# Starting application
cd ~/hello-world
npm install
npm start