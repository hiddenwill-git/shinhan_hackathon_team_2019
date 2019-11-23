$(document).ready(function () {
    var viewPortScale = 1 / window.devicePixelRatio;

    $('#viewport').attr('content', 'user-scalable=no, initial-scale='+viewPortScale+', width=device-width');

    var path = $(location).attr('pathname');

    console.log('lockscreen_02');

    var ad = JSON.parse($.cookie('ad2'));

    if(ad.type == 'back'){
        $('#loding').hide();
        $('#modalText').text('20점이 적립되었습니다');
        $('#myModal').modal('show');
    }
    else if(ad.type == 'pin'){
        $('#loding').hide();
        $('#modalText').text('50점이 적립되었습니다');
        $('#myModal').modal('show');

    }
    else if(ad.type == 'reserve'){
        $('#loding').hide();
        $('#modalText').text('100점이 적립되었습니다');
        $('#myModal').modal('show');
    }

    ad.type = null;
    $.cookie('ad2', JSON.stringify(ad));
    $('#spanNum').html(ad.num);


    startDate();
    setInterval(startDate, 1000);
    setTimeout(function () {
        $('#myModal').modal('hide');
        }, 900);

    var adNum = 0;

    setInterval(function () {
        if(adNum == 0){
            $("#adImg").attr("src", "../img/widget_AD_04.png");
            adNum = 1;
        }
        else{
            $("#adImg").attr("src", "../img/widget_AD_02.png");
            adNum = 0;
        }

    }, 7000);

    setTimeout(function () {
        $('#loding').hide();
    }, 800);

    $('#backIndex').click(function (){
        window.location.href = "http://15.164.233.47:8080/mobile/html/background.html";
    });

    $('#tabtab').click(function () {
        // var tabCookie = {type : 'ad1', name : '황용식'};
        $.cookie('tabkey', '최향미');

        $("#tabtab").attr("href", "http://15.164.233.47:8080/mobile/html/tab_01.html");
    })

    $('#backA').click(function () {
        window.location.href = 'http://15.164.233.47:8080/mobile/html/lockscreen_02.html';
    })

    $('#adA').click(function () {
        var aStr = $("#adImg").attr("src");

        console.log(aStr);
        if(aStr.indexOf('widget_AD_02') != -1){
            $.cookie('adImage', 'ad_02');
        }
        else{
            $.cookie('adImage', 'ad_04');
        }
    })

    console.log(getCurl());
});

function startDate(){
    var week = new Array('일요일', '월요일', '화요일', '수요일', '목요일', '금요일', '토요일');
    var dateString = "";
    var newDate = new Date();

    dateString += ("0" + (newDate.getMonth() + 1)).slice(-2) + "월 "; //월은 0부터 시작하므로 +1을 해줘야 한다.
    dateString += ("0" + newDate.getDate()).slice(-2) + "일 ";
    dateString += week[newDate.getDay()];
    $(".day").text(dateString);

    startTime();
}

function startTime(){
    var dateString = "";
    var newDate = new Date();

    dateString += ("0" + newDate.getHours()).slice(-2) + ":";
    dateString += ("0" + newDate.getMinutes()).slice(-2);
    $(".time").text(dateString);
}

function getCurl(){
    $.ajax({
        type: "GET",
        url : "http://15.164.233.47:8080/api/v1/resource/test12",
        dataType: "json",
        success: function (data) {
            console.log(data);
            return data;
        },
        error: function (request, status, error) {
            console.log('code : ' + request.status + '\n' + "message : " + request.responseText + '\n' + 'e : ');
            return request;
        }
    });
}