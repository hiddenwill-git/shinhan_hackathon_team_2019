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
    $scope.firstName = "Thomas";
    $scope.lastName = "Ochman";

   
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