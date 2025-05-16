import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr')
  ];

  /// The name of the application
  ///
  /// In en, this message translates to:
  /// **'Clinic App'**
  String get appName;

  /// Welcome message on home screen
  ///
  /// In en, this message translates to:
  /// **'Welcome back!'**
  String get welcomeBack;

  /// Subtitle on login screen
  ///
  /// In en, this message translates to:
  /// **'Sign in to continue'**
  String get signInToContinue;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// Sign in button text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get signIn;

  /// Forgot password button text
  ///
  /// In en, this message translates to:
  /// **'Forgot Password?'**
  String get forgotPassword;

  /// Text for sign up prompt
  ///
  /// In en, this message translates to:
  /// **'Don\'t have an account?'**
  String get dontHaveAccount;

  /// Sign up button text
  ///
  /// In en, this message translates to:
  /// **'Sign Up'**
  String get signUp;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your email'**
  String get pleaseEnterEmail;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your password'**
  String get pleaseEnterPassword;

  /// Default user name
  ///
  /// In en, this message translates to:
  /// **'User'**
  String get user;

  /// Quick actions section title
  ///
  /// In en, this message translates to:
  /// **'Quick Actions'**
  String get quickActions;

  /// Appointments menu item
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get appointments;

  /// Procedures menu item
  ///
  /// In en, this message translates to:
  /// **'Procedures'**
  String get procedures;

  /// Stock menu item
  ///
  /// In en, this message translates to:
  /// **'Stock'**
  String get stock;

  /// Profile menu item
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Recent activity section title
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get recentActivity;

  /// Upcoming appointments title
  ///
  /// In en, this message translates to:
  /// **'Upcoming Appointments'**
  String get upcomingAppointments;

  /// Message showing number of appointments today
  ///
  /// In en, this message translates to:
  /// **'You have {count} appointments today'**
  String youHaveAppointmentsToday(int count);

  /// Low stock alert title
  ///
  /// In en, this message translates to:
  /// **'Low Stock Alert'**
  String get lowStockAlert;

  /// Message showing number of items needing restock
  ///
  /// In en, this message translates to:
  /// **'{count} items need to be restocked'**
  String itemsNeedRestock(int count);

  /// Search appointments placeholder
  ///
  /// In en, this message translates to:
  /// **'Search appointments...'**
  String get searchAppointments;

  /// All filter option
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// Today filter option
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get today;

  /// Upcoming filter option
  ///
  /// In en, this message translates to:
  /// **'Upcoming'**
  String get upcoming;

  /// Past filter option
  ///
  /// In en, this message translates to:
  /// **'Past'**
  String get past;

  /// Procedure management screen title
  ///
  /// In en, this message translates to:
  /// **'Procedure Management'**
  String get procedureManagement;

  /// Message when no procedures are found
  ///
  /// In en, this message translates to:
  /// **'No Procedures Found'**
  String get noProceduresFound;

  /// Message to add first procedure
  ///
  /// In en, this message translates to:
  /// **'Add a new procedure to get started'**
  String get addProcedureToStart;

  /// Add procedure button text
  ///
  /// In en, this message translates to:
  /// **'Add Procedure'**
  String get addProcedure;

  /// Account settings section title
  ///
  /// In en, this message translates to:
  /// **'Account Settings'**
  String get accountSettings;

  /// Edit profile menu item
  ///
  /// In en, this message translates to:
  /// **'Edit Profile'**
  String get editProfile;

  /// Change email menu item
  ///
  /// In en, this message translates to:
  /// **'Change Email'**
  String get changeEmail;

  /// Change password menu item
  ///
  /// In en, this message translates to:
  /// **'Change Password'**
  String get changePassword;

  /// Preferences section title
  ///
  /// In en, this message translates to:
  /// **'Preferences'**
  String get preferences;

  /// Notifications menu item
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// Language menu item
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// Sign out button text
  ///
  /// In en, this message translates to:
  /// **'Sign Out'**
  String get signOut;

  /// Message shown when password reset email is sent
  ///
  /// In en, this message translates to:
  /// **'Password reset email sent'**
  String get passwordResetEmailSent;

  /// Create account button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get createAccount;

  /// Welcome text on register screen
  ///
  /// In en, this message translates to:
  /// **'Join Us'**
  String get joinUs;

  /// Subtitle on register screen
  ///
  /// In en, this message translates to:
  /// **'Create your account to get started'**
  String get createAccountToGetStarted;

  /// Full name field label
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// Name validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter your name'**
  String get pleaseEnterName;

  /// Email validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid email'**
  String get pleaseEnterValidEmail;

  /// Password validation message
  ///
  /// In en, this message translates to:
  /// **'Password must be at least 6 characters'**
  String get passwordMustBeAtLeast6Characters;

  /// Text for sign in prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccount;

  /// Home navigation item
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get home;

  /// Stock management screen title
  ///
  /// In en, this message translates to:
  /// **'Stock Management'**
  String get stockManagement;

  /// Message when no stock items are found
  ///
  /// In en, this message translates to:
  /// **'No Stock Items Found'**
  String get noStockItemsFound;

  /// Message to add first stock item
  ///
  /// In en, this message translates to:
  /// **'Add a new stock item to get started'**
  String get addStockItemToStart;

  /// Add stock item button text
  ///
  /// In en, this message translates to:
  /// **'Add Stock Item'**
  String get addStockItem;

  /// Edit stock item dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Stock Item'**
  String get editStockItem;

  /// Add new stock item dialog title
  ///
  /// In en, this message translates to:
  /// **'Add New Stock Item'**
  String get addNewStockItem;

  /// Item name field label
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// Item name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter item name'**
  String get enterItemName;

  /// Description field label
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get description;

  /// Description field hint
  ///
  /// In en, this message translates to:
  /// **'Enter item description'**
  String get enterItemDescription;

  /// Price field label
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// Price field hint
  ///
  /// In en, this message translates to:
  /// **'Enter item price'**
  String get enterItemPrice;

  /// Quantity field label
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

  /// Quantity field hint
  ///
  /// In en, this message translates to:
  /// **'Enter current quantity'**
  String get enterCurrentQuantity;

  /// Unit field label
  ///
  /// In en, this message translates to:
  /// **'Unit'**
  String get unit;

  /// Unit field hint
  ///
  /// In en, this message translates to:
  /// **'Enter unit (e.g., boxes, bottles)'**
  String get enterUnit;

  /// Minimum quantity field label
  ///
  /// In en, this message translates to:
  /// **'Minimum Quantity'**
  String get minimumQuantity;

  /// Minimum quantity field hint
  ///
  /// In en, this message translates to:
  /// **'Enter minimum quantity for restock alert'**
  String get enterMinimumQuantity;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Save changes button text
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// Restock item dialog title
  ///
  /// In en, this message translates to:
  /// **'Restock Item'**
  String get restockItem;

  /// Current quantity text
  ///
  /// In en, this message translates to:
  /// **'Current quantity: {quantity} {unit}'**
  String currentQuantity(int quantity, String unit);

  /// Add quantity field label
  ///
  /// In en, this message translates to:
  /// **'Add Quantity'**
  String get addQuantity;

  /// Add quantity field hint
  ///
  /// In en, this message translates to:
  /// **'Enter quantity to add'**
  String get enterQuantityToAdd;

  /// Restock button text
  ///
  /// In en, this message translates to:
  /// **'Restock'**
  String get restock;

  /// Delete stock item dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Stock Item'**
  String get deleteStockItem;

  /// Delete confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {itemName}?'**
  String deleteConfirmation(String itemName);

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Last restocked date text
  ///
  /// In en, this message translates to:
  /// **'Last restocked: {date}'**
  String lastRestocked(String date);

  /// Needs restock label
  ///
  /// In en, this message translates to:
  /// **'Needs Restock'**
  String get needsRestock;

  /// Restock now button text
  ///
  /// In en, this message translates to:
  /// **'Restock Now'**
  String get restockNow;

  /// No description provided for @adminPanel.
  ///
  /// In en, this message translates to:
  /// **'Admin Panel'**
  String get adminPanel;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @errorWithMessage.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorWithMessage(Object error);

  /// No description provided for @totalClinics.
  ///
  /// In en, this message translates to:
  /// **'Total Clinics'**
  String get totalClinics;

  /// No description provided for @activeClinics.
  ///
  /// In en, this message translates to:
  /// **'Active Clinics'**
  String get activeClinics;

  /// No description provided for @totalUsers.
  ///
  /// In en, this message translates to:
  /// **'Total Users'**
  String get totalUsers;

  /// No description provided for @totalAppointments.
  ///
  /// In en, this message translates to:
  /// **'Total Appointments'**
  String get totalAppointments;

  /// No description provided for @manageClinics.
  ///
  /// In en, this message translates to:
  /// **'Manage Clinics'**
  String get manageClinics;

  /// No description provided for @addEditRemoveClinics.
  ///
  /// In en, this message translates to:
  /// **'Add, edit, or remove clinics'**
  String get addEditRemoveClinics;

  /// No description provided for @manageUsers.
  ///
  /// In en, this message translates to:
  /// **'Manage Users'**
  String get manageUsers;

  /// No description provided for @viewManageUsers.
  ///
  /// In en, this message translates to:
  /// **'View and manage user accounts'**
  String get viewManageUsers;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System Settings'**
  String get systemSettings;

  /// No description provided for @configureSystemPreferences.
  ///
  /// In en, this message translates to:
  /// **'Configure system preferences'**
  String get configureSystemPreferences;

  /// No description provided for @addNewClinic.
  ///
  /// In en, this message translates to:
  /// **'Add New Clinic'**
  String get addNewClinic;

  /// No description provided for @clinicName.
  ///
  /// In en, this message translates to:
  /// **'Clinic Name'**
  String get clinicName;

  /// No description provided for @address.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// No description provided for @phone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get phone;

  /// Title for admin controls section
  ///
  /// In en, this message translates to:
  /// **'Admin Controls'**
  String get adminControls;

  /// Title for super admin panel card
  ///
  /// In en, this message translates to:
  /// **'Super Admin Panel'**
  String get superAdminPanel;

  /// Description for super admin panel card
  ///
  /// In en, this message translates to:
  /// **'Manage clinics, users, and view statistics'**
  String get manageClinicsUsersStats;

  /// Title for email verification screen
  ///
  /// In en, this message translates to:
  /// **'Verify Email'**
  String get emailVerificationRequired;

  /// Message shown on email verification screen
  ///
  /// In en, this message translates to:
  /// **'Please check your email and click the verification link to continue.'**
  String get pleaseVerifyEmail;

  /// Button text for resending verification email
  ///
  /// In en, this message translates to:
  /// **'Resend Email'**
  String get resendVerificationEmail;

  /// Message shown when verification email is sent
  ///
  /// In en, this message translates to:
  /// **'Verification email sent. Please check your inbox.'**
  String get verificationEmailSent;

  /// OK button text
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @confirmPassword.
  ///
  /// In en, this message translates to:
  /// **'Confirm Password'**
  String get confirmPassword;

  /// No description provided for @registrationSuccess.
  ///
  /// In en, this message translates to:
  /// **'Registration Successful'**
  String get registrationSuccess;

  /// Message shown when email is verified successfully
  ///
  /// In en, this message translates to:
  /// **'Email verified successfully!'**
  String get emailVerifiedSuccess;

  /// Message shown when email is not verified yet
  ///
  /// In en, this message translates to:
  /// **'Email not verified yet. Please check your inbox.'**
  String get emailNotVerifiedYet;

  /// Button text for checking verification status
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get checkStatus;

  /// Button text for returning to login screen
  ///
  /// In en, this message translates to:
  /// **'Back to Login'**
  String get backToLogin;

  /// Title for clinic management screen
  ///
  /// In en, this message translates to:
  /// **'Clinic Management'**
  String get clinicManagement;

  /// Message shown when no clinics are found
  ///
  /// In en, this message translates to:
  /// **'No Clinics Found'**
  String get noClinicsFound;

  /// Message to add first clinic
  ///
  /// In en, this message translates to:
  /// **'Add a new clinic to get started'**
  String get addClinicToStart;

  /// Add clinic button text
  ///
  /// In en, this message translates to:
  /// **'Add Clinic'**
  String get addClinic;

  /// No description provided for @noAppointmentsFound.
  ///
  /// In en, this message translates to:
  /// **'No appointments found'**
  String get noAppointmentsFound;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'tr': return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
