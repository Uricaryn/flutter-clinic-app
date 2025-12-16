# 🚀 Play Store Deployment Rehberi

## ✅ Tamamlanan Güncellemeler

### Gradle & SDK
- ✅ Android Gradle Plugin: 8.7.3 (en güncel)
- ✅ Kotlin: 1.9.24
- ✅ Firebase BoM: 33.7.0
- ✅ Target SDK: 35 (Android 15)
- ✅ Compile SDK: 35
- ✅ Min SDK: 21 (Android 5.0+)
- ✅ Java: 17
- ✅ R8 Full Mode: Enabled
- ✅ ProGuard: Configured

## 📝 Play Store Gereksinimleri (2025)

| Gereksinim | Durum | Açıklama |
|------------|-------|----------|
| Target SDK 34+ | ✅ | SDK 35 kullanılıyor |
| 64-bit support | ✅ | Flutter otomatik sağlıyor |
| App Bundle (.aab) | ✅ | Flutter build komutu ile |
| Signing | ⚠️ | Keystore oluşturulmalı |

## 🔑 1. Keystore Oluşturma (İlk Defa)

### Windows:
```powershell
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

### Mac/Linux:
```bash
keytool -genkey -v -keystore ~/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

**ÖNEMLI NOTLAR:**
- Şifrelerinizi güvenli bir yerde saklayın!
- Keystore dosyasını ASLA Git'e commit etmeyin!
- Yedekleyin - kaybederseniz uygulamayı güncelleyemezsiniz!

## 📋 2. key.properties Dosyası Oluşturma

1. `android/key.properties.template` dosyasını kopyalayın
2. `android/key.properties` olarak kaydedin
3. Bilgilerinizi girin:

```properties
storePassword=KEYSTORE_ŞIFRENIZ
keyPassword=KEY_ŞIFRENIZ
keyAlias=upload
storeFile=C:/Users/YourName/upload-keystore.jks
```

**Not:** `storeFile` mutlak yol veya relative path olabilir:
- Windows: `C:/Users/YourName/upload-keystore.jks`
- Mac/Linux: `/Users/YourName/upload-keystore.jks`
- Relative: `../upload-keystore.jks`

## 🏗️ 3. Release Build Oluşturma

### App Bundle (Play Store için önerilen):
```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

### APK (Test için):
```bash
flutter build apk --release
```

Çıktı: `build/app/outputs/flutter-apk/app-release.apk`

## 📊 4. Version Management

Her yeni release için `pubspec.yaml` dosyasında version'ı güncelleyin:

```yaml
version: 1.0.0+1
#        ↑     ↑
#   versionName versionCode
```

- **versionName** (1.0.0): Kullanıcıların gördüğü versiyon
- **versionCode** (+1): Her build'de artırılmalı (Play Store için)

**Örnek:**
- İlk release: `1.0.0+1`
- İkinci release: `1.0.1+2`
- Major update: `2.0.0+3`

## 📱 5. Play Store Console Hazırlığı

### Gerekli Bilgiler:
- ✅ Uygulama başlığı: **Ordana** (AndroidManifest.xml'de)
- ✅ Package name: `com.clinicapp.clinic_app`
- ⚠️ App icon: Mevcut (doğrulayın)
- ⚠️ Ekran görüntüleri (en az 2)
- ⚠️ Feature graphic (1024x500)
- ⚠️ Gizlilik politikası URL'i
- ⚠️ Uygulama açıklaması

### Store Listing Checklist:
- [ ] Uygulama açıklaması (TR & EN)
- [ ] Kısa açıklama (80 karakter max)
- [ ] Ekran görüntüleri (Telefon: en az 2, maks 8)
- [ ] Feature Graphic (1024x500px)
- [ ] App icon (512x512px)
- [ ] Gizlilik politikası URL
- [ ] İletişim e-postası
- [ ] Kategori seçimi
- [ ] İçerik derecelendirmesi anketi

## 🔒 6. Güvenlik & Privacy

### AndroidManifest.xml Kontrol:
```xml
<!-- Gerekli permissions -->
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
```

### Gizlilik Politikası:
Play Store, veri toplayan tüm uygulamalar için gizlilik politikası zorunlu kıldı.
- Firebase kullanıyorsunuz → Gizlilik politikası şart
- Kullanıcı verileri topluyorsunuz → Açıklama gerekli

## 🧪 7. Pre-launch Checklist

### Test Etmeniz Gerekenler:
- [ ] Release build'i test cihazda çalıştırın
- [ ] Tüm Firebase özellikleri çalışıyor mu?
- [ ] Login/Logout düzgün çalışıyor mu?
- [ ] Stok yönetimi çalışıyor mu?
- [ ] Randevu sistemi çalışıyor mu?
- [ ] Crash yok mu?
- [ ] Memory leaks yok mu?
- [ ] Network hatalarını düzgün handle ediyor mu?

### Build Doğrulama:
```bash
# APK boyutunu kontrol edin
ls -lh build/app/outputs/flutter-apk/app-release.apk

