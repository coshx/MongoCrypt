
var resources = [];

exports.getNewResource = function(plan_name){



  var url = "mongodb://heroku:1dsJh76GFBaSSn88@23.21.192.227:27017/db1"

  var resource =  {id : resources.length + 1, config : { "MONGOCRYPT2_URL" : url } }

  resources.push(resource) ;
  return resource ;
}

exports.getResource = function(id){
 id = parseInt(id)
 for (i in resources) {
   if(resources[i].id == id){
     return resources[i]  ;
   }
 }
}

exports.destroyResource = function(id){
 id = parseInt(id)
 for (i in resources) {
   if(resources[i].id == id){
     delete resources[i]
     var exec = require('child_process').exec;
     exec('node -v', flow.set('output'));
     results = flow.get('output') ;
     console.log(results) ;
   }
 }
}



