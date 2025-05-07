# Flutter Clinic App

A comprehensive clinic management application built with Flutter and Firebase.

## Features

- User Authentication (Admin, Doctor, Nurse, Receptionist, Patient)
- Clinic Management
- Appointment Scheduling
- Patient Records
- Stock Management
- Procedure Management
- Real-time Notifications
- Analytics Dashboard

## Setup

1. Clone the repository:
```bash
git clone https://github.com/yourusername/flutter-clinic-app.git
cd flutter-clinic-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Firebase Setup:
   - Create a new Firebase project
   - Enable Authentication, Firestore, Storage, and Cloud Functions
   - Download `google-services.json` and place it in `android/app/`
   - Download `GoogleService-Info.plist` and place it in `ios/Runner/`

4. Environment Setup:
   - Copy `google-services.json.example` to `google-services.json`
   - Update the Firebase configuration with your project details

5. Run the app:
```bash
flutter run
```

## Project Structure

```
lib/
├── core/           # Core functionality and services
├── features/       # Feature modules
│   ├── admin/     # Admin panel
│   ├── auth/      # Authentication
│   ├── clinic/    # Clinic management
│   ├── profile/   # User profiles
│   └── ...
└── shared/        # Shared widgets and utilities
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Flutter Team
- Firebase Team
- All contributors 