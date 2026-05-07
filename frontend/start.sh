#!/bin/bash
# إزالة بقايا كاش الجرادل الخاص بجهاز الكمبيوتر لمنع التعارض
rm -rf android/.gradle
rm -rf build

flutter pub get
DEVICE=$(adb devices | grep -w 'device' | head -n 1 | cut -f1)
if [ -z "$DEVICE" ]; then
  echo '📱 No phone found! Make sure USB is connected.'
  flutter run
else
  echo "🚀 Found phone: $DEVICE - Running app..."
  flutter run -d $DEVICE
fi
