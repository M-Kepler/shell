#!/bin/bash

#日志接口

set -e

module_name=$1
log_dir=$(pwd)

#限制日志为1K
log_file_maxsize=1000

# 获得文件大小
function filesize() {
    ls -alt ${1} | grep -v ^d | awk '{if ($9) printf("%s",$5)}'
}

function log()
{
    # 日志文件
    log_level=$1
    log_file=${log_dir}/${module_name}_${log_level}.log

    if [ -f ${log_file} ]; then
        fsize=$(filesize ${log_file})
        if [[ ${fsize} -gt ${log_file_maxsize} ]]; then
            if [ -f ${log_file}".bk1" ]; then
                # 只保留三个日志文件 info.log info.log.bk1 info.log.bk2
                mv ${log_file}".bk1" ${log_file}".bk2"
            fi
            mv ${log_file} ${log_file}".bk1"
        fi
    fi
    # 日志加上时间戳
    echo "["$(date)"] "$@ >> ${log_file}
}

function log_info()
{
    log_message=$1
    log info $log_message
}

function log_err()
{
    log_message=$1
    log err $log_message
}

function test()
{
    for((i=0; i<17 * 3 - 1; i++)); do
        log_info "test info level log $i"
        log_err "test error level log $i"
    done
}

test
