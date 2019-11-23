$(document).ready(function () {
    var viewPortScale = 1 / window.devicePixelRatio;

    $('#viewport').attr('content', 'user-scalable=no, initial-scale='+viewPortScale+', width=device-width');

    if($.cookie('ad1') == undefined){
        var ad1Data = {type : null, num: 3000};

        $.cookie('ad1', JSON.stringify(ad1Data));
    }

    $('#btA1').click(function() {
        console.log('btA1 click');
    });

    $('#btA2').click(function() {
        console.log('btA2 click');
    });

    $('#btB1').click(function() {
        console.log('btB1 click');
    });

    $('#btB2').click(function() {
        console.log('btB2 click');
    });
});