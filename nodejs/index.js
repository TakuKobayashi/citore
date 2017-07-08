var express = require('express');
var app = express();

var port = process.env.PORT || 3110;

//サーバーの立ち上げ
var http = require('http');

//指定したポートにきたリクエストを受け取れるようにする
var server = http.createServer(app).listen(port, function () {
  console.log('Server listening at port %d', port);
});

var io = require('socket.io').listen(server);

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
  ws.on('message', function (message) {
    console.log('message:', message);
    connections.forEach(function (con, i) {
      con.send(message);
    });
  });
});

app.get('/jquery/jquery.js', function(req, res) {
  res.sendFile(__dirname + '/node_modules/jquery/dist/jquery.js');
});
app.get('/', function(req, res){
  res.sendFile(__dirname + '/index.html');
});

//サーバーと接続されると呼ばれる
io.on('connection', function(socket){
  console.log('a user connected');
  //接続している、人達(socket)がサーバーにメッセーッジを送った時にcallbackされるイベントを登録
  //第一引数はイベント名
  socket.on('message', function(msg){
    //受け取った人以外でつながっている人全員に送る場合(broadcastを使う)
    //socket.broadcast.emit('message', 'hello');
    //受け取った人含めて全員に送る場合
    //位第一引数のイベント名に対して送る
    //socket.broadcast.emit('message', msg);
    io.emit('message', msg);
    console.log('message: ' + msg);
  });

  //サーバーとの接続が遮断されると呼ばれる
  socket.on('disconnect', function(){
    console.log('user disconnected');
  });
});