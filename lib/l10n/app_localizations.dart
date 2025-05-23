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

  /// Message when there are no appointments today
  ///
  /// In en, this message translates to:
  /// **'No appointments for today'**
  String get noAppointmentsToday;

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

  /// Clinic management screen title
  ///
  /// In en, this message translates to:
  /// **'Clinic Management'**
  String get clinicManagement;

  /// Clinic management section subtitle
  ///
  /// In en, this message translates to:
  /// **'Manage clinic information and operators'**
  String get manageClinicInfoAndOperators;

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

  /// Splash screen slogan
  ///
  /// In en, this message translates to:
  /// **'Smart Healthcare, Easy Management'**
  String get splashSlogan;

  /// Register screen title
  ///
  /// In en, this message translates to:
  /// **'Create Your Account'**
  String get registerTitle;

  /// Register screen subtitle
  ///
  /// In en, this message translates to:
  /// **'Join our healthcare community'**
  String get registerSubtitle;

  /// Name field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your full name'**
  String get nameHint;

  /// Email field hint text
  ///
  /// In en, this message translates to:
  /// **'Enter your email address'**
  String get emailHint;

  /// Password field hint text
  ///
  /// In en, this message translates to:
  /// **'Create a password'**
  String get passwordHint;

  /// Confirm password field hint text
  ///
  /// In en, this message translates to:
  /// **'Confirm your password'**
  String get confirmPasswordHint;

  /// Password match validation message
  ///
  /// In en, this message translates to:
  /// **'Passwords do not match'**
  String get passwordsDoNotMatch;

  /// Register button text
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get registerButton;

  /// Text for login prompt
  ///
  /// In en, this message translates to:
  /// **'Already have an account?'**
  String get alreadyHaveAccountText;

  /// Login link text
  ///
  /// In en, this message translates to:
  /// **'Sign In'**
  String get loginLink;

  /// Procedure name field label
  ///
  /// In en, this message translates to:
  /// **'Procedure Name'**
  String get procedureName;

  /// Procedure name field hint
  ///
  /// In en, this message translates to:
  /// **'Enter procedure name'**
  String get enterProcedureName;

  /// Procedure name validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter procedure name'**
  String get pleaseEnterProcedureName;

  /// Procedure description field hint
  ///
  /// In en, this message translates to:
  /// **'Enter procedure description'**
  String get enterProcedureDescription;

  /// Description validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter description'**
  String get pleaseEnterDescription;

  /// Procedure price field hint
  ///
  /// In en, this message translates to:
  /// **'Enter procedure price'**
  String get enterProcedurePrice;

  /// Price validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter price'**
  String get pleaseEnterPrice;

  /// Price format validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid price'**
  String get pleaseEnterValidPrice;

  /// Duration field label
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// Procedure duration field hint
  ///
  /// In en, this message translates to:
  /// **'Enter procedure duration'**
  String get enterProcedureDuration;

  /// Minutes unit text
  ///
  /// In en, this message translates to:
  /// **'minutes'**
  String get minutes;

  /// Duration validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter duration'**
  String get pleaseEnterDuration;

  /// Duration format validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid duration'**
  String get pleaseEnterValidDuration;

  /// Materials section title
  ///
  /// In en, this message translates to:
  /// **'Materials'**
  String get materials;

  /// Add material dialog title
  ///
  /// In en, this message translates to:
  /// **'Add Material'**
  String get addMaterial;

  /// Stock item selection field label
  ///
  /// In en, this message translates to:
  /// **'Select Stock Item'**
  String get selectStockItem;

  /// Quantity field hint
  ///
  /// In en, this message translates to:
  /// **'Enter quantity'**
  String get enterQuantity;

  /// Quantity validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter quantity'**
  String get pleaseEnterQuantity;

  /// Quantity format validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid quantity'**
  String get pleaseEnterValidQuantity;

  /// Add button text
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// Edit procedure dialog title
  ///
  /// In en, this message translates to:
  /// **'Edit Procedure'**
  String get editProcedure;

  /// Delete procedure dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Procedure'**
  String get deleteProcedure;

  /// Delete procedure confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete {procedureName}?'**
  String deleteProcedureConfirmation(String procedureName);

  /// Unit validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter unit'**
  String get pleaseEnterUnit;

  /// Minimum quantity validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter minimum quantity'**
  String get pleaseEnterMinimumQuantity;

  /// Monthly income card title
  ///
  /// In en, this message translates to:
  /// **'Monthly Income'**
  String get monthlyIncome;

  /// Stock value card title
  ///
  /// In en, this message translates to:
  /// **'Stock Value'**
  String get stockValue;

  /// Profit margin card title
  ///
  /// In en, this message translates to:
  /// **'Profit Margin'**
  String get profitMargin;

  /// Expenses section title
  ///
  /// In en, this message translates to:
  /// **'Expenses'**
  String get expenses;

  /// Add expense button text
  ///
  /// In en, this message translates to:
  /// **'Add Expense'**
  String get addExpense;

  /// Message when no expenses are found
  ///
  /// In en, this message translates to:
  /// **'No Expenses Found'**
  String get noExpensesFound;

  /// Invoice number text
  ///
  /// In en, this message translates to:
  /// **'Invoice No: {number}'**
  String invoiceNumber(String number);

  /// Delete expense dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Expense'**
  String get deleteExpense;

  /// Delete expense confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this expense?'**
  String get deleteExpenseConfirmation;

  /// Operators section title
  ///
  /// In en, this message translates to:
  /// **'Operators'**
  String get operators;

  /// Add operator button text
  ///
  /// In en, this message translates to:
  /// **'Add Operator'**
  String get addOperator;

  /// Message when no operators are found
  ///
  /// In en, this message translates to:
  /// **'No Operators Found'**
  String get noOperatorsFound;

  /// Delete operator dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Operator'**
  String get deleteOperator;

  /// Delete operator confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this operator?'**
  String get deleteOperatorConfirmation;

  /// Doctors section title
  ///
  /// In en, this message translates to:
  /// **'Doctors'**
  String get doctors;

  /// Add doctor button text
  ///
  /// In en, this message translates to:
  /// **'Add Doctor'**
  String get addDoctor;

  /// Message when no doctors are found
  ///
  /// In en, this message translates to:
  /// **'No Doctors Found'**
  String get noDoctorsFound;

  /// Delete doctor dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Doctor'**
  String get deleteDoctor;

  /// Delete doctor confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this doctor?'**
  String get deleteDoctorConfirmation;

  /// This month text for charts
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// Critical stock text for charts
  ///
  /// In en, this message translates to:
  /// **'Critical Stock'**
  String get criticalStock;

  /// Today text for profit margin chart
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayProfit;

  /// New appointment screen title
  ///
  /// In en, this message translates to:
  /// **'New Appointment'**
  String get newAppointment;

  /// Validation message for date and time selection
  ///
  /// In en, this message translates to:
  /// **'Please select date and time'**
  String get pleaseSelectDateAndTime;

  /// Validation message for procedure selection
  ///
  /// In en, this message translates to:
  /// **'Please select a procedure'**
  String get pleaseSelectProcedure;

  /// Validation message for doctor selection
  ///
  /// In en, this message translates to:
  /// **'Please select a doctor'**
  String get pleaseSelectDoctor;

  /// Validation message for patient selection
  ///
  /// In en, this message translates to:
  /// **'Please select a patient'**
  String get pleaseSelectPatient;

  /// Success message when appointment is created
  ///
  /// In en, this message translates to:
  /// **'Appointment created successfully'**
  String get appointmentCreatedSuccessfully;

  /// Error message prefix
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Message when user is not found
  ///
  /// In en, this message translates to:
  /// **'User not found'**
  String get userNotFound;

  /// Message when clinic is not found
  ///
  /// In en, this message translates to:
  /// **'Clinic not found'**
  String get clinicNotFound;

  /// Patient information section title
  ///
  /// In en, this message translates to:
  /// **'Patient Information'**
  String get patientInformation;

  /// Patient selection dropdown label
  ///
  /// In en, this message translates to:
  /// **'Select Patient'**
  String get selectPatient;

  /// Patient selection dropdown hint
  ///
  /// In en, this message translates to:
  /// **'Select a patient'**
  String get selectPatientHint;

  /// Patient search field hint
  ///
  /// In en, this message translates to:
  /// **'Search by name or phone'**
  String get searchPatientByNameOrPhone;

  /// Message when no patients are found
  ///
  /// In en, this message translates to:
  /// **'No patients found'**
  String get noPatientsFound;

  /// Add new patient button text
  ///
  /// In en, this message translates to:
  /// **'Add New Patient'**
  String get addNewPatient;

  /// Edit patient button text
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get editPatient;

  /// Appointment details section title
  ///
  /// In en, this message translates to:
  /// **'Appointment Details'**
  String get appointmentDetails;

  /// Date selection button text
  ///
  /// In en, this message translates to:
  /// **'Select Date'**
  String get selectDate;

  /// Time selection button text
  ///
  /// In en, this message translates to:
  /// **'Select Time'**
  String get selectTime;

  /// Procedure selection field label
  ///
  /// In en, this message translates to:
  /// **'Procedure'**
  String get procedure;

  /// Doctor selection field label
  ///
  /// In en, this message translates to:
  /// **'Select Doctor'**
  String get selectDoctor;

  /// Doctor selection field hint
  ///
  /// In en, this message translates to:
  /// **'Select a doctor'**
  String get selectDoctorHint;

  /// Doctor search field label
  ///
  /// In en, this message translates to:
  /// **'Search Doctor'**
  String get searchDoctor;

  /// Doctor search field hint
  ///
  /// In en, this message translates to:
  /// **'Search by doctor name'**
  String get searchDoctorByName;

  /// Message when no doctors are available
  ///
  /// In en, this message translates to:
  /// **'No doctors available yet'**
  String get noDoctorsYet;

  /// Notes field label
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// Create appointment button text
  ///
  /// In en, this message translates to:
  /// **'Create Appointment'**
  String get createAppointment;

  /// Patient notes dialog title
  ///
  /// In en, this message translates to:
  /// **'Patient Notes'**
  String get patientNotes;

  /// Notes field hint
  ///
  /// In en, this message translates to:
  /// **'Edit notes...'**
  String get editNotes;

  /// Success message when notes are updated
  ///
  /// In en, this message translates to:
  /// **'Notes updated'**
  String get notesUpdated;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Edit patient screen title
  ///
  /// In en, this message translates to:
  /// **'Edit Patient'**
  String get editPatientTitle;

  /// Delete patient dialog title
  ///
  /// In en, this message translates to:
  /// **'Delete Patient'**
  String get deletePatient;

  /// Delete patient confirmation message
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this patient? This action cannot be undone.'**
  String get deletePatientConfirmation;

  /// Success message when patient is deleted
  ///
  /// In en, this message translates to:
  /// **'Patient deleted successfully'**
  String get patientDeletedSuccessfully;

  /// Success message when patient is updated
  ///
  /// In en, this message translates to:
  /// **'Patient updated successfully'**
  String get patientUpdatedSuccessfully;

  /// Error message when loading patient data fails
  ///
  /// In en, this message translates to:
  /// **'Error loading patient data: {error}'**
  String errorLoadingPatientData(String error);

  /// Validation message for date of birth selection
  ///
  /// In en, this message translates to:
  /// **'Please select date of birth'**
  String get pleaseSelectDateOfBirth;

  /// Phone validation message
  ///
  /// In en, this message translates to:
  /// **'Please enter phone number'**
  String get pleaseEnterPhone;

  /// Date of birth selection text
  ///
  /// In en, this message translates to:
  /// **'Select Date of Birth'**
  String get selectDateOfBirth;

  /// Gender field label
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get gender;

  /// Not specified option for gender
  ///
  /// In en, this message translates to:
  /// **'Not Specified'**
  String get notSpecified;

  /// Male option for gender
  ///
  /// In en, this message translates to:
  /// **'Male'**
  String get male;

  /// Female option for gender
  ///
  /// In en, this message translates to:
  /// **'Female'**
  String get female;

  /// Text for system theme option
  ///
  /// In en, this message translates to:
  /// **'Use System Theme'**
  String get useSystemTheme;

  /// Text for theme option
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;
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
