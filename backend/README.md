# My Party - Backend Service ⚙️

[![Node.js](https://img.shields.io/badge/Environment-Node.js-green.svg)](https://nodejs.org/)
[![Express](https://img.shields.io/badge/Framework-Express-lightgray.svg)](https://expressjs.com/)
[![MySQL](https://img.shields.io/badge/Database-MySQL-blue.svg)](https://www.mysql.com/)

[English (🇬🇧)](#english) | [العربية (🇾🇪)](#arabic)

---

<a name="english"></a>
## 🇬🇧 English Documentation

Welcome to the **Backend Service** component of **My Party**. Developed with **Node.js** and **Express.js**, this robust backend powers the mobile application by handling API requests, secure authentication (JWT), media uploads, and instant **Socket.io** notifications.

### ✨ Key Features
- **RESTful Architecture**: Clean, modular API routes optimized for performance.
- **Socket.io Integration**: Complete real-time messaging pipeline for in-app client updates.
- **MySQL Connection**: Persistent and consistent relational database management.
- **Role-based Authentication**: Secured with JSON Web Tokens (JWT) and Bcrypt encryption.

### 🚀 Local Setup (Manual)
If you wish to work on the backend manually (without the Docker orchestrator):
1. Navigate to the backend directory and copy the exact `.env` configurations required.
2. Install necessary npm packages:
   ```bash
   npm install
   ```
3. Boot the environment in development mode:
   ```bash
   npm run dev
   ```

*(For automated Docker setup containing the MySQL database instantiation, refer to the root `README.md`)*

---

<a name="arabic"></a>
## 🇾🇪 القراءة باللغة العربية (Arabic Documentation)

مرحباً بك في خدمة الواجهة الخلفية (Backend) الخاصة بمنصة **My Party**. تم بناء هذا الخادم القوي ليعمل بواسطة **Node.js** وإطار عمل **Express.js**، حيث يتولى معالجة طلبات التطبيق (APIs)، المصادقة الآمنة (JWT)، حفظ المرفقات، والإشعارات الفورية عن طريق **Socket.io**.

### ✨ الميزات الرئيسية
- **بنية المنفذ البرمجي (RESTful)**: مسارات API نظيفة ومنظمة بشكل يضمن أفضل أداء.
- **تكامل Socket.io**: مسارات إشعارات لحظية وشبكة بث متكاملة لتحديثات البيانات الفورية.
- **قاعدة بيانات MySQL**: نظام قواعد بيانات علائقي قوي لحفظ واسترجاع البيانات بفعالية.
- **مصادقة آمنة باستخدام JWT**: توفير بيئة محمية مع تشفير كلمات المرور بصلاحيات مقسمة حسب أدوار المستخدمين.

### 🚀 طريقة الإعداد اليدوي
إذا أردت العمل على برمجة وإدارة الواجهة الخلفية يدوياً بدون بيئة حاويات الدوكر التشغيلية:
1. انتقل لمجلد الباك اند وقم بإعداد وتجهيز ملف الـ `.env` بناءً على إعداداتك المحلية.
2. قم بتحميل كافة الحزم المطلوبة:
   ```bash
   npm install
   ```
3. تشغيل الخادم في وضعية التطوير:
   ```bash
   npm run dev
   ```

*(للتعرف على طريقة التشغيل الآلية المعززة بـ Docker والتي تتضمن أيضاً تهيئة قاعدة بيانات الـ MySQL، يُرجى الرجوع لملف الـ `README.md` الرئيسي)*
