# بورس تک (Boors Tech / Takvan Plus)

دو پوشه اینجاست:

- `takvan_plus/` — اپ Flutter (اندروید، قابل build برای وب هم به لطف ریسپانسیو بودن UI)
- `takvan_plus_backend/` — سرور Node/Express: تنها جایی که کلید OpenAI و اسکرپرهای TSETMC/CODAL/ره‌آورد۳۶۵/آرزدیجیتال اجرا می‌شن

## چرا دو پروژه جدا؟

اپ موبایل هرگز نباید مستقیم به TSETMC/CODAL/OpenAI وصل بشه:
- کلید OpenAI روی کلاینت = قابل استخراج و سوءاستفاده توسط هرکسی
- بیشتر سایت‌های داده مالی ایرانی CORS باز ندارن و اگه هزاران کاربر مستقیم بهشون بزنن، IP سرویس بلاک می‌شه

پس همه‌چیز از بک‌اند شما رد می‌شه، کش می‌شه، و اپ فقط با بک‌اند خودتون صحبت می‌کنه.

## اجرای سریع (بدون دیتای واقعی، فقط برای دیدن UI)

```bash
cd takvan_plus
flutter pub get
flutter gen-l10n   # فایل‌های app_fa.arb/app_en.arb رو به کد تولید می‌کنه (نسخه دستی موجوده، این مرحله اختیاریه)
flutter run
```

با `AppConfig.useMockData = true` (پیش‌فرض)، کل اپ با داده نمایشی کار می‌کنه — نیازی به بک‌اند نیست.

## وصل کردن به داده واقعی

1. **بک‌اند رو دیپلوی کنید:**
   ```bash
   cd takvan_plus_backend
   npm install
   cp .env.example .env   # مقادیر واقعی رو پر کنید: کلید OpenAI، JWT secrets، SMS provider
   npm start
   ```
   روی یک VPS ایرانی یا خارجی (Hetzner, Liara, ArvanCloud, ...) با PM2 یا Docker اجرا کنید. پشت Nginx/Caddy با HTTPS (Let's Encrypt) قرارش بدید.

2. **دامنه شخصی:**
   - یک ساب‌دامین بسازید مثل `api.yourdomain.com` و DNS A record رو به IP سرور بدید
   - با Caddy (ساده‌ترین) یا Nginx + certbot گواهی SSL بگیرید
   - مسیر `/v1/*` بک‌اند رو پشت این دامنه expose کنید

3. **اپ رو به بک‌اند واقعی وصل کنید:**
   ```bash
   flutter build apk --release \
     --dart-define=API_BASE_URL=https://api.yourdomain.com/v1 \
     --dart-define=WS_BASE_URL=wss://api.yourdomain.com/ws \
     --dart-define=USE_MOCK_DATA=false
   ```

4. **اسکرپرهای TSETMC/CODAL/ره‌آورد۳۶۵/آرزدیجیتال رو تست و تنظیم کنید:**
   - `services/tsetmc.js` — endpoint های غیررسمی، ممکنه insCode نمادها یا ساختار پاسخ عوض بشه؛ قبل از production با `curl` تست کنید
   - `services/codal.js` — از API عمومی جستجوی کدال استفاده می‌کنه
   - `services/rahavard365.js` و `services/arzdigital.js` — HTML scraping با cheerio؛ چون این محیط توسعه به اینترنت دسترسی نداشت، سلکتورهای CSS رو **حتماً** با بازکردن DOM واقعی سایت‌ها تایید/اصلاح کنید (جاهایی که کامنت `TODO` دارن)
   - همه این‌ها کش می‌شن (`services/cache.js`) — برای production چندنسخه‌ای، `NodeCache` رو با Redis عوض کنید

5. **OpenAI:** `OPENAI_API_KEY` رو در `.env` بک‌اند بذارید. `routes/assistant.js` پاسخ رو stream می‌کنه، دقیقاً هماهنگ با چیزی که `assistant_repository.dart` انتظار داره.

6. **SMS/OTP:** `routes/auth.js` یک TODO داره برای وصل به یک SMS gateway ایرانی (کاوه‌نگار، قاصدک، فراپیامک) — فعلاً کد رو در لاگ سرور چاپ می‌کنه (فقط برای توسعه).

## انتشار

- **اندروید:** `flutter build appbundle --release --dart-define=...` → آپلود AAB به Google Play Console (یا کافه‌بازار/مایکت برای بازار ایران)
- **وب (اختیاری، چون UI ریسپانسیوه):** `flutter build web --dart-define=...` → استاتیک روی همون دامنه یا Vercel/Netlify سرو کنید

## چیزی که هنوز باید خودتون تکمیل کنید

- امضای واقعی APK/AAB (`android/key.properties` + signingConfig در `build.gradle`)
- دیتابیس واقعی برای کاربران/اشتراک/تسک‌ها/دیده‌بان (این نسخه از Riverpod state در حافظه استفاده می‌کنه؛ برای sync بین دستگاه‌ها یک DB مثل PostgreSQL پشت بک‌اند لازمه)
- تکمیل و تست همه سلکتورهای HTML scraping در برابر DOM زنده سایت‌ها
- درگاه پرداخت برای بخش اشتراک (زرین‌پال/آیدی‌پی و ...)
- آیکون و لوگوی نهایی اپ (فعلاً placeholder)
