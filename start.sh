#!/bin/bash

option=${1:---install}

log_dir="/etc/verlihub/logs"
log_tls="${log_dir}/tls.log"
log_hub="${log_dir}/hub.log"

if [ ${option} = "--install" ]
then
    echo ""
    echo "starting installation"
    sleep 5
    echo ""

    address_local=$(ifconfig lo | awk '/inet / {print $2}');
    address_public=$(ifconfig eth0 | awk '/inet / {print $2}');

    echo "Local Address: $address_local"
    echo "Public Address: $address_public"
    echo ""

    echo "checking log directory"
    if [ ! -d ${log_dir} ]; then
        echo "creating log directory"
        mkdir -p "${log_dir}"
    fi

    echo "checking tls log file"
    if [[ ! -e "${log_tls}" ]]; then
        echo "creating tls log file: ${log_tls}"
        touch "${log_tls}"
    fi

    echo "checking hub log file"
    if [[ ! -e "${log_hub}" ]]; then
        echo "creating hub log file: ${log_hub}"
        touch "${log_hub}"
    fi

    echo ""
    echo "Create SSH keys for TLS Proxy:"
    /usr/bin/openssl req -new -newkey rsa:4096 -x509 -sha256 -days 365 -nodes -out "/etc/verlihub/verlihub.crt" -keyout "/etc/verlihub/verlihub.key"
    echo ""

    echo "backing keys and logs:"
    mv -r "${log_dir}" "/tmp/vh"
    mv -r "/etc/verlihub/verlihub.crt" "/tmp/vh.crt"
    mv -r "/etc/verlihub/verlihub.key" "/tmp/vh.key"
    echo ""

    echo "Create New Hub:"
    /usr/local/bin/vh --install

    echo "restoring keys and logs:"
    mv -r "/tmp/vh" "${log_dir}"
    mv "/tmp/vh.crt" "/etc/verlihub/verlihub.crt"
    mv "/tmp/vh.key" "/etc/verlihub/verlihub.key"

    echo ""
    echo "Completed!"
    echo ""

elif [ ${option} = "--test" ]
then
    echo ""
    echo "performing tests"
    sleep 5
    echo ""

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
    echo ""
    echo "starting tls"
    sleep 5

    address_local=$(ifconfig lo | awk '/inet / {print $2}');
    address_public=$(ifconfig eth0 | awk '/inet / {print $2}');

    echo "checking log directory"
    if [ ! -d ${log_dir} ]; then
        echo "creating log directory"
        mkdir -p "${log_dir}"
    fi

    echo "checking tls log file"
    if [[ ! -e "${log_tls}" ]]; then
        echo "creating tls log file: ${log_tls}"
        touch "${log_tls}"
    fi

    echo "checking hub log file"
    if [[ ! -e "${log_hub}" ]]; then
        echo "creating hub log file: ${log_hub}"
        touch "${log_hub}"
    fi

    echo ""
    echo "Local Address: $address_local"
    echo "Public Address: $address_public"
    echo ""

    /usr/bin/nohup /usr/src/verlihub-proxy/proxy --cert="/etc/verlihub/verlihub.crt" --key="/etc/verlihub/verlihub.key" --host="${address_public}:4111" --hub="${address_local}:4111" &> "${log_tls}" &
    #/usr/bin/nohup /usr/src/verlihub-proxy/proxy --cert="/etc/verlihub/verlihub.crt" --key="/etc/verlihub/verlihub.key" --host="172.17.0.1:4111" --hub="${address_local}:4111" &> "${log_tls}" &

    echo ""
    echo "LOG TLS: ${log_tls}"
    echo ""
    echo "Completed!"
    echo ""

    echo "starting hub"
    sleep 5
    echo ""

    TERM=xterm
    #/usr/bin/nohup /usr/local/bin/vh_daemon /usr/local/bin/verlihub &> "${log_hub}"
    /usr/bin/nohup /usr/local/bin/vh --run /etc/verlihub &> "${log_hub}" &

    echo ""
    echo "LOG HUB: ${log_hub}"
    echo ""
    echo "Completed!"
    echo ""
fi
