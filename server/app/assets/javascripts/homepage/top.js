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
  $(".top-prosucts-contents").slick({
    // アクセシビリティ。左右ボタンで画像の切り替えをできるかどうか
    accessibility: true,
    // 自動再生。trueで自動再生される。
    autoplay: true,
    // 自動再生で切り替えをする時間
    autoplaySpeed: 3000,
    // 自動再生や左右の矢印でスライドするスピード
    speed: 400,
    // ドラッグができるかどうか
    draggable: true,
    // 切り替え時のフェードイン設定。trueでon
    fade: true,
    // 左右の次へ、前へボタンを表示するかどうか
    arrows: true,
    // 無限スクロールにするかどうか。最後の画像の次は最初の画像が表示される。
    infinite: true,
    // 最初のスライダーの位置
    initialSlide: 0,
    // スライドのエリアに画像がいくつ表示されるかを指定
    slidesToShow: 3,
    // 一度にスライドする数
    slidesToScroll: 1,
    // タッチスワイプに対応するかどうか
    swipe: false,
    // 縦方向へのスライド
    vertical: false,
    // 表示中の画像を中央へ
　  centerMode: true,
    // 中央のpadding
    centerPadding: '160px'
  });

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