import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Clinic App';

  @override
  String get welcomeBack => 'Welcome back!';

  @override
  String get signInToContinue => 'Sign in to continue';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get signUp => 'Sign Up';

  @override
  String get pleaseEnterEmail => 'Please enter your email';

  @override
  String get pleaseEnterPassword => 'Please enter your password';

  @override
  String get user => 'User';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get appointments => 'Appointments';

  @override
  String get procedures => 'Procedures';

  @override
  String get stock => 'Stock';

  @override
  String get profile => 'Profile';

  @override
  String get recentActivity => 'Recent Activity';

  @override
  String get upcomingAppointments => 'Upcoming Appointments';

  @override
  String youHaveAppointmentsToday(int count) {
    return 'You have $count appointments today';
  }

  @override
  String get lowStockAlert => 'Low Stock Alert';

  @override
  String itemsNeedRestock(int count) {
    return '$count items need to be restocked';
  }

  @override
  String get searchAppointments => 'Search appointments...';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get upcoming => 'Upcoming';

  @override
  String get past => 'Past';

  @override
  String get procedureManagement => 'Procedure Management';

  @override
  String get noProceduresFound => 'No Procedures Found';

  @override
  String get addProcedureToStart => 'Add a new procedure to get started';

  @override
  String get addProcedure => 'Add Procedure';

  @override
  String get accountSettings => 'Account Settings';

  @override
  String get editProfile => 'Edit Profile';

  @override
  String get changeEmail => 'Change Email';

  @override
  String get changePassword => 'Change Password';

  @override
  String get preferences => 'Preferences';

  @override
  String get notifications => 'Notifications';

  @override
  String get language => 'Language';

  @override
  String get signOut => 'Sign Out';

  @override
  String get passwordResetEmailSent => 'Password reset email sent';

  @override
  String get createAccount => 'Create Account';

  @override
  String get joinUs => 'Join Us';

  @override
  String get createAccountToGetStarted => 'Create your account to get started';

  @override
  String get fullName => 'Full Name';

  @override
  String get pleaseEnterName => 'Please enter your name';

  @override
  String get pleaseEnterValidEmail => 'Please enter a valid email';

  @override
  String get passwordMustBeAtLeast6Characters => 'Password must be at least 6 characters';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get home => 'Home';

  @override
  String get stockManagement => 'Stock Management';

  @override
  String get noStockItemsFound => 'No Stock Items Found';

  @override
  String get addStockItemToStart => 'Add a new stock item to get started';

  @override
  String get addStockItem => 'Add Stock Item';

  @override
  String get editStockItem => 'Edit Stock Item';

  @override
  String get addNewStockItem => 'Add New Stock Item';

  @override
  String get itemName => 'Item Name';

  @override
  String get enterItemName => 'Enter item name';

  @override
  String get description => 'Description';

  @override
  String get enterItemDescription => 'Enter item description';

  @override
  String get price => 'Price';

  @override
  String get enterItemPrice => 'Enter item price';

  @override
  String get quantity => 'Quantity';

  @override
  String get enterCurrentQuantity => 'Enter current quantity';

  @override
  String get unit => 'Unit';

  @override
  String get enterUnit => 'Enter unit (e.g., boxes, bottles)';

  @override
  String get minimumQuantity => 'Minimum Quantity';

  @override
  String get enterMinimumQuantity => 'Enter minimum quantity for restock alert';

  @override
  String get cancel => 'Cancel';

  @override
  String get saveChanges => 'Save Changes';

  @override
  String get restockItem => 'Restock Item';

  @override
  String currentQuantity(int quantity, String unit) {
    return 'Current quantity: $quantity $unit';
  }

  @override
  String get addQuantity => 'Add Quantity';

  @override
  String get enterQuantityToAdd => 'Enter quantity to add';

  @override
  String get restock => 'Restock';

  @override
  String get deleteStockItem => 'Delete Stock Item';

  @override
  String deleteConfirmation(String itemName) {
    return 'Are you sure you want to delete $itemName?';
  }

  @override
  String get delete => 'Delete';

  @override
  String lastRestocked(String date) {
    return 'Last restocked: $date';
  }

  @override
  String get needsRestock => 'Needs Restock';

  @override
  String get restockNow => 'Restock Now';

  @override
  String get adminPanel => 'Admin Panel';

  @override
  String get statistics => 'Statistics';

  @override
  String errorWithMessage(Object error) {
    return 'Error: $error';
  }

  @override
  String get totalClinics => 'Total Clinics';

  @override
  String get activeClinics => 'Active Clinics';

  @override
  String get totalUsers => 'Total Users';

  @override
  String get totalAppointments => 'Total Appointments';

  @override
  String get manageClinics => 'Manage Clinics';

  @override
  String get addEditRemoveClinics => 'Add, edit, or remove clinics';

  @override
  String get manageUsers => 'Manage Users';

  @override
  String get viewManageUsers => 'View and manage user accounts';

  @override
  String get systemSettings => 'System Settings';

  @override
  String get configureSystemPreferences => 'Configure system preferences';

  @override
  String get addNewClinic => 'Add New Clinic';

  @override
  String get clinicName => 'Clinic Name';

  @override
  String get address => 'Address';

  @override
  String get phone => 'Phone';

  @override
  String get adminControls => 'Admin Controls';

  @override
  String get superAdminPanel => 'Super Admin Panel';

  @override
  String get manageClinicsUsersStats => 'Manage clinics, users, and view statistics';

  @override
  String get emailVerificationRequired => 'Email Verification Required';

  @override
  String get pleaseVerifyEmail => 'Please verify your email address before logging in. Check your inbox for the verification link.';

  @override
  String get resendVerificationEmail => 'Resend Verification Email';

  @override
  String get verificationEmailSent => 'Verification email sent. Please check your inbox.';

  @override
  String get ok => 'OK';
}
