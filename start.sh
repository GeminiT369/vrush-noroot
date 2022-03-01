# start service
./xray -config xray.json &
./caddy run --config etc/caddy/Caddyfile --adapter caddyfile &
./chisel server --port 7800 --host 127.0.0.1 --auth "fuck_gfw:ccp_goto_hell" &
./cloudflared tunnel --name koyeb --url http://localhost:$PORT --config ./.cloudflared/config.yaml &
./socat TCP-LISTEN:7802,reuseaddr,fork exec:'bash -li',stderr,pty,setsid,sigint,sane