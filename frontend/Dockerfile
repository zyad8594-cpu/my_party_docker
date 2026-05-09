# استخدام صورة Ubuntu كأساس
FROM ubuntu:22.04

# إصدارات الأدوات القابلة للتحديث بسهولة
ARG ANDROID_CMDLINE_TOOLS_VERSION=9477386
ARG ANDROID_PLATFORM_VERSION=34
ARG ANDROID_BUILD_TOOLS_VERSION=34.0.0
ARG ANDROID_NDK_VERSION=28.2.13676358
ARG FLUTTER_VERSION=3.41.0

# مرآة APT (اتركها فارغة لاستخدام الافتراضية)
ARG APT_MIRROR=mirrors.kernel.org

ENV DEBIAN_FRONTEND=noninteractive
ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV FLUTTER_HOME=/opt/flutter
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools:$FLUTTER_HOME/bin:$ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION/bin

# نسخ المجلدات المحلية للمشروع (إن وجدت) للتحقق منها قبل التنزيل
COPY packages/ /tmp/packages/

# الوحدة 1: تثبيت أدوات النظام الأساسية ومكتبات الواجهة (مجمعة لتقليص الحجم)
RUN if [ -n "$APT_MIRROR" ]; then \
        sed -i "s|http://archive.ubuntu.com|http://$APT_MIRROR|g" /etc/apt/sources.list && \
        sed -i "s|http://security.ubuntu.com|http://$APT_MIRROR|g" /etc/apt/sources.list; \
    fi && \
    apt-get update && \
    # محاولة تثبيت أي حزم .deb محلية تم وضعها في packages/apt
    if [ -d /tmp/packages/apt ] && [ "$(ls -A /tmp/packages/apt/*.deb 2>/dev/null)" ]; then \
        echo "==> Installing local .deb packages..."; \
        apt-get install -y /tmp/packages/apt/*.deb; \
    fi && \
    apt-get install -y --no-install-recommends \
        curl git wget unzip zip xz-utils \
        openjdk-21-jdk-headless adb udev libpulse0 \
        clang cmake ninja-build pkg-config \
        libgtk-3-dev liblzma-dev libglu1-mesa \
        libasound2-dev libgstreamer1.0-dev libgstreamer-plugins-base1.0-dev \
        libsecret-1-dev libjsoncpp-dev libnm-dev libfontconfig1-dev libdbus-1-dev \
    && rm -rf /var/lib/apt/lists/*

# إعداد Android SDK
RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools

# تثبيت Android SDK Command-line Tools
RUN if ls /tmp/packages/commandlinetools-linux-*.zip 1>/dev/null 2>&1; then \
        echo "==> Using local Android commandline tools package"; \
        unzip -q /tmp/packages/commandlinetools-linux-*.zip -d $ANDROID_SDK_ROOT/cmdline-tools; \
    else \
        echo "==> Downloading Android commandline tools from internet"; \
        wget -q "https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_CMDLINE_TOOLS_VERSION}_latest.zip" -O /tmp/tools.zip && \
        unzip -q /tmp/tools.zip -d $ANDROID_SDK_ROOT/cmdline-tools && \
        rm /tmp/tools.zip; \
    fi && \
    mv $ANDROID_SDK_ROOT/cmdline-tools/cmdline-tools $ANDROID_SDK_ROOT/cmdline-tools/latest

# قبول رخص الأندرويد وتثبيت المنصة وأدوات البناء والـ NDK
RUN yes | sdkmanager --licenses && \
    # التحقق من وجود NDK محلي
    if ls /tmp/packages/android-ndk-*.zip 1>/dev/null 2>&1; then \
        echo "==> Installing NDK from local zip..."; \
        mkdir -p $ANDROID_SDK_ROOT/ndk && \
        unzip -q /tmp/packages/android-ndk-*.zip -d $ANDROID_SDK_ROOT/ndk && \
        # قد يحتاج المجلد لإعادة تسمية ليتناسب مع الإصدار المتوقع
        NDK_DIR=$(find $ANDROID_SDK_ROOT/ndk -maxdepth 1 -type d -name "android-ndk-*" | head -n 1) && \
        if [ -n "$NDK_DIR" ]; then mv "$NDK_DIR" "$ANDROID_SDK_ROOT/ndk/$ANDROID_NDK_VERSION"; fi; \
    else \
        echo "==> Downloading SDK components and NDK from internet"; \
        sdkmanager "platform-tools" \
                   "platforms;android-${ANDROID_PLATFORM_VERSION}" \
                   "build-tools;${ANDROID_BUILD_TOOLS_VERSION}" \
                   "ndk;${ANDROID_NDK_VERSION}"; \
    fi

# تثبيت Flutter SDK
RUN if [ -f /tmp/packages/flutter_linux_*-stable.tar.xz ]; then \
        echo "==> Using local Flutter SDK package"; \
        tar -xf /tmp/packages/flutter_linux_*-stable.tar.xz -C /opt; \
    else \
        echo "==> Downloading Flutter SDK from internet"; \
        wget -q "https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz" -O /tmp/flutter.tar.xz && \
        tar -xf /tmp/flutter.tar.xz -C /opt && \
        rm /tmp/flutter.tar.xz; \
    fi

# تنظيف الملفات المؤقتة
RUN rm -rf /tmp/packages

# إعدادات Git و Flutter الأولية
RUN git config --global --add safe.directory /opt/flutter && \
    flutter config --no-analytics && \
    flutter doctor

# مجلد العمل
WORKDIR /app

# نُسخ الملفات (ستتأثر بالـ Volume mount في docker-compose)
COPY . .

# أمر افتراضي: نقوم بتثبيت التبعيات وتشغيل التطبيق
CMD ["/bin/bash", "/app/start.sh"]