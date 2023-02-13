# CloudFlare IP Scanner (Ping test + Download Speed Test)

جستجوی یک رنج آی پی خاص، جهت سهولت و تسریع عملیات.

ضمن تشکر از جناب باشسیز گرامی بابت این اسکریپت کارامد

1. دریافت اسکریپت

```shell
git clone https://github.com/Argo160/Solo-CFScanner.git
```

2. تغییر دایرکتوری و قابل اجرا کردن فایل ها

```shell
cd Solo-CFScanner/scripts
chmod +x v2ctl v2ctl-mac v2ray v2ray-mac
```

3. دریافت فایل کانفیگ وی تو ری

```shell
curl -s http://bot.sudoer.net/config.real -o ./config.real
```

4. اجرای برنامه(تعداد عملیات همزمان و همچنین سرعت دانلود را انتخاب کنید)
مقادیر قابل استفاده برای گزینه [speed] عبارتند از: (25 50 100 150 200 250 500)
مقادیر قابل استفاده برای [threads] عبارتند از: 8و16و32و...
```shell
bash cfFindIP.sh [threads] ./config.real [speed]
```
بطور مثال در این کد، 8 عملیات همزمان اجرا میشود و آی‌پی‌هایی با قابلیت سرعت 100kb سنجیده و انتخاب میشوند.

```shell
bash cfFindIP.sh 8 ./config.real 100
```

5. رنج آی پی مورد نظر خود را وارد کنید

رنج آی پی های موجود برای کلادفلر عبارتند از: 
```shell
5,23,31,38,45,64,65,66,72,80,89,91,93,95,103,104,108,123,141,146,147,154,156,159,160,162,168,170,172,174,176,185,188,191,192,193,194,195,196,199,202,203,204,205,206,207,208,212,216
```

6. نتیجه:
یک فایل با اسم (تاریخ+زمان) در پوشه result که در زیر مجموعه پوشه Solo-CFScanner واقع است، ساخته خواهد شد.
```shell
cd ..
cd result
ls
```


## Video guide
A video guide usage can be found in [youtube](https://youtu.be/xzuMnxEw97U "youtube").
