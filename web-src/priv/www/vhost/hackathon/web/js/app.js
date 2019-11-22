var app = angular.module('app', ['restangular', 'ngRoute','ui.bootstrap','angular-echarts3']);

// app.run([
//     '$rootScope', '$modalStack',
//     function ($rootScope, $modalStack) {
//         $rootScope.$on('$locationChangeStart', function (event) {
//             var top = $modalStack.getTop();
//             if (top) {
//                 $modalStack.dismiss(top.key);
//                 event.preventDefault();
//             }
//         });
//     }
// ])

app.config(['$routeProvider', 'RestangularProvider', '$locationProvider',
    function ($routeProvider, RestangularProvider, $locationProvider) {
        RestangularProvider.setDefaultHeaders({
            'Accept': 'application/json',
            'Content-Type': 'application/json',
            'X-Requested-With': 'XMLHttpRequest',
            'Access-Control-Allow-Credentials': 'true',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
            'Access-Control-Allow-Headers': '*'
        });
        RestangularProvider.setDefaultHttpFields({
            'withCredentials': true,
            'HTTP/1.1 200 OK': true
        });

        RestangularProvider.setErrorInterceptor(
            function (response) {
                if (response.status == 401) {
                } else if (response.status == 405) {
                } else {
                }
                return false;
            });
    }
])


app.controller("appController", function ($scope,$modal) {
    console.log('start app!');
    // btn btn-default btn-sm
    $scope.toggle = {
        items:[{selected_index:-1,label:'보유자산',style:'btn btn-default btn-sm'},
                {selected_index:-1,label:'6개월내 결혼 가능성',style:'btn btn-default btn-sm'},
                {selected_index:-1,label:"탈퇴 위험율",style:'btn btn-default btn-sm'},
                {selected_index:-1,label:'자동차 보유 유뮤',style:'btn btn-default btn-sm'}],
        style:"btn btn-default btn-sm"};
    // 2개가 선택된경우 다른 항목을 해제할때까지 상태 유지
    $scope.toggle.click = function(item) {
        var is_selected = item.style == 'btn btn-default btn-sm';
        var selected = $scope.toggle.items.filter(function (row) {
            return row.selected_index != -1
        });
        if (selected.length < 2 && is_selected) {
            item.style ='btn btn-warning btn-sm';
            item.selected_index = 1;
        } else {
            item.style ='btn btn-default btn-sm';
            item.selected_index = -1;
        }
            
    }
   
    $scope.open = function(size) {
	    var modalInstance = $modal.open({
	          templateUrl: 'tmpl/popup1.html',
	          controller: 'PopupController',
	          size: 'md',
	          resolve: {
	            items: function () {
	              return null;
	            }
	          }
	        });
      };

      var data = [{domain:'man',name:'남',value:Math.floor(Math.random() * 5555)},
                    {domain:'woman',name:'여',value:Math.floor(Math.random() * 5555)}]
      $scope.chart1 = activity_simple_chart(data);
      var data1 = [];
      for (var i=0;i<24;i++) {
        data1.push(Math.floor(Math.random() * 99999))
      }
      $scope.chart2 = activity_simple_line_chart(data1);

      function activity_simple_chart(data1) {
        return {
            title: {
                show: false,
                text: '남성/여성 통계',
                subtext: '남여 통계',
                x: 'center'
            },

            tooltip: {
                trigger: 'item',
                formatter: "{b} {d}%"
            },
            legend: {
                show: false, orient: 'vertical',
                left: 'left', data: ['man','woman']
            },
            series: [{
                name: '성별?',
                type: 'pie',
                radius: '55%',
                center: ['50%', '60%'],
                data: data1
            }]
        }
    }


    // 지역분포
    function activity_simple_line_chart(data1) {
        return {
            title: {
                show: false,
                text: '지역통계 통계',
                subtext: '지역 통계',
                x: 'center'
            },
            tooltip: {
                trigger: 'axis',
                axisPointer: {
                    type: 'shadow'
                }
            },
            xAxis : [
                {
                    type : 'value',
                    boundaryGap: [0, 0.01]
                }
            ],
            yAxis : [
                {
                    type : 'category',
                    data: ['강남구','강동구','강북구','강서구','관악구','광진구','구로구','금천구','노원구','도봉구','동대문구','동작구','마포구','서대문구','서초구','성동구','성북구','송파구','양천구','영등포구','용산구','은평구','종로구','중구','중랑구']
                }
            ],
            series: [{
                name: '인원수',
                type:'bar',
                data: data1
            }]
        }
    }
});


app.controller('PopupController', function($scope,$modal,$timeout,$modalInstance,items) {
    $scope.cancel = function() {
        $modalInstance.dismiss('cancel');
    }

    $scope.next = function() {

    }
})