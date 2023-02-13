const express = require('express')
const app = express()
 
app.get('/', function (req, res) {
    console.log("GET /")
    res.send('Hello World')
})
 
app.listen(8080)