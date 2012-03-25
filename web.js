var express = require('express');
var resources = [];

function get_resource(id) {
 id = parseInt(id)
 for (i in resources) {
   if(resources[i].id == id){
     return resources[i] 
   }
 }
}

function destroy_resource(id) {
 id = parseInt(id)
 for (i in resources) {
   if(resources[i].id == id){
     delete resources[i] 
   }
 }
}

/**
 * Module dependencies.
 */

var express = require('express')
  , routes = require('./routes');
var crypto  = require('crypto');

var app = module.exports = express.createServer();

// Configuration

app.configure(function(){
  app.set('views', __dirname + '/views');
  app.set('view engine', 'jade');
  app.use(express.bodyParser());
  app.use(express.methodOverride());
  app.use(express.cookieParser());
  app.use(express.session({ secret: 'your secret here' }));
  app.use(app.router);
  app.use(express.static(__dirname + '/public'));
});

app.configure('development', function(){
  app.use(express.errorHandler({ dumpExceptions: true, showStack: true }));
});

app.configure('production', function(){
  app.use(express.errorHandler());
});

function basic_auth (req, res, next) {
  if (req.headers.authorization && req.headers.authorization.search('Basic ') === 0) {
    // fetch login and password
    if (new Buffer(req.headers.authorization.split(' ')[1], 'base64').toString() == 
        process.env.HEROKU_USERNAME + ':' + process.env.HEROKU_PASSWORD) {
      next();
      return;
    }
  }
  console.log('Unable to authenticate user');
  console.log(req.headers.authorization);
  res.header('WWW-Authenticate', 'Basic realm="Admin Area"');
  res.send('Authentication required', 401);
}

function sso_auth (req, res, next) {
  if(req.params.length == 0){
    var id = req.param('id');
  }else{
    var id = req.params.id;
  }
  console.log("id for sso auth is ")
  console.log(id)
  console.log(req.params)
  var pre_token = id + ':' + process.env.SSO_SALT + ':' + req.param('timestamp')
  var shasum = crypto.createHash('sha1')
  shasum.update(pre_token)
  var token = shasum.digest('hex')
  if( req.param('token') != token){
	console.log(req.param('token'))
	console.log(token)
	console.log(pre_token)
    res.send("Token Mismatch.", 403);
    return;
  }
  var time = (new Date().getTime() / 1000) - (2 * 60);
  if( parseInt(req.param('timestamp')) < time ){
    res.send("Timestamp Expired", 403);
    return;
  }
  res.cookie('heroku-nav-data', req.param('nav-data'))
  req.session.resource = get_resource(id)
  req.session.email = req.param('email')
  next();
}

// Routes

app.get('/', routes.index);

app.post('/heroku/resources', express.bodyParser(), basic_auth, function(request, response) {
  // TODO actually spin up db node
  console.log(request.body)
  var resource =  {id : resources.length + 1, plan : request.body.plan }
  resources.push(resource)
  response.send(resource)
});

//Deprovision
app.delete('/heroku/resources/:id', basic_auth, function(request, response) {
  console.log(request.params)
  if(!get_resource(request.params.id)){
    response.send("Not found", 404);
    return;
  }
  destroy_resource(request.params.id)
  response.send("ok")
})

//GET SSO
app.get('/heroku/resources/:id', sso_auth, function(request, response) {
  response.redirect("/")
})

//POST SSO
app.post('/sso/login', express.bodyParser(), sso_auth, function(request, response){
  response.redirect("/")
})

var port = process.env.PORT || 3000;
app.listen(port, function() {
  console.log("Listening on " + port);
});