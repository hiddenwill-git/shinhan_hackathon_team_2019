$(document).ready(function () {
    var viewPortScale = 1 / window.devicePixelRatio;

    $('#viewport').attr('content', 'user-scalable=no, initial-scale='+viewPortScale+', width=device-width');

    console.log('lockscreen_01');

    var ad1 = JSON.parse($.cookie('ad1'));

    if(ad1.type == 'back'){
        // $('#myModal').modal('toggle');
        $('#modalText').text('20점이 적립되었습니다');
        $('#myModal').modal('show');

        // $('#myModal').show();
    }
    else if(ad1.type == 'pin'){
        $('#modalText').text('50점이 적립되었습니다');
        $('#myModal').modal('show');
    }
    else if(ad1.type == 'reserve'){
        $('#modalText').text('100점이 적립되었습니다');
        $('#myModal').modal('show');
    }

    ad1.type = null;
    $.cookie('ad1', JSON.stringify(ad1));
    $('#spanNum').html(ad1.num);


    startDate();
    setInterval(startDate, 1000);
    setTimeout(function () {
        $('#myModal').modal('hide');
    }, 900);
    // }

    var adNum = 0;

    setInterval(function () {
        if(adNum == 0){
            $("#adImg").attr("src", "../img/widget_AD_04.png");
            adNum = 1;
        }
        else{
            $("#adImg").attr("src", "../img/widget_AD_01.png");
            adNum = 0;
        }

    }, 7000);

    $('#backIndex').click(function (){
        window.location.href = "http://localhost:8080/mobile/html/index.html";
    });

    $('#tabtab').click(function () {
        $.cookie('tabkey', '황용식');

        $("#tabtab").attr("href", "http://localhost:8080/mobile/html/tab_01.html");
    })

    $('#backA').click(function () {
        window.location.href = 'http://localhost:8080/mobile/html/lockscreen_01.html';
    })

    $('#adA').click(function () {
        var aStr = $("#adImg").attr("src");

        console.log(aStr);
        if(aStr.indexOf('widget_AD_01') != -1){
            $.cookie('adImage', 'ad_01');
        }
        else{
            $.cookie('adImage', 'ad_04');
        }
    })
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

function gogo(){
    console.log('클릭요');
    $.ajax({
        type : "GET",
        url : "http://localhost:8080/mobile/html/tab_02.html",
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