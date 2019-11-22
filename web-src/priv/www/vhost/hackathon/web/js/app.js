var app = angular.module('app', ['restangular', 'ngRoute','ui.bootstrap']);

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
});


app.controller('PopupController', function($scope,$modal,$timeout,$modalInstance,items) {
    $scope.cancel = function() {
        $modalInstance.dismiss('cancel');
    }

    $scope.next = function() {

    }
})