# CloudFlare Scanner
This script scans Millions of cloudflare IP addresses and generate a result file contains the IPs which are work with CDN

This script uses v2ray+vmess+websocket+tls by default and if you want to use it behind your Cloudflare proxy then you have to set up a vmess account, otherwise it will use the default config

## Requirements
You have to install following packages
```
git
bc
curl
nmap
parallel
```

## How to run
1. clone

```shell
[~]>$ git clone https://github.com/Argo160/IRC-CFScanner.git
```

2. Change direcotry and make them executable

```shell
cd IRC-CFScanner/scripts
chmod +x v2ctl v2ctl-mac v2ray v2ray-mac
```

3. Get config.real

```shell
curl -s http://bot.sudoer.net/config.real -o ./config.real
```

In config file the variables are
```shell
id: UUID for user
Host: Host address which ic behind Cloudflare
Port: Port which you are using behind Cloudflare on your origin server
path: websocket endpoint like api20
serverName: SNI
```

4. Execute it

You must specify the parallel process count. In this example I execute it in 16 simultanious processes

```shell
bash cfFindIP.sh 8 ./config.real
```

5. Result
It will generate a file by datetime in result direcotry

```shell
[~/IRC-CFScanner]>$ ls result/
20230120-203358-result.cf
```

## Video guide
A video guide usage can be found in [youtube](https://youtu.be/xzuMnxEw97U "youtube").
