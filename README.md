# My Party 🎉

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Flutter](https://img.shields.io/badge/Frontend-Flutter-blue.svg)](https://flutter.dev/)
[![Node.js](https://img.shields.io/badge/Backend-Node.js-green.svg)](https://nodejs.org/)
[![Docker](https://img.shields.io/badge/Docker-Supported-blue.svg)](https://www.docker.com/)

[English (🇬🇧)](#english) | [العربية (🇾🇪)](#arabic)

---

<a name="english"></a>
## 🇬🇧 English Documentation

Welcome to **My Party**, a comprehensive and modern platform designed to revolutionize event and party management. This application provides powerful tools for planning events, managing suppliers, handling client requests, and much more, complete with real-time notifications.

### 📑 Table of Contents
1. [About the Project](#about-the-project)
2. [Architecture & Tech Stack](#architecture--tech-stack)
3. [Key Features](#key-features)
4. [Prerequisites](#prerequisites)
5. [Installation & Deployment](#installation--deployment)
   - [Method 1: Docker Compose (Recommended)](#method-1-docker-compose-recommended)
   - [Method 2: Manual Setup (For Developers)](#method-2-manual-setup-for-developers)
6. [Project Structure](#project-structure)
7. [Contributing & License](#contributing--license)

---

### � About the Project
**My Party** is built as a complete solution for event managers, bringing together the planning, financial tracking, supplier management, and real-time synchronization into one unified platform.

---

### �🏗️ Architecture & Tech Stack
This repository is an organized monorepo containing both the mobile application and the backend service:
- **Frontend (`/frontend`)**: Built with [Flutter](https://flutter.dev/), offering a beautiful, responsive, and cross-platform mobile experience (Android & iOS).
- **Backend (`/backend`)**: Developed using **Node.js** and **Express.js**, featuring robust REST APIs, **Socket.io** for real-time notifications, and **JWT** for secure authentication. It utilizes **MySQL** as its primary database.
- **Deployment**: Fully containerized with **Docker** and **Docker Compose** for a seamless, unified local development and production deployment experience.

---

### ✨ Key Features
- **Event & Task Management**: Easily create, update, and track events, tasks, and schedules.
- **Supplier & Service Coordination**: Manage all event suppliers and core services elegantly in one dashboard.
- **Real-time Notifications**: Socket.io integration to keep clients and staff fully updated instantly.
- **Role-based Access**: Custom roles and systemic users management module.
- **Dashboards & Financials**: Live statistics, cost estimation, and income tracking.

---

### �️ Prerequisites
Before running the project, you need to install the following:
- [Docker](https://www.docker.com/) and [Docker Compose](https://docs.docker.com/compose/) (For containerized deployment)
- [Node.js](https://nodejs.org/en/) & [npm](https://www.npmjs.com/) (For manual backend implementation)
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (For manual frontend implementation)
- An Android Emulator or a real device connected via USB with **ADB** (Android Debug Bridge) enabled.

---

### 🚀 Installation & Deployment

#### Method 1: Docker Compose (Recommended)
This method automates the building and starting of both backend and frontend via Docker.

1. **Clone the repository:**
   ```bash
   git clone https://github.com/your-username/my_party_docker.git
   cd my_party_docker
   ```

2. **Start the containers:**
   Run the following command from the root directory to spin up the database, backend, and frontend environments:
   ```bash
   docker-compose up --build
   ```
   > **Note**: The backend will run on `http://localhost:3000`. The frontend container will automatically detect attached USB devices (via `plugdev` group and `/dev/bus/usb` volumes) and build/run the Flutter application on your connected Android device.

3. **Stopping the containers:**
   ```bash
   docker-compose down
   ```

#### Method 2: Manual Setup (For Developers)

**Backend Setup:**
1. Navigate to the backend directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Run the development server:
   ```bash
   npm run dev
   ```

**Frontend Setup:**
1. Navigate to the frontend directory:
   ```bash
   cd frontend
   ```
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application (ensure a device or emulator is running):
   ```bash
   flutter run
   ```

---

### 📁 Project Structure

```text
my_party_docker/
│
├── backend/                  # Node.js backend source code
│   ├── controllers/          # API Controllers
│   ├── routes/               # Express routes
│   ├── config/               # Database and Socket setup
│   ├── database/             # Initial SQL scripts & migrations
│   ├── Dockerfile            # Backend Docker instructions
│   └── index.js              # Server entry point
│
├── frontend/                 # Flutter mobile application
│   ├── lib/                  # Dart source code
│   ├── android/              # Android native code
│   ├── ios/                  # iOS native code
│   └── Dockerfile            # Frontend Docker instructions
│
├── docker-compose.yml        # Unified container orchestrator
├── .gitignore                # Global git ignore configuration
├── README.md                 # Project documentation (This file)
└── LICENSE                   # MIT License
```

---

### 🤝 Contributing & License
Contributions, issues, and feature requests are welcome! Feel free to check the [issues page](https://github.com/your-username/my_party_docker/issues).
This project is licensed under the [MIT License](LICENSE).

<br/>
<br/>

---

<a name="arabic"></a>
## 🇾🇪 القراءة باللغة العربية (Arabic Documentation)

مرحباً بك في **My Party**، المنصة الشاملة والحديثة المصممة لإحداث ثورة في إدارة الفعاليات والحفلات. يوفر هذا التطبيق أدوات قوية لتخطيط الفعاليات، إدارة الموردين، التعامل مع طلبات العملاء، وأكثر من ذلك بكثير، مع تقديم إشعارات لحظية (Real-time).

### � جدول المحتويات
1. [عن المشروع](#عن-المشروع)
2. [البنية التقنية والأدوات](#البنية-التقنية-والأدوات)
3. [المميزات الرئيسية](#المميزات-الرئيسية)
4. [المتطلبات الأساسية](#المتطلبات-الأساسية)
5. [طرق التثبيت والتشغيل](#طرق-التثبيت-والتشغيل)
   - [الطريقة الأولى: باستخدام Docker (موصى به)](#الطريقة-الأولى-باستخدام-docker-موصى-به)
   - [الطريقة الثانية: التثبيت اليدوي (للمطورين)](#الطريقة-الثانية-التثبيت-اليدوي-للمطورين)
6. [هيكل المشروع](#هيكل-المشروع)
7. [المساهمة والترخيص](#المساهمة-والترخيص)

---

### 🌟 عن المشروع
تم بناء **My Party** كحل متكامل لمديري الفعاليات، لجمع عمليات التخطيط، التتبع المالي، إدارة الموردين، والمزامنة اللحظية في منصة واحدة موحدة.

---

### 🏗️ البنية التقنية والأدوات
تم تنظيم هذا المستودع كـ Monorepo يحتوي على كل من تطبيق الهاتف الذكي وخدمة الواجهة الخلفية (Backend):
- **الواجهة الأمامية (Frontend - `/frontend`)**: تم بناؤها باستخدام [Flutter](https://flutter.dev/)، لتقديم تجربة استخدام عصرية، متجاوبة، وتعمل على منصات متعددة (Android و iOS).
- **الواجهة الخلفية (Backend - `/backend`)**: تم تطويرها باستخدام **Node.js** و **Express.js**، وتتميز ببناء واجهات برمجة تطبيقات (REST APIs) قوية، وتقنية **Socket.io** للإشعارات اللحظية، بالإضافة إلى الـ **JWT** للمصادقة الآمنة، وقاعدة بيانات **MySQL**.
- **بيئة التشغيل والنشر**: معبأة بالكامل باستخدام **Docker** و **Docker Compose** للحصول على تجربة تطوير ونشر سلسة وموحدة.

---

### ✨ المميزات الرئيسية
- **إدارة الفعاليات والمهام**: إنشاء، تحديث، وتتبع الفعاليات، المهام والجداول الزمنية بسهولة تامة.
- **تنسيق الموردين والخدمات**: إدارة جميع موردي الفعالية والخدمات الأساسية بأناقة من لوحة تحكم واحدة.
- **إشعارات فورية**: تكامل مع تقنية Socket.io لإبقاء العملاء وفرق العمل على اطلاع فوري بالتحديثات.
- **الوصول المبني على الصلاحيات**: أدوار مخصصة ووحدة إدارة مستخدمين منهجية.
- **لوحات التحكم والتقارير المالية**: إحصائيات مباشرة، تقدير للتكاليف، وتتبع دقيق للعائدات والمصاريف.

---

### 🛠️ المتطلبات الأساسية
قبل تشغيل المشروع، يجب عليك تثبيت البرامج التالية:
- [Docker](https://www.docker.com/) و [Docker Compose](https://docs.docker.com/compose/) (للتشغيل التلقائي والمعبأ).
- [Node.js](https://nodejs.org/en/) و [npm](https://www.npmjs.com/) (للتشغيل اليدوي للواجهة الخلفية).
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (للتشغيل اليدوي للواجهة الأمامية).
- محاكي أندرويد أو جهاز حقيقي متصل عبر الـ USB مع تفعيل وضع تصحيح أخطاء USB (ADB).

---

### 🚀 طرق التثبيت والتشغيل

#### الطريقة الأولى: باستخدام Docker (موصى به)
تقوم هذه الطريقة بأتمتة بناء وتشغيل كل من الواجهة الخلفية والأمامية وقاعدة البيانات باستخدام Docker.

1. **نسخ المستودع (Clone):**
   ```bash
   git clone https://github.com/your-username/my_party_docker.git
   cd my_party_docker
   ```

2. **تشغيل الحاويات:**
   قم بتشغيل الأمر التالي من المسار الجذري للمشروع لتهيئة قاعدة البيانات وبناء الخوادم وتشغيلها:
   ```bash
   docker-compose up --build
   ```
   > **ملاحظة هامة**: ستعمل الواجهة الخلفية على الرابط `http://localhost:3000`. بينما ستقوم حاوية الواجهة الأمامية تلقائيًا باكتشاف أجهزة الـ USB المتصلة (عبر مجموعة `plugdev` ومسار `/dev/bus/usb`) وبناء/تشغيل تطبيق Flutter مباشرة على جهاز أندرويد المتصل الخاص بك.

3. **إيقاف المشروع:**
   ```bash
   docker-compose down
   ```

#### الطريقة الثانية: التثبيت اليدوي (للمطورين)

**إعداد الواجهة الخلفية (Backend):**
1. انتقل إلى مجلد الواجهة الخلفية:
   ```bash
   cd backend
   ```
2. قم بتثبيت الحزم البرمجية:
   ```bash
   npm install
   ```
3. قم بتشغيل الخادم في وضع التطوير:
   ```bash
   npm run dev
   ```

**إعداد الواجهة الأمامية (Frontend):**
1. انتقل إلى مجلد الواجهة الأمامية:
   ```bash
   cd frontend
   ```
2. جلب وتحديث مكاتب وحزم الـ Flutter:
   ```bash
   flutter pub get
   ```
3. تشغيل التطبيق (تأكد من تشغيل المحاكي أو ربط جهازك الحقيقي):
   ```bash
   flutter run
   ```

---

### 📁 هيكل المشروع

```text
my_party_docker/
│
├── backend/                  # الكود المصدري للواجهة الخلفية Node.js
│   ├── controllers/          # متحكمات الـ API
│   ├── routes/               # مسارات Express
│   ├── config/               # إعدادات قاعدة البيانات والـ Socket
│   ├── database/             # ملفات ونصوص قواعد البيانات (SQL)
│   ├── Dockerfile            # تعليمات أداة Docker للباك اند
│   └── index.js              # ملف بدء الخادم (Entry point)
│
├── frontend/                 # تطبيق الهاتف المحمول (Flutter)
│   ├── lib/                  # الكود المصدري بلغة Dart
│   ├── android/              # أكواد الـ Android الأصلية (Native)
│   ├── ios/                  # أكواد الـ iOS الأصلية (Native)
│   └── Dockerfile            # تعليمات أداة Docker للفرونت اند
│
├── docker-compose.yml        # المنسق الموحد لحاويات Docker
├── .gitignore                # الإعدادات العالمية لملفات الحفظ المؤقت
├── README.md                 # التوثيق الخاص بالمشروع (هذا الملف)
└── LICENSE                   # ترخيص المشروع (MIT)
```

---

### 🤝 المساهمة والترخيص
نرحب دوماً بجميع المساهمات برمجياً، الإبلاغ عن المشاكل، أو طلب إضافة مميزات جديدة! 
لا تتردد في التحقق من [صفحة القضايا (Issues)](https://github.com/your-username/my_party_docker/issues).

هذا المشروع مرخص بموجب ترخيص [MIT License](LICENSE).
