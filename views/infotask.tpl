%rebase base title='任务详细  恶意代码可视化分析系统',position='任务详细'

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


        .button-label .circles{
            left: 0;
            transition: all 0.3s;
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
		<button class="btn btn-primary" id="check2" href="javascript:void(0);">查看原文件</button>
		<button class="btn btn-primary" id="check" href="javascript:void(0);">查看数据结构</button>
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
  
<div class="modal fade" id="myModal" tabindex="-1" role="dialog"  aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog" >
      <div class="modal-content" id="contentDiv">
         <div class="widget-header bordered-bottom bordered-blue ">
           <i class="widget-icon fa fa-pencil themeprimary"></i>
           <span class="widget-caption themeprimary" id="modalTitle">节点源数据</span>
		</div>
			<p>{{taskinfo[0].get('dataflow','未知')}}
			</p>
      </div>
   </div>
</div>
<div class="modal fade" id="myModal2" tabindex="-1" role="dialog"  aria-labelledby="myModalLabel" aria-hidden="true">
    <div class="modal-dialog" >
      <div class="modal-content" id="contentDiv">
         <div class="widget-header bordered-bottom bordered-blue ">
           <i class="widget-icon fa fa-pencil themeprimary"></i>
           <span class="widget-caption themeprimary" id="modalTitle2">源文件</span>
		</div>
          <text>{{taskinfo[0].get('text','未知')}}</text>
      </div>
   </div>
</div>
 
 
 <script>
	$('#check').click(function(){
        $('#modalTitle').html('节点源数据');
        $('#myModal').modal('show');
        isEdit = 0;
		
    });
	$('#check2').click(function(){
        $('#modalTitle2').html('源文件');
        $('#myModal2').modal('show');
        isEdit = 0;
    });
 </script>


<div>
<script>

  var treeData = {{!taskinfo[0].get('control_data','未知')}};
  // ************** Generate the tree diagram  *****************
  //定义树图的全局属性（宽高）
  var margin = {top: 20, right: 120, bottom: 20, left: 120},
      width2 = 1500,
      height = 800;

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

  root = treeData[0];//treeData为上边定义的节点属性
  root.x0 = height / 2;
  root.y0 = 0;

  update(root);

  d3.select(self.frameElement).style("height", "1500px");

  function update(source) {

    // Compute the new tree layout.计算新树图的布局
    var nodes = tree.nodes(root).reverse(),
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
		.on("dblclick", click);

    nodeEnter.append("rect")
      .attr("x",-23)
      .attr("y", -10)
      .attr("width",70)
      .attr("height",22)
      .attr("rx",10)
        .style("fill", "#357CAE")
		.on("mouseover",function(d){
			d3.select(this).style("fill","#ADFF2F");
		})
		.on("mouseout",function(d){
			d3.select(this)
                .transition()
                .duration(1500)
				.style("fill","#357CAE")
				})
		.on("click",function(d,i){
            //单击时让连接线加粗
			d3.select(this).style("fill","#ADFF2F");
			name = d["name"];
            out = d["out"];
			children = "";
			whilethen = d['parent']['whilethen'];
			//提取whilethen的常数节点，引用light2
			var str = whilethen
			re = /0x[0-9a-fA-F]+/g
			node = str.match(re);
			light2(node,whilethen);
			if(d["children"]){
				for(var i=0;i<d["children"].length;i++){
					children = children + d["children"][i]["name"]+" ";
				};
			}else{
				children="null";
			}
            temp = "本块地址："+name+"</br>"+"出口地址："+out+"</br>"+"下一入口地址："+children+"</br>"+"到达条件："+whilethen;
            oonload(tk_index=temp);
			
			light(name);
        });


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
    var linkEnter = link.enter().insert("path", "g")
        .attr("class", "link2")
        .attr("id",function(d){ return d.source.name;})
        .attr("d", function(d) {
          var o = {x: source.x0, y: source.y0};
          return diagonal({source: o, target: o});  //diagonal - 生成一个二维贝塞尔连接器, 用于节点连接图.
        })
        .on("mouseover", function(d) {
          d3.select(this).style("stroke", "green");
		  d3.select(this).style("stroke-width", "5");
        })
        .on("mouseout", function(d) {
          d3.select(this).style("stroke", "#CCC");
		  d3.select(this).style("stroke-width", "2");
        })
        .on("click", d => {
            out = d['source']['out'];
            whilethen = d['source']['whilethen'];
            temp = "出口地址："+out+"</br>"+"跳转条件："+whilethen;
            oonload(tk_index=temp);
        });//
	
	function light(nodename){
		var lightnodes = [nodename];
		linelight(nodename);
		console.log(nodename);
		function linelight(nodename){
		    for(var i=0;i<links.length;i++){
		        if(links[i]['target']['name']==nodename){
		            lightnodes.push(links[i]['source']['name']);
		            linelight(links[i]['source']['name']);
		        }
		    }
		}
		linkEnter.style("stroke-width",function(line){
			for(var i=0;i<lightnodes.length;i++){
				if(line['target']['name']==lightnodes[i]){
              //console.log(line.target.name);
					return 4;
				}else if(line['source']['name']==lightnodes[0]){
					return 4;
				}
			}
        })
		linkEnter.transition()
				.ease("bounce")
                .duration(1500)
				.style("stroke",function(line){
			for(var i=0;i<lightnodes.length;i++){
				if(line['target']['name'] ==lightnodes[i]){
					return "orange";
				}
				else if(line['source']['name']==lightnodes[0]){
					return "red";
				}
			}
			return "#ccc";
		})
		;
	}
	
	
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
    if (d.children) {
      d._children = d.children;
      d.children = null;
    } else {
      d.children = d._children;
      d._children = null;
    }
    update(d);
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

</script>

<div id="data" style="position:absolute;left:200px;top:1000px">
<script>

var links=[{{!taskinfo[0].get('dataflow','未知')}}];

var nodes = {};
  links.forEach(function(link) {  //将link里面的source和target传入结点 nodes
    link.source = nodes[link.source] || (nodes[link.source] = {name: link.source});
    link.target = nodes[link.target] || (nodes[link.target] = {name: link.target});
  });

  var count=0; 
  for(var key in links){ 
     count++; 
  } 

  var scaleOFwindows = d3.scale.linear()
          .domain([1, 100])
          .range([300, 1200])


  var width = 1000;
  var height = scaleOFwindows(count);
  var x=300;
  var y=500;
  var display=1;
  var force = d3.layout.force()//layout将json格式转化为力学图可用的格式
      .nodes(d3.values(nodes))//设定节点数组
      .links(links)//设定连线数组
      .size([width, height])//作用域的大小
      .linkDistance(100)//连接线长度
      .charge(-1000)//顶点的电荷数。该参数决定是排斥还是吸引，数值越小越互相排斥
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

  var svg = d3.select("#data").append("svg")
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
          .attr("refX",70)//箭头坐标
          .attr("refY", 0)
          .attr("markerWidth", 12)//标识的大小
          .attr("markerHeight", 12)
          .attr("orient", "auto")//绘制方向，可设定为：auto（自动确认方向）和 角度值
          .attr("stroke-width",2)//箭头宽度

         .append("path")
          .attr("id","marker_path")
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
                           var lineColor='#ccc';
                           return lineColor;
                       })
                      .style("pointer-events", "none")
                      .style("stroke-width",2)//线条粗细
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
  /* edges_text.append('textPath')
			.attr('xlink:href',function(d,i) {return '#edgepath'+i})
			.style("pointer-events", "none")
			.text(function(d){console.log(d);return d.rela;}); */

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
            var maxvalue=100;
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
        var max=50;
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
		  var flow;
          Nodename = d.name.replace(/\(.*\)/,"");
		  if(Nodename.indexOf("0x")!=-1){
			  var re = /0x[0-9a-fA-F]+/;
			  Nodename = Nodename.match(re);
			  for(var i=0;i<links.length;i++){
			  if(links[i]['rela'].indexOf(Nodename)!=-1){
				  flow = links[i]['rela'];
				  nodeRealname = "节点："+Nodename+"</br>"+"数据流："+flow;
				  oonload(tk_index=nodeRealname);
				  break;
			  };
			  
		  }
		  }
          else{
			  nodeRealname = "节点："+Nodename+"</br>";
			  oonload(tk_index=nodeRealname);
		  }
          light3(d.name);
      })
      .on("dblclick",function(d,i){
                    d.fixed = false;
                  })
      .call(drag)//将当前选中的元素传到drag函数中，使顶点可以被拖动
      .on("mouseover",function(d){
          d3.select(this).style("fill","red");
          nodeRealname = d.name;
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
                      var maxvalue=100;
                      var color = d3.interpolate(a,b);
                      var linear = d3.scale.linear()
                            .domain([minvalue, maxvalue])
                            .range([0, 1]);
                      weight=node.weight;
                      return color(linear(weight));
                  }
                });
      });

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

  function light2(nodename,rela){
	  console.log(rela);
	  var lightnodes=[]
	  for(var j=0;j<nodename.length;j++){
		  for(var i in nodes){
			  if(i.indexOf(nodename[j])>0){
				  nodename[j]=i;
				  lightnodes.push(nodename[j])
				  break
			  }
		  }
	  }
      linelight(nodename);
	  //console.log(links);
      function linelight(nodename){
          for(var j=0;j<nodename.length;j++){
			  for(var i=0;i<links.length;i++){
				if(links[i].source.name==nodename[j]){
				  lightnodes.push(links[i].target.name);
				  tmp=[];
				  tmp.push(links[i].target.name);
				  linelight(tmp);
				}
			  }
		  }
      }
      //console.log(lightnodes);//后续节点 连线全部加粗
      edges_line.style("stroke-width",function(line){
        for(var i=0;i<lightnodes.length;i++){
          if(line.source.name ==lightnodes[i]){
            //console.log(line.target.name);
            return 4;
          }else if(line.target.name==lightnodes[0]){
            return 4;
          }
        }
      })
      //颜色
      edges_line.style({"stroke":function(line){
        for(var i=0;i<lightnodes.length;i++){
          if(line.source.name ==lightnodes[i]){
            //console.log(line.target.name);
            return "orange";
          }
          else if(line.target.name==lightnodes[0]){
            return "green";
          }
        }
        return "#ccc";
      },
      "visibility":function(line){
        if(display==0){
          console.log('sss');
          for(var i=0;i<lightnodes.length;i++){
            if(line.source.name ==lightnodes[i]){
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
    function light3(nodename){
	  var lightnodes=[nodename]
      linelight(nodename);
      function linelight(nodename){
		  for(var i=0;i<links.length;i++){
			if(links[i].source.name==nodename){
			  lightnodes.push(links[i].target.name);
			  linelight(links[i].target.name);
			}
		  }
      }
      //console.log(lightnodes);//后续节点 连线全部加粗
      edges_line.style("stroke-width",function(line){
        for(var i=0;i<lightnodes.length;i++){
          if(line.source.name ==lightnodes[i]){
            //console.log(line.target.name);
            return 4;
          }else if(line.target.name==lightnodes[0]){
            return 4;
          }
        }
      })
      //颜色
      edges_line.style({"stroke":function(line){
        for(var i=0;i<lightnodes.length;i++){
          if(line.source.name ==lightnodes[i]){
            //console.log(line.target.name);
            return "orange";
          }
          else if(line.target.name==lightnodes[0]){
            return "green";
          }
        }
        return "#ccc";
      },
      "visibility":function(line){
        if(display==0){
          console.log('sss');
          for(var i=0;i<lightnodes.length;i++){
            if(line.source.name ==lightnodes[i]){
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
  function checkfile1(){
	  
  }



</script>
</div>
 </body>