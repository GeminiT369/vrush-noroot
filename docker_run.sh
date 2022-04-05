#!/bin/bash
# config
AUUID=${AUUID:-5194845a-cacf-4515-8ea5-fa13a91b1026}
ParameterSSENCYPT=${ParameterSSENCYPT:-chacha20-ietf-poly1305}
# download execuable
wget "https://caddyserver.com/api/download?os=linux&arch=amd64" -O caddy
wget "https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip" -O xray-linux-64.zip
wget "https://github.com/jpillora/chisel/releases/latest/download/chisel_1.7.7_linux_amd64.gz" -O chisel.gz
wget "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64" -O cloudflared
# unzip
gzip -d chisel.gz
unzip -o xray-linux-64.zip
# add to path
mv geosite.dat geoip.dat -t /usr/bin
chmod +x caddy cloudflared chisel xray
mv caddy cloudflared chisel xray -t /usr/bin/
# generate config
cat /tmp/Caddyfile | sed -e "1c :$PORT" -e "s/\$AUUID/$AUUID/g" -e "s/\$MYUUID-HASH/$(caddy hash-password --plaintext $AUUID)/g" > /etc/caddy/Caddyfile &&\
cat /tmp/config.json | sed -e "s/\$AUUID/$AUUID/g" -e "s/\$ParameterSSENCYPT/$ParameterSSENCYPT/g" > /etc/xray/xray.json

# start
xray -config /etc/xray/xray.json
caddy run --config /etc/caddy/Caddyfile --adapter caddyfile
chisel server --port 7800 --host 127.0.0.1 --auth "fuck_gfw:ccp_goto_hell"
cloudflared tunnel --name koyeb --url http://127.0.0.1:$PORT --config /etc/cloudflared/config.yaml
