#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import sys
import time
import hashlib
import json
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
    nodelink = {}
    for i in nodelist:
        if i.value=='REG_INI':
            i.value = 'Node0'
        nodelink[i.value.strip()]=i.string.strip()
    return nodelink


def deal(file):
    filename = file
    path= '.\\log\\data_log\\'
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
    # print "-------------------------"
    nodelink = showmethelist()
    # print "-------------------------"
    #print "ERRORLINE: \n", error_line
    nodes = {}
    #存储路径
    BASE_DIR = os.path.dirname(__file__)
    times = str(time.time())
    name = hashlib.md5(times).hexdigest()
    path = BASE_DIR+"//log//links_log//"+name    #存储路径
    # with open(path,"a") as ref:
    for node in nodelist:
        node.value=node.value.strip()
        nodes[node.name]=node.value  #建立nodes字典键值对（key为Node1形式，value为简化字符串
    #print nodes
    # nodes {'Node90': 'Add32(Node33,0x00000008)', 'Node9': 'LDle:I32(Node8)', 'Node8': 'Add32(Node7,0x00000014)', 'Node1': 'Add32(Node0,0x00000008)', 'Node0': 'REG_INI', 'Node3': 'Add32(Node0,0x00000004)', 'Node2': 'Add32(Node0,0x00000070)', 'Node5': 'Add32(Node2,0x00000008)', 'Node4': 'Add32(Node2,0x00000004)', 'Node7': 'LDle:I32(Node1)', 'Node6': 'LDle:I32(Node3)', 'Node11': '1Uto32(Node10)', 'Node10': 'CmpEQ32(Node9,0x00000000)', 'Node13': 'LDle:I32(Node4)', 'Node12': 'LDle:I32(Node5)', 'Node15': 'CmpLE32S(Node14,0x00000012)', 'Node14': 'Sub32(Node12,Node13)', 'Node17': '32to1(Node16)', 'Node16': '1Uto32(Node15)', 'Node19': 'LDle:I8(Node18)', 'Node18': 'Add32(Node13,0x00000010)', 'Node28': 'Add32(Node13,0x00000012)', 'Node29': 'LDle:I8(Node28)', 'Node24': '8Uto32(Node19)', 'Node25': 'Shl32(Node24,0x08)', 'Node26': 'Or32(Node25,Node23)', 'Node27': 'Sub32(Node26,0x00000013)', 'Node20': 'Add32(Node13,0x00000011)', 'Node21': 'LDle:I8(Node20)', 'Node22': '8Uto32(Node21)', 'Node23': '8Uto32(Node21)', 'Node39': 'LDle:I32(Node38)', 'Node38': 'Add32(Node37,0x08c9b2c0)', 'Node33': '8Uto32(Node29)', 'Node32': 'LDle:I32(Node31)', 'Node31': 'Add32(Node6,0x00000024)', 'Node30': '8Uto32(Node29)', 'Node37': 'Shl32(Node33,0x03)', 'Node36': 'CmpLE32U(Node13,Node12)', 'Node35': '1Uto32(Node34)', 'Node34': 'CmpEQ32(Node33,0x00000005)', 'Node48': 'And32(Node47,0x20000000)', 'Node49': 'And32(Node45,0x000000fe)', 'Node46': 'Add32(Node32,0x0000000c)', 'Node47': 'LDle:I32(Node46)', 'Node44': 'Add32(Node32,0x00000008)', 'Node45': 'LDle:I32(Node44)', 'Node42': 'CmpEQ32(Node32,0x00000000)', 'Node43': '1Uto32(Node42)', 'Node40': 'Add32(Node37,0x08c9b2c4)', 'Node41': 'LDle:I32(Node40)', 'Node59': 'Add32(Node58,Node9)', 'Node58': 'LDle:I32(Node57)', 'Node55': 'Add32(Node32,0x00000018)', 'Node54': 'LDleI0x00000080(Node53)', 'Node57': '0x00000000', 'Node56': 'LDle:I32(Node55)', 'Node51': 'And32(Node41,Node48)', 'Node50': 'And32(Node39,Node49)', 'Node53': 'A0d', 'Node52': 'Or32(Node51,Node50)', 'Node68': 'Add32(Node66,0x00000020)', 'Node69': 'Add32(Node66,0x0000001c)', 'Node60': 'And32(Node45,Node47)', 'Node61': 'CmpEQ32(Node60,0xffffffff)', 'Node62': '1Uto32(Node61)', 'Node63': '32to1(Node62)', 'Node64': 'Add32(Node56,0x00000008)', 'Node65': 'LDle:I32(Node64)', 'Node66': 'CmpEQ32(Node33,Node57)', 'Node67': '1Uto32(Node66)', 'Node88': 'CmpEQ32(Node33,0x0833d33Node57)', 'Node89': 'Add32(Node88,0x0000001c)', 'Node82': 'Add32(Node66,0x00000018)', 'Node83': 'Add32(Node66,0x00000014)', 'Node80': '1Uto32(Node66)', 'Node81': 'Sub32(Node66,0x00000004)', 'Node86': 'Add32(Node66,0x00000008)', 'Node87': 'Add32(Node66,0x00000004)', 'Node84': 'Add32(Node66,0x00000010)', 'Node85': 'Add32(Node66,0x0000000c)', 'Node77': '8stmt_typeUto32(Node29)', 'Node76': '8Uto32(Node75)', 'Node75': 'LDle:I8(Node74)', 'Node74': 'Add32(Node72,0x00000011)', 'Node73': 'to32(Node19)', 'Node72': 'LDleI32(Node4)', 'Node71': '8Uto32(Node70)', 'Node70': 'LD24leI8(Node20)', 'Node79': 'Add32(Node78,0x0000001c)', 'Node78': 'CmpEQ32(Node77,Node57)'}
    #转成需要格式

    #下面的是将nodes字典按要求格式重写到文件
    count = 1
    for i in range(len(nodes)):
        if i!=0:
            Node = nodes["Node"+str(i)]  #根据索引取值
            pattern1 = '\(\w+,\w+\)|\(\w+\)'  #取出括号里子节点
            Son_node = re.findall(pattern1, Node, flags=0)
            if Son_node:
                pattern2 = "\(|,|\)" #取出括号里子节点
                Son_node = re.split(pattern2,Son_node[0],flags=0)
                Son_node = [x for x in Son_node if x != '']  #子节点已取出
                for j in range(len(Son_node)): #判断类型
                    if Son_node[j][0:2]=="0x":
                        Son_node[j] = str(count) + '.'+ Son_node[j]
                        count=count+1
                    if Son_node[j][0:4]=='Node':
                        Son_node[j] = nodes[Son_node[j]]
                    with open(path, 'a') as f:
                        f.write("{source:'"+Son_node[j]+"',target:'"+Node+"',type:'resolved',rela:''},\n")
    temp=[]
    with open(path, 'r') as ff:
        text = ff.read()
    temp.append(name)
    temp.append(nodelink)
    temp.append(text)
    return temp