# AAB boyutunu kontrol edin
ls -lh build/app/outputs/bundle/release/app-release.aab
```

**Beklenen boyutlar:**
- APK: ~40-80 MB (Flutter app için normal)
- AAB: ~30-60 MB (daha optimize)

## 📤 8. Play Store'a Yükleme

1. [Google Play Console](https://play.google.com/console)'a gidin
2. "Create app" butonuna tıklayın
3. Gerekli bilgileri doldurun
4. "Production" sekmesine gidin
5. "Create new release" butonuna tıklayın
6. `app-release.aab` dosyasını yükleyin
7. Release notes yazın
8. "Review release" → "Start rollout to production"

### İlk Kez Yayın:
- Google'ın inceleme süreci: 1-7 gün
- Tüm store listing bilgilerini tamamlayın
- İçerik derecelendirmesi anketi doldurun
- Ülke/bölge seçimleri yapın

## 🔄 9. Güncelleme Yayınlama

Her güncelleme için:

1. **Version'ı artırın:**
   ```yaml
   # pubspec.yaml
   version: 1.0.1+2  # +2 artırıldı
   ```

2. **Build oluşturun:**
   ```bash
   flutter clean
   flutter pub get
   flutter build appbundle --release
   ```

3. **Play Console'da yeni release:**
   - Production → Create new release
   - AAB dosyasını yükle
   - Release notes ekle
   - Review & rollout

## 🐛 10. Troubleshooting

### Build Hatası:
```bash
# Cache temizle
flutter clean
cd android
./gradlew clean
cd ..

# Yeniden build
flutter pub get
flutter build appbundle --release
```

### Signing Hatası:
- `key.properties` dosyasının doğru yerde olduğundan emin olun
- Şifrelerin doğru olduğunu kontrol edin
- Keystore dosyasının yolunu kontrol edin

### Version Conflict:
```bash
# Gradle wrapper güncellemesi gerekiyorsa
cd android
./gradlew wrapper --gradle-version 8.9
```

## 📞 Yardım & Kaynaklar

- [Flutter Deployment Guide](https://docs.flutter.dev/deployment/android)
- [Play Console Help](https://support.google.com/googleplay/android-developer)
- [Firebase Console](https://console.firebase.google.com/)
- [Android Developer Docs](https://developer.android.com/studio/publish)

## ⚡ Hızlı Komutlar

```bash
# Clean build
flutter clean && flutter pub get

# Debug build (test için)
flutter run

# Release APK (test için)
flutter build apk --release

# Release App Bundle (Play Store için)
flutter build appbundle --release

# Build'i analiz et
flutter build appbundle --release --analyze-size

# Specific flavor
flutter build appbundle --release --flavor production
```

## 🎯 Son Notlar

1. **Keystore'u asla kaybetmeyin!** - Yedekleyin
2. **Version code'u her build'de artırın**
3. **Release notes yazın** - Kullanıcılar için önemli
4. **Test edin** - Production'a göndermeden önce
5. **Beta test** - Internal/Closed test track kullanın
6. **Monitör edin** - Play Console crashlytics kontrol edin

---

**Hazırlayan:** AI Assistant  
**Tarih:** Aralık 2025  
**Güncelleme:** Her deploy öncesi bu dosyayı kontrol edin

