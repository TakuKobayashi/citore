var bgRenderIndex = 0;
var images = []

var imageLoad = function(url, onload){
  var img = new Image();
  img.src = url;
  img.onload = function() {
    onload(img);
  }
}

$(document).ready(function(){
  var canvas  = document.getElementById('bgimage');
  var ctx = canvas.getContext('2d');
  var imagepathes = $('.top-mv-visual-bg-item').data('imagepathes');

  var width = window.innerWidth;
  var height = window.innerHeight;

  var resizeCanvas = function(){
    width = window.innerWidth;
    height = window.innerHeight;
    $('#bgimage').attr('width', width);
    $('#bgimage').attr('height', height);
    if(images.length > 0){
      ctx.drawImage(images[bgRenderIndex], 0, 0, width, height);
    }
  }

  resizeCanvas();

  for(var i = 0;i < imagepathes.length;++i){
    imageLoad(imagepathes[i], function(image){
      if(images.length == 0){
        ctx.drawImage(image, 0, 0, width, height);
      }
      images.push(image);
    });
  }
  window.addEventListener('resize', resizeCanvas, false);

  setInterval(function(){
    bgRenderIndex++;
    bgRenderIndex = bgRenderIndex % images.length;
    ctx.drawImage(images[bgRenderIndex], 0, 0, width, height);
  }, 3000);
});