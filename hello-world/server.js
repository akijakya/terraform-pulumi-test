const express = require('express');
const app = express();
const path = require('path');
const PORT = 3000;

app.get('/', function (req, res) {
    res.status(200);
    res.sendFile(path.join(__dirname, '/index.html'));
});

app.listen(PORT, () => {
    console.log(`The server is up and running on ${PORT}`);
});