$(document).ready(function () {
    var viewPortScale = 1 / window.devicePixelRatio;

    $('#viewport').attr('content', 'user-scalable=no, initial-scale='+viewPortScale+', width=device-width');

    var cookieData = $.cookie('adImage');

    if(cookieData == 'ad_04'){
        $("#dfImage").attr("src", "../img/ad_04.png");
    }

    $('#backb').click(function() {
        setScore('back', 20);
    });

    $('#pinBtn').click(function() {
        setScore('pin',50);
    });

    $('#reserveBtn').click(function() {
        setScore('reserve',100);
    });
});

function setScore(type, number){
    var ad1 = JSON.parse($.cookie('ad1'));
    var jsonData = {type : type, num : Number((ad1.num) + number)};
    $.cookie('ad1',JSON.stringify(jsonData));

    var href = $('#backb').attr('href');
    window.location.href = href;
}