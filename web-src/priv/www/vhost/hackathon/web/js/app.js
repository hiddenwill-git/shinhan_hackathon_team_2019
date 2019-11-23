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
        // '성별:남자','성별:여자','연령대:10대','연령대:20대','연령대:30대','연령대:40대',
        //     '직업:관리자','직업:전문가','직업:사무직','직업:서비스종사자','직업:자영업','직업:농/어업_종사자','직업:공무원','직업:주부','직업:무직','직업:군인',
        //     '결혼유무:기혼','결혼유무:미혼','자녀수:없음','자녀수:1명','자녀수:2명','자녀수:3명','자녀수:4명이상'
        target_groups:[
            {label:'전체 조회 조건 그룹',tags:['성별:여성','성별:남성']},
            {label:'현대 자동차 하반기 판매 캠페인',tags:['연령대:20대','연령대:30대']},
            {label:'신혼부부 대상 마케팅',tags:['결혼유무:기혼','연령대:20대','연령대:30대','자녀수:없음','자녀수:1명','자녀수:2명']},
            {label:'자영업 대상 마케팅',tags:['직업:서비스종사자','직업:자영업','직업:농/어업_종사자']}
        ],
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
    // group tag
    $scope.load_target_tags = function(e) {
        // console.log(e.tags);
        $scope.$broadcast('tagsinput:add',e.tags, $scope.tagsProperties.tagsinputId);
    }
    // tag
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
        // return; // end
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
        // 팝업에서 사용하자!
        $scope.last_meta_query = meta1;
    };
    

    $scope.onTagsAdded = function(data) {
        // console.log('onTagsAdded',data);
    };

    $scope.onTagsRemoved = function(data) {
        // console.log('onTagsRemoved',data);
    };


    $scope.tagsProperties = {
        tagsinputId: '$$$',
        initTags: ['성별:여성','성별:남성'],
        // initTags: ['성별:남자','성별:여자','직업:군인','직업:단순노무_종사자','직업:기능_종사자'],
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
            }
        }
    }
    function toggle_init() {
        // btn btn-default btn-sm
        $scope.toggle = {
            items: [{ seg:1,selected_index: -1, label: '가계소비지출비율', style: 'btn btn-default btn-sm' },
            { seg:2,selected_index: -1, label: '자산비중', style: 'btn btn-default btn-sm' },
            { seg:3,selected_index: -1, label: "캠핑관심도", style: 'btn btn-default btn-sm' },
            { seg:4,selected_index: -1, label: '가족규모', style: 'btn btn-default btn-sm' },
            { seg:5,selected_index: -1, label: '유류비 소비 비중', style: 'btn btn-default btn-sm' },
            { seg:6,selected_index: -1, label: '차량관심도', style: 'btn btn-default btn-sm' }],
            style: "btn btn-default btn-sm",
            x_seg:null,
            y_seg:null
        };
        // 2개가 선택된경우 다른 항목을 해제할때까지 상태 유지
        $scope.toggle.click = function (item) {
            var is_selected = item.style == 'btn btn-default btn-sm';
            var selected = $scope.toggle.items.filter(function (row) {
                return row.selected_index != -1
            });
            if (selected.length < 2 && is_selected) {
                item.style = 'btn btn-warning btn-sm';
                if ($scope.toggle.x_text == null) {
                    $scope.toggle.x_text = item.label;
                    $scope.toggle.x_seg = item.seg;
                } else {
                    $scope.toggle.y_text = item.label;
                    $scope.toggle.y_seg = item.seg;
                }
                item.selected_index =0;
            } else {
                item.style = 'btn btn-default btn-sm';
                if (is_selected) return;
                if (item.label == $scope.toggle.x_text) {
                    $scope.toggle.x_text = null;
                    $scope.toggle.x_seg = null;
                } else {
                    $scope.toggle.y_text = null;
                    $scope.toggle.y_seg = null;
                }
                grid_init();
                promotion_init();
                item.selected_index = -1;
            }
            if ($scope.toggle.x_text != null && $scope.toggle.y_text != null) {
            
                $scope.last_meta_query['seg'] = $scope.toggle.x_seg +","+$scope.toggle.y_seg;
                _api('query')
                // $scope.last_meta_query
                .get('promotion',$scope.last_meta_query)
                    .then(function (res) {
                        if (res[0].result_msg == 'STATUS_NORMAL') {
                            var data = res[0].result_data;
                            var total = 0;
                            for (var p in data) total += data[p];

                            for (var p in data) {
                                console.log(data[p],' total : ',total,' rate :',data[p]/total);
                            }
                            
                            $scope.toggle.grids.forEach(function(n){
                                n.num = data[n.id];
                                n.class += ' on80';
                            })
                        }
                })
            }
        }
    }

    
    function grid_init() {
        $scope.toggle.grids = [];
        console.log('grid_init');
        for (var i=0;i<10;i++) {
            $scope.toggle.grids.push({id:i,class:'num'+i,num:0})
        }
    }

    $scope.modal_init = function(modal) {
        console.log('modal_init');
        toggle_init();
        promotion_init();
        grid_init();
    }
    
    function calc(is_selected,reference,sum,grids,index) {
        if (is_selected) {
            sum.f1 += grids[index].num;
        } else {
            sum.f1 -= grids[index].num;
        }
        // 집행 예상비용
        sum.f3 = sum.f1 * reference.price;
        // 인당평균 광고집행 비용
        sum.f2 = sum.f3 / sum.f1;
        // 인원수
        $scope.promotion.summmary.total.f1 =
            $scope.promotion.summmary.group1.f1 + 
            $scope.promotion.summmary.group2.f1 +
            $scope.promotion.summmary.group3.f1;
        
        $scope.promotion.summmary.total.f3 =
            $scope.promotion.summmary.group1.f3 + 
            $scope.promotion.summmary.group2.f3 +
            $scope.promotion.summmary.group3.f3;

        // 인당평균 광고집행 비용
        $scope.promotion.summmary.total.f2 =
            $scope.promotion.summmary.total.f3 /
            $scope.promotion.summmary.total.f1;
    }

    // 프로모션 계산기 숫자 클릭 이벤트
    $scope.promotion = {
        groups:{group1:[],group2:[],group3:[]},
        click:function(e,name) {
            if ($scope.toggle.x_text == null || $scope.toggle.y_text == null) return;
            var grids = $scope.toggle.grids;
            var sum = $scope.promotion.summmary[name];
            var is_selected = e.style == null; 
            e.style = e.style == null ? 'on' : null;
            console.log(e,name);
            // console.log($scope.toggle.grids[7].num);
            if (e.id == 0) {
                calc(is_selected,e,sum,$scope.toggle.grids,7);
            } else if (e.id == 1) {
                calc(is_selected,e,sum,grids,8);
            } else if (e.id == 2) {
                calc(is_selected,e,sum,grids,9);
            } else if (e.id == 3) {
                calc(is_selected,e,sum,grids,4);
            } else if (e.id == 4) {
                calc(is_selected,e,sum,grids,5);
            } else if (e.id == 5) {
                calc(is_selected,e,sum,grids,6);
            } else if (e.id == 6) {
                calc(is_selected,e,sum,grids,1);
            } else if (e.id == 7) {
                calc(is_selected,e,sum,grids,2);
            } else if (e.id == 8) {
                calc(is_selected,e,sum,grids,3);
            } 
        }
    }
    
    function promotion_init() {
        console.log('promotion_init');
        // 집행인원 | 인당평균 광고집행 비용 | 집혱 예상 비용 | 예상 반응율
        $scope.promotion.summmary = {
            group1:{f1:0, f2:0, f3:0, f4:'30'},
            group2:{f1:0, f2:0, f3:0, f4:'30'},
            group3:{f1:0, f2:0, f3:0, f4:'30'},
            total :{f1:0, f2:0, f3:0, f4:'30'},
            title :{prom1:'전업주부 대상으로 한 소형 SUV(베뉴) ',prom2:'액티비티를 즐기는 고객을 대상 캠핑카',prom3:'전기차'}
        };
        $scope.promotion.groups.group1 = [];
        $scope.promotion.groups.group2 = [];
        $scope.promotion.groups.group3 = [];
        for (var p in $scope.promotion.groups) {
            for (var i=0;i<9;i++) {
                $scope.promotion.groups[p].push({id:i,label:'인당 단가 6,000원',price:6000,style:null})
            }
            // $scope.promotion.groups[p].reverse();
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
    //   $scope.chart_tab1_1 = activity_simple_line_chart(data1);

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
                    // label: {
                    //     normal: {
                    //         formatter: '{a|{a}}{abg|}\n{hr|}\n  {b|{b}：}{c}  {per|{d}%}  ',
                    //         // formatter: '{a|{a}}{abg|}\n{hr|}\n  {b|{b}}  {per|{d}%}  ',
                    //         backgroundColor: '#eee',
                    //         borderColor: '#aaa',
                    //         borderWidth: 1,
                    //         borderRadius: 4,
                    //         rich: {
                    //             a: {
                    //                 color: '#999',
                    //                 lineHeight: 22,
                    //                 align: 'center'
                    //             },
                    //             hr: {
                    //                 borderColor: '#aaa',
                    //                 width: '100%',
                    //                 borderWidth: 0.5,
                    //                 height: 0
                    //             },
                    //             b: {
                    //                 fontSize: 12,
                    //                 lineHeight: 33
                    //             },
                    //             per: {
                    //                 color: '#eee',
                    //                 backgroundColor: '#334455',
                    //                 padding: [2, 4],
                    //                 borderRadius: 2
                    //             }
                    //         }
                    //     }
                    // },
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

    pro();
    function pro() {
        _api('query')
           .get('promotion_user_status','')
        .then(function (res) {
            if (res[0].result_msg == 'STATUS_NORMAL') {
                var data = res[0].result_data;
                // var page1 = data.page1[0];
                // var chart = [[],[]];
                // page1.forEach(function(n){
                //     chart[0].push(n.timeslot);
                //     chart[1].push(n.freq);
                // });
                $scope.chart_tab1_1 = promotion_chart(data.page1[0]);
                $scope.chart_tab1_2 = promotion_chart(data.page1[1]);
                $scope.chart_tab1_3 = promotion_chart(data.page1[2]);
                $scope.chart_tab1_4 = promotion_chart(data.page1[0]);

                $scope.chart_tab2_1 = promotion_chart(data.page2[0]);
                $scope.chart_tab2_2 = promotion_chart(data.page2[1]);
                $scope.chart_tab2_3 = promotion_chart(data.page2[2]);
                $scope.chart_tab2_4 = promotion_chart(data.page2[0]);

                $scope.chart_tab3_1 = promotion_chart(data.page3[0]);
                $scope.chart_tab3_2 = promotion_chart(data.page3[1]);
                $scope.chart_tab3_3 = promotion_chart(data.page3[2]);
                $scope.chart_tab3_4 = promotion_chart(data.page3[0]);
            }
        })
    }

    
    function promotion_chart(rows) {
        var cat = [];
        var data = [];
        rows.forEach(function(n){
            cat.push(n.timeslot);
            data.push(n.freq);
        });
        return {
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
                    data: cat
                }
            ],
            series: [{
                name: '인원수',
                type: 'bar',
                data:data
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
            xAxis: [
                {
                    type: 'value',
                    boundaryGap: [0, 0.01]
                }
            ],
            yAxis: [
                {
                    type: 'category',
                    data: ['강남구', '강동구', '강북구', '강서구', '관악구', '광진구', '구로구']
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

app.filter('num_comma', function () {
    return function(num) {
        if (num) {
          return num.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
        } else {
          return num;
        }
    };
  });