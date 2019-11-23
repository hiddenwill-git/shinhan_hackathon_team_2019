$(document).ready(function () {
    // var viewPortScale = 1 / window.devicePixelRatio;
    //
    // $('#viewport').attr('content', 'user-scalable=no, initial-scale='+viewPortScale+', width=device-width');

    var cookieData = $.cookie('tabkey');

    $('.name').text(cookieData);

    $('#backA').click(function () {
        var cookieData = $.cookie('tabkey');

        if(cookieData == '황용식'){
            $("#backA").attr("href", "http://15.164.233.47:8080/mobile/html/lockscreen_01.html");
        }
        else if(cookieData == '최향미'){
            $("#backA").attr("href", "http://15.164.233.47:8080/mobile/html/lockscreen_02.html");
        }
        else if (cookieData == '노규태') {
            $("#backA").attr("href", "http://15.164.233.47:8080/mobile/html/lockscreen_03.html");
        }
    })
});

function gogo(){
    console.log('클릭요');
    $.ajax({
        type : "GET",
        url : "http://15.164.233.47:8080/mobile/html/tab_02.html",
        dataType : "text",
        error : function() {
            alert('통신실패!!');
        },
        success : function(data) {
            $('#wrap').html(data);
            console.log('dfsdfjlk');
        }

    });
}