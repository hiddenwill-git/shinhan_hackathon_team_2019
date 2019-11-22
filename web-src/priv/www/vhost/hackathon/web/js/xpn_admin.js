// create the module and name it scotchApp
var xpnApp = angular.module('xpnApp', ['restangular','ngRoute']);

// create the controller and inject Angular's $scope
xpnApp.controller('mainController', function($scope) {
    $scope.message = 'Everyone come and see how good I look!';
});

xpnApp.controller('info', function($scope) {
    $scope.info = {
		'user_id':'test_id',
		'user_name':'test_name',
		'license':'test_license',
		'expire':'20151212',
		'message':'test messgae'
	};
});

xpnApp.controller('nodes', function($scope, Restangular) {
	$scope.nodes = Restangular.all('nodes').getList().$object;//.then( function(items) {
    //console.log(items);
  //});
  //Restangular.all("users").getList().$object;
  //console.log(JSON.stringify($scope.nodes));
});

xpnApp.config(['$routeProvider', 'RestangularProvider',
  function($routeProvider,RestangularProvider) {
  	RestangularProvider.setBaseUrl('/api');
  	RestangularProvider.setDefaultHeaders({
        'Accept': 'application/json',
  	    'Content-Type': 'application/json',
  	    'X-Requested-With': 'XMLHttpRequest',
  	    'Access-Control-Allow-Credentials': 'true',
  	    'Access-Control-Allow-Origin':'*',
  	    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE',
  	    'Access-Control-Allow-Headers': 'Accept, X-Requested-With'

  	});
  	RestangularProvider.setDefaultHttpFields({
  	    'withCredentials': true,
  	    'HTTP/1.1 200 OK': true
  	});

  function genProgressbar(percent) {
    if (percent > 60 && percent < 80) {
      return 'progress-bar-warning';
    } else if (percent > 80) {
      return 'progress-bar-danger';
    } else {
      return 'progress-bar-success';
    }
  }

  function genPercent(count,total) {
    return Math.round(100*count/total);
  }

  function genDiskSize(size) {
    var i = Math.floor( Math.log(size) / Math.log(1024) );
    return ( size / Math.pow(1024, i) ).toFixed(2) * 1 + ' ' + ['B', 'kB', 'MB', 'GB', 'TB'][i];
  };

  function fmt_uptime(u) {
      var uptime = Math.floor(u / 1000);
      var sec = uptime % 60;
      var min = Math.floor(uptime / 60) % 60;
      var hour = Math.floor(uptime / 3600) % 24;
      var day = Math.floor(uptime / 86400);

      if (day > 0)
          return day + 'd ' + hour + 'h';
      else if (hour > 0)
          return hour + 'h ' + min + 'm';
      else
          return min + 'm ' + sec + 's';
  }

  RestangularProvider.addResponseInterceptor(function(data, operation, what, url, response, deferred) {
      //var res = data[0];
      //var newResponse = {};
      var result = [];
      if (url == "/api/nodes") {
        data.forEach(function(item){
            var data = {};
            ["name","fd_used","fd_total","sockets_used","sockets_total","proc_used","proc_total",
              "mem_used","mem_limit","mem_alarm","disk_free","disk_free_limit","uptime","running","run_queue",
              'fd_percent','fd_type','sockets_percent','sockets_type','proc_percent','proc_type',
              'mem_percent','mem_type','disk_percent','disk_type']
              .forEach(function(key){
                if (item.hasOwnProperty(key)) {
                  if (key == 'uptime') {
                    data[key] = fmt_uptime(item[key]);
                  } else {
                    data[key] = item[key];
                  }
                } else {
                  //newResponse[key] = {};
                }
              });

              data["fd_percent"] = genPercent(item["fd_used"],item["fd_total"]);
              data["fd_type"] = genProgressbar(data["fd_percent"]);

              data["sockets_percent"] = genPercent(item["sockets_used"],item["sockets_total"]);
              data["sockets_type"] = genProgressbar(data["sockets_percent"]);

              data["proc_percent"] = genPercent(item["proc_used"],item["proc_total"]);
              data["proc_type"] = genProgressbar(data["sockets_percent"]);

              data["mem_percent"] = genPercent(item["mem_used"],item["mem_limit"]);
              data["mem_used"] = genDiskSize(item["mem_used"]);
              data["mem_limit"] = genDiskSize(item["mem_limit"]);
              data["mem_type"] = genProgressbar(data["mem_percent"]);

              data["disk_percent"] = genPercent(item["disk_free_limit"],item["disk_free"]);
              data["disk_type"] = genProgressbar(data["disk_percent"]);
              data["disk_free"] = genDiskSize(item["disk_free"]);
              data["disk_free_limit"] = genDiskSize(item["disk_free_limit"]);
              result.push(data);
        })
        
      } else {
        newResponse = data[0];
      }
        // var newResponse = response;
        // if (angular.isArray(response)) {
        //     angular.forEach(newResponse, function(value, key) {
        //         newResponse[key].originalElement = angular.copy(value);
        //     });
        // } else {
        //     newResponse.originalElement = angular.copy(response);
        // }
        // return newResponse;
        return result;
        //return newResponse;
    });

    $routeProvider.
      when('/page1', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      when('/page2', {
        templateUrl: 'tmpl/blank2.html',
        controller: 'test'
      }).
      when('/dashboard', {
        templateUrl: 'tmpl/dashboard/main.html',
        controller: 'nodes'
      }).
      when('/publish', {
        templateUrl: 'tmpl/publish/main.html',
        controller: 'mainController'
      }).
      when('/publish-report', {
        templateUrl: 'tmpl/publish_report/main.html',
        controller: 'mainController'
      }).
      when('/connections', {
        templateUrl: 'tmpl/connections/main.html',
        controller: 'mainController'
      }).
      when('/queues', {
        templateUrl: 'tmpl/queues/main.html',
        controller: 'mainController'
      }).
      when('/statistics', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      when('/settings', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      when('/vhost', {
        templateUrl: 'tmpl/vhost/main.html',
        controller: 'mainController'
      }).
      when('/task', {
        templateUrl: 'tmpl/task/main.html',
        controller: 'mainController'
      }).
      when('/sys', {
        templateUrl: 'tmpl/sys/main.html',
        controller: 'mainController'
      }).
      when('/monitoring', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      when('/recovery', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      when('/account', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      when('/logging', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      when('/license', {
        templateUrl: 'tmpl/blank.html',
        controller: 'mainController'
      }).
      otherwise({
        redirectTo: '/login'
      });
  }]);