# Zoho Mail SMTP Konfigürasyonu

## Zoho Mail ile Email Gönderimi

Backend'inizden `info@whabbiton.com` adresi üzerinden email göndermek için Zoho Mail SMTP ayarlarını kullanacağız.

## Zoho SMTP Ayarları

### .env Dosyası Konfigürasyonu

Backend klasöründe `.env` dosyasına şu ayarları ekleyin:

```env
# Zoho Mail SMTP Settings
SMTP_HOST=smtp.zoho.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=info@whabbiton.com
SMTP_PASSWORD=your-zoho-password-or-app-password
EMAIL_FROM="Clinic App <info@whabbiton.com>"

# Frontend URL (email linklerinde kullanılacak)
FRONTEND_URL=https://your-app-domain.com
```

## Zoho App Password Oluşturma (Önerilen)

Güvenlik için normal şifreniz yerine "App Password" kullanın:

### Adımlar:

1. **Zoho hesabınıza giriş yapın**
   - https://accounts.zoho.com/

2. **Security bölümüne gidin**
   - My Account → Security → App Passwords

3. **Yeni App Password oluşturun**
   - "Generate New Password" tıklayın
   - İsim: "Clinic Backend API"
   - Generate

4. **Şifreyi kopyalayın**
   - Gösterilen şifreyi `.env` dosyasındaki `SMTP_PASSWORD` olarak kullanın
   - ⚠️ Bu şifreyi bir daha göremeyeceksiniz, güvenli bir yere kaydedin

## SMTP Test

Email ayarlarınızı test etmek için:

```bash
cd backend
node -e "
const nodemailer = require('nodemailer');
require('dotenv').config();

const transporter = nodemailer.createTransporter({
  host: process.env.SMTP_HOST,
  port: parseInt(process.env.SMTP_PORT),
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASSWORD,
  },
});

transporter.sendMail({
  from: process.env.EMAIL_FROM,
  to: 'test@example.com',
  subject: 'Test Email from Clinic Backend',
  text: 'If you receive this, SMTP is working correctly!',
}).then(() => {
  console.log('✅ Email sent successfully!');
  process.exit(0);
}).catch((err) => {
  console.error('❌ Email failed:', err.message);
  process.exit(1);
});
"
```

## Zoho Mail Özellikleri

### Gönderim Limitleri

- **Free Plan:** 25 emails/gün
- **Mail Lite:** 250 emails/gün
- **Mail Premium:** 500 emails/gün
- **Zoho Mail Suite:** Sınırsız

### Port Seçenekleri

| Port | Şifreleme | Kullanım |
|------|-----------|----------|
| 587 | STARTTLS | Önerilen (kullandığımız) |
| 465 | SSL/TLS | Alternatif |
| 25 | Yok | Önerilmez |

**Neden 587?**
- Modern ve güvenli
- Çoğu firewall tarafından izin veriliyor
- STARTTLS ile şifrelenmiş bağlantı

## Email Şablonları

Backend'de 3 tip email gönderiliyor:

### 1. Email Doğrulama

```javascript
// Kullanıcı kayıt olduğunda
sendVerificationEmail(email, token, userName);
```

**Gönderen:** Clinic App <info@whabbiton.com>
**Konu:** Email Adresinizi Doğrulayın - Clinic App
**İçerik:** Doğrulama linki

### 2. Şifre Sıfırlama

```javascript
// Kullanıcı şifre sıfırlama istediğinde
sendPasswordResetEmail(email, token, userName);
```

**Gönderen:** Clinic App <info@whabbiton.com>
**Konu:** Şifre Sıfırlama Talebi - Clinic App
**İçerik:** Şifre sıfırlama linki (1 saat geçerli)

### 3. Hoşgeldin Emaili

```javascript
// Başarılı kayıt sonrası
sendWelcomeEmail(email, userName);
```

**Gönderen:** Clinic App <info@whabbiton.com>
**Konu:** Clinic App'e Hoşgeldiniz!
**İçerik:** Karşılama mesajı ve özellikler

## Email Şablonlarını Türkçeleştirme

Mevcut email'ler İngilizce. Türkçeleştirmek isterseniz:

```javascript
// src/utils/emailService.js içinde
subject: 'Email Adresinizi Doğrulayın - Clinic App',
html: `
  <h2>${userName}, Hoşgeldiniz!</h2>
  <p>Kaydınızı tamamlamak için email adresinizi doğrulayın:</p>
  <a href="${verificationUrl}">Email'imi Doğrula</a>
  ...
`
```

## Sorun Giderme

### Hata: "Invalid login credentials"

**Çözüm:**
1. Zoho şifrenizin doğru olduğundan emin olun
2. App Password kullanmayı deneyin
3. İki faktörlü doğrulama aktifse, App Password zorunlu

### Hata: "Connection timeout"

**Çözüm:**
1. Sunucunuzun port 587'ye erişebildiğinden emin olun
2. Firewall ayarlarını kontrol edin
3. `SMTP_HOST=smtp.zoho.com` doğru yazıldığından emin olun

### Hata: "Authentication failed"

