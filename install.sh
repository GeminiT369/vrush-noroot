#!/bin/bash
# set val
PORT=${PORT:-8080}
AUUID=${AUUID:-5194845a-cacf-4515-8ea5-fa13a91b1026}
ParameterSSENCYPT=${ParameterSSENCYPT:-chacha20-ietf-poly1305}
CADDYIndexPage=${CADDYIndexPage:-https://codeload.github.com/ripienaar/free-for-dev/zip/master}

# download execution
wget "https://caddyserver.com/api/download?os=linux&arch=amd64" -O caddy
wget "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" -O xray-linux-64.zip
wget "https://github.com/GeminiT369/vps/raw/main/socat" -O socat
wget "https://github.com/jpillora/chisel/releases/latest/download/chisel_1.7.7_linux_amd64.gz" -O chisel.gz
wget https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 cloudflared -O cloudflared
unzip -o xray-linux-64.zip && rm -rf xray-linux-64.zip && gzip -d chisel.gz
chmod +x caddy xray socat chisel cloudflared

# set caddy
mkdir -p etc/caddy/ usr/share/caddy
echo -e "User-agent: *\nDisallow: /" > usr/share/caddy/robots.txt
wget $CADDYIndexPage -O usr/share/caddy/index.html && unzip -qo usr/share/caddy/index.html -d usr/share/caddy/ && mv usr/share/caddy/*/* usr/share/caddy/


# set config file
cat ./Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(./caddy hash-password --plaintext $AUUID)/g" > etc/caddy/Caddyfile
cat ./config.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" > xray.json

# set remote access
#mkdir -p /run/sshd
#echo 'PermitRootLogin yes' >>  /etc/ssh/sshd_config
#echo root:xwybest|chpasswd
#/usr/sbin/sshd -D
