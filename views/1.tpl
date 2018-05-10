<!DOCTYPE html>
<html>
 <head>
  <meta charset="utf-8" />
  <script type="text/javascript" src="http://code.jquery.com/jquery-1.6.2.min.js"></script> 
  <script type="text/javascript" src="http://127.0.0.1/D3learn/jquery.tipsy.js"></script>
  <script src="http://d3js.org/d3.v3.min.js"></script>
  <link href="http://127.0.0.1/D3learn/tipsy.css" rel="stylesheet" type="text/css" />
  <style>
        .link {
          fill: none;
          stroke: #666;
          stroke-width: 1.5px;
        }

        #licensing {
          fill: green;
        }

        .link.licensing {
          stroke: green;
        }

        .link.resolved {
          stroke-dasharray: 0,2 1;
        }

        circle {
          fill: #ccc;
          stroke: #333;
          stroke-width: 1.5px;
        }

        text {
          font: 12px Microsoft YaHei;
          pointer-events: none;
          text-shadow: 0 1px 0 #fff, 1px 0 0 #fff, 0 -1px 0 #fff, -1px 0 0 #fff;
        }

        .linetext {
            font-size: 12px Microsoft YaHei;
        }
        .overlay {
          fill: none;
          pointer-events: all;
        }
        button {
          padding: 10px 20px;
        }
        #toggle-button{ display: none; }
        .button-label{
            position: relative;
            display: inline-block;
            width: 80px;
            height: 30px;
            background-color: #ccc;
            box-shadow: #ccc 0px 0px 0px 2px;
            border-radius: 30px;
            overflow: hidden;
        }
        .circles{
            position: absolute;
            top: 0;
            left: 0;
            width: 30px;
            height: 30px;
            border-radius: 50%;
            background-color: #fff;
        }
        .button-label .text {
            line-height: 30px;
            font-size: 18px;
            text-shadow: 0 0 2px #ddd;
        }

        .off { color: #fff; display: none; text-indent: 10px;}
        .on { color: #fff; display: inline-block; text-indent: 34px;}
        .button-label .circles{
            left: 0;
            transition: all 0.3s;
        }
        #toggle-button:checked + label.button-label .circles{
            left: 50px;
        }
        #toggle-button:checked + label.button-label .off{ display: inline-block; }
        #toggle-button:checked + label.button-label .on{ display: none; }
        #toggle-button:checked + label.button-label{
            background-color: #51ccee;
        }

</style>
 </head>
 <body>
  <p>hello</p>
  <div>
  <button id="zoom_in" onclick="stop()">停止浮动</button>
  <button id="zoom_out" onclick="start()">开启浮动</button>
  <button id="button" onclick="delline()">去除多余线</button>
  <button id="button" onclick="displayline()">显示线条</button>
  <div class="toggle-button-wrapper" >
    <input type="checkbox" id="toggle-button" name="switch">
    连接线
    <label for="toggle-button" class="button-label" onclick="change()">
        <span class="circles"></span>
        <span class="text off" onclick="delline()">ON</span>
        <span class="text on" onclick="displayline()">OFF</span>
    </label>
  </div>


  </div>
  <div>

  <script>

var links=[{{!NodeandLink[2]}}];
var nodeslink={{!NodeandLink[1]}};
var nodes = {};
links.forEach(function(link) {  //将link里面的source和target传入结点 nodes
  link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
  link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
});
var width = 1560;
var height = 1500;
var x=300;
var y=500;
var display=1;
var force = d3.layout.force()//layout将json格式转化为力学图可用的格式
    .nodes(d3.values(nodes))//设定节点数组
    .links(links)//设定连线数组
    .size([width, height])//作用域的大小
    .linkDistance(100)//连接线长度
    .charge(-500)//顶点的电荷数。该参数决定是排斥还是吸引，数值越小越互相排斥
    .on("tick", tick)//指时间间隔，隔一段时间刷新一次画面
    .start();//开始转换

var drag = force.drag()
            .on("dragstart",function(d,i){
              d.fixed = true;    //拖拽开始后设定被拖拽对象为固定
              console.log("拖拽状态：开始");
            })
            .on("dragend",function(d,i){
              console.log("拖拽状态：结束");
            })
            .on("drag",function(d,i){
              console.log("拖拽状态：进行中");
            });

var svg = d3.select("body").append("svg")
    .attr("preserveAspectRatio","xMinYMin meet")
    .attr("width", width)
    .attr("height", height);

//箭头
var marker=
    svg.append("marker")   //append 添加标签  attr 添加标签属性
    //.attr("id", function(d) { return d; })
        .attr("id", "resolved")
        //.attr("markerUnits","strokeWidth")//设置为strokeWidth箭头会随着线的粗细发生变化
        .attr("markerUnits","userSpaceOnUse")
        .attr("viewBox", "0 -5 10 10")//坐标系的区域  viewBox的四个参数分别代表：最小X轴数值；最小y轴数值；宽度；高度。
        .attr("refX",32)//箭头坐标
        .attr("refY", 0)
        .attr("markerWidth", 12)//标识的大小
        .attr("markerHeight", 12)
        .attr("orient", "auto")//绘制方向，可设定为：auto（自动确认方向）和 角度值
        .attr("stroke-width",2)//箭头宽度

       .append("path")
        .attr("d", "M0,-5 L10,0 L0,5 L5,0")//箭头的路径
        .attr('fill','steelblue');//箭头颜色


