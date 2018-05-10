$(function() {

    IMAGES = [];
    
    function resizeImage(file, no) {
        var d = new $.Deferred();
        var mpImg = new MegaPixImage(file);
        var src_keeper = document.getElementById('src_keeper');
        EXIF.getData(file, function() {
            var orientation = file.exifdata.Orientation;
            var mpImg = new MegaPixImage(file);
            mpImg.render(src_keeper, { maxWidth: 1024, orientation: orientation }, function() {
                var resized_img = $(src_keeper).attr('src');
                d.resolve(resized_img, no);
            });
        });
        return d.promise();
    }

    var sortable;
    $('#file').on('change', function() {
        var files_length = this.files.length; 
        for (var i=0; i<files_length; i++) {
            var file = this.files[i];
            resizeImage(file, i).then(function(resize_image, no) {
                var img = $('<img>');
                $(img).css('width', '100px');
                img.attr('id', no);
                img.attr('src', resize_image);
                var canvasData = resize_image.replace(/^data:image\/jpeg;base64,/, '');
                IMAGES.push(canvasData);
                $('#img').append(img);
                // 全ての画像を読み込んだら以下の処理を実行
                if ($('#img').find('img').size() == files_length) {
                    if (files_length > 1) {
                        sortable = new Sortable(document.getElementById('img'), {
                            group: 'photo',
                            animation: 150
                        });
                    }
                }
            });
        };
    });
    
     $('#upload_button').on('click', function() {
     
        var debugStr = "";
        console.log("upload_button clicked");
        debugStr += "<br/>start";

        var fd = new FormData();
        var curLength = IMAGES.length;
        debugStr = debugStr + "<br/>" + curLength;
                
        $('#img').find('img').each(function() {
            var i = parseInt($(this).attr('id'));
            fd.append('image_files[]', IMAGES[i]);
            debugStr = debugStr + "<br/>uploadFile index : " + i;
        });
        $.ajax({
            url: 'http://tniky1.com/sandbox/kinoko/recieve.php',
/*             url: 'https://taptappun.net/bannosama/photos/upload_message', */
//            url: 'http://taptappun.net/bannosama/photos/upload',
            type: 'POST',
            data: fd,
            processData: false,
            contentType: false,
            dataType: 'json',
            success: function(response) {
                console.dir(response);
                $("#debug_msg0").text("ok");
                $("#debug_msg1").text(response.toString());
                debugStr += "<br/>ok";
                $("#debug_msg3").text(debugStr);
            },
            error: function(response) {
                console.dir(response);
                console.dir(response.status);
                $("#debug_msg0").text("ng");
                $("#debug_msg1").text(response.toString());
                $("#debug_msg2").text(JSON.stringify(response));
                debugStr += "<br/>ng";
                $("#debug_msg3").text(debugStr);
            }
        })
        .done(function(data) {
        });
    });
    
     // jQuery Upload Thumbs 
    $('form input:file').uploadThumbs({
        position  : '#preview',    // any: arbitrarily jquery selector
        alternate : '.alt'         // selecter for alternate view input file names
    });
    
});


function file_upload()
{
    var debugStr = "";
    console.log("upload_button clicked");
    debugStr += "<br/>start";

    // フォームデータを取得
    var formdata = new FormData($('#my_form').get(0));
    $.ajax({
        url: 'http://taptappun.net/bannosama/photos/upload',
/*         url: 'https://taptappun.net/bannosama/photos/upload_message', */
/*         url: 'http://tniky1.com/sandbox/kinoko/recieve.php', */
        type : "POST",
        data : formdata,
        processData: false,
        contentType: false,
        dataType: 'json',
        success: function(response) {
            console.log("ok");
            console.dir(response);
            $("#debug_msg0").text("ok");
            $("#debug_msg1").text(response.toString());
            debugStr += "<br/>ok";
            $("#debug_msg3").text(debugStr);
        },
        error: function(response) {
            console.log("ng");
            console.dir(response);
            console.dir(response.status);
            $("#debug_msg0").text("ng");
            $("#debug_msg1").text(response.toString());
            $("#debug_msg2").text(JSON.stringify(response));
            debugStr += "<br/>ng";
            $("#debug_msg3").text(debugStr);
        }
        
    })
    .done(function(data) {
    });
    
}

