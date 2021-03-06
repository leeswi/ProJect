#!/usr/bin/env python
#coding=utf-8
import os,sys,json
from bottle import request,route,error,run,default_app
from bottle import template,static_file,redirect,abort
import logging
from beaker.middleware import SessionMiddleware
from bottle import TEMPLATE_PATH
from gevent import monkey;
import MySQLdb
from strdeal import *
from datadeal import *
monkey.patch_all()

db_name = 'jingsai'
db_user = 'root'
db_pass = '123456'
db_ip = 'localhost'
db_port = 3306


#获取本脚本所在的路径
pro_path = os.path.split(os.path.realpath(__file__))[0]
#split分离路径和文件名
sys.path.append(pro_path)

#定义assets路径，即静态资源路径，如css,js,及样式中用到的图片等
assets_path = '/'.join((pro_path,'assets'))

#定义图片路径
images_path = '/'.join((pro_path,'images'))

#定义文件上传存放的路径
upload_path = '/'.join((pro_path,'log/source_data'))

#定义文件处理结果存放的路径
result_path = '/'.join((pro_path,'result'))

#定义模板路径
TEMPLATE_PATH.append('/'.join((pro_path,'views')))

#定义日志目录
log_path = ('/'.join((pro_path,'log')))

#定义日志输出格式
logging.basicConfig(level=logging.ERROR,
        format = '%(asctime)s %(filename)s[line:%(lineno)d] %(levelname)s %(message)s',
        datefmt = '%Y-%m-%d %H:%M:%S',
        filename = "%s/error_log" % log_path,
        filemode = 'a')

def writeDb(sql,db_data=()):
    """
    连接mysql数据库（写），并进行写的操作
    """
    try:
        conn = MySQLdb.connect(db=db_name,user=db_user,passwd=db_pass,host=db_ip,port=int(db_port),charset="utf8")
        cursor = conn.cursor()
    except Exception,e:
        print e
        logging.error('数据库连接失败:%s' % e)
        return False

    try:
        cursor.execute(sql,db_data)
        conn.commit()
    except Exception,e:
        print e
        conn.rollback()
        logging.error('数据写入失败:%s' % e)
        return False
    finally:
        cursor.close()
        conn.close()
    return True


def readDb(sql,db_data=()):
    """
    连接mysql数据库（从），并进行数据查询
    """
    try:
        conn = MySQLdb.connect(db=db_name,user=db_user,passwd=db_pass,host=db_ip,port=int(db_port),charset="utf8")
        cursor = conn.cursor()
    except Exception,e:
        print e
        logging.error('数据库连接失败:%s' % e)
        return False

    try:
        cursor.execute(sql,db_data)
        data = [dict((cursor.description[i][0], value) for i, value in enumerate(row)) for row in cursor.fetchall()]
    except Exception,e:
        logging.error('数据执行失败:%s' % e)
        return False
    finally:
        cursor.close()
        conn.close()
    return data


#设置session参数
session_opts = {
    'session.type':'file',
    'session.cookei_expires':3600,
    'session.data_dir':'/tmp/sessions',
    'sessioni.auto':True
    }

def checkLogin(fn):
    """验证登陆，如果没有登陆，则跳转到login页面"""
    def BtnPrv(*args,**kw):
        s = request.environ.get('beaker.session')
        if not s.get('userid',None):
            return redirect('/login')
        return fn(*args,**kw)
    return BtnPrv

def checkAccess(fn):
    """验证权限，如果非管理员权限，则返回404页面"""
    def BtnPrv(*args,**kw):
        s = request.environ.get('beaker.session')
        if not s.get('userid',None):
            return redirect('/login')
        elif s.get('access',None) != 1: 
            abort(404)
        return fn(*args,**kw)
    return BtnPrv




@error(404)
def error404(error):
    """定制错误页面"""
    return template('404')


@route('/assets/<filename:re:.*\.css|.*\.js|.*\.png|.*\.jpg|.*\.gif>')
def server_static(filename):
    """定义/assets/下的静态(css,js,图片)资源路径"""
    return static_file(filename, root=assets_path)

@route('/assets/<filename:re:.*\.ttf|.*\.otf|.*\.eot|.*\.woff|.*\.svg|.*\.map>')
def server_static(filename):
    """定义/assets/字体资源路径"""
    return static_file(filename, root=assets_path)

@route('/images/<filename:re:.*\.png>')
def server_static(filename):
    """定义/images/图片资源路径"""
    return static_file(filename, root=images_path)

@route('/log/source_data/<filename:re:.*\.txt>')
def server_static(filename):
    """定义上传文件存放路径"""
    return static_file(filename, root=upload_path)


