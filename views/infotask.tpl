%rebase base title='任务详细  第一物流任务系统',position='任务详细'

<script type="text/javascript" src="/assets/js/jquery.tipsy.js"></script>
<script type="text/javascript" src="/assets/js/d3.v3.min.js"></script>
<link href="/assets/css/tipsy.css" rel="stylesheet" type="text/css" />
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
        .tooltip{
        position: absolute;
        width: 120;
        height: auto;
        font-family: simsun;
        font-size: 14px;
        text-align: center;
        border-style: solid;
        border-width: 1px;
        background-color: white;
        border-radius: 5px;
        }
        *{padding:0px;margin:0px;font-family:"微软雅黑";}
        dd,dl,dt,em,i,p,textarea,a,div{padding:0px;margin:0px;}
        img{border:0px;}
        ul,li{padding:0px;margin:0px;list-style:none; float:left}
        .fl{ float:left}
        span.fl{
          font-family: simsun;
          font-size: 14px;
        }
        .fr{ float:right}
        
        /*右下角弹出*/
        .dingwe{ position:relative;}
        .tipfloat{display:none;z-index:999;border:1px #5db2ff solid; position:fixed; bottom:0px; right:2px;width:388px;height:auto; background:#fff}
        .tipfloat_bt{ height:30px; line-height:30px;background:#5db2ff; padding:0px 20px; font-size:18px; color:#fff; }
        .xx_nrong{word-wrap:break-word;font-size:14px; color:#333; text-align:left; padding:20px 20px; line-height:26px; }

        .node2 {
        cursor: pointer;
        }

        .node2 circle {
          fill: #357CAE;
          stroke: steelblue;
          stroke-width: 3px;
        }
        .node2 rect {
          fill: #2990ca;
          stroke-width: 1.5px;
        }

        .node2 text {
          font: 10px sans-serif;
        }

        .link2 {
          fill: none;
          stroke: #ccc;
          stroke-width: 2px;
        }


</style>
<body>
  <div class="page-body">
      <button class="btn btn-primary" onclick="stop()">停止浮动</button>
      <button class="btn btn-primary" onclick="start()">开启浮动</button>
      <button class="btn btn-primary" id="button" onclick="delline()">隐藏线条</button>
      <button class="btn btn-primary" id="button" onclick="displayline()">显示线条</button>
      <button class="btn btn-primary" id="zoom_out" onclick="zoomClick()">缩小视图</button>
      <button class="btn btn-primary" id="zoom_in" onclick="zoomClick()">放大视图</button>

        <input type="checkbox" id="toggle-button" name="switch">
        连接线
        <label for="toggle-button" class="button-label" onclick="change()">
            <span class="circles"></span>
            <span class="text off" onclick="delline()">ON</span>
            <span class="text on" onclick="displayline()">OFF</span>
        </label>
      <div>
     <!--弹出信息 右下角-->   
      <div class="tipfloat" data-num="3">
          <p class="tipfloat_bt">
              <span class="fl">节点信息</span>
              <span class="fr close"><img src="../images/guanbi.png"></span>
          </p>
          <div class="ranklist">
               <div class="xx_nrong">
              </div> 
          </div>
      </div>
  </div>


<div>

<script>

  var treeData = {{!taskinfo[0].get('control_data','未知')}};
  // ************** Generate the tree diagram  *****************
  //定义树图的全局属性（宽高）
  var margin = {top: 20, right: 120, bottom: 20, left: 120},
      width2 = 1500,
      height = 100;

  var i = 0,
      duration = 750,//过渡延迟时间
      root;

  var tree = d3.layout.tree()//创建一个树布局
                      .size([height, width2]);

  var diagonal = d3.svg.diagonal()
      .projection(function(d) { return [d.y, d.x]; });//创建新的斜线生成器

  //声明与定义画布属性
  var svg2 = d3.select("body").append("svg")
                               .attr("width", width2 + margin.right + margin.left)
                               .attr("height", height + margin.top + margin.bottom)
                              .append("g")
                               .attr("transform", "translate(" + margin.left + "," + margin.top + ")");
  

  var marker2=
      svg2.append("marker")   //append 添加标签  attr 添加标签属性
            .attr("id", "resolved")
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

  root = treeData[0];//treeData为上边定义的节点属性
  root.x0 = height / 2;
  root.y0 = 0;

  



  update(root);

  d3.select(self.frameElement).style("height", "1500px");

  function update(source) {

    // Compute the new tree layout.计算新树图的布局
    var nodes = tree.nodes(source).reverse(),
        links = tree.links(nodes);

    var tooltip = d3.select("body").append("div")
                          .attr("class","tooltip") //用于css设置类样式
                          .attr("opacity",0.0);
    var color=d3.scale.category20();
    // Normalize for fixed-depth.设置y坐标点，每层占100px
    // 连接线的长度
    nodes.forEach(function(d) { d.y = d.depth * 180; });

    // Update the nodes…每个node对应一个group
    var node = svg2.selectAll("g.node2")
        .data(nodes, function(d) { return d.id || (d.id = ++i); });//data()：绑定一个数组到选择集上，数组的各项值分别与选择集的各元素绑定

    // Enter any new nodes at the parent's previous position.新增节点数据集，设置位置
    var nodeEnter = node.enter().append("g")  //在 svg 中添加一个g，g是 svg 中的一个属性，是 group 的意思，它表示一组什么东西，如一组 lines ， rects ，circles 其实坐标轴就是由这些东西构成的。
        .attr("class", "node2") //attr设置html属性，style设置css属性
        .attr("transform", function(d) { return "translate(" + source.y0 + "," + source.x0 + ")"; })
        .on("click", click)
        .on("mouseover",function(d,i){
                  /*
                  鼠标移入时，
                  （1）通过 selection.html() 来更改提示框的文字
                  （2）通过更改样式 left 和 top 来设定提示框的位置
                  （3）设定提示框的透明度为1.0（完全不透明）
                  */
            if(d.order){
              tooltip.html(d.order+"↘")
                  .style("left",(d3.event.pageX-100)+"px")
                  .style("top",(d3.event.pageY-20)+"px")
                  .style("opacity",1.0);
              tooltip.style("box-shadow","2px 2px 0px"+color(i));//在提示框后添加阴影
              }})
              .on("mousemove",function(d){
                  /* 鼠标移动时，更改样式 left 和 top 来改变提示框的位置 */
                  tooltip.style("left",(d3.event.pageX-60)+"px")
                          .style("top",(d3.event.pageY-40)+"px");
              })
              .on("mouseout",function(d){
                  //鼠标移除 透明度设为0
                  tooltip.style("opacity",0.0);
              }) ;

    nodeEnter.append("rect")
      .attr("x",-23)
      .attr("y", -10)
      .attr("width",70)
      .attr("height",22)
      .attr("rx",10)
        .style("fill", "#357CAE");//d 代表数据，也就是与某元素绑定的数据。


    //添加标签
    nodeEnter.append("text")
        .attr("x", function(d) { return d.children || d._children ? 13 : 13; })
        .attr("dy", "5")
        // .attr("text-anchor", function(d) { return d.children || d._children ? "end" : "start"; })
      .attr("text-anchor", "middle")
        .text(function(d) { return d.name; })
      .style("fill", "white")
        .style("fill-opacity", 1e-6);

    var nodeUpdate = node.transition()  //开始一个动画过渡
        .duration(duration)  //过渡延迟时间,此处主要设置的是圆圈节点随斜线的过渡延迟
        .attr("transform", function(d) { return "translate(" + d.y + "," + d.x + ")"; });

    nodeUpdate.select("rect")
              .attr("x",-23)
              .attr("y", -10)
              .attr("width",70)
              .attr("height",22)
              .attr("rx",10)
              .style("fill", function(node){
                            if(node.order)
                                {return "red";
                            }else{
                              return "#357CAE";
                            }
                          });

    nodeUpdate.select("text")
      .attr("text-anchor", "middle")
        .style("fill-opacity", 1);

    // Transition exiting nodes to the parent's new position.过渡现有的节点到父母的新位置。
    //最后处理消失的数据，添加消失动画
    var nodeExit = node.exit().transition()
        .duration(duration)
        .attr("transform", function(d) { return "translate(" + source.y + "," + source.x + ")"; })
        .remove();

    // nodeExit.select("circle")
      //   .attr("r", 1e-6);
    nodeExit.select("rect")
            .attr("x",-23)
            .attr("y", -10)
            .attr("width",70)
            .attr("height",22)
            .attr("rx",10)
            .style("fill", "#357CAE");

    nodeExit.select("text")
      .attr("text-anchor", "middle")
        .style("fill-opacity", 1e-6);

    // Update the links…线操作相关
    //再处理连线集合
    var link = svg2.selectAll("path.link2")
        .data(links, function(d) { return d.target.id; });


    // Enter any new links at the parent's previous position.
    //添加新的连线
    link.enter().insert("path", "g")
        .attr("class", "link2")
        .attr("id",function(d){ return d.source.name;})
        .attr("d", function(d) {
          var o = {x: source.x0, y: source.y0};
          return diagonal({source: o, target: o});  //diagonal - 生成一个二维贝塞尔连接器, 用于节点连接图.
        })
        .attr("marker-end", "url(#resolved)" );//



    // var linetexts = svg.selectAll("g")
    //     .append('text')
    //     .style('font-size', '7px')
    //     .style('x', '180')
    //     .style('y', '100')
    //    .append('textPath')
    //     .attr('xlink:href',function(links){
    //       console.log(links);
    //       return '#'+links.name;})
    //     .text("12345");


    // Transition links to their new position.将斜线过渡到新的位置
    //保留的连线添加过渡动画
    link.transition()
        .duration(duration)
        .attr("d", diagonal);

    // Transition exiting nodes to the parent's new position.过渡现有的斜线到父母的新位置。
    //消失的连线添加过渡动画
    link.exit().transition()
        .duration(duration)
        .attr("d", function(d) {
          var o = {x: source.x, y: source.y};
          return diagonal({source: o, target: o});
        })
        .remove();

    // Stash the old positions for transition.将旧的斜线过渡效果隐藏
    nodes.forEach(function(d) {
      d.x0 = d.x;
      d.y0 = d.y;
    });
  }

  //定义一个将某节点折叠的函数
  // Toggle children on click.切换子节点事件
  function click(d) {
    // if (d.children) {
    //   d._children = d.children;
    //   d.children = null;
    // } else {
    //   d.children = d._children;
    //   d._children = null;
    // }
    // update(d);
    console.log(d);
    if(d.parent){
      temp=d;
      while(temp.parent){
        temp1=temp;
        temp=temp.parent;
      }
      if(temp=='null'){d._parent = temp1;}
      else{d._parent = temp;}
      d.parent = null;
    }else{
      d.parent = d._parent;
      d._parent = null;
    }

    if(d.parent){
      update(d.parent);
    }else{
      update(d);
    }
    
  }

</script>
</div>
  
  <div><!-- 数据流模块 -->
  <script>
    var links=[{{!taskinfo[0].get('str','未知')}}];
    var nodeslink={{!taskinfo[0].get('nodelink','未知')}};
    var nodes = {};
    links.forEach(function(link) {  //将link里面的source和target传入结点 nodes
      link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
      link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
    });

    var count=0; 
    for(var key in nodeslink){ 
        count++; 
    } 

    var scaleOFwindows = d3.scale.linear()
            .domain([1, 100])
            .range([560, 1800]);


    var width = 1560;
    var height = scaleOFwindows(count);
    var x=300;
    var y=500;
    var display=1;
    var force = d3.layout.force()//layout将json格式转化为力学图可用的格式
        .nodes(d3.values(nodes))//设定节点数组
        .links(links)//设定连线数组
        .size([width, height])//作用域的大小
        .linkDistance(80)//连接线长度
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
    //缩放
    // var zoom = d3.behavior.zoom().scaleExtent([1, 8]).on("zoom", null);

    var svg = d3.select("body").append("svg")
        .attr("preserveAspectRatio","xMinYMin meet")
        .attr("width", width)
        .attr("height", height)
        // .call(zoom);




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

    var tooltip = d3.select("body")
                    .append("div")
                    .attr("class","tooltip")
                    .style("opacity",0.0);

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
            var Nodename;
            Nodename = d.name.replace(/\(.*\)/,"");
            nodeRealname = "结点："+Nodename+"</br>"+"数据流："+nodeslink[d.name];
            oonload(tk_index=nodeRealname);
            light(d.name);
        })
        .on("dblclick",function(d,i){
                      d.fixed = false;
                    })
        .call(drag)//将当前选中的元素传到drag函数中，使顶点可以被拖动
        .on("mouseover",function(d){
            d3.select(this).style("fill","red");
            nodeRealname = nodeslink[d.name];
            tooltip.html(nodeRealname)
                .style("left", (d3.event.pageX) + "px")
                .style("top", (d3.event.pageY + 20) + "px")
                .style("opacity",1.0);
        })
        .on("mousemove",function(d){
            tooltip.style("left", (d3.event.pageX) + "px")
                    .style("top", (d3.event.pageY + 20) + "px");
        })
        .on("mouseout",function(d){
            tooltip.style("opacity",0.0);
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

    var xx_num;
    function oonload(tk_index){
         xx_num=$(".tipfloat").attr("data-num");
        tankuan()

        $(".close").click(function(){
            $(".tipfloat").animate({height:"hide"},800);
            
        });
    }
    function tankuan(){
        if(tk_index!=xx_num){     
            $(".tipfloat").animate({height:"show"},800);
        
            //文本输出可删除
        $(".xx_nrong").html(tk_index);
            tk_index++;
         }
    }

    function zoomed() {
        svg.attr("transform",
            "translate(" + zoom.translate() + ")" +
            "scale(" + zoom.scale() + ")"
        );
    }

    // function interpolateZoom (translate, scale) {
    //     var self = this;
    //     return d3.transition().duration(350).tween("zoom", function () {
    //         var iTranslate = d3.interpolate(zoom.translate(), translate),
    //             iScale = d3.interpolate(zoom.scale(), scale);
    //         return function (t) {
    //             zoom
    //                 .scale(iScale(t))
    //                 .translate(iTranslate(t));
    //             zoomed();
    //         };
    //     });
    // }

    // function zoomClick() {
    //   var direction = 1,
    //       factor = 0.2,
    //       target_zoom = 1,
    //       center = [width / 2, height / 2],
    //       extent = zoom.scaleExtent(),
    //       translate = zoom.translate(),
    //       translate0 = [],
    //       l = [],
    //       view = {x: translate[0], y: translate[1], k: zoom.scale()};

      
    //   direction = (this.id === 'zoom_in') ? 1 : -1;
    //   target_zoom = zoom.scale() * (1 + factor * direction);

    //   if (target_zoom < extent[0] || target_zoom > extent[1]) { return false; }

    //   translate0 = [(center[0] - view.x) / view.k, (center[1] - view.y) / view.k];
    //   view.k = target_zoom;
    //   l = [translate0[0] * view.k + view.x, translate0[1] * view.k + view.y];

    //   view.x += center[0] - l[0];
    //   view.y += center[1] - l[1];

    //   interpolateZoom([view.x, view.y], view.k);
    // }
  </script>
  </div>
 </body>