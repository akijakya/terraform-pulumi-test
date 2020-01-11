"use strict";

const aws = require("@pulumi/aws");
const fs = require('fs');

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

let group = new aws.ec2.SecurityGroup("akijakya-pulumi-test", {
    ingress: [
        { protocol: "tcp", fromPort: 22, toPort: 22, cidrBlocks: ["0.0.0.0/0"] },
        { protocol: "tcp", fromPort: 80, toPort: 80, cidrBlocks: ["0.0.0.0/0"] },
    ],
    egress: [
        { protocol: "-1", fromPort: 0, toPort: 0, cidrBlocks: ["0.0.0.0/0"] },
    ],
});

const deployer = new aws.ec2.KeyPair("deployer", {
    publicKey: fs.readFileSync('../../../Creds/pulumi_key.pub', 'utf8'),
});

let userData = fs.readFileSync('../terraform/scripts/greeter-dockerhub.sh', 'utf8');
// `#! /bin/bash

// # installing Docker
// sudo apt-get install -yy \
//     apt-transport-https \
//     ca-certificates \
//     curl \
//     gnupg-agent \
//     software-properties-common
// curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
// sudo add-apt-repository \
//    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
//    bionic \
//    stable"
// sudo apt update
// sudo apt install -yy docker-ce docker-ce-cli containerd.io
// sudo groupadd docker
// sudo usermod -aG docker $USER

// # pulling and starting the docker container
// sudo systemctl start docker
// sudo docker pull akijakya/docker-single-test:latest
// sudo docker run -d -p 80:3000 akijakya/docker-single-test:latest`;

let serverNames = ["dev", "test", "prod"];
let serverArray = [];

serverNames.forEach((e) => {
    serverArray.push (
        new aws.ec2.Instance("akijakya-" + e, {
            instanceType: size,
            securityGroups: [ group.name ], // reference the security group resource above
            ami: ami.id,
            userData: userData,
            keyName: deployer,
            tags: {
                Name: `akijakya-${e}`,
            },
        })
    )
})

// Creating servers with a for loop:

// for (let i = 0; i < serverNames.length; ++i) {
//     serverArray[i] = new aws.ec2.Instance(serverNames[i], {
//         instanceType: size,
//         securityGroups: [ group.name ], // reference the security group resource above
//         ami: ami.id,
//         userData: userData,
//     });
// }

// The original example code for one instance:

// let server = new aws.ec2.Instance("webserver-www", {
//     instanceType: size,
//     securityGroups: [ group.name ], // reference the security group resource above
//     ami: ami.id,
//     userData = userData,
// });

// Writing data out

exports.publicIp = serverArray.map(e => e.publicIp);
exports.publicHostName = serverArray.map(e => e.publicDns);
// exports.publicIp = server.publicpublicIpIp;
// exports.publicHostName = server.publicDns;
exports.amiName = ami.id;