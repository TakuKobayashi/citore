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
  var width = $('#bgimage').width();
  var height = $('#bgimage').height();
  console.log(width);
  console.log(height);
  $('#bgimage').attr('width', width);
  $('#bgimage').attr('height', height);
  for(var i = 0;i < imagepathes.length;++i){
  	imageLoad(imagepathes[i], function(image){
      images.push(image);
      if(i == 0){
        drawImage(ctx, image)
      }
  	});
      /* 画像を描画 */
  }
  setInterval(function(){
  	bgRenderIndex++;
  	bgRenderIndex = bgRenderIndex % images.length
    ctx.drawImage(images[bgRenderIndex], 0, 0);
  }, 3000);
});