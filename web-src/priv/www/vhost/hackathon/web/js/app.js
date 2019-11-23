var app = angular.module('app', ['restangular', 'ngRoute', 'ui.bootstrap', 'angular-echarts3',
    'angularjs.bootstrap.tagsinput.template', 'angularjs.bootstrap.tagsinput']);

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

        RestangularProvider.addResponseInterceptor(function (data, operation, what, url, response, deferred) {
            return angular.isArray(data) ? data : [data];
        });
    }
])
app.factory('API', function (Restangular) {
    return Restangular.withConfig(function (config) {
        config.setBaseUrl('/api/v1');
    });
});

app.factory("_api", function (API, $timeout, $window) {
    return function (prefix) {
        return {
            get: function (arg1, arg2) {
                return API.all(prefix).customGET(arg1, arg2);
            },
            post: function (arg1) {
                return API.all(prefix).post(arg1);
            },
            remove: function (arg1) {
                return API.all(prefix).customDELETE('', arg1);
            }
        }
    }
})

app.controller("appController", function ($scope, $modal, $window, $timeout, _api) {
    console.log('start app!');
    // profile_sex=F,M&profile_job=10,7,6,9,4&profile_age=10,20,30,40&profile_married=true&profile_children=0,1,2,3,4
    $scope.model = {
        baskets: [],
        tags: '',
        sel1_opt:[{code:null,name:'선택'},{code:'M',name:'남성'},{code:'F',name:'여성'}],
        sel2_opt:[{code:null,name:'선택'},{code:'10',name:'10대'},
            {code:'20',name:'20대'},{code:'30',name:'30대'},{code:'40',name:'40대'},{code:'50',name:'50대'}],
        sel3_opt:[{code:null,name:'선택'},{code:'1',name:'관리자'},{code:'2',name:'전문가'},
            {code:'3',name:'사무직'},{code:'4',name:'서비스종사자'},{code:'5',name:'자영업'},{code:'6',name:'농/어업_종사자'},
            {code:'7',name:'공무원'},{code:'8',name:'주부'},{code:'9',name:'무직'},{code:'10',name:'군인'}],
        sel4_opt:[{code:null,name:'선택'},{code:true,name:'기혼'},{code:false,name:'미혼'}],
        sel5_opt:[{code:null,name:'선택'},{code:0,name:'없음'},{code:1,name:'1명'},{code:2,name:'2명'},{code:3,name:'3명'},{code:4,name:'4명 이상'}]
    };
    $scope.sel1_selected = $scope.model.sel1_opt[0];
    $scope.sel2_selected = $scope.model.sel2_opt[0];
    $scope.sel3_selected = $scope.model.sel3_opt[0];
    $scope.sel4_selected = $scope.model.sel4_opt[0];
    $scope.sel5_selected = $scope.model.sel5_opt[0];

    $scope.onChange = function(e,id) {
        // console.log(e,id);
        if (e.code == null) return;
        var prefix = id == 'sel1' ? '성별' : 
                id == 'sel2' ? '연령대' :
                id == 'sel3' ? '직업' :
                id == 'sel4' ? '결혼유무' :
                id == 'sel5' ? '자녀수' : '';
            $scope.$broadcast('tagsinput:add', prefix+':'+e.name, $scope.tagsProperties.tagsinputId);
    }

    function load_chart_by_tags(param) {
        _api('query')
            // profile_sex=F,M&profile_job=10,7,6,9,4&profile_age=10,20,30,40&profile_married=true&profile_children=0,1,2,3,4
            // .get('target', { profile_sex: 'F,M', profile_job: '10,7,6,9,4', profile_age: '10,20,30,40', profile_married: true, profile_children: '0,1,2,3,4' })
              .get('target',param)
            .then(function (res) {
                if (res[0].result_msg == 'STATUS_NORMAL') {
                    var data = res[0].result_data;
                    $scope.chart1 = activity_simple_chart('자산', split('finance1_assets_amount', data, []));
                    $scope.chart2 = activity_simple_chart('소비항목', split('finance2_main_expense', data, []));
                    $scope.chart3 = activity_simple_chart('직업 ', split('profile_job', data, [], []));
                    $scope.chart4 = activity_simple_chart('가족수', split('profile_family_cnt', data, []));
                }
            })
    }
    // load_chart_by_tags(null);

    function split(field, data, acc) {
        var sum = [{ value: 0, name: '남성' }, { value: 0, name: '여성' }];

        for (var p in data[field]) { // M, F
            for (var p1 in data[field][p]) {
                if (p == 'M') sum[0].value += data[field][p][p1];
                if (p == 'F') sum[1].value += data[field][p][p1];
                acc.push({ value: data[field][p][p1], name: p1 });
            }
        };
        return [sum, acc];
    }

    $scope.onTagsChange = function(data) {
        // console.log('onTagsChange',data);
        // console.log(angular.toJson(data.tags));
        // var tags = angular.toJson(data.tags);
        var meta = {profile_sex:[],profile_job:[],profile_age:[],profile_married:[],profile_children:[]};
        data.tags.forEach(function (n) {
            var t = n.split(":");
            if (t.length == 2) {
                if (t[0] == '성별') {
                    meta.profile_sex.push(t[1] == '남성' ? "M" : "F");
                } else if (t[0] == '연령대') {
                    meta.profile_age.push(t[1].replace(/[^0-9]/g,''));
                } else if (t[0] == '직업') {
                    var job = t[1] == '관리자' ? 1 :
                            t[1] == '전문가' ? 2 :
                            t[1] == '사무직' ? 3 :
                            t[1] == '서비스종사자' ? 4 :
                            t[1] == '자영업' ? 5 :
                            t[1] == '농/어업_종사자' ? 6 :
                            t[1] == '공무원' ? 7 :
                            t[1] == '주부' ? 8 :
                            t[1] == '무직' ? 9 :
                            t[1] == '군인' ? 10 : null;
                    meta.profile_job.push(job);
                } else if (t[0] == '결혼유무') {
                    meta.profile_married.push(t[1] == '기혼');
                } else if (t[0] == '자녀수') {
                    meta.profile_children.push(t[1].replace(/[^0-9]/g,''));
                } else {
                    return;
                }
            }
        });
        // console.log(meta);
        var meta1 = {profile_sex:[],profile_job:[],profile_age:[],profile_married:[],profile_children:[]};
        for (var p in meta) {
            if (meta[p].length == 0) {
                meta1[p] = null;
            } else {
                meta1[p] = meta[p].join();
            }
        };
        // console.log(meta1);
        load_chart_by_tags(meta1);
    };

    $scope.onTagsAdded = function(data) {
        console.log('onTagsAdded',data);
    };

    $scope.onTagsRemoved = function(data) {
        console.log('onTagsRemoved',data);
    };


    $scope.tagsProperties = {
        tagsinputId: '$$$',
        initTags: [],
        // initTags: ['성별:남자','성별:여자','직업:군인','직업:단순노무_종사자','직업:기능_종사자'],
        // maxTags: 10,
        // maxLength: 15,
        placeholder: '원하는 검색 조건 테그를 입력하세요.'
    };

    _api('baskets')
        .get()
        .then(function (res) {
            if (res[0].result_msg == 'STATUS_NORMAL') {
                $scope.model.baskets = res[0].result_data;
            }
        })

    $scope.$watch('model.tags', function (newValue, oldValue) {
        console.log(newValue, oldValue);
    })


    $scope.read_basket = function (basket) {
        var t = [];
        for (var p in basket) {

            if (p != 'target_group_name' && p != 'target_id') {
                t.push(p + ':' + basket[p]);
                // console.log(t);
            }
        }
    }

    // btn btn-default btn-sm
    $scope.toggle = {
        items: [{ selected_index: -1, label: '보유자산', style: 'btn btn-default btn-sm' },
        { selected_index: -1, label: '6개월내 결혼 가능성', style: 'btn btn-default btn-sm' },
        { selected_index: -1, label: "탈퇴 위험율", style: 'btn btn-default btn-sm' },
        { selected_index: -1, label: '자동차 보유 유뮤', style: 'btn btn-default btn-sm' }],
        style: "btn btn-default btn-sm"
    };
    // 2개가 선택된경우 다른 항목을 해제할때까지 상태 유지
    $scope.toggle.click = function (item) {
        var is_selected = item.style == 'btn btn-default btn-sm';
        var selected = $scope.toggle.items.filter(function (row) {
            return row.selected_index != -1
        });
        if (selected.length < 2 && is_selected) {
            item.style = 'btn btn-warning btn-sm';
            item.selected_index = 1;
        } else {
            item.style = 'btn btn-default btn-sm';
            item.selected_index = -1;
        }

    }

    $scope.open = function (size) {
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

    var data = [{ domain: 'man', name: '남', value: Math.floor(Math.random() * 5555) },
    { domain: 'woman', name: '여', value: Math.floor(Math.random() * 5555) }]
    //   $scope.chart1 = activity_simple_chart(data);
    var data1 = [];
    for (var i = 0; i < 24; i++) {
        data1.push(Math.floor(Math.random() * 99999))
    }
    //   $scope.chart2 = activity_simple_line_chart(data1);

    function activity_simple_chart(title, data1) {
        var peoples = data1[0];
        var data2 = data1[1];
        return {
            tooltip: {
                trigger: 'item',
                formatter: "{a} <br/>{b}: {c} ({d}%)"
            },
            series: [
                {
                    name: '성별',
                    type: 'pie',
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
                    data: peoples,
                    // [
                    //     {value:1, name:'여'},
                    //     {value:1, name:'남'}
                    // ]
                },
                {
                    name: title,
                    type: 'pie',
                    radius: ['40%', '55%'],
                    label: {
                        normal: {
                            formatter: '{a|{a}}{abg|}\n{hr|}\n  {b|{b}：}{c}  {per|{d}%}  ',
                            // formatter: '{a|{a}}{abg|}\n{hr|}\n  {b|{b}}  {per|{d}%}  ',
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
                    data: data2
                    // [
                    //     {value:1, name:'10대'},
                    //     {value:2, name:'20대'},
                    //     {value:1, name:'30대'},
                    //     {value:2, name:'40대'},

                    //     {value:1, name:'10대'},
                    //     {value:2, name:'20대'},
                    //     {value:1, name:'30대'},
                    //     {value:2, name:'40대'}
                    // ]
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
            xAxis: [
                {
                    type: 'value',
                    boundaryGap: [0, 0.01]
                }
            ],
            yAxis: [
                {
                    type: 'category',
                    data: ['강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구', '금천구', '노원구', '도봉구', '동대문구', '동작구', '마포구', '서대문구', '서초구', '성동구', '성북구', '송파구', '양천구', '영등포구', '용산구', '은평구', '종로구', '중구', '중랑구']
                }
            ],
            series: [{
                name: '인원수',
                type: 'bar',
                data: data1
            }]
        }
    }
});


app.controller('PopupController', function ($scope, $modal, $timeout, $modalInstance, items) {
    $scope.cancel = function () {
        $modalInstance.dismiss('cancel');
    }

    $scope.next = function () {

    }
})



app.filter('isEmpty', function () {
    return function (val) {
        return (val == undefined || val.length === 0 || !val.trim());
    };
});


app.filter('tag_meta_to_value', function () {
    return function (tag) {
        return tag == 'job' ? '직업' :
            tag == 'age' ? '나이대' :
                tag == 'child' ? '자녀수' :
                    tag;
    }
});