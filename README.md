![GitHub stars](https://img.shields.io/github/stars/voipiran/AsteriskGrafana?style=for-the-badge)
![GitHub last commit](https://img.shields.io/github/last-commit/voipiran/AsteriskGrafana?style=for-the-badge)
![License](https://img.shields.io/github/license/voipiran/AsteriskGrafana?style=for-the-badge)

# AsteriskGrafana

> **Modern Grafana Dashboards for Asterisk & Issabel**

Open Source project developed and maintained by **VoIPIran**

🌐 https://voipiran.io

---

## Overview

AsteriskGrafana provides ready-to-use Grafana dashboards for Asterisk-based PBX systems.

The installer automatically installs Grafana, configures the required data sources, imports dashboards and prepares everything for immediate use.

The project is actively maintained and continuously updated with new dashboards and monitoring features.

### Supported Platforms

- ✅ Issabel 5
- 🚧 FreePBX *(Coming Soon)*

---

## Current Dashboards

- 📊 Queue Analytics
- 📞 Asterisk CDR Reports
- 🖥️ Linux System Resources
- ⚡ Real-Time Live Monitoring

---

# 🚀 Quick Installation

Copy & Paste the following command into your **Issabel** server:

```bash
rm -rf AsteriskGrafana && \
git clone https://github.com/voipiran/AsteriskGrafana.git && \
cd AsteriskGrafana && \
chmod +x install.sh && \
./install.sh
```

After installation open:

```
http://SERVER_IP:3000
```

Default Login

```
Username : admin
Password : admin
```

---

# فارسی

## معرفی

**AsteriskGrafana** یک پروژه متن‌باز برای ارائه داشبوردهای حرفه‌ای Grafana روی سیستم‌های تلفنی مبتنی بر **Asterisk** است.

این پروژه توسط **VoIPIran** توسعه داده می‌شود و به صورت مداوم بروزرسانی خواهد شد.

هدف پروژه ارائه داشبوردهای کامل برای **مانیتورینگ، گزارش‌گیری و تحلیل سیستم‌های تلفنی** بدون نیاز به تنظیمات پیچیده Grafana است.

در حال حاضر پروژه از **Issabel 5** پشتیبانی می‌کند و نسخه **FreePBX** نیز به زودی منتشر خواهد شد.

---

## داشبوردهای فعلی

- 📊 گزارش Queue
- 📞 گزارش CDR
- 🖥️ مانیتورینگ منابع لینوکس
- ⚡ مانیتورینگ لحظه‌ای (Real-Time)

---

🌐 **Website**

https://voipiran.io

---

⭐ **If you like this project, don't forget to Star the repository!**
