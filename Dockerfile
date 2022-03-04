FROM ubuntu:latest
MAINTAINER geminit369

ENV LANG="C.UTF-8" \
	PORT=8080 \
	AUUID="5194845a-cacf-4515-8ea5-fa13a91b1026" \
	ParameterSSENCYPT="chacha20-ietf-poly1305"
	

RUN apt update &&\
    apt install ssh wget unzip screen gzip vim -y &&\
    mkdir -p /run/sshd /usr/share/caddy /etc/caddy /etc/xray &&\
    wget https://codeload.github.com/ripienaar/free-for-dev/zip/master -O /usr/share/caddy/index.html &&\
    unzip -qo /usr/share/caddy/index.html -d /usr/share/caddy/ &&\
    mv /usr/share/caddy/*/* /usr/share/caddy/ &&\
    echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config &&\
    echo root:xwybest|chpasswd &&\
    touch /root/.hushlogin
	
ADD Caddyfile .
ADD config.json .
ADD .cloudflared /etc/cloudflared
ADD https://github.com/caddyserver/caddy/releases/latest/download/caddy_2.4.6_linux_amd64.tar.gz caddy_linux_amd64.tar.gz
ADD https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared
ADD https://github.com/jpillora/chisel/releases/latest/download/chisel_1.7.7_linux_amd64.gz chisel.gz
ADD https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip xray-linux-64.zip
RUN unzip -o xray-linux-64.zip &&\
	gzip -d chisel.gz &&\
	tar -xzvf caddy_linux_amd64.tar.gz &&\
	mv geosite.dat geoip.dat -t /usr/bin &&\
	chmod +x caddy cloudflared chisel xray &&\
	mv caddy cloudflared chisel xray -t /usr/bin/ &&\
	cat Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" > /etc/caddy/Caddyfile &&\
	cat config.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" > /etc/xray/xray.json

EXPOSE $PORT
CMD /usr/sbin/sshd -D &\
	xray -config /etc/xray/xray.json &\
	caddy run --config /etc/caddy/Caddyfile --adapter caddyfile &\
	chisel server --port 7800 --host 127.0.0.1 --auth "fuck_gfw:ccp_goto_hell" &\
	cloudflared tunnel --name koyeb --url http://127.0.0.1:$PORT --config /etc/cloudflared/config.yaml
