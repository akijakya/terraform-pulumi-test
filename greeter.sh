#! /bin/bash
apt update

# Installing Node
apt install -yy npm

# Starting application
cd ~/hello-world
npm install
npm start