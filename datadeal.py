# -*- coding: utf-8 -*-

import re

data_list = []

def deal2(file):
    filename = file
    with open(".\\log\\source_data\\" + filename, "r") as f:
        data = f.read()

    datalist = re.findall(r"\['.*']", data)

    #字符串列表化
    list_data=[]
    for i in datalist:
        temp=i.replace(' ','').strip("[|]|'").split("\',\'")
        list_data.append(temp)

    #去重
    new_list = []
    for i in range(len(list_data)):
        if list_data[i] not in new_list:
            new_list.append(list_data[i])

    #将每条数据建立成字典存到列表
    #如{'whilethen': '32to1(1Uto32(CmpEQ32(LDle:I32(0x0804a040),0x00001000)))==False', 'children': '0x8048444', 'name': '0x804842e', 'parent': '', 'out': '0x804843e'}
    dic_list = []
    for i in new_list:
        temp={}
        temp["name"]=i[0] #基本块入口地址
        temp["out"]=i[1] #基本块出口地址
        temp["children"]=i[2] #下一个基本块入口地址
        temp["whilethen"]=i[3] #跳转条件
        temp["parent"]="Null"
        dic_list.append(temp)

    leaf = []  #没有孩子的叶子节点
    for i in dic_list:
        if not i["children"]:
            leaf.append(i)

    leaf_list=[]
    temp_list=[]
    for i in leaf:
        for j in dic_list:
            if ((i["name"]==j["name"]) and (j["children"])):
                temp_list.append(i)
                break
    for i in leaf:
        if i not in temp_list:
            leaf_list.append(i)

    leaf = leaf_list
    # for i in leaf:
    #     print i
    #从下往上逐层嵌套
    for i in dic_list:
        for j in leaf:
            if i["children"]==j["name"]:
                j["parent"]=i["name"]
                i["children"]=j

    for i in dic_list: #删除叶子节点
        if i in leaf:
            dic_list.remove(i)

    #判定叶节点
    def check_node(node,dic_list):
        name=[]
        children=[]
        for i in dic_list:
            if i["name"] not in name:
                name.append(i["name"])
        for i in dic_list:
            if i["name"]==node:
                children.append(i["children"])
        for i in children:
            if i in name:
                return False
        return True

    # for i in dic_list:
    #     print i
    def guiyi(dic_list):
        #print check_node("0x804858b",dic_list)
        name = []
        for i in dic_list:
            if i["name"] not in name:
                name.append(i["name"])

        leaf=[]
        for i in dic_list:
            if(check_node(i["name"],dic_list)):
                leaf.append(i)
        # for i in leaf:
        #     print i
        # print "***********"
        #将叶子结点的分支节点合并
        for i in leaf:
            temp=[]
            temp.append(i["children"])
            for j in leaf:
                if(i!=j and i["name"]==j["name"]):
                    temp.append(j["children"])
                    leaf.remove(j)
            i["children"]=temp
            for k in dic_list:
                if k["name"]==i["name"]:
                    temp2=[]
                    for x in i['children']:
                        if type(x)==list:
                            temp2.append(x[0])
                        else:
                            temp2.append(x)
                    k["children"]=temp2

        #去重
        new_dic_list=[]
        for i in dic_list:
            if i not in new_dic_list:
                new_dic_list.append(i)

        for i in leaf:
            for j in new_dic_list:
                if j["children"]==i["name"]:
                    i["parent"] = j["name"]
                    if type(i)==list:
                        j["children"]=i
                    else:
                        temp=[]
                        temp.append(i)
                        j['children']=temp
                if(j==i and len(new_dic_list)!=1):
                    new_dic_list.remove(j)

        #检验格式
        return new_dic_list

    while(len(dic_list)!=1):
        res = guiyi(dic_list)
        dic_list = res

    if(len(dic_list)==1):
        res = str(dic_list)
        res = res.replace(" ","")
        # res = res.replace("\'children\':\'\',","")
        res = res.replace("\'\',","{name:\'none\'},")
        # res = res.replace("\'", "\"")
        print '----------------'
        print res
        return res


# deal2('source.txt')

