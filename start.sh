#!/bin/bash

option=${1:---install}

if [ ${option} = "--install" ]
then
    echo ""

    address_local=$(ifconfig lo | awk '/inet / {print $2}');
    address_public=$(ifconfig ens160 | awk '/inet / {print $2}');

    echo "Local Address: $address_local"
    echo "Public Address: $address_public"
    echo ""

    echo "Create SSH keys for TLS Proxy:"
    /usr/bin/openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out "/etc/verlihub/verlihub.crt" -keyout "/etc/verlihub/verlihub.key"
    echo ""

    echo "Create New Hub:"
    /usr/local/bin/vh --install

    echo ""
    echo "Completed!"
    echo ""

elif [ ${option} = "--test" ]
then
    echo "Information of your container's network interfaces:"
    ifconfig
    echo ""

    echo "Information in: /etc/hosts"
    cat /etc/hosts
    echo ""

    echo "Test mysql connection:"
    read -p "enter mysql host: " mysqlHost
    read -p "enter mysql user: " mysqlUser
    read -s -p "enter mysql password: " mysqlPassword
    echo ""

    if mysql -u$mysqlUser -p$mysqlPassword -h$mysqlHost -e ';'
    then
        echo 'database connection successful :)'
    else
        echo 'database connection unsuccessful :('
    fi

    echo ""
    echo "Completed!"
    echo ""

elif [ ${option} = "--run" ]
then
    address_local=$(ifconfig lo | awk '/inet / {print $2}');
    address_public=$(ifconfig ens160 | awk '/inet / {print $2}');

    echo "Local Address: $address_local"
    echo "Public Address: $address_public"
    echo ""

    echo sleep 10 seconds
    sleep 10
    /usr/src/verlihub-proxy/proxy --cert="/etc/verlihub/verlihub.crt" --key="/etc/verlihub/verlihub.key" --host="${address_public}:4111" --hub="${address_local}:4111"
    echo ""

    echo sleep 10 seconds
    sleep 10
    echo ""

    TERM=xterm
    /usr/local/bin/vh_daemon /usr/local/bin/verlihub

    echo "Completed!"
    echo ""
fi
