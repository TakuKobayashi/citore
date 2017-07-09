var path = require('path');
var railsRootPath = path.normalize(__dirname + "/../server");
var fs = require("fs");
var apiConfigString = fs.readFileSync(path.normalize(railsRootPath + "/config/apiconfig.yml"), "utf8");

var YAML = require('yamljs');
var apiConfig = YAML.parse(apiConfigString);

var sanitizer = require('./sanitizer.js');

var express = require('express');
var app = express();

var port = process.env.PORT || 3110;

//サーバーの立ち上げ
var http = require('http');

//指定したポートにきたリクエストを受け取れるようにする
var server = http.createServer(app).listen(port, function () {
  console.log('Server listening at port %d', port);
});

var Twitter = require('twitter');
var twitterClient = new Twitter({
  consumer_key: apiConfig.twitter.citore.consumer_key,
  consumer_secret: apiConfig.twitter.citore.consumer_secret,
  access_token_key: apiConfig.twitter.citore.bot.access_token_key,
  access_token_secret: apiConfig.twitter.citore.bot.access_token_secret
});

var WebSocketServer = require('ws').Server;
var wss = new WebSocketServer({server:server});

var connections = []; 
wss.on('connection', function (ws) {
  console.log('connect!!');
  connections.push(ws);
  ws.on('close', function () {
    console.log('close');
    connections = connections.filter(function (conn, i) {
      return (conn === ws) ? false : true;
    });
  });
});

var twitterStream = twitterClient.stream('statuses/sample.json');
twitterStream.on('data', function(event) {
  if(event.user.lang == "ja" && !event.retweeted && !event.favorited){
    var sanitized_word = sanitizer.delete_reply_and_hashtag(event.text);
    sanitized_word = sanitizer.delete_retweet(sanitized_word);
    sanitized_word = sanitizer.delete_url(sanitized_word);
    sanitized_word = sanitizer.delete_symbols(sanitized_word);
    connections.forEach(function (con, i) {
      con.send(sanitized_word);
    });
  }  
});

twitterStream.on('error', function(error) {
  throw error;
});