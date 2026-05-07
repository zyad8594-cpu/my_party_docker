# استخدام صورة Ubuntu كأساس
FROM ubuntu:22.04

# إصدارات الأدوات القابلة للتحديث بسهولة
ARG ANDROID_CMDLINE_TOOLS_VERSION=9477386
ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0
ARG FLUTTER_VERSION=3.41.0

# مرآة APT (اتركها فارغة لاستخدام الافتراضية)
ARG APT_MIRROR=mirrors.kernel.org

RUN if [ -n "$APT_MIRROR" ]; then \
        sed -i "s|http://archive.ubuntu.com|http://$APT_MIRROR|g" /etc/apt/sources.list && \
        sed -i "s|http://security.ubuntu.com|http://$APT_MIRROR|g" /etc/apt/sources.list; \
    fi

ENV DEBIAN_FRONTEND=noninteractive

# الوحدة 1: أدوات النظام الأساسية
RUN apt-get update && apt-get install -y \
    curl git wget unzip zip xz-utils \
    && rm -rf /var/lib/apt/lists/*

# الوحدة 2: بيئة الأندرويد الأساسية
RUN apt-get update && apt-get install -y \
    openjdk-21-jdk-headless adb udev libpulse0 \
    && rm -rf /var/lib/apt/lists/*

# الوحدة 3: أدوات بناء لينكس
RUN apt-get update && apt-get install -y \
    clang cmake ninja-build pkg-config \
    && rm -rf /var/lib/apt/lists/*

# الوحدة 4: مكتبات النظام والواجهة
RUN apt-get update && apt-get install -y \
    libgtk-3-dev liblzma-dev libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

# الوحدة 5: مكتبات الإضافات (GStreamer/Audio)
RUN apt-get update && apt-get install -y \
    libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
    libsecret-1-dev libjsoncpp-dev libnm-dev libfontconfig1-dev libdbus-1-dev \
    && rm -rf /var/lib/apt/lists/*

# إعداد Android SDK
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools


# نسخ مجلد الحزم المحلية (إن وجد)
COPY packages/ /tmp/packages/

# تثبيت Android SDK Command-line Tools (محلي أو من الإنترنت)
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    if ls /tmp/packages/commandlinetools-linux-*.zip 1>/dev/null 2>&1; then \
        echo "==> Using local Android commandline tools package"; \
        unzip -q /tmp/packages/commandlinetools-linux-*.zip -d $ANDROID_SDK_ROOT/cmdline-tools; \
    else \
        echo "==> Downloading Android commandline tools from internet"; \
        wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" -O /tmp/tools.zip && \
        unzip -q /tmp/tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
        rm /tmp/tools.zip; \
    fi && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest && \
    rm -rf /tmp/packages

# قبول رخص الأندرويد وتثبيت المنصة وأدوات البناء
RUN yes | sdkmanager --licenses && \
    sdkmanager "platform-tools" "platforms;android-${ANDROID_PLATFORM_VERSION}" "build-tools;${ANDROID_BUILD_TOOLS_VERSION}"

# نسخ مجلد الحزم المحلية مرة أخرى (ﻷنه حذفناه سابقًا) لاستخدامه مع Flutter
COPY packages/ /tmp/packages/

# تثبيت Flutter SDK (محلي أو من الإنترنت)
ENV FLUTTER_HOME=/opt/flutter
RUN if [ -f /tmp/packages/flutter_linux_*-stable.tar.xz ]; then \
        echo "==> Using local Flutter SDK package"; \
        tar -xf /tmp/packages/flutter_linux_*-stable.tar.xz -C /opt; \
    else \
        echo "==> Downloading Flutter SDK from internet"; \
        wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -O /tmp/flutter.tar.xz && \
        tar -xf /tmp/flutter.tar.xz -C /opt && \
        rm /tmp/flutter.tar.xz; \
    fi && \
    rm -rf /tmp/packages
ENV PATH=$PATH:$FLUTTER_HOME/bin

# إعدادات Git و Flutter الأولية (بدون تشغيل pub get هنا)
RUN git config --global --add safe.directory /opt/flutter && \
    flutter config --no-analytics && \
    flutter doctor

# مجلد العمل
WORKDIR /app

# نُسخ الملفات (سيتم استبدالها بالمجلد المرتبط، لكنها تسمح ببناء صورة مستقلة عند الحاجة)
COPY . .

# أمر افتراضي: نقوم بتثبيت التبعيات لأن المجلد المرتبط قد لا يحتويها
CMD ["/bin/bash", "-c", "flutter pub get && exec bash"]