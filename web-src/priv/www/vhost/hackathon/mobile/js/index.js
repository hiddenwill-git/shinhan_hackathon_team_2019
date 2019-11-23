$(document).ready(function () {
    var viewPortScale = 1 / window.devicePixelRatio;

    $('#viewport').attr('content', 'user-scalable=no, initial-scale='+viewPortScale+', width=device-width');

    // setDefault();   // 최초 선택별 점수 초기화

    var adCookie = {type : null, num : 3000};

    if($.cookie('ad1') == undefined){
        $.cookie('ad1', JSON.stringify(adCookie));
    }

    if($.cookie('ad2') == undefined){
        $.cookie('ad2', JSON.stringify(adCookie));
    }

    if($.cookie('ad3') == undefined){
        $.cookie('ad3', JSON.stringify(adCookie));
    }

    $('#btA1').click(function() {
        window.open("http://localhost:8080/mobile/html/lockscreen_01.html", "box_new", "width=410,height=780,scrollbars=no,resizable=yes");
    });

    $('#btA2').click(function() {
        window.open("http://localhost:8080/mobile/html/lockscreen_02.html", "box_new", "width=410,height=780,scrollbars=no,resizable=yes");
    });

    $('#btB1').click(function() {
        window.open("http://localhost:8080/mobile/html/lockscreen_03.html", "box_new", "width=410,height=780,scrollbars=no,resizable=yes");
    });
});

function setDefault(){
    var adCookie = {type : null, num : 3000};
    $.cookie('ad1', JSON.stringify(adCookie));
    $.cookie('ad2', JSON.stringify(adCookie));
    $.cookie('ad3', JSON.stringify(adCookie));
}