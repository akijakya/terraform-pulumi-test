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
    ],
});

let server = new aws.ec2.Instance("webserver-www", {
    instanceType: size,
    securityGroups: [ group.name ], // reference the security group resource above
    ami: ami.id,
});

exports.publicIp = server.publicIp;
exports.publicHostName = server.publicDns;
exports.amiName = ami.id;