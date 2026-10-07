# راهنمای ساخت APK فروشگاه‌یار

## پیش‌نیاز (یک‌بار روی کامپیوتر)

1. **Flutter** را نصب کنید:
   - از سایت: https://docs.flutter.dev/get-started/install
   - یا با دستور (ویندوز با git):
     ```
     git clone https://github.com/flutter/flutter.git -b stable
     ```
   - مسیر `flutter/bin` را به PATH اضافه کنید.

2. **Android Studio** را نصب کنید و از بخش SDK Manager این‌ها را بگیرید:
   - Android SDK
   - Android SDK Command-line Tools
   - یک emulator یا کابل برای گوشی واقعی

3. در ترمینال چک کنید:
   ```
   flutter doctor
   ```
   موارد قرمز را طبق راهنما درست کنید.

---

## ساخت پروژه و APK

1. این پوشه `flutter-app` را از zip خارج کنید.

2. داخل پوشه ترمینال باز کنید و بزنید:
   ```
   flutter create --project-name foroshgah_yar --org ir.apadanasleep .
   ```
   (فایل‌های `lib` و `pubspec.yaml` ما حفظ می‌شوند؛ فقط پوشه‌های android/ios ساخته می‌شوند.)

3. وابستگی‌ها:
   ```
   flutter pub get
   ```

4. ساخت APK انتشار:
   ```
   flutter build apk --release
   ```

5. فایل APK اینجا ساخته می‌شود:
   ```
   build/app/outputs/flutter-apk/app-release.apk
   ```

این فایل را به گوشی منتقل و نصب کنید.

---

## اتصال به سایت

1. در وردپرس: **فروشگاه‌یار** → **ساخت توکن**
2. توکن را کپی کنید
3. در اپ:
   - آدرس سایت: `https://apadanasleep.ir`
   - توکن: همان که کپی کردید
4. دکمه **اتصال به فروشگاه**

---

## اگر خطا دیدید

- `flutter clean` بعد `flutter pub get` دوباره
- برای نصب روی گوشی: Developer options → USB debugging
- اگر امضای debug خواستید (تست سریع‌تر):
  ```
  flutter build apk --debug
  ```
