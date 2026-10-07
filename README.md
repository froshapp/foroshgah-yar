# فروشگاه‌یار - اپلیکیشن اندروید مدیریت ووکامرس

اپلیکیشن مدرن و تمیز برای مدیریت فروشگاه‌های ووکامرس با پشتیبانی چند فروشگاه.

## ویژگی‌های فاز ۱

- ورود امن با توکن
- مدیریت چند فروشگاه
- داشبورد آماری
- مدیریت کامل سفارشات (لیست، فیلتر، تغییر وضعیت تکی/گروهی، جزئیات، یادداشت، ثبت سفارش)
- مدیریت محصولات (لیست، افزودن، ویرایش قیمت و موجودی)
- تاریخ شمسی
- نوتیفیکیشن سفارش جدید (Firebase)

## ساختار پروژه

```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── api/
│   │   ├── api_client.dart
│   │   └── endpoints.dart
│   ├── models/
│   ├── services/
│   └── theme/
├── features/
│   ├── auth/
│   ├── dashboard/
│   ├── orders/
│   ├── products/
│   └── stores/
└── shared/
    └── widgets/
```

## راه‌اندازی

1. Flutter SDK 3.16+ نصب کنید
2. `flutter pub get`
3. فایل `lib/core/api/api_client.dart` را با آدرس سایت خود تنظیم کنید
4. `flutter run`

## وابستگی‌های اصلی

- dio (HTTP)
- provider یا riverpod (state management)
- shared_preferences (ذخیره توکن و فروشگاه‌ها)
- shamsi_date (تاریخ شمسی)
- firebase_messaging (نوتیفیکیشن)
