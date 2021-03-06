%rebase base title = '恶意代码分析'

<style>
    .index_text {
        font-size:16px;
        text-indent:2em
    }
</style>
<div class="page-body">
    <div class="row">
        <div class="col-lg-9 col-md-9 col-sm-12 col-xs-12">
            <h1>系统使用说明</h1>
            <h2><li>功能介绍</li></h2>
            <ul style="margin-left:60px;">
                <h3>
                    <li type="square">提交数据</li>
                </h3>
                <ul>
                    <p class="index_text">1.点击左侧菜单栏“任务管理”，选择“提交数据”选项</p>
                    <p class="index_text">2.在输入框中输入任务名，选择样本文件并点击上传</p>
                    <p class="index_text">3.文件格式说明：本系统接受样本监控模块生成的数据流和控制流文件，提交格式为文件格式为txt，文件名不得包含中文。 <a
                        href="../log/source_data/source.txt">查看示例文件</a></p>
                </ul>
                <h3>
                    <li type="square">处理中心</li>
                </h3>
                <ul>
                    <p class="index_text">1.点击左侧菜单栏“任务管理”，选择“处理中心”选项可查看已提交的任务</p>
                    <p class="index_text">2.“处理中心”可执行提交新任务、查看已提交的任务、删除任务、查看样本文件等操作</p>
                    <p class="index_text">3.点击任务名可以进入该任务的数据分析界面</p>
                </ul>
                <h3>
                    <li type="square">数据分析</li>
                </h3>
                <ul>
                    <p class="index_text">1.数据分析界面为系统根据用户提交的样本文件生成的可视化分析模型，分为控制流部分和数据流部分</p>
                    <p class="index_text">2.控制流部分表示为树形结构，数据流部分表示为力导图结构，用户可根据定义的交互动作对恶意代码进行辅助分析</p>
                    <p class="index_text">3.页面顶部定义了“查看源文件”和“查看数据结构”按钮，便于用户查看原始数据</p>
                </ul>
                <h3>
                    <li type="square">用户管理</li>
                </h3>
                <ul>
                    <p class="index_text">1.点击左侧菜单栏“任务管理”，选择“用户管理”选项</p>
                    <p class="index_text">2.“用户管理”界面可执行对用户的增、删、改、查。</p>
                </ul>
            </ul>
            <h2><li>辅助分析</li></h2>
            <ul style="margin-left:60px;">
                <h3>
                    <li type="square">高亮显示</li>
                </h3>
                <ul>
                    <p class="index_text">高亮显示主要涉及结点高亮和连线高亮。在控制流部分，鼠标悬停与节点或连线上方时，节点或连线呈绿色高亮状态。触发路径探索功能时，相关连线也会呈高亮状态突出显示路径。在数据流部分，鼠标悬停与节点上方会使节点呈红色高亮状态，同时也有路径探索高亮功能。</p>
                </ul>
                <h3>
                    <li type="square">折叠拖拽</li>
                </h3>
                <ul>
                    <p class="index_text">1.展开折叠功能主要相对于控制流部分而言，因为控制流部分定义为树形图，因此可以通过双击结点对该节点的所有子节点进行折叠隐藏，再次双击则将该节点的隐藏子节点展开。</p>
                    <p class="index_text">2.拖拽功能适用于力导图，力导图模式节点处于自由浮动状态，根据结点关系和重力关系自动成图。单击节点并按住鼠标移动可拖拽节点，松开鼠标节点位置固定，双击可解除锁定。</p>
                </ul>
                <h3>
                    <li type="square">路径探索</li>
                </h3>
                <ul>
                    <p class="index_text">1.路径探索用于寻找数据节点的关系。点击控制路数据节点，则高亮显示由起始节点至该节点的整条路线，同时红色高亮该节点的出口方向。点击数据流节点则自动探索该节点要经过的其它节点，并将整条路径高亮显示。</p>
                    <p class="index_text">2.关联分析功能指用户可通过点击控制流部分的结点来对与本节点相关的用数据流表示的跳转条件进行数据流图的高亮索引</p>
                </ul>
                <h3>
                    <li type="square">提示框</li>
                </h3>
                <ul>
                    <p class="index_text">提示框用于显示更加详细的节点信息。单击控制流节点（连线）或是数据流节点会在界面右下角弹出节点信息框，信息框的主要内容包括控制流节点代表的代码块地址、该代码块的出口地址、下一代码块的入口地址、到达该代码块满足的跳转条件，控制流连线（出发点）的出口地址、跳转条件，数据流节点的变量名及所在数据流信息。</p>
                </ul>
            </ul>
        </div>
        <div class="col-lg-3 col-md-3 col-sm-12 col-xs-12">
        <img src="/images/1.png" height="400" width="400" style="border:3px solid #E8E8E8;" />
        <img src="/images/2.png" height="400" width="400" style="border:3px solid #E8E8E8;" />
    </div>
</div>
