#!/bin/bash

# 处理 INI 文件

set -e

function rwini() {
    # ini 文件路径
    ini_path=$1
    # ini 配置节点
    session=$2
    # ini 配置键值
    key=$3
    value=$4
    #检查${key}是否存在
    awk "/\[${session}\]/{a=1}a==1" ${ini_path} | sed -e '1d' -e '/^$/d' -e 's/[ \t]*$//g' -e 's/^[ \t]*//g' -e '/\[/,$d' | grep "${key}.\?=" >/dev/null
    if [ "$?" = "0" ]; then
        #更新, 找到指定section行号码
        sectionNum=$(sed -n -e "/\[${session}\]/=" ${ini_path})
        sed -i "${sectionNum},/^\[.*\]/s/\(${key}.\?=\).*/\1 ${value}/g" ${ini_path}
    else
        #新增，找到指定section，在下一行新增
        sed -i "/^\[${session}\]/a\\${key} = ${value}" ${ini_path}
    fi
}

function test()
{
    ini_path=~/test.ini
    touch $ini_path
    sec_name="test"
    echo "[test]
a = 111 
b = 222" > $ini_path

    # 修改配置
    rwini $ini_path $sec_name a 111a
    echo "after modify $ini_path"
    cat $ini_path

    # 新增配置
    rwini $ini_path $sec_name c 333
}

test
