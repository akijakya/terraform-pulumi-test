"use strict";

const aws = require("@pulumi/aws");

let size = "t2.micro";     // t2.micro is available in the AWS free tier
let ami = aws.getAmi({
    filters: [{
      name: "name",
    //   values: ["amzn-ami-hvm-*"],
      values: ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server*"],
    }],
    // owners: ["137112412989"], // This owner ID is Amazon
    owners: ["099720109477"],
    mostRecent: true,
});

let group = new aws.ec2.SecurityGroup("webserver-secgrp", {
    ingress: [
        { protocol: "tcp", fromPort: 22, toPort: 22, cidrBlocks: ["0.0.0.0/0"] },
        { protocol: "tcp", fromPort: 80, toPort: 80, cidrBlocks: ["0.0.0.0/0"] },
    ],
});

let userData = 
`#! /bin/bash

# installing Docker
sudo apt-get install -yy \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg-agent \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   bionic \
   stable"
sudo apt update
sudo apt install -yy docker-ce docker-ce-cli containerd.io
sudo groupadd docker
sudo usermod -aG docker $USER

# pulling and starting the docker container
sudo systemctl start docker
sudo docker pull akijakya/docker-single-test:latest
sudo docker run -d -p 80:3000 akijakya/docker-single-test:latest`;

let server = new aws.ec2.Instance("webserver-www", {
    instanceType: size,
    securityGroups: [ group.name ], // reference the security group resource above
    ami: ami.id,
    userData = userData,
});

exports.publicIp = server.publicIp;
exports.publicHostName = server.publicDns;
exports.amiName = ami.id;