#!/bin/bash

option=${1:---install}

if [ ${option} = "--install" ]
then
    /usr/bin/openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out "/etc/verlihub/verlihub.crt" -keyout "/etc/verlihub/verlihub.key"
    /usr/local/bin/vh --install

elif [ ${option} = "--test" ]
then
    echo "Information of your container's network interfaces:"
    ifconfig

    echo "Test mysql connection:"
    read -p "enter mysql host: " mysqlHost
    read -p "enter mysql user: " mysqlUser
    read -s -p "enter mysql password: " mysqlPassword

    if mysql -u$mysqlUser -p$mysqlPassword -h$mysqlHost -e ';'
    then
        echo 'ok'
    else
        echo "not ok"
    fi

elif [ ${option} = "--run" ]
then
    echo sleep 10 seconds
    sleep 10
    /usr/src/verlihub-proxy/proxy --cert="/etc/verlihub/verlihub.crt" --key="/etc/verlihub/verlihub.key" --host="172.17.0.3:4111" --hub="127.0.0.1:4111"

    echo sleep 10 seconds
    sleep 10
    TERM=xterm

    /usr/local/bin/vh_daemon /usr/local/bin/verlihub
fi
