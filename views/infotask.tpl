%rebase base title='任务详细  第一物流任务系统',position='任务详细'
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

</style>

<div class="page-body">
    <div class="row">
        <div class="col-lg-9 col-md-9 col-sm-12 col-xs-12">

            <div style="margin-bottom:15px;">
                <span class="label label-info" style="font-size:16px;">处理结果</span>
            </div>
            <div>
                <iframe id="test" width="150%" frameborder="no" onload="onload="this.height=100"" src="/result/1.html" sandbox='allow-popups allow-scripts allow-forms allow-same-origin'></iframe>
            </div>
           </div>
        </div>
    </div>
</div>

<script src="/assets/js/datetime/bootstrap-datepicker.js"></script>
<script>
    $('.date-picker').datepicker();     //时间插件

    function reinitIframe(){
        var iframe = document.getElementById("test");
        try{
        var bHeight = iframe.contentWindow.document.body.scrollHeight;
        var dHeight = iframe.contentWindow.document.documentElement.scrollHeight;
        var height = Math.max(bHeight, dHeight);
        iframe.height = height;
        console.log(height);
        }catch (ex){}
        }
    window.setInterval("reinitIframe()", 200);


</script>