/* 将连接线设置为曲线
var path = svg.append("g").selectAll("path")
    .data(force.links())
    .enter().append("path")
    .attr("class", function(d) { return "link " + d.type; })
    .style("stroke",function(d){
        //console.log(d);
       return "#A254A2";//连接线的颜色
    })
    .attr("marker-end", function(d) { return "url(#" + d.type + ")"; });
*/

//设置连接线
var edges_line = svg.selectAll(".edgepath")
                    .data(force.links())
                    .enter()
                    .append("path")
                    .attr({
                          'd': function(d) {return 'M '+d.source.x+','+d.source.y+' L '+ d.target.x +','+d.target.y},
                          'class':'edgepath',
                          //'fill-opacity':0,
                          //'stroke-opacity':0,
                          //'fill':'blue',
                          //'stroke':'red',
                          'id':function(d,i) {return 'edgepath'+i;}})
                    .style("stroke",function(d){
                         var lineColor='#B43232';
                         //根据关系的不同设置线条颜色
                         // if(d.rela=="上位产品" || d.rela=="上游" || d.rela=="下位产品"){
                         //     lineColor="#A254A2";
                         // }else if(d.rela=="主营产品"){
                         //     lineColor="#B43232";
                         // }
                         return lineColor;
                     })
                    .style("pointer-events", "none")
                    .style("stroke-width",0.5)//线条粗细
                    .attr("marker-end", "url(#resolved)" );//根据箭头标记的id号标记箭头

var edges_text = svg.append("g").selectAll(".edgelabel")
                    .data(force.links())
                    .enter()
                    .append("text")
                    .style("pointer-events", "none")
                    //.attr("class","linetext")
                    .attr({ 'class':'edgelabel',
                               'id':function(d,i){return 'edgepath'+i;},
                               'dx':80,
                               'dy':0
                               //'font-size':10,
                               //'fill':'#aaa'
                               });

    //设置线条上的文字
    edges_text.append('textPath')
              .attr('xlink:href',function(d,i) {return '#edgepath'+i})
              .style("pointer-events", "none")
              .text(function(d){return d.rela;});

