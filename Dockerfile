FROM ubuntu:20.04
MAINTAINER Przemek Wiejak <przemek@wiejak.app>

ENV DEBIAN_FRONTEND noninteractive
ENV HOME /root

RUN apt-get update && apt-get dist-upgrade -yq && \
    apt-get install libpcre3-dev libssl-dev golang net-tools \
    	libmysqlclient-dev mysql-client g++ libmaxminddb-dev \
    	libmaxminddb0 libicu-dev gettext libasprintf-dev \
    	make cmake python2.7-dev liblua5.2-dev libperl-dev git -yq && \
    apt-get clean -y && \
    apt-get autoclean -y && \
    rm -fr /var/lib/apt && \
    git clone https://github.com/Verlihub/verlihub.git /usr/src/verlihub && \
    cd /usr/src/verlihub && \
    mkdir -p build && cd build && \
    cmake .. && make && make install && ldconfig && \
    git clone https://github.com/Verlihub/tls-proxy.git /usr/src/verlihub-proxy && \
    cd /usr/src/verlihub-proxy && \
    go build proxy.go

ADD start.sh /usr/local/bin/start.sh

RUN chmod +x /usr/local/bin/start.sh

EXPOSE 4111

ENTRYPOINT ["/usr/local/bin/start.sh"]

CMD ["--run"]
