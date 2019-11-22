# AngularJS ECharts3


### Installation

```
$ bower install angular-echarts3 --save
```

```
<script src="../bower_components/echarts/dist/echarts.min.js"></script>
<script src="../bower_components/angular-echarts3/dist/angular-echarts3.js"></script>
```

```
angular.module('Your App',["angular-echarts3"]);
```

```
<mw-charts style="width: 650px;height:400px;" ng-model="option">
        </mw-charts>
```

``` 
option = {
             title: {
                 text: '测试'
             },
             tooltip: {},
             legend: {
                 data: ['销量']
             },
             xAxis: {
                 data: ["衬衫", "羊毛衫", "雪纺衫", "裤子", "高跟鞋", "袜子"]
             },
             yAxis: {},
             series: [{
                 name: '销量2',
                 type: 'bar',
                 data: [5, 20, 36, 10, 10, 20]
             }]
         }
```



### Echarts3

[Echarts3](http://echarts.baidu.com/)

### License

The MIT License (MIT)

Copyright (C) 2016

　　Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
      
　　The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
      
　　THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
