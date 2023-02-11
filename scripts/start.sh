clear
cd Solo-CFScanner/scripts
chmod +x v2ctl v2ctl-mac v2ray v2ray-mac
sleep 2
clear
curl -s http://bot.sudoer.net/config.real -o ./config.real
sleep 10
bash cfFindIP.sh ./config.real
