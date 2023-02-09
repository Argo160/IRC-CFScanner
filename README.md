فقط آی پی رنج 45 جهت جستجو برای ایرانسل.(موقت - تست)

ضمن تشکر از جناب باشسیز گرامی بابت این اسکریپت کارامد

1. clone

```shell
git clone https://github.com/Argo160/IRC-CFScanner.git
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
