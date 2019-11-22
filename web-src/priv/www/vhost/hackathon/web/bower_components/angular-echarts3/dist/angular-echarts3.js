(function() {
    'use strict';

    angular.module('angular-echarts3', []).directive('mwChart', mwChart);

    function mwChart($window) {
        var directive = {
            restrict: 'AE',
            require: 'ngModel',
            template: '<div></div>',
            replace: true,
            scope: {
                chartClick: '=?', // chart-click
            },

            link: mwChartLink
        }

        return directive;

        function mwChartLink(scope, el, attr, ngModel) {
            var ndWrapper = el[0];
            var echart = echarts.init(ndWrapper);
            if (scope.chartClick) {
                echart.on('click', scope.chartClick);
                // });
                // console.log(scope.chartClick);
            }


            angular.element($window).bind('resize', function() {
                // TODO
                // $timeout module error
               // $timeout(function() {

                 if (echart) {
                   echart.resize();
                 }
               // }, 300);
             });

            scope.$watch(function() {
                return $window.innerWidth;
            }, function(value) {
                // console.log(' innerWidth watch', $window.innerWidth);
                echart.resize();
            });
            scope.$watch(function() {
                return $window.innerHeight;
            }, function(value) {
                // console.log(' innerHeight watch', $window.innerWidth);
                echart.resize();
            });

            ngModel.$formatters.unshift(function(option) {
                if (option) {
                    echart.clear();
                    echart.setOption(option);
                    echart.resize();
                }
            });

        }
    }
})();
