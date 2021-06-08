import express from "express";
import path from "path";
import { fileURLToPath } from "url";


const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const app = express();
const port = 8080;

app.get("/", (req, res) => {
  res.sendFile(path.join(`${__dirname}/public/index.html`));
});

// POST method route
app.post('/', function (req, res) {
  console.log(req)
  res.redirect('/')
})

app.use(express.static('public'));
app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`);
});
