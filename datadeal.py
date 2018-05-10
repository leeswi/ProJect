# -*- coding: utf-8 -*-

import re

data_list = []


def deal2(file):
    filename = file
    with open(".\\" + filename, "r") as f:
        data = f.read()

    datalist = re.findall(r"\['.*']", data)
    datalist.reverse()
    for i in range(len(datalist)):
        strf = datalist[i][1:-1].replace(" ", "").split("\',\'")
        for i in range(len(strf)):
            strf[i] = strf[i].replace("\'", "")
        data_list.append(strf)
    #print data_list

    # 合并相关字符串
    for i in range(len(data_list)):
        if (i > 0 and data_list[i][0] == "" and data_list[i - 1][2] == ""):
            data_list[i][0] = data_list[i - 1][0]
            data_list[i - 1][2] = data_list[i][2]
    # 去重
    new_list = []
    for i in range(len(data_list)):
        if data_list[i] not in new_list:
            new_list.append(data_list[i])
    print new_list

    Allnodes = []
    for i in range(len(new_list)):
        Allnodes.append(new_list[i][0])
        Allnodes.append(new_list[i][1])
    print Allnodes

    nodes = []

    # 校验
    for i in range(len(Allnodes)):
        # print new_list[i]
        node = {}
        node["name"] = Allnodes[i]
        if (i == 0):
            node["parent"] = "null"
        else:
            node["parent"] = Allnodes[i - 1]
        if (i < len(Allnodes) - 1):
            node["children"] = Allnodes[i + 1]
        else:
            node["children"] = "null"
        # if(i%2==0 and i!=0):
        #     node["order"] = new_list[i%2-1][3]

        nodes.append(node)
    print nodes
    for i in range(len(new_list)):
        for j in range(len(nodes)):
            if(new_list[i][2]==nodes[j]['name']):
                nodes[j]['order']=new_list[i][3]
                break
    print nodes
    # for i in range(len(nodes)):
    #     print nodes[i]
    temp = ["null"]
    for i in range(len(nodes)):
        if (nodes[len(nodes) - i - 1]["children"] != "null"):
            nodes[len(nodes) - i - 1]["children"] =  nodes[len(nodes) - i]
        else:
            nodes[len(nodes)-i-1].pop("children")

            #print nodes[len(nodes) - i - 1]["children"]
    res = str(nodes[0])
    res = res.replace("{","[{")
    res = res.replace("}", "}]")
    print res
    with open('out.txt','w') as f:
        f.write(res)
    return res


deal2("deal.txt")