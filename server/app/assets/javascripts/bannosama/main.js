function file_upload()
{
    var debugStr = "";
    console.log("upload_button clicked");
    debugStr += "<br/>start";

    dispLoading("loading...");
    // フォームデータを取得
    var formdata = new FormData($('#my_form').get(0));
    $.ajax({
        url: 'http://taptappun.net/bannosama/photos/upload',
        //  url: 'https://taptappun.net/bannosama/photos/upload_message',
        // url: 'http://tniky1.com/sandbox/kinoko/recieve.php',
        type : "POST",
        data : formdata,
        processData: false,
        contentType: false,
        dataType: 'json',
        success: function(response) {
            console.log("ok");
            console.dir(response);
            // $("#debug_msg0").text("ok");
            // $("#debug_msg1").text(response.toString());
            // debugStr += "<br/>ok";
            // $("#debug_msg3").text(debugStr);

            $('#confirm-modal').modal({backdrop: 'static', keyboard: false, show: true});
            removeLoading();
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
            $('#confirm-modal-error').modal({backdrop: 'static', keyboard: false, show: true});
            removeLoading();
        }

    })
    .done(function(data) {
    });
}
