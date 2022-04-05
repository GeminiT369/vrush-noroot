FROM ubuntu:latest
MAINTAINER geminit369

ENV LANG="C.UTF-8" \
	PORT=8080
	
RUN apt update &&\
    apt install ssh wget unzip screen gzip vim -y &&\
    mkdir -p /run/sshd /usr/share/caddy /etc/caddy /etc/xray /tmp &&\
    wget https://codeload.github.com/ripienaar/free-for-dev/zip/master -O /usr/share/caddy/index.html &&\
    unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ &&\
    mv /usr/share/caddy/*/* /usr/share/caddy/ &&\
    echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config &&\
    echo root:xwybest|chpasswd

ADD docker_run.sh .
ADD Caddyfile /tmp/Caddyfile
ADD config.json /tmp/config.json
ADD .cloudflared /etc/cloudflared

EXPOSE $PORT
CMD /usr/sbin/sshd -D & bash docker_run.sh
