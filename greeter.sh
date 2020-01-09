#! /bin/bash
sudo apt update

# Installing Node
sudo apt install -yy npm

# Starting application
cd ~/hello-world
npm install
npm start