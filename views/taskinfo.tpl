%rebase base title='任务列表  恶意代码可视化分析系统',position='任务列表',managetopli="active open",adduser="active"

<div class="page-body">
    <div class="row">
        <div class="col-lg-12 col-md-12 col-sm-12 col-xs-12">
            <div class="widget">
                <div class="widget-header bordered-bottom bordered-themesecondary">
                    <i class="widget-icon fa fa-tags themesecondary"></i>
                    <span class="widget-caption themesecondary">任务列表</span>
                    <div class="widget-buttons">
                        <a href="#" data-toggle="maximize">
                            <i class="fa fa-expand"></i>
                        </a>
                        <a href="#" data-toggle="collapse">
                            <i class="fa fa-minus"></i>
                        </a>
                        <a href="#" data-toggle="dispose">
                            <i class="fa fa-times"></i>
                        </a>
                    </div>

                </div><!--Widget Header-->
                <div class="widget-body  no-padding">
                    <div class="tickets-container">
						<div class="table-toolbar" style="float:left">
                            <a id="adduser" href="/addtask" class="btn btn-primary">
                                <i class="btn-label fa fa-plus"></i>提交数据
                            </a>
							<a id="adduser" href="/taskinfo" class="btn">
                                <i class="btn-label fa fa-home"></i>处理中心
                            </a>
                        </div>
                       <table id="myLoadTable" class="table table-bordered table-hover"></table>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script type="text/javascript">
$(function(){
    /**
    *表格数据
    */

    $('#myLoadTable').bootstrapTable({
          method: 'post',
          url: '/api/gettask',
          contentType: "application/json",
          datatype: "json",
          cache: false,
          checkboxHeader: true,
          striped: true,
          pagination: true,
          pageSize: 15,
          pageList: [10,20,50],
          search: true,
          showColumns: true,
          showRefresh: true,
          minimumCountColumns: 2,
          clickToSelect: true,
          smartDisplay: true,
          //sidePagination : "server",
          sortOrder: 'asc',
          sortName: 'id',
          columns: [{
              field: 'id',
              title: '编号',
              align: 'center',
              valign: 'middle',
              width:25,
              sortable: false
          },{
              field: 'subject',
              title: '任务名',
              align: 'center',
              valign: 'middle',
              sortable: false,
              formatter:getinfo1
          },{
              field: 'content',
              title: '样本文件',
              align: 'center',
              valign: 'middle',
              sortable: false,
              formatter: getinfo2
          },{
              field: 'inputid',
              title: '发布人',
              align: 'center',
              valign: 'middle',
              sortable: false
          },{
              field: '',
              title: '操作',
              align: 'center',
              valign: 'middle',
              width:200,
              formatter:getinfo

          }]
      });


        //定义列操作
        function getinfo(value,row,index){
            eval('rowobj='+JSON.stringify(row));
            //定义编辑按钮样式，只有管理员或自己编辑的任务才有权编辑
            if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['inputid']){
                var style_edit = '<a href="/edittask/'+rowobj['id']+'" class="btn-sm btn-info" >';
            }else{
                var style_edit = '<a class="btn-sm btn-info" disabled>';
            }
            //定义删除按钮样式，只有管理员或自己编辑的任务才有权删除
            if({{session.get('access',None)}} == '1' || "{{session.get('name',None)}}" == rowobj['inputid']){
                var style_del = '&nbsp;<a href="/deltask/'+rowobj['id']+'" class="btn-sm btn-danger">';
            }else{
                var style_del = '&nbsp;<a class="btn-sm btn-danger" disabled>';
            }

            return [
                style_del,
                    '<i class="fa fa-times"> 删除</i>',
                '</a>'
            ].join('');
        }
        //
        function getinfo1(value,row,index){
            eval('rowobj='+JSON.stringify(row))
            return [
                '<a href="/infotask/'+rowobj['id']+'" style="text-decoration:none">',
                    rowobj['subject'],
                 '</a>'
            ].join('');
        }
        function getinfo2(value,row,index){
            eval('rowobj='+JSON.stringify(row))
            return [
                '<a href="../log/source_data/'+rowobj['content']+'" style="text-decoration:none">',
                    rowobj['content'],
                 '</a>'
            ].join('');
        }


})
function getdata(param){
    $("#myLoadTable").bootstrapTable('refresh',{url: '/api/gettask?witchbtn='+param});
}

</script>
