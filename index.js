var express = require('express')
var path = require('path')
var {fileURLToPath} = require('url')


const app = express();
const port = 8080;

app.get("/", (req, res) => {
  res.sendFile(path.join(`${__dirname}/public/index.html`));
});

// POST method route
app.post('/', function (req, res) {
  res.redirect('/')
})

app.use(express.static('public'));
app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
