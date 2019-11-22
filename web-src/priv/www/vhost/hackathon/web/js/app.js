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

// c("관리자",
// "전문가",
// "사무_종사자",
// "서비스_종사자",
// "판매_종사자",
// "농림_어업_종사자",
// "기능_종사자",
// "장치_및_기계조작_종사자",
// "단순노무_종사자",
// "군인")

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
        
        RestangularProvider.addResponseInterceptor(function(data, operation, what, url, response, deferred) {
            return angular.isArray(data) ? data : [data];
        });
    }
])
app.factory('API', function(Restangular){
    return Restangular.withConfig(function(config){
      config.setBaseUrl('/api/v1');
    });
});

app.factory("_api", function(API,$timeout,$window) {
	return function(prefix){
		return {
			get: function(arg1,arg2) {
				return API.all(prefix).customGET(arg1,arg2);
			},
			post: function(arg1) {
				return API.all(prefix).post(arg1);
			},
			remove: function(arg1) {
				return API.all(prefix).customDELETE('',arg1);
			}
		}
	}
})

app.controller("appController", function ($scope,$modal,$window,$timeout,_api) {
    console.log('start app!');
    $scope.model = {
        baskets:[],
        tags:''
    };

    _api('baskets')
      .get()
      .then(function(res) {
        if (res[0].result_msg == 'STATUS_NORMAL') {
            $scope.model.baskets = res[0].result_data;
        }
    })
    
    $scope.read_basket = function(basket) {
        var t = [];
        for(var p in basket) {
            
            if (p != 'target_group_name' && p != 'target_id') {
                t.push(p + ':' + basket[p]);
                // console.log(t);
            }
        }
        $scope.model.tags = null;
        $scope.model.tags = "a,b,c";
        console.log($scope.model.tags);
        $timeout(function() {
            $window.dispatchEvent(new Event("resize"));
            console.log('apply');
            $scope.model.tags = "a,b,c";
            $scope.$apply(function(){
                $scope.model.tags = "a,b,c";
            });
                
            
        }, 100);
    }
    $scope.model.tags = "120~30대,여자,남자,대한민국 거주,미혼,자녀 무,주택 무,자동차 유,보우자산 1억 ~ 2억,신용카드 월 사용액 200만원,최근카드 소비성향 키워드 : 결혼준비";
    
    
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
            tooltip: {
                trigger: 'item',
                formatter: "{a} <br/>{b}: {c} ({d}%)"
            },
            legend: {
                orient: 'vertical',
                x: 'left',
                data:['直达','营销广告','搜索引擎','邮件营销','联盟广告','视频广告','百度','谷歌','必应','其他']
            },
            series: [
                {
                    name:'성별',
                    type:'pie',
                    selectedMode: 'single',
                    radius: [0, '30%'],
        
                    label: {
                        normal: {
                            position: 'inner'
                        }
                    },
                    labelLine: {
                        normal: {
                            show: false
                        }
                    },
                    data:[
                        {value:1, name:'남'},
                        {value:1, name:'여'}
                    ]
                },
                {
                    name:'연령',
                    type:'pie',
                    radius: ['40%', '55%'],
                    label: {
                        normal: {
                            formatter: '{a|{a}}{abg|}\n{hr|}\n  {b|{b}：}{c}  {per|{d}%}  ',
                            backgroundColor: '#eee',
                            borderColor: '#aaa',
                            borderWidth: 1,
                            borderRadius: 4,
                            rich: {
                                a: {
                                    color: '#999',
                                    lineHeight: 22,
                                    align: 'center'
                                },
                                hr: {
                                    borderColor: '#aaa',
                                    width: '100%',
                                    borderWidth: 0.5,
                                    height: 0
                                },
                                b: {
                                    fontSize: 12,
                                    lineHeight: 33
                                },
                                per: {
                                    color: '#eee',
                                    backgroundColor: '#334455',
                                    padding: [2, 4],
                                    borderRadius: 2
                                }
                            }
                        }
                    },
                    data:[
                        {value:1, name:'10대'},
                        {value:2, name:'20대'},
                        {value:1, name:'30대'},
                        {value:2, name:'40대'},
                        {value:1, name:'10대'},
                        {value:2, name:'20대'},
                        {value:1, name:'30대'},
                        {value:2, name:'40대'}
                    ]
                }
            ]
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



app.filter('isEmpty', function () {
    return function (val) {
      return (val == undefined || val.length === 0 || !val.trim());
    };
});


app.filter('tag_meta_to_value', function () {
    return function(tag) {
        return tag == 'job' ?'직업' :
            tag == 'age' ? '나이대' :
            tag == 'child' ? '자녀수' :
            tag;
    }
});