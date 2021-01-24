#!/usr/bin/env bash

function run_onece_by_ps() {
    echo "run once by ps"
    local ps_ret=$(ps -ef | grep singleton.sh | grep -v grep -c)
    if [ "${ps_ret}" -ge 1 ]; then
        echo -e "singleton.sh already running, num: ${ps_ret}"
        # 输出进程数是2，因为在shell里没执行一个命令都会fork出一个子进程
        exit 1;
    fi
    while [ true ]; do
        echo "singleton.sh run..."
        sleep 1
    done
}

function run_once_by_flag() {
    LOCK_FILE=/var/lock/singleton.lock
    # 用于检测该进程是否存在，避免进程不在了，但是锁文件还在，导致后面的脚本无法运行
    if [ -e ${LOCK_FILE} ] && kill -0 $(cat ${LOCK_FILE}) ; then
        echo "$0 already running"
        exit 1;
    fi
    # 确保退出时，锁文件被删除
    trap "rm -f ${LOCK_FILE}; exit" INT TERM EXIT

    # 将当前进程id写入到锁文件
    echo "on begin $$, write pid to lock file"
    echo $$ > ${LOCK_FILE}

    echo "do something in $$ process"
    sleep 5

    # 程序退出时删除锁文件
    echo "on exit $$ delete lock file"
    rm -f ${LOCK_FILE}
}


function run_once_by_flock() {
    [ "${FLOCKER}" != "$0" ] && exec env FLOCKER="$0" flock -en "$0" "$0" "$@" ||:
    echo "do something..."
    sleep 10
}

function main() {
    # run_onece_by_ps
    # run_once_by_flag
    run_once_by_flock
}

main 
