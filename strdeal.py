#!/usr/bin/python
# -*- coding: UTF-8 -*-
import re
import os
import time
import hashlib

nodelist = []
first_list = []


global count
count = 0
global f_list
f_list = []

def deal(file):
    filename = file
    path= '.\\log\\source_data\\'
    with open(path+filename, 'r') as f:
        data = f.read()

    #提取所有数据流（跳转条件）形成列表
    first_list=re.findall(r"\['.*']", data)
    list_data = []
    for i in first_list:
        temp = i.replace(' ','').strip("[|]|'").replace("==False","").replace("==True","").split("\',\'")
        list_data.append(temp[3])

    #去掉重复数据流
    first_list=[]
    for i in list_data:
        if i not in first_list:
            first_list.append(i)

    BASE_DIR = os.path.dirname(__file__)
    times = str(time.time())
    name = hashlib.md5(times).hexdigest()
    path = BASE_DIR + "//log//links_log//" + name  # 存储路径

    Alllinks = []
    re1 = '([0-9A-Za-z_:]+)' #匹配最深括号里的值 0x0804a040
    re2 = '\([0-9A-Za-z_:,]+\)' #匹配最深括号 (0x0804a040)
    re3 = '[0-9A-Za-z:]+\([0-9A-Za-z_:,]+\)' #匹配最深括号加父节点 LDle:I32(0x0804a040)
    re4 = '[0-9A-Za-z_:]+'

    def check(strf):
        all_f = {}
        all_f_l = []
        f = re.findall(re4,strf,flags=0)
        for i in range(len(f))[::-1]:
            if f[i][0:2]!='0x':
                temp = f[i]
                while(f[i] in all_f_l):
                    f[i]=f[i]+'+'
                all_f_l.append(f[i])
                all_f[f[i]]=temp
        print all_f
        print all_f_l
        for i in range(len(all_f_l))[::-1]:
            re_str = all_f_l[i]
            strinfo = re.compile(re_str)
            strf = re.sub(strinfo,all_f_l[i]+'(', strf, 1)
            print strf
    # check('LDle:I32(Add32(Shl32(Add32(Add32(REG_INI_24, 0x0000006c), 0xe54f6e74), 0x02), 0x00402c20)) == 0x4028b8')

    def FindNodeLink(strf,source):
        dads = re.findall(re3,strf,flags=0) # [‘LDle:I32(0x0804a040)’]
        global count

        for h in dads:
            sons = re.findall(re2,h,flags=0) # ['(0x0804a040)']
            if len(sons)==1:
                sons=sons[0] #(0x0804a040)
            dad = h.replace(sons,'') #LDle:I32
            son = re.findall(re1,sons,flags=0)
            for k in son:
                if k[0:2]=='0x':
                    k = str(count)+'.'+str(k)
                    count=count+1
                # else:
                #     if k not in f_list:
                #         f_list.append(k)
                #     else:
                #         k = str(k)+'+'
                #         if k not in f_list:
                #             f_list.append(k)
                #         else:
                #             k = str(k) + '+'
                with open(path, 'a') as f:
                    f.write("{source:'"+k+"',target:'"+str(dad)+"',type:'resolved',rela:'"+source+"'},\n")
                    #print("{source:'"+k+"',target:'"+str(dad)+"',type:'resolved',rela:'"+source+"'},\n")
                result = "{source:'"+k+"',target:'"+str(dad)+"',type:'resolved',rela:'"+source+"'},"
                if result not in Alllinks:
                    Alllinks.append(result)
                    # print result

            strf = strf.replace(sons,'')
        if re.findall(re2,strf,flags=0):
            FindNodeLink(strf,source)

    for i in first_list:
        FindNodeLink(i,i)

    temp = []
    with open(path, 'r') as ff:
        text = ff.read()
    temp.append(name)
    temp.append(text)

    return temp

#deal('malware1_result.txt')