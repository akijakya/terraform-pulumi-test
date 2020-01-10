const express = require('express');
const app = express();
const path = require('path');

app.get('/', function (req, res) {
    res.status(200);
    res.sendFile(path.join(__dirname, '/index.html'));
});

module.exports = app;