//圆圈
var circle = svg.append("g").selectAll("circle")
    .data(force.nodes())//表示使用force.nodes数据
    .enter().append("circle")
    .style("fill",function(node){
        var re_hex=/0x[0-9a-fA-F]+/;
        var re_fat=/\(/;
        var color='blue';//圆圈背景色
        if(node.name.match(re_hex) && !node.name.match(re_fat)){
            color="yellow";
            return color;
        }else{//根据权重颜色渐变
          var a = d3.rgb(0,255,255);  //浅蓝色
          var b = d3.rgb(0,0,255);    //蓝色
          var minvalue=1;
          var maxvalue=7;
          var color = d3.interpolate(a,b);
          var linear = d3.scale.linear()
                .domain([minvalue, maxvalue])
                .range([0, 1]);
          weight=node.weight;
          return color(linear(weight));
        }
    })
    .on("mouseover",function(node){
            d3.select(this)
              .style("fill","red");
        })
    .on("mouseout",function(node){
        d3.select(this)
            .transition()
            .duration(1500)
            .style("fill",function(node){
                var re_hex=/0x[0-9a-fA-F]+/;
                var re_fat=/\(/;
                var color='blue';//圆圈背景色
                if(node.name.match(re_hex) && !node.name.match(re_fat)){
                    color="yellow";
                    return color
                }else{
                    var a = d3.rgb(0,255,255);  //浅蓝色
                    var b = d3.rgb(0,0,255);    //蓝色
                    var minvalue=1;
                    var maxvalue=7;
                    var color = d3.interpolate(a,b);
                    var linear = d3.scale.linear()
                          .domain([minvalue, maxvalue])
                          .range([0, 1]);
                    weight=node.weight;
                    return color(linear(weight));
                }
              });
    })
    .style('stroke',"white")
    .attr("r", function(node){
      var min=1;
      var max=7;
      var linear = d3.scale.linear()
              .domain([min, max])
              .range([10, 20]);
      weight=node.weight;
      return linear(weight);
    }
    )//设置圆圈半径
    .on("click",function(d,i){
        //单击时让连接线加粗
        //force.stop();

        light(d.name);
        //d3.select(this).style('stroke-width',2);
    })
    .on("dblclick",function(d,i){
                  d.fixed = false;
                })
    .call(drag)//将当前选中的元素传到drag函数中，使顶点可以被拖动

    $('circle').tipsy({
        gravity: 'w',
        html: true,
        title: function() {
          d = this.__data__;
          nodeRealname = nodeslink[d.name];
          if(nodeRealname){
            return nodeRealname;
          }else{
            return "常数";
          }
        }
      });

  //圆圈的提示文字

/* 矩形
var rect=svg.append("rect")
         .attr({"x":100,"y":100,
                "width":100,"height":50,
                "rx":5,//水平圆角
                "ry":10//竖直圆角
             })
          .style({
             "stroke":"red",
             "stroke-width":1,
             "fill":"yellow"
});*/
var text = svg.append("g").selectAll("text")
                .data(force.nodes())
                //返回缺失元素的占位对象（placeholder），指向绑定的数据中比选定元素集多出的一部分元素。
                .enter()
                .append("text")
                .attr("dy", ".35em")
                .attr("text-anchor", "middle")//在圆圈中加上数据
                .style('fill',"black")
                .attr('x',function(d){
                    // console.log(d.name+"---"+ d.name.length);
                    var re_en = /[a-zA-Z]+/g;

                    var re_fat = /\([,a-zA-Z0-9]+\)/g;
                    var re_hex = /0x[0-9a-fA-F]+/;

                    // 重名问题
                    //var re_num = /[^\x00-\xff]+/g;//匹配中文
                    //匹配十六进制数
                    if(d.name.match(re_fat)){
                        d3.select(this).append('tspan')
                         .attr('x',0)
                         .attr('y',2)
                         .attr("dy",20)
                         .text(function(){
                            var str=(d.name.match(re_fat))[0];
                            var subStr=new RegExp(str,'ig');
                            a = d.name.replace(subStr, "");
                            // console.log(str)  //(Node0,0x00000008)
                            // console.log(a)  // Add32
                            return a;
                         });
                    }
                    else if(d.name.match(re_hex)){
                        d3.select(this).append('tspan')
                         .attr('x',0)
                         .attr('y',2)
                         .attr("dy",20)
                         .text(function(){return d.name.match(re_hex);});
                    }
                    else{
                        d3.select(this).append('tspan')
                         .attr('x',0)
                         .attr('y',2)
                         .attr("dy",20)
                         .text(function(){return d.name;});
                    }
                });

function light(nodename){
    var lightnodes=[nodename];
    linelight(nodename);
    function linelight(nodename){
        //从所有连线中匹配
        for(var i=0;i<links.length;i++){
          if(links[i].target.name==nodename){
            lightnodes.push(links[i].source.name);
            linelight(links[i].source.name);
          }
        }
    }
    //console.log(lightnodes);//后续节点 连线全部加粗
    edges_line.style("stroke-width",function(line){
      for(var i=0;i<lightnodes.length;i++){
        if(line.target.name ==lightnodes[i]){
          //console.log(line.target.name);
          return 4;
        }else if(line.source.name==lightnodes[0]){
          return 4;
        }
      }
    })
    //颜色
    edges_line.style({"stroke":function(line){
      for(var i=0;i<lightnodes.length;i++){
        if(line.target.name ==lightnodes[i]){
          //console.log(line.target.name);
          return "orange";
        }
        else if(line.source.name==lightnodes[0]){
          return "green";
        }
      }
      return "#B43232";
    },
    "visibility":function(line){
      console.log(display);
      if(display==0){
        console.log('sss');
        for(var i=0;i<lightnodes.length;i++){
          if(line.target.name ==lightnodes[i]){
            //console.log(line.target.name);
            return "visible";
          }
        }
        return "hidden";
      }
      else
        return "visible";
    }

    })

}



function tick() {
  circle.attr("transform", transform1);//圆圈
  text.attr("transform", transform2);//顶点文字

  edges_line.attr('d', function(d) {
      var path='M '+d.source.x+' '+d.source.y+' L '+ d.target.x +' '+d.target.y;
      return path;
  });

  edges_text.attr('transform',function(d,i){
        if (d.target.x<d.source.x){
            bbox = this.getBBox();
            rx = bbox.x+bbox.width/2;
            ry = bbox.y+bbox.height/2;
            return 'rotate(180 '+rx+' '+ry+')';
        }
        else {
            return 'rotate(0)';
        }
   });
}

//设置连接线的坐标,使用椭圆弧路径段双向编码
function linkArc(d) {
  return 'M '+d.source.x+' '+d.source.y+' L '+ d.target.x +' '+d.target.y
}
//设置圆圈和文字的坐标
function transform1(d) {
  return "translate(" + d.x + "," + d.y + ")";
}
function transform2(d) {
      return "translate(" + (d.x) + "," + d.y + ")";
    }
function stop(){
  force.stop();
}
function start(){
  force.start();
}
function delline(){
  edges_line.style("visibility","hidden");
  display=0;

}
function displayline(){
  edges_line.style("visibility","visible");
  display=1;
}
  </script>
  </div>
 </body>
</html>