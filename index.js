const port = 8080;

var express = require('express'),
    app = express();
var bodyParser = require('body-parser');

app.use(express.static(__dirname + '/public'));

app.use(bodyParser.urlencoded({
   extended: false
}));

app.use(bodyParser.json());

app.get('/', function(req, res){
  res.render('form');// if jade
  // You should use one of line depending on type of frontend you are with
  res.sendFile(__dirname + '/form.html'); //if html file is root directory
 res.sendFile("index.html"); //if html file is within public directory
});

app.post('/',function(req,res){
  
   var ferightWeight = req.body.weight;
   var pickUpLocation = req.body.pickUpLocation;
   var dropOffLocation = req.body.dropOffLocation;
   var searchParams = {
     'weight' : ferightWeight,
     'pickUpLocation' : pickUpLocation,
     'dropOffLocation' :dropOffLocation
    }

   res.send(searchParams);
   console.log(searchParams);
});

app.listen(port);