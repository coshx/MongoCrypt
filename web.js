
/**
 * Module dependencies.
 */
var express = require('express')
  //, routes = require('./routes');
var crypto  = require('crypto');
var http    = require('http');
var fs      = require('fs');
var db      = require('./public/javascripts/db_interface')   ;


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
  console.log("---Basic auth---")
  console.log(req.headers.authorization)
  console.log(req.headers.authorization.search('Basic '))
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
  req.session.source = "HEROKU"       ;

  req.session.resource = db.getResource(id) ;
  req.session.email = req.param('email')    ;
  next();
}

// Routes

//app.get('/', routes.index);
//HOME PAGE
app.get('/home', function(request, response) {
  	response.render('home.jade', {  title: 'MongoCrypt', session_source: request.session.source, headerActives: 'home' })
});
//PRICING
app.get('/pricing', function(request, response){
	response.render('pricing.jade', { title: 'MongoCrypt', session_source: request.session.source, headerActives: 'pricing'})
});

//DEMO LANDING PAGE
app.get('/landing', function(request, response) {
  	response.render('landing.jade', {  title: 'MongoCrypt',session_source: request.session.source, headerActives: 'landing'})
});
//README
app.get('/help', function(request, response) {
  	response.render('help.jade', {  title: 'MongoCrypt',session_source: request.session.source, headerActives: 'help'})
});
//SSO LANDING PAGE
app.get('/', function(request, response) {
  if(request.session.resource){
    response.render('index.jade', {layout: 'layout.jade', title: 'MongoCrypt', session_source: request.session.source, resource: request.session.resource, email: request.session.email })
  }
  else if(request.session.email){
    console.log("---Error loading sso landing page---")
	console.log("session info:")
	console.log(request.session)
	console.log("session resource:")
	console.log(request.session.resource)
	response.redirect("/landing")	
  }
  else{
	response.redirect("/home")
    //response.send("Not found", 404);
  }
});

//provision
app.post('/heroku/resources', express.bodyParser(), basic_auth, function(request, response) {
  console.log(request.body)
  var resource = db.getNewResource("test") ;
  response.send(resource)
});

//Deprovision
app.delete('/heroku/resources/:id', basic_auth, function(request, response) {
  console.log(request.params)
  if(!db.getResource(request.params.id)){
    response.send("Not found", 404);
    return;
  }
  db.destroyResource(request.params.id)
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

//Plan Change
app.put('/heroku/resources/:id', express.bodyParser(), basic_auth, function(request, response) {
  console.log(request.body)
  console.log(request.params) 
  var resource =  db.getResource(request.params.id)
  if(!resource){
    response.send("Not found", 404);
    return;
  }
  resource.plan = request.body.plan
  response.send("ok")
})

var port = process.env.PORT || 3000;
app.listen(port, function() {
  console.log("Listening on " + port);
});

app.dynamicHelpers({
  session: function(req, res){
    return req.session;
  }
});