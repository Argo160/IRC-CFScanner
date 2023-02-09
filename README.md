فقط آی پی رنج 45 جهت جستجو برای ایرانسل.

ضمن تشکر از جناب باشسیز گرامی بابت این اسکریپت کارامد

1. دریافت اسکریپت

```shell
git clone https://github.com/Argo160/IRC-CFScanner.git
```

2. تغییر دایرکتوری و قابل اجرا کردن فایل ها

```shell
cd IRC-CFScanner/scripts
chmod +x v2ctl v2ctl-mac v2ray v2ray-mac
```

3. دریافت فایل کانفیگ وی تو ری

```shell
curl -s http://bot.sudoer.net/config.real -o ./config.real
```

4. اجرای برنامه

تعداد اجرای عملیات همزمان را مشخص کنید. بطور مثال در این کد 8 عملیات همزمان اجرا میشود

```shell
bash cfFindIP.sh 8 ./config.real
```

5. نتیجه:
یک فایل با اسم (تاریخ+زمان) در پوشه result ساخته خواهد شد
```shell
ls result/
```

## Video guide
A video guide usage can be found in [youtube](https://youtu.be/xzuMnxEw97U "youtube").
