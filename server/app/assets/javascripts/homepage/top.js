var bgRenderIndex = 0;
var images = []

var imageLoad = function(url, onload){
  var img = new Image();
  img.src = url;
  img.onload = function() {
  	onload(img);
  }
}

var drawImage = function(canvas, image){
  canvas.drawImage(image, 0, 0);
}

$(document).ready(function(){
  var canvas  = document.getElementById('bgimage');
  var ctx = canvas.getContext('2d');
  var imagepathes = $('.top-mv-visual-bg-item').data('imagepathes');

  var resizeCanvas = function(){
  	console.log(images.length);
    var width = window.innerWidth;
    var height = window.innerHeight;
    $('#bgimage').attr('width', width);
    $('#bgimage').attr('height', height);
    if(images.length > 0){
      drawImage(ctx, images[bgRenderIndex]);
    }
  }

  resizeCanvas();

  for(var i = 0;i < imagepathes.length;++i){
  	imageLoad(imagepathes[i], function(image){
  	  if(images.length == 0){
  	    drawImage(ctx, image);
  	  }
      images.push(image);
  	});
  }
  window.addEventListener('resize', resizeCanvas, false);

  setInterval(function(){
  	bgRenderIndex++;
  	bgRenderIndex = bgRenderIndex % images.length
    drawImage(ctx, images[bgRenderIndex]);
  }, 3000);
});