@route('/result/<filename:re:[0-9a-zA-Z]+|.*\.html>')
def server_static(filename):
    """定义/assets/字体资源路径"""
    return static_file(filename, root=result_path)

@route('/')
@checkLogin   #函数调用
def index():
    return template('index',message='')

@route('/user')
@checkAccess
def user():
    sql = """
    SELECT
        U.id,
        U.name,
        U.username,
        U.access,
        t.subject
    FROM
        user as U
        LEFT OUTER JOIN task as t on U.id=t.inputid and t.del_status=1
    """
    result = readDb(sql,)
    return template('user',department_result=result)

@route('/adduser',method="POST")
@checkAccess
def adduser():
    name = request.forms.get("name")
    username = request.forms.get("username")
    passwd = request.forms.get("passwd")
    access = request.forms.get("access")

    #把密码进行md5加密码处理后再保存到数据库中
    m = hashlib.md5()
    m.update(passwd)
    passwd = m.hexdigest()

    #检测表单各项值，如果出现为空的表单，则返回提示

    if not (name and username and access):
        message = "表单不允许为空！"
        return message
    else:
        access = int(access)

    sql = """
            INSERT INTO
                user(name,username,passwd,access)
            VALUES(%s,%s,%s,%s)
        """
    data = (name,username,passwd,access)
    result = writeDb(sql,data)
    if result:
        return '0'
    else:
        return '-1'

@route('/changeuser/<id>',method="POST")
@checkAccess
def changeuser(id):
    name = request.forms.get("name")
    username = request.forms.get("username")
    passwd = request.forms.get("passwd")
    access = request.forms.get("access")
    #把密码进行md5加密码处理后再保存到数据库中
    if not passwd:
        sql = "select passwd from user where id = %s"
        passwd = readDb(sql,id)[0]['passwd']
    else:
        m = hashlib.md5()
        m.update(passwd)
        passwd = m.hexdigest()

    def checkRequest(list_data):
        for i in list_data:
            if not i.strip():
                return '-2'

    if not (name and username and access):
        message = "表单不允许为空！"
        return message
    else:
        access = int(access)


    sql = """
            UPDATE user SET
            name=%s,username=%s,passwd=%s,access=%s
            WHERE id=%s
        """
    data = (name,username,passwd,access,id)
    result = writeDb(sql,data)
    if result:
        return '0'
    else:
        return '-1'

@route('/deluser',method="POST")
@checkAccess
def deluser():
    id = request.forms.get('str').rstrip(',')
    if not id:
        return '-1'
    print type(id)
    sql = "delete from user where id in (%s)" %id
    result = writeDb(sql,)
    if result:
        return '0'
    else:
        return '-1'

@route('/api/getuser',method=['GET', 'POST'])
@checkAccess
def getuser():
    sql = """
        SELECT
            U.id,
            U.name,
            U.username,
            U.access,
            GROUP_CONCAT(t.subject SEPARATOR ",") as subject
        FROM
            user as U
            LEFT OUTER JOIN task as t on U.id=t.inputid and t.del_status=1
        GROUP BY
            U.id
        """
    userlist = readDb(sql,)
    return json.dumps(userlist)

@route('/taskinfo')
@checkLogin
def taskinfo():
    s = request.environ.get('beaker.session')
    return template('taskinfo',session=s)

@route('/api/gettask',method=['GET','POST'])
@checkLogin
def tasklist():
    status = request.query.witchbtn or -1
    wherestr = "WHERE 1=1"
    if int(status) in [0,1,2]:
        wherestr = ' '.join((wherestr,'AND T.status=%d' % int(status)))
    sql = """
        SELECT
           t.id,
           t.inputid,
           t.subject,
           t.content
        FROM
           (
            SELECT
                T.id,
                Ui.name as inputid,
                T.subject,
                T.content
            FROM
                task as T
                LEFT OUTER JOIN user as Ui on Ui.id=T.inputid
            {where} AND T.del_status=1
            ) AS t
        """.format(where=wherestr)

    tasklist = readDb(sql,)
    return json.dumps(tasklist)

@route('/addtask')
@checkLogin
def addtask():
    user_sql = "select id,name from user;"
    # department_sql = "select id,name from department;"
    user_data = readDb(user_sql,)

    # department_data = readDb(department_sql,)
    return template('addtask',user_data=user_data,task_data=[{}])

@route('/addtask',method="POST")
@checkLogin
def do_addtask():
    s = request.environ.get('beaker.session')

    upload = request.files.get("content")  #获取数据流控制流文件
    upload.save('./log/source_data', overwrite=True)  # 把数据流控制流文件保存到指定目录路径下
    inputid = s['userid']
    subject = request.forms.get("subject")
    content = upload.filename
    ###恶意代码处理模块 返回两个文件
    #
    #控制流文件处理
    control_data = deal2(content)
    #数据流处理
    dataflow = deal(content)
    #行为分析
    behavior = behave(content)
    print behavior
    dataflow_path = dataflow[0]
    str = dataflow[1]

    sql = """
        INSERT INTO 
        task(inputid,subject,content,control_data,dataflow,dataflow_path)
        VALUES(%s,%s,%s,%s,%s,%s)
    """
    data = (inputid,subject,content,control_data,str,dataflow_path)
    result = writeDb(sql,data)
    if result:
        sql1 = "SELECT MAX(id) FROM task"
        result1 = readDb(sql1,)
        result1 = (result1[0].values())[0]
        print result1
    
        sql2 = "INSERT INTO behavior (`id`,`out`,`behaviors`) VALUES (%s,%s,%s)"
        if behavior and result1:
            for key in behavior:
                data = (result1,key,behavior[key])
                writeDb(sql2,data)
        redirect('/taskinfo')
    else:
        return '添加失败'

@route('/infotask/<id>')
@checkLogin
def infotask(id):
    #获取任务详细内容页
    id = int(id)
    s = request.environ.get('beaker.session')
    myusername = s['name']
    task_sql = """
    SELECT
    	t.id,
    	t.inputid,
    	t.subject,
    	t.content,
    	t.control_data,
    	t.dataflow
    FROM
    	(
    	SELECT
    	   T.id,
    	   Ui.name as inputid,
    	   T.subject,
    	   T.content,
    	   T.control_data,
    	   T.dataflow
    	FROM
    	   task as T
    	   LEFT OUTER JOIN user as Ui on Ui.id=T.inputid
    	   ) AS t
    	WHERE
    	   id=%s
    """ %id
    taskinfo = readDb(task_sql,)
    with open("./log/source_data/"+taskinfo[0]['content']) as f:
        text = f.read()
    taskinfo[0]['text'] = text
    sql1 = """
    SELECT `out`,behaviors FROM behavior WHERE id = %s
    """
    behaviors = readDb(sql1,(id,))
    print behaviors
    return template('infotask', taskinfo=taskinfo, myusername=myusername, behaviors=behaviors)

@route('/login')
def login():
    """用户登陆"""
    return template('login',message='')

@route('/login',method='POST')
def do_login():
    """用户登陆过程，判断用户帐号密码，保存SESSION"""
    username = request.forms.get('username').strip()
    passwd = request.forms.get('passwd').strip()
    if not username or not passwd:
        message = u'帐号或密码不能为空！'
        return template('login',message=message)

    m = hashlib.md5()
    m.update(passwd)
    passwd_md5 = m.hexdigest()
    auth_sql = '''
        SELECT
            id,username,name,access
        FROM
            user
        WHERE
            username=%s and passwd=%s
        '''
    auth_user = readDb(auth_sql,(username,passwd_md5))
    if auth_user:
        s = request.environ.get('beaker.session')
        s['username'] = username
        s['name'] = auth_user[0]['name']
        s['userid'] = auth_user[0]['id']
        s['access'] = auth_user[0]['access']
        s.save()
    else:
        message = u'帐号或密码错误！'
        return template('login',message=message)
    return redirect('/')

@route('/logout')
@checkLogin
def logout():
    """退出系统"""
    s = request.environ.get('beaker.session')
    user = s.get('user',None)
    try:
        s.delete()
    except Exception:
        pass
    return redirect('/login')

@route('/deltask/<id>')
@checkLogin
def deltask(id):
    """删除任务，其实就是把任务的删除状态改成0（0为被删除，1为正常）"""
    s = request.environ.get('beaker.session')
    del_userid = s['userid']
    sql = """
        UPDATE
            task
        SET
            del_userid=%s,
            del_status=%s
        WHERE
            id=%s
    """
    data = (del_userid,0,id)
    result = writeDb(sql,data)
    if result:
        redirect('/taskinfo')
    else:
        return '-1'

@route('/recoverytask/<id>')
@checkLogin
def recovery(id):
    """恢复任务，即把任务的删除状态从0改成1（0为被删除，1为正常）"""
    sql = """
        UPDATE
            task
        SET
            del_status=%s
        WHERE
            id=%s
    """
    data = (1,id)
    result = writeDb(sql,data)
    if result:
        redirect('/droptask')
    else:
        return '-1'




if __name__ == '__main__':
    app = default_app()
    app = SessionMiddleware(app, session_opts)
    run(app=app,host='127.0.0.1', port=8880,debug=True,server='gevent')

