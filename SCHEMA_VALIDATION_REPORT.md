# Schema & Model Validation Report

## 🔍 Problem Tanımı

PostgreSQL mode'da uygulama düzgün çalışmıyor. Firebase mode çalışıyordu ama PostgreSQL'de veriler ve modeller uyumsuz görünüyor.

---

## ✅ Database Schema Kontrolü

### Oluşturulması Gereken Tablolar:

1. ✅ **clinics** - Klinik bilgileri
2. ✅ **users** - Kullanıcılar (authentication için)
3. ✅ **patients** - Hastalar
4. ✅ **procedures** - İşlemler/Tedaviler
5. ✅ **stock_items** - Stok malzemeleri
6. ✅ **operators** - Operatörler (çalışanlar)
7. ✅ **appointments** - Randevular
8. ✅ **expenses** - Giderler
9. ✅ **procedure_materials** - İşlem-Malzeme ilişkisi
10. ✅ **appointment_stock_items** - Randevu-Stok ilişkisi
11. ✅ **appointment_procedures** - Randevu-İşlem ilişkisi

Schema dosyası mevcut: `backend/migrations/001_initial_schema.sql`

---

## 🔴 Olası Sorunlar

### 1. **Database Migration Çalıştırılmadı**

Migration script'leri var ama veritabanında tablolar oluşturulmamış olabilir.

**Test:**
```bash
# Backend terminalinde
npm run migrate
```

### 2. **Backend API Field Names vs Flutter Model Field Names**

**PostgreSQL DB:**
- `full_name` (snake_case)
- `date_of_birth`
- `created_at`

**Backend API Response:**
- `fullName` (camelCase) ✅
- `dateOfBirth` (camelCase) ✅
- `createdAt` (camelCase) ✅

**Flutter Models:**
- `fullName` ✅
- `dateOfBirth` ✅
- `createdAt` ✅

**Durum:** Field naming **DOĞRU** görünüyor.

### 3. **clinicId Null Problemi**

Yeni kayıt olan kullanıcıların `clinicId`'si null. Bu durumda:
- ❌ Hiçbir clinic'e bağlı değil
- ❌ Hiçbir veri gösteremez (çünkü tüm veriler `clinicId` ile filtreleniyor)

**Çözüm:** Kayıt sonrası kullanıcı için otomatik clinic oluşturulmalı.

### 4. **Backend Response Format**

Login/Register response'ları şu alanları **içermiyor:**
- ❌ `createdAt`
- ❌ `updatedAt`
- ❌ `lastLogin`

Bu yüzden Flutter'da parse hatası oluyor.

---

## 🔧 Çözümler

### Çözüm 1: Database Migration'ı Çalıştır

```bash
cd backend

# Migration script çalıştır
node migrations/run-migrations.js

# Veya manuel:
npm run migrate
```

### Çözüm 2: Otomatik Clinic Oluştur (Backend)

`backend/src/controllers/authController.js` - Register methodunda:

```javascript
// After user creation:
if (user.role === 'clinic_admin' && !user.clinic_id) {
  // Create clinic automatically
  const clinic = await Clinic.create({
    name: `${user.full_name}'s Clinic`,
    ownerId: user.id,
  });
  
  // Update user with clinic_id
  await User.update(user.id, { clinicId: clinic.id });
  
  // Update response
  user.clinic_id = clinic.id;
}
```

### Çözüm 3: Backend Response'ları Düzelt

Tüm user response'larına eksik alanları ekle:

```javascript
// authController.js - login & register
user: {
  id: user.id,
  email: user.email,
  fullName: user.full_name,
  phone: user.phone,
  avatar: user.avatar,
  role: user.role,
  clinicId: user.clinic_id,
  emailVerified: user.email_verified,
  createdAt: user.created_at,      // ← EKLE
  updatedAt: user.updated_at,      // ← EKLE
  lastLogin: user.last_login,      // ← EKLE
}
```

### Çözüm 4: Flutter Model'i Güncelle (Zaten yapıldı ✅)

`PostgresqlUser.fromJson` nullable yapmak:

```dart
createdAt: json['createdAt'] != null
    ? DateTime.parse(json['createdAt'] as String)
    : DateTime.now(),  // ✅ Fallback
```

---

## 📊 Test Checklist

### Backend Test:
```bash
cd backend

# 1. Database kontrol
npm run migrate

# 2. Server başlat
npm run dev

# 3. Test endpoint
curl http://localhost:8080/health
```

### Flutter Test:
```bash
# 1. Firebase mode test (karşılaştırma için)
flutter run

# 2. PostgreSQL mode test
flutter run --dart-define=DB_MODE=postgresql

# 3. Login dene
# 4. Yeni kullanıcı kaydet
# 5. Clinic oluştuğunu kontrol et
```

---

## 🎯 Hemen Yapılması Gerekenler

1. ✅ **Migration çalıştır** - Database tablolarını oluştur
2. ⚠️ **Backend'i güncelle** - Otomatik clinic creation
3. ⚠️ **Response fields ekle** - createdAt, updatedAt, lastLogin
4. ✅ **Flutter hot restart** - Yeni kodları yükle

---

## 📝 Notlar

- Firebase mode çalışıyor çünkü Firebase Firestore field naming farklı
- PostgreSQL backend'de **clinicId olmadan hiçbir veri gösteremezsiniz**
- Test kullanıcısı için manuel clinic oluşturabilirsiniz

---

## 🚀 Hızlı Fix

```bash
# Backend terminalinde
cd backend

# Migration çalıştır
node migrations/run-migrations.js

# Backend restart
npm run dev
```

```bash
# Flutter terminalinde
# Hot restart: R tuşuna bas
```

Sonra yeni kullanıcı kaydı yapın ve test edin!