**Çözüm:**
1. SMTP_USER = tam email adresi (`info@whabbiton.com`)
2. SMTP_PASSWORD = Zoho şifreniz veya App Password
3. Zoho hesabınızda SMTP erişiminin açık olduğundan emin olun

### Hata: "Sender address rejected"

**Çözüm:**
1. `EMAIL_FROM` değeri Zoho hesabınızla eşleşmeli
2. Format: `"Clinic App <info@whabbiton.com>"`
3. Zoho'da bu email adresini verify etmiş olmalısınız

## Production Ayarları

### .env Production Örneği

```env
# Zoho Mail (Production)
SMTP_HOST=smtp.zoho.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=info@whabbiton.com
SMTP_PASSWORD=your-zoho-app-password-here
EMAIL_FROM="Whabbiton Clinic <info@whabbiton.com>"

# Frontend URLs
FRONTEND_URL=https://your-production-domain.com

# Diğer ayarlar...
DATABASE_URL=postgresql://...
JWT_SECRET=...
```

## Email Monitoring

### Zoho Mail Kontrolü

1. **Gönderilen Emailler:**
   - Zoho Mail web arayüzü → Sent folder
   - Gönderilen email'leri görebilirsiniz

2. **Hata Logları:**
   - Backend console'da email hatalarını görebilirsiniz
   - `console.error('Error sending email:', error)`

3. **Email Delivery:**
   - Spam klasörünü kontrol edin
   - SPF/DKIM ayarlarının doğru olduğundan emin olun

## SPF ve DKIM Ayarları

Zoho Mail ile email gönderirken, domain'inizin SPF ve DKIM kayıtlarını ayarlamalısınız:

### SPF Kaydı (DNS)

```
Type: TXT
Name: @
Value: v=spf1 include:zoho.com ~all
```

### DKIM Kaydı

1. Zoho Mail → Control Panel → Email Configuration → DKIM
2. Verilen DKIM kaydını domain DNS'ine ekleyin
3. Verify edin

**Neden Önemli?**
- Email'leriniz spam'e düşmez
- Delivery rate artar
- Email güvenliği sağlanır

## Nodemailer Dependency

Email servisi için nodemailer gerekli:

```bash
cd backend
npm install nodemailer
```

Zaten `package.json`'da olmalı, yoksa ekleyin:

```json
{
  "dependencies": {
    "nodemailer": "^6.9.7"
  }
}
```

## Test Email Gönderimi

Backend çalışırken test email göndermek için:

```bash
# Backend'i başlatın
cd backend
npm start

# Başka bir terminalde
curl -X POST http://localhost:3000/api/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "Test123!",
    "fullName": "Test User",
    "role": "patient"
  }'

# Zoho Mail'den verification email gönderilecek
```

## Email Şablonlarını Özelleştirme

### Logo Eklemek

```javascript
html: `
  <div style="text-align: center;">
    <img src="https://your-domain.com/logo.png" alt="Logo" style="max-width: 200px;">
  </div>
  <h2>Welcome to Clinic App!</h2>
  ...
`
```

### Türkçe Şablonlar

Email servisinde tüm metinleri Türkçe'ye çevirebilirsiniz:

```javascript
subject: 'Email Adresinizi Doğrulayın',
html: `
  <h2>Merhaba ${userName}!</h2>
  <p>Hesabınızı oluşturduğunuz için teşekkürler...</p>
`
```

## Güvenlik Önerileri

1. ✅ **App Password kullanın** (normal şifre yerine)
2. ✅ **SMTP_PASSWORD'u .env'de tutun** (asla commit etmeyin)
3. ✅ **Rate limiting ekleyin** (email bombing'i önlemek için)
4. ✅ **Email validation** yapın (geçerli email formatı kontrolü)
5. ✅ **Unsubscribe link** ekleyin (marketing email'leri için)

## Rate Limiting (Email)

Aşırı email gönderimini önlemek için:

```javascript
// Kullanıcı başına limitleme
const emailRateLimit = {
  verification: 3, // Günde 3 doğrulama emaili
  passwordReset: 5, // Günde 5 şifre sıfırlama
  interval: 24 * 60 * 60 * 1000, // 24 saat
};
```

## Özet - Hızlı Setup

```bash
# 1. Backend .env dosyasını düzenleyin
cd backend
nano .env

# 2. Şu satırları ekleyin/güncelleyin:
SMTP_HOST=smtp.zoho.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=info@whabbiton.com
SMTP_PASSWORD=your-zoho-app-password
EMAIL_FROM="Whabbiton Clinic <info@whabbiton.com>"
FRONTEND_URL=https://your-domain.com

# 3. Nodemailer'ı yükleyin (yoksa)
npm install nodemailer

# 4. Backend'i başlatın
npm start

# 5. Test email gönderin
# Kayıt olma veya şifre sıfırlama işlemi yapın

# ✅ Email'ler info@whabbiton.com adresinden gönderilecek!
```

## Support

Sorun yaşarsanız:
- **Zoho Support:** https://www.zoho.com/mail/help/
- **Backend logs:** `npm start` çıktısını kontrol edin
- **Email test:** Verification/reset email'leri test edin

