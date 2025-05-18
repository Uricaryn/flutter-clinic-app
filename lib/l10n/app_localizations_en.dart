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
  String get noAppointmentsToday => 'No appointments for today';

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
  String get emailVerificationRequired => 'Verify Email';

  @override
  String get pleaseVerifyEmail => 'Please check your email and click the verification link to continue.';

  @override
  String get resendVerificationEmail => 'Resend Email';

  @override
  String get verificationEmailSent => 'Verification email sent. Please check your inbox.';

  @override
  String get ok => 'OK';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get registrationSuccess => 'Registration Successful';

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
  String get manageClinicInfoAndOperators => 'Manage clinic information and operators';

  @override
  String get noClinicsFound => 'No Clinics Found';

  @override
  String get addClinicToStart => 'Add a new clinic to get started';

  @override
  String get addClinic => 'Add Clinic';

  @override
  String get noAppointmentsFound => 'No appointments found';

  @override
  String get splashSlogan => 'Smart Healthcare, Easy Management';

  @override
  String get registerTitle => 'Create Your Account';

  @override
  String get registerSubtitle => 'Join our healthcare community';

  @override
  String get nameHint => 'Enter your full name';

  @override
  String get emailHint => 'Enter your email address';

  @override
  String get passwordHint => 'Create a password';

  @override
  String get confirmPasswordHint => 'Confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get registerButton => 'Create Account';

  @override
  String get alreadyHaveAccountText => 'Already have an account?';

  @override
  String get loginLink => 'Sign In';

  @override
  String get procedureName => 'Procedure Name';

  @override
  String get enterProcedureName => 'Enter procedure name';

  @override
  String get pleaseEnterProcedureName => 'Please enter procedure name';

  @override
  String get enterProcedureDescription => 'Enter procedure description';

  @override
  String get pleaseEnterDescription => 'Please enter description';

  @override
  String get enterProcedurePrice => 'Enter procedure price';

  @override
  String get pleaseEnterPrice => 'Please enter price';

  @override
  String get pleaseEnterValidPrice => 'Please enter a valid price';

  @override
  String get duration => 'Duration';

  @override
  String get enterProcedureDuration => 'Enter procedure duration';

  @override
  String get minutes => 'minutes';

  @override
  String get pleaseEnterDuration => 'Please enter duration';

  @override
  String get pleaseEnterValidDuration => 'Please enter a valid duration';

  @override
  String get materials => 'Materials';

  @override
  String get addMaterial => 'Add Material';

  @override
  String get selectStockItem => 'Select Stock Item';

  @override
  String get enterQuantity => 'Enter quantity';

  @override
  String get pleaseEnterQuantity => 'Please enter quantity';

  @override
  String get pleaseEnterValidQuantity => 'Please enter a valid quantity';

  @override
  String get add => 'Add';

  @override
  String get editProcedure => 'Edit Procedure';

  @override
  String get deleteProcedure => 'Delete Procedure';

  @override
  String deleteProcedureConfirmation(String procedureName) {
    return 'Are you sure you want to delete $procedureName?';
  }

  @override
  String get pleaseEnterUnit => 'Please enter unit';

  @override
  String get pleaseEnterMinimumQuantity => 'Please enter minimum quantity';

  @override
  String get monthlyIncome => 'Monthly Income';

  @override
  String get stockValue => 'Stock Value';

  @override
  String get profitMargin => 'Profit Margin';

  @override
  String get expenses => 'Expenses';

  @override
  String get addExpense => 'Add Expense';

  @override
  String get noExpensesFound => 'No Expenses Found';

  @override
  String invoiceNumber(String number) {
    return 'Invoice No: $number';
  }

  @override
  String get deleteExpense => 'Delete Expense';

  @override
  String get deleteExpenseConfirmation => 'Are you sure you want to delete this expense?';

  @override
  String get operators => 'Operators';

  @override
  String get addOperator => 'Add Operator';

  @override
  String get noOperatorsFound => 'No Operators Found';

  @override
  String get deleteOperator => 'Delete Operator';

  @override
  String get deleteOperatorConfirmation => 'Are you sure you want to delete this operator?';

  @override
  String get doctors => 'Doctors';

  @override
  String get addDoctor => 'Add Doctor';

  @override
  String get noDoctorsFound => 'No Doctors Found';

  @override
  String get deleteDoctor => 'Delete Doctor';

  @override
  String get deleteDoctorConfirmation => 'Are you sure you want to delete this doctor?';

  @override
  String get thisMonth => 'This Month';

  @override
  String get criticalStock => 'Critical Stock';

  @override
  String get todayProfit => 'Today';

  @override
  String get newAppointment => 'New Appointment';

  @override
  String get pleaseSelectDateAndTime => 'Please select date and time';

  @override
  String get pleaseSelectProcedure => 'Please select a procedure';

  @override
  String get pleaseSelectDoctor => 'Please select a doctor';

  @override
  String get pleaseSelectPatient => 'Please select a patient';

  @override
  String get appointmentCreatedSuccessfully => 'Appointment created successfully';

  @override
  String get error => 'Error';

  @override
  String get userNotFound => 'User not found';

  @override
  String get clinicNotFound => 'Clinic not found';

  @override
  String get patientInformation => 'Patient Information';

  @override
  String get selectPatient => 'Select Patient';

  @override
  String get selectPatientHint => 'Select a patient';

  @override
  String get searchPatientByNameOrPhone => 'Search by name or phone';

  @override
  String get noPatientsFound => 'No patients found';

  @override
  String get addNewPatient => 'Add New Patient';

  @override
  String get editPatient => 'Edit Patient';

  @override
  String get appointmentDetails => 'Appointment Details';

  @override
  String get selectDate => 'Select Date';

  @override
  String get selectTime => 'Select Time';

  @override
  String get procedure => 'Procedure';

  @override
  String get selectDoctor => 'Select Doctor';

  @override
  String get selectDoctorHint => 'Select a doctor';

  @override
  String get searchDoctor => 'Search Doctor';

  @override
  String get searchDoctorByName => 'Search by doctor name';

  @override
  String get noDoctorsYet => 'No doctors available yet';

  @override
  String get notes => 'Notes';

  @override
  String get createAppointment => 'Create Appointment';

  @override
  String get patientNotes => 'Patient Notes';

  @override
  String get editNotes => 'Edit notes...';

  @override
  String get notesUpdated => 'Notes updated';

  @override
  String get save => 'Save';

  @override
  String get editPatientTitle => 'Edit Patient';

  @override
  String get deletePatient => 'Delete Patient';

  @override
  String get deletePatientConfirmation => 'Are you sure you want to delete this patient? This action cannot be undone.';

  @override
  String get patientDeletedSuccessfully => 'Patient deleted successfully';

  @override
  String get patientUpdatedSuccessfully => 'Patient updated successfully';

  @override
  String errorLoadingPatientData(String error) {
    return 'Error loading patient data: $error';
  }

  @override
  String get pleaseSelectDateOfBirth => 'Please select date of birth';

  @override
  String get pleaseEnterPhone => 'Please enter phone number';

  @override
  String get selectDateOfBirth => 'Select Date of Birth';

  @override
  String get gender => 'Gender';

  @override
  String get notSpecified => 'Not Specified';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get useSystemTheme => 'Use System Theme';

  @override
  String get theme => 'Theme';
}
