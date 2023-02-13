const express = require('express')
const app = express()
 
app.get('/', function (req, res) {
    console.log("GET /")
    res.send('Hello World\n')
})
 
app.listen(8080)
