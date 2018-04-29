#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import sys
import time
import hashlib
nodelist = []
first_list = []
result_list = []
global errortime
errortime = 0

class Unit_node:

    node_number = 0
    def __init__(self):
        self.name = '0'
        self.value = '0'
        self.string = '0'

    def getname(self):
        self.name = 'Node'+str(Unit_node.node_number)
        #print self.name
        Unit_node.node_number+=1
        return self.name

    def getvalue(self, string):
        str = string
        #print "str_begin: ", str
        if not nodelist:
            return 'REG_INI'
        if str == '0':
            print "这些字符串中包含错误字符串"
            sys.exit(0)
        for i in nodelist:
            if string.find(i.string):
                str = str.replace(i.string, i.name)
        self.value = str
        return str

    def getstring(self, string):
        while True:
            pattern = 'Node\w+'
            getlist = re.findall(pattern, string, flags=0)
            if not getlist:
                break
            for i in getlist:
                for node in nodelist:
                    if node.name == i:
                        string = string.replace(i, node.string)
        self.string = string
        return self.string



    def createnode(self, string):  #创建节点的时候要首先判断节点的合法性，错误的结点会导致数据处理的错误
        for i in nodelist:
            if string == i.string:
                return
        #print 'string: ', string
        newnode = Unit_node()
        newnode.name = str(newnode.getname())
        #print 'newnode.name: ', newnode.name
        newnode.string = newnode.getstring(string)
        #print 'newnode.string: ', newnode.string
        newnode.value = newnode.getvalue(string)
        nodelist.append(newnode)


def isexist(string):
    if not nodelist:
        return 0
    for i in nodelist:
        if i.string == string or i.value == string:
            return 1
    return 0

def finishcut(string):
    if string[0:4] == 'Node':
        return 1
    pattern = '\w+\(\w+,\w+\)'
    pattern0 = '[(,]\w+\(\w+\)'    #内部单因子类型
    pattern00 = '\w+\:\w+\(\w+\)'     #LDle:I32(0x00000004)
    pattern000 = '\w+\(\w+\)'
    get_struct = re.findall(pattern, string,flags=0)   #双因子
    get_struct0 = re.findall(pattern0, string, flags=0)   #单因子
    get_struct00 = re.findall(pattern00, string, flags=0)  #带冒号单因子
    get_struct000 = re.findall(pattern000, string, flags=0)
    if get_struct:
        if len(get_struct[0]) == len(string):
            return 1
    elif get_struct0:
        if len(get_struct0[0]) == len(string):
            return 1
    elif get_struct00:
        if len(get_struct00[0]) == len(string):
            return 1
    elif get_struct000:
        #print len(get_struct000[0]), len(string)
        if get_struct000[0] == string[0:len(string)-1]:
            return 1
    else:
        return 0





def finishcutstring(string):
    #把字符串中所有的可替换的全部换掉
    str = string
    for i in nodelist:
        str = str.replace('REG_INI', 'Node0')
        str = str.replace(i.value, i.name)
    return str


def get_unit(string):    #被调用一次添加一个节点到nodelist
    #print string
    global errortime
    errortime += 1
    if errortime == 100:
        return "Error"
    pattern = '\w+\(\w+,\w+\)'     #(Add32(REG_INI,0x00000070) 
    pattern0 = '[(,]\w+\(\w+\)'
    pattern00 = '\w+\:\w+\(\w+\)'     #LDle:I32(0x00000004)
    get_struct = re.findall(pattern, string, flags=0)   #双因子
    get_struct0 = re.findall(pattern0, string, flags=0)   #单因子
    get_struct00 = re.findall(pattern00, string, flags=0)  #带冒号单因子
    #print 'get_struct: ', get_struct
    #print 'get_struct0: ', get_struct0
    #print 'get_struct00: ', get_struct00
    if get_struct:
        get_struct = list(set(get_struct))    #去重复元素
        #print 'get_struct: ', get_struct
        for i in get_struct:
            newnodei = Unit_node()

            #print 'i_get_struct: ', i
            if isexist(i):
                continue
            pattern1 = '\(\w+,'  #前因子
            unit1 = re.findall(pattern1, i, flags=0)
            unit1 = unit1[0][1:-1]
            if unit1[0:2]!="0x":
                if unit1[0:4] != 'Node':
                    newnode = Unit_node()
                    newnode.createnode(unit1)
                #print 'unit1: ', unit1

            pattern2 = ',\w+\)'  #后因子
            unit2 = re.findall(pattern2, i, flags=0)
            unit2 = unit2[0][1:-1]            
            if unit2[0:2]!="0x":
                if unit2[0:4] != 'Node':
                    newnode = Unit_node()
                    newnode.createnode(unit2)
        
            if not isexist(i):
                newnodei.createnode(i)

        string = finishcutstring(string)
    #返回单次发现存在的单元
    get_struct0+=get_struct00
    get_struct0 = list(set(get_struct0))  #去重复元素
    if get_struct0:
        for str in get_struct0:
            #print 'str： ', str
            #处理单因子情况
            newnodestr = Unit_node()
            if isexist(str):
                continue
            pattern3 = '\(\w+\)'
            unit3 = re.findall(pattern3, str, flags=0)
            unit3 = unit3[0][1:-1]
            if unit3[0:4]!='Node':
                newnode = Unit_node()
                newnode.createnode(unit3)
            if str[0]=='(' or str[0]==',':
                str = str[1:]
            if not isexist(str):
                if str[0:4]!='Node':
                    newnodestr.createnode(str)
        string = finishcutstring(string)
    return string
    

def cut_repeat(eachline):
    #print "cut_repeat: ", eachline
    string = eachline
    if not nodelist:   #如果为空
        pass
    errorline = 0
    while True:
        errorline += 1
        if errorline ==100:
            return "Error"
        if finishcut(string):
            if not isexist(string) :
                if string[0:4] != 'Node':
                    new = Unit_node()
                    new.createnode(string)                
            break
        global errortime
        errortime = 0
        string = get_unit(string)
        if string == "Error":
            return "Error"
        #print "string : ", string
        
    finishtocut = string       #再此处之前加上对最后字符串的确定，不存在则添加
    return finishtocut

def showmethelist():
    for i in nodelist:
        print i.name, "：", i.value#, '\t', i.string
        

def deal(file):
    filename = file
    path= '.\\upload\\'
    with open(path+filename, 'r') as f:
        for eachline in f:
            first_list.append(eachline)
    #print first_list

    error_line = []
    for eachline in first_list:
        #print 'eachine: ', eachline
        result_line = cut_repeat(eachline)
        if result_line == "Error":    #错误判断，当100次以内为处理完成单行，返回Error
            error_line.append(eachline)
        else:
            result_list.append(result_line)

    pass 
    print "-------------------------"
    showmethelist()
    print "-------------------------"
    print "ERRORLINE: \n", error_line
    BASE_DIR = os.path.dirname(__file__)
    times = str(time.time())
    name = hashlib.md5(times).hexdigest()
    with open(BASE_DIR+"//result//"+name,"a") as ref:
        for node in nodelist:
            node.value=node.value.strip()
            ref.write(node.name+':'+node.value+'\n')
    return nodelist