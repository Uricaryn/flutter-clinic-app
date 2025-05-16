import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Klinik Uygulaması';

  @override
  String get welcomeBack => 'Tekrar Hoşgeldiniz';

  @override
  String get signInToContinue => 'Devam etmek için giriş yapın';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get forgotPassword => 'Şifremi Unuttum?';

  @override
  String get dontHaveAccount => 'Hesabınız yok mu?';

  @override
  String get signUp => 'Kayıt Ol';

  @override
  String get pleaseEnterEmail => 'Lütfen e-posta adresinizi girin';

  @override
  String get pleaseEnterPassword => 'Lütfen şifrenizi girin';

  @override
  String get user => 'Kullanıcı';

  @override
  String get quickActions => 'Hızlı İşlemler';

  @override
  String get appointments => 'Randevular';

  @override
  String get procedures => 'İşlemler';

  @override
  String get stock => 'Stok';

  @override
  String get profile => 'Profil';

  @override
  String get recentActivity => 'Son Aktiviteler';

  @override
  String get upcomingAppointments => 'Yaklaşan Randevular';

  @override
  String youHaveAppointmentsToday(int count) {
    return 'Bugün $count randevunuz var';
  }

  @override
  String get lowStockAlert => 'Düşük Stok Uyarısı';

  @override
  String itemsNeedRestock(int count) {
    return '$count ürünün stoklanması gerekiyor';
  }

  @override
  String get searchAppointments => 'Randevularda ara...';

  @override
  String get all => 'Tümü';

  @override
  String get today => 'Bugün';

  @override
  String get upcoming => 'Yaklaşan';

  @override
  String get past => 'Geçmiş';

  @override
  String get procedureManagement => 'İşlem Yönetimi';

  @override
  String get noProceduresFound => 'İşlem Bulunamadı';

  @override
  String get addProcedureToStart => 'Başlamak için yeni bir işlem ekleyin';

  @override
  String get addProcedure => 'İşlem Ekle';

  @override
  String get accountSettings => 'Hesap Ayarları';

  @override
  String get editProfile => 'Profili Düzenle';

  @override
  String get changeEmail => 'E-posta Değiştir';

  @override
  String get changePassword => 'Şifre Değiştir';

  @override
  String get preferences => 'Tercihler';

  @override
  String get notifications => 'Bildirimler';

  @override
  String get language => 'Dil';

  @override
  String get signOut => 'Çıkış Yap';

  @override
  String get passwordResetEmailSent => 'Şifre sıfırlama e-postası gönderildi';

  @override
  String get createAccount => 'Hesap Oluştur';

  @override
  String get joinUs => 'Bize Katılın';

  @override
  String get createAccountToGetStarted => 'Başlamak için hesabınızı oluşturun';

  @override
  String get fullName => 'Ad Soyad';

  @override
  String get pleaseEnterName => 'Lütfen adınızı girin';

  @override
  String get pleaseEnterValidEmail => 'Lütfen geçerli bir e-posta adresi girin';

  @override
  String get passwordMustBeAtLeast6Characters => 'Şifre en az 6 karakter olmalıdır';

  @override
  String get alreadyHaveAccount => 'Zaten hesabınız var mı?';

  @override
  String get home => 'Ana Sayfa';

  @override
  String get stockManagement => 'Stok Yönetimi';

  @override
  String get noStockItemsFound => 'Stok Ürünü Bulunamadı';

  @override
  String get addStockItemToStart => 'Başlamak için yeni bir stok ürünü ekleyin';

  @override
  String get addStockItem => 'Stok Ürünü Ekle';

  @override
  String get editStockItem => 'Stok Ürününü Düzenle';

  @override
  String get addNewStockItem => 'Yeni Stok Ürünü Ekle';

  @override
  String get itemName => 'Ürün Adı';

  @override
  String get enterItemName => 'Ürün adını girin';

  @override
  String get description => 'Açıklama';

  @override
  String get enterItemDescription => 'Ürün açıklamasını girin';

  @override
  String get price => 'Fiyat';

  @override
  String get enterItemPrice => 'Ürün fiyatını girin';

  @override
  String get quantity => 'Miktar';

  @override
  String get enterCurrentQuantity => 'Mevcut miktarı girin';

  @override
  String get unit => 'Birim';

  @override
  String get enterUnit => 'Birimi girin (örn. kutu, şişe)';

  @override
  String get minimumQuantity => 'Minimum Miktar';

  @override
  String get enterMinimumQuantity => 'Yeniden stok uyarısı için minimum miktarı girin';

  @override
  String get cancel => 'İptal';

  @override
  String get saveChanges => 'Değişiklikleri Kaydet';

  @override
  String get restockItem => 'Ürünü Yeniden Stokla';

  @override
  String currentQuantity(int quantity, String unit) {
    return 'Mevcut miktar: $quantity $unit';
  }

  @override
  String get addQuantity => 'Miktar Ekle';

  @override
  String get enterQuantityToAdd => 'Eklenecek miktarı girin';

  @override
  String get restock => 'Yeniden Stokla';

  @override
  String get deleteStockItem => 'Stok Ürününü Sil';

  @override
  String deleteConfirmation(String itemName) {
    return '$itemName ürününü silmek istediğinizden emin misiniz?';
  }

  @override
  String get delete => 'Sil';

  @override
  String lastRestocked(String date) {
    return 'Son stoklanma: $date';
  }

  @override
  String get needsRestock => 'Yeniden Stoklanması Gerekiyor';

  @override
  String get restockNow => 'Şimdi Stokla';

  @override
  String get adminPanel => 'Yönetici Paneli';

  @override
  String get statistics => 'İstatistikler';

  @override
  String errorWithMessage(Object error) {
    return 'Hata: $error';
  }

  @override
  String get totalClinics => 'Toplam Klinik';

  @override
  String get activeClinics => 'Aktif Klinik';

  @override
  String get totalUsers => 'Toplam Kullanıcı';

  @override
  String get totalAppointments => 'Toplam Randevu';

  @override
  String get manageClinics => 'Klinikleri Yönet';

  @override
  String get addEditRemoveClinics => 'Klinik ekle, düzenle veya sil';

  @override
  String get manageUsers => 'Kullanıcıları Yönet';

  @override
  String get viewManageUsers => 'Kullanıcı hesaplarını görüntüle ve yönet';

  @override
  String get systemSettings => 'Sistem Ayarları';

  @override
  String get configureSystemPreferences => 'Sistem tercihlerini yapılandır';

  @override
  String get addNewClinic => 'Yeni Klinik Ekle';

  @override
  String get clinicName => 'Klinik Adı';

  @override
  String get address => 'Adres';

  @override
  String get phone => 'Telefon';

  @override
  String get adminControls => 'Yönetici Kontrolleri';

  @override
  String get superAdminPanel => 'Süper Yönetici Paneli';

  @override
  String get manageClinicsUsersStats => 'Klinikleri, kullanıcıları yönetin ve istatistikleri görüntüleyin';

  @override
  String get emailVerificationRequired => 'E-posta Doğrulama Gerekli';

  @override
  String get pleaseVerifyEmail => 'Giriş yapmadan önce e-posta adresinizi doğrulayın. Doğrulama bağlantısı için gelen kutunuzu kontrol edin.';

  @override
  String get resendVerificationEmail => 'Doğrulama E-postasını Tekrar Gönder';

  @override
  String get verificationEmailSent => 'Doğrulama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.';

  @override
  String get ok => 'Tamam';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get registrationSuccess => 'Kayıt Başarılı';

  @override
  String get emailVerifiedSuccess => 'Email verified successfully!';

  @override
  String get emailNotVerifiedYet => 'Email not verified yet. Please check your inbox.';

  @override
  String get checkStatus => 'Check Status';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get clinicManagement => 'Clinic Management';

  @override
  String get noClinicsFound => 'No Clinics Found';

  @override
  String get addClinicToStart => 'Add a new clinic to get started';

  @override
  String get addClinic => 'Add Clinic';

  @override
  String get noAppointmentsFound => 'Randevu bulunamadı';
}
