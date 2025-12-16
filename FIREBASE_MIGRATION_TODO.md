# Firebase → PostgreSQL Migration TODO

## ⚠️ **Kalan Firebase Bağımlılıkları**

Toplam **36 dosya** hala Firebase import'ları içeriyor.

---

## 🎯 **Strateji:**

### Seçenek 1: **Şimdilik Firebase import'larını bırak** (Önerilen)
- Firebase paketleri `pubspec.yaml`'dan kaldırıldı
- Ama bazı dosyalar hata vermeden derleniyor olabilir
- **Test edelim**: `flutter run` çalıştır, hangi dosyalar hata veriyorsa sadece onları düzelt

### Seçenek 2: **Tüm dosyaları temizle**
- 36 dosyayı tek tek güncelle
- Zaman alır ama temiz olur

---

## 📋 **Firebase Kullanan Dosyalar:**

### **1. Core Services** (5 dosya)
- [ ] `lib/core/services/email_service.dart`
- [ ] `lib/core/services/crashlytics_service.dart`
- [ ] `lib/core/services/analytics_service.dart`
- [ ] `lib/core/services/storage_service.dart`
- [ ] `lib/core/providers/database_provider.dart`

**Aksiyon**: Bu servisler PostgreSQL'de kullanılmıyorsa silinebilir veya boş bırakılabilir.

---

### **2. Test/Script Files** (2 dosya)
- [ ] `lib/core/scripts/test_data_creator.dart`
- [ ] `lib/core/scripts/run_test_data_creator.dart`

**Aksiyon**: Test dosyaları, production'da kullanılmaz. Göz ardı edilebilir.

---

### **3. Domain Models** (7 dosya)
Sadece Firebase import'ları var (Timestamp için):
- [ ] `lib/features/appointment/domain/models/appointment_model.dart`
- [ ] `lib/features/clinic/domain/models/expense_model.dart`
- [ ] `lib/features/clinic/domain/models/clinic_model.dart`
- [ ] `lib/features/stock/domain/models/stock_item_model.dart`
- [ ] `lib/features/profile/domain/models/user_model.dart`
- [ ] `lib/features/patient/domain/models/patient_model.dart`
- [ ] `lib/features/operator/domain/models/operator_model.dart`

**Aksiyon**: 
```dart
// DEĞİŞTİR:
import 'package:cloud_firestore/cloud_firestore.dart';
Timestamp createdAt;

// BUNA:
DateTime createdAt;
```

---

### **4. Appointment Screens** (4 dosya)
- [ ] `lib/features/appointment/presentation/screens/appointments_screen.dart`
- [ ] `lib/features/appointment/presentation/screens/new_appointment_screen.dart`
- [ ] `lib/features/appointment/presentation/screens/edit_appointment_screen.dart`
- [ ] `lib/features/appointment/presentation/screens/appointment_details_screen.dart`

---

### **5. Patient Screens** (2 dosya)
- [ ] `lib/features/patient/presentation/screens/edit_patient_screen.dart`
- [ ] `lib/features/patient/presentation/screens/new_patient_screen.dart`

---

### **6. Other Feature Screens** (16 dosya)
- [ ] Procedure widgets (4 dosya)
- [ ] Clinic screens (3 dosya)
- [ ] Stock widgets (4 dosya)
- [ ] Operator widgets (3 dosya)
- [ ] Other screens (2 dosya)

---

## 🚀 **Öncelikli Düzeltme Listesi:**

### **Kritik** (Uygulamanın çalışması için gerekli):
1. ✅ ~~`main.dart`~~ (Tamamlandı)
2. ✅ ~~`auth_provider.dart`~~ (Tamamlandı)
3. ✅ ~~`profile_screen.dart`~~ (Tamamlandı)
4. ✅ ~~`home_screen.dart`~~ (Tamamlandı)
5. ✅ ~~Authentication screens~~ (Tamamlandı)

### **Yüksek Öncelik** (Sık kullanılan özellikler):
6. [ ] `appointments_screen.dart`
7. [ ] `new_appointment_screen.dart`
8. [ ] `new_patient_screen.dart`

### **Orta Öncelik**:
9. [ ] Domain models (7 dosya) - `Timestamp` → `DateTime`
10. [ ] Diğer özellik ekranları

### **Düşük Öncelik**:
11. [ ] Test scripts
12. [ ] Utility services (analytics, crashlytics, etc.)

---

## 🔧 **Otomatik Düzeltme:**

### **1. Tüm `Timestamp` kullanımlarını `DateTime`'a çevir:**

```bash
# PowerShell (Windows)
Get-ChildItem -Path "lib" -Filter "*.dart" -Recurse | 
  ForEach-Object {
    (Get-Content $_.FullName) -replace 
      "import 'package:cloud_firestore/cloud_firestore.dart';", "" |
      Set-Content $_.FullName
  }
```

### **2. Gereksiz Firebase import'larını sil:**

Manuel olarak her dosyayı kontrol et ve kullanılmayan import'ları sil.

---

## ✅ **Test Adımları:**

### **1. Compile Test:**
```bash
flutter clean
flutter pub get
flutter analyze
```

### **2. Run Test:**
```bash
flutter run
```

### **3. Feature Test:**
- [ ] Login/Logout
- [ ] Profile görüntüleme/düzenleme
- [ ] Randevu oluşturma
- [ ] Hasta ekleme
- [ ] Stok yönetimi

---

## 📊 **İlerleme:**

- **Tamamlanan**: 2/38 (5%)
  - ✅ profile_screen.dart
  - ✅ home_screen.dart
- **Kalan**: 36/38 (95%)

---

## 🎯 **Önerilen Yaklaşım:**

1. **Önce test et** → `flutter run` yap, hangi dosyalar hata verirse onları düzelt
2. **Appointment ekranları** → En çok kullanılan özellik
3. **Domain models** → `Timestamp` → `DateTime` değişikliği
4. **Diğerleri** → Zamanla düzelt

---

## 💡 **Not:**

Firebase import'ları olan ama **aktif olarak Firebase kullanmayan** dosyalar derleme sırasında hata vermeyebilir. Bu yüzden:

1. ✅ App'i çalıştır
2. ✅ Hangi ekranlar hata veriyor test et
3. ✅ Sadece hata veren dosyaları düzelt

**Gereksiz optimizasyon yapma!** 🚀
