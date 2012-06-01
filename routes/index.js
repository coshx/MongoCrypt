exports.home = function(req, res){
  var locals = {title:'Home', headerActives: 'home'};
  res.render('home',locals);};
exports.landing = function(req, res){
  var locals = {title:'Manage', headerActives:'landing'};
  res.render('landing',locals);};

exports.help = function(req, res){
  var locals = {title:'Help', headerActives:'help'};
  res.render('help',locals);};

exports.index = function(req, res){
  var locals = {title:'Index', headerActives: 'index'};
  res.render('index',locals);};
  
exports.pricing = function(req, res){
  var locals = {title:'Pricing', headerActives: 'pricing'};
  res.render('pricing',locals);};
  
  /*
 * GET home page.
 */