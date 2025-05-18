import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get appName => 'Klinik Uygulaması';

  @override
  String get welcomeBack => 'Tekrar Hoş Geldiniz!';

  @override
  String get signInToContinue => 'Devam etmek için giriş yapın';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get signIn => 'Giriş Yap';

  @override
  String get forgotPassword => 'Şifremi Unuttum';

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
  String get noAppointmentsToday => 'Bugün için randevu yok';

  @override
  String get lowStockAlert => 'Düşük Stok Uyarısı';

  @override
  String itemsNeedRestock(int count) {
    return '$count ürün yeniden stoklanmalı';
  }

  @override
  String get searchAppointments => 'Randevuları ara...';

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
  String get changeEmail => 'E-postayı Değiştir';

  @override
  String get changePassword => 'Şifreyi Değiştir';

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
  String get enterUnit => 'Birim girin';

  @override
  String get minimumQuantity => 'Minimum Miktar';

  @override
  String get enterMinimumQuantity => 'Lütfen minimum miktarı girin';

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
  String get needsRestock => 'Yeniden Stoklanmalı';

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
  String get addEditRemoveClinics => 'Klinikleri ekle, düzenle veya kaldır';

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
  String get manageClinicsUsersStats => 'Klinikleri ve kullanıcıları yönet, istatistikleri görüntüle';

  @override
  String get emailVerificationRequired => 'E-posta Doğrulama';

  @override
  String get pleaseVerifyEmail => 'Devam etmek için lütfen e-postanızı kontrol edin ve doğrulama bağlantısına tıklayın.';

  @override
  String get resendVerificationEmail => 'E-postayı Tekrar Gönder';

  @override
  String get verificationEmailSent => 'Doğrulama e-postası gönderildi. Lütfen gelen kutunuzu kontrol edin.';

  @override
  String get ok => 'Tamam';

  @override
  String get confirmPassword => 'Şifreyi Onayla';

  @override
  String get registrationSuccess => 'Kayıt Başarılı';

  @override
  String get emailVerifiedSuccess => 'E-posta başarıyla doğrulandı!';

  @override
  String get emailNotVerifiedYet => 'E-posta henüz doğrulanmadı. Lütfen gelen kutunuzu kontrol edin.';

  @override
  String get checkStatus => 'Durumu Kontrol Et';

  @override
  String get backToLogin => 'Girişe Dön';

  @override
  String get clinicManagement => 'Klinik Yönetimi';

  @override
  String get manageClinicInfoAndOperators => 'Klinik bilgilerini ve operatörleri yönet';

  @override
  String get noClinicsFound => 'Klinik Bulunamadı';

  @override
  String get addClinicToStart => 'Başlamak için yeni bir klinik ekleyin';

  @override
  String get addClinic => 'Klinik Ekle';

  @override
  String get noAppointmentsFound => 'Randevu bulunamadı';

  @override
  String get splashSlogan => 'Akıllı Sağlık, Kolay Yönetim';

  @override
  String get registerTitle => 'Hesabınızı Oluşturun';

  @override
  String get registerSubtitle => 'Sağlık topluluğumuza katılın';

  @override
  String get nameHint => 'Adınızı ve soyadınızı girin';

  @override
  String get emailHint => 'E-posta adresinizi girin';

  @override
  String get passwordHint => 'Şifre oluşturun';

  @override
  String get confirmPasswordHint => 'Şifrenizi onaylayın';

  @override
  String get passwordsDoNotMatch => 'Şifreler eşleşmiyor';

  @override
  String get registerButton => 'Hesap Oluştur';

  @override
  String get alreadyHaveAccountText => 'Zaten hesabınız var mı?';

  @override
  String get loginLink => 'Giriş Yap';

  @override
  String get procedureName => 'İşlem Adı';

  @override
  String get enterProcedureName => 'İşlem adını girin';

  @override
  String get pleaseEnterProcedureName => 'Lütfen işlem adını girin';

  @override
  String get enterProcedureDescription => 'İşlem açıklamasını girin';

  @override
  String get pleaseEnterDescription => 'Lütfen açıklama girin';

  @override
  String get enterProcedurePrice => 'İşlem fiyatını girin';

  @override
  String get pleaseEnterPrice => 'Lütfen fiyat girin';

  @override
  String get pleaseEnterValidPrice => 'Lütfen geçerli bir fiyat girin';

  @override
  String get duration => 'Süre';

  @override
  String get enterProcedureDuration => 'İşlem süresini girin';

  @override
  String get minutes => 'dakika';

  @override
  String get pleaseEnterDuration => 'Lütfen süre girin';

  @override
  String get pleaseEnterValidDuration => 'Lütfen geçerli bir süre girin';

  @override
  String get materials => 'Malzemeler';

  @override
  String get addMaterial => 'Malzeme Ekle';

  @override
  String get selectStockItem => 'Stok Ürünü Seçin';

  @override
  String get enterQuantity => 'Miktar girin';

  @override
  String get pleaseEnterQuantity => 'Lütfen miktar girin';

  @override
  String get pleaseEnterValidQuantity => 'Lütfen geçerli bir miktar girin';

  @override
  String get add => 'Ekle';

  @override
  String get editProcedure => 'İşlemi Düzenle';

  @override
  String get deleteProcedure => 'İşlemi Sil';

  @override
  String deleteProcedureConfirmation(String procedureName) {
    return '$procedureName işlemini silmek istediğinizden emin misiniz?';
  }

  @override
  String get pleaseEnterUnit => 'Lütfen birim girin';

  @override
  String get pleaseEnterMinimumQuantity => 'Lütfen minimum miktarı girin';

  @override
  String get monthlyIncome => 'Aylık Gelir';

  @override
  String get stockValue => 'Stok Değeri';

  @override
  String get profitMargin => 'Kâr Marjı';

  @override
  String get expenses => 'Giderler';

  @override
  String get addExpense => 'Gider Ekle';

  @override
  String get noExpensesFound => 'Gider Bulunamadı';

  @override
  String invoiceNumber(String number) {
    return 'Fatura No: $number';
  }

  @override
  String get deleteExpense => 'Gideri Sil';

  @override
  String get deleteExpenseConfirmation => 'Bu gideri silmek istediğinizden emin misiniz?';

  @override
  String get operators => 'Operatörler';

  @override
  String get addOperator => 'Operatör Ekle';

  @override
  String get noOperatorsFound => 'Operatör Bulunamadı';

  @override
  String get deleteOperator => 'Operatörü Sil';

  @override
  String get deleteOperatorConfirmation => 'Bu operatörü silmek istediğinizden emin misiniz?';

  @override
  String get doctors => 'Doktorlar';

  @override
  String get addDoctor => 'Doktor Ekle';

  @override
  String get noDoctorsFound => 'Doktor Bulunamadı';

  @override
  String get deleteDoctor => 'Doktoru Sil';

  @override
  String get deleteDoctorConfirmation => 'Bu doktoru silmek istediğinizden emin misiniz?';

  @override
  String get thisMonth => 'Bu Ay';

  @override
  String get criticalStock => 'Kritik Stok';

  @override
  String get todayProfit => 'Bugün';

  @override
  String get newAppointment => 'Yeni Randevu';

  @override
  String get pleaseSelectDateAndTime => 'Lütfen tarih ve saat seçin';

  @override
  String get pleaseSelectProcedure => 'Lütfen işlem seçin';

  @override
  String get pleaseSelectDoctor => 'Lütfen doktor seçin';

  @override
  String get pleaseSelectPatient => 'Lütfen hasta seçin';

  @override
  String get appointmentCreatedSuccessfully => 'Randevu başarıyla oluşturuldu';

  @override
  String get error => 'Hata';

  @override
  String get userNotFound => 'Kullanıcı bulunamadı';

  @override
  String get clinicNotFound => 'Klinik bulunamadı';

  @override
  String get patientInformation => 'Hasta Bilgileri';

  @override
  String get selectPatient => 'Hasta Seçin';

  @override
  String get selectPatientHint => 'Hasta seçin';

  @override
  String get searchPatientByNameOrPhone => 'İsim veya telefon ile arayın';

  @override
  String get noPatientsFound => 'Hasta bulunamadı';

  @override
  String get addNewPatient => 'Yeni Hasta Ekle';

  @override
  String get editPatient => 'Hastayı Düzenle';

  @override
  String get appointmentDetails => 'Randevu Detayları';

  @override
  String get selectDate => 'Tarih Seçin';

  @override
  String get selectTime => 'Saat Seçin';

  @override
  String get procedure => 'İşlem';

  @override
  String get selectDoctor => 'Doktor Seçin';

  @override
  String get selectDoctorHint => 'Doktor seçin';

  @override
  String get searchDoctor => 'Doktor Ara';

  @override
  String get searchDoctorByName => 'Doktor adı ile arayın';

  @override
  String get noDoctorsYet => 'Henüz doktor bulunmuyor';

  @override
  String get notes => 'Notlar';

  @override
  String get createAppointment => 'Randevu Oluştur';

  @override
  String get patientNotes => 'Hasta Notları';

  @override
  String get editNotes => 'Notları düzenleyin...';

  @override
  String get notesUpdated => 'Notlar güncellendi';

  @override
  String get save => 'Kaydet';

  @override
  String get editPatientTitle => 'Hastayı Düzenle';

  @override
  String get deletePatient => 'Hastayı Sil';

  @override
  String get deletePatientConfirmation => 'Bu hastayı silmek istediğinize emin misiniz? Bu işlem geri alınamaz.';

  @override
  String get patientDeletedSuccessfully => 'Hasta başarıyla silindi';

  @override
  String get patientUpdatedSuccessfully => 'Hasta başarıyla güncellendi';

  @override
  String errorLoadingPatientData(String error) {
    return 'Hasta bilgileri yüklenirken hata oluştu: $error';
  }

  @override
  String get pleaseSelectDateOfBirth => 'Lütfen doğum tarihi seçin';

  @override
  String get pleaseEnterPhone => 'Lütfen telefon numarası girin';

  @override
  String get selectDateOfBirth => 'Doğum Tarihi Seçin';

  @override
  String get gender => 'Cinsiyet';

  @override
  String get notSpecified => 'Belirtilmedi';

  @override
  String get male => 'Erkek';

  @override
  String get female => 'Kadın';

  @override
  String get useSystemTheme => 'Sistem Temasını Kullan';

  @override
  String get theme => 'Tema';
}
