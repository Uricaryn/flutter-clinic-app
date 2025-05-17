import 'package:flutter/material.dart';
import 'package:clinic_app/features/auth/presentation/screens/login_screen.dart';
import 'package:clinic_app/features/auth/presentation/screens/register_screen.dart';
import 'package:clinic_app/features/auth/presentation/screens/registration_success_screen.dart';
import 'package:clinic_app/features/home/presentation/screens/home_screen.dart';
import 'package:clinic_app/features/clinic/presentation/screens/clinic_manager_panel_screen.dart';
import 'package:clinic_app/features/appointment/presentation/screens/appointments_screen.dart';
import 'package:clinic_app/features/appointment/presentation/screens/new_appointment_screen.dart';
import 'package:clinic_app/features/patient/presentation/screens/new_patient_screen.dart';
import 'package:clinic_app/features/appointment/presentation/screens/edit_appointment_screen.dart';
import 'package:clinic_app/features/appointment/presentation/screens/appointment_details_screen.dart';
import 'package:clinic_app/features/patient/presentation/screens/edit_patient_screen.dart';
import 'package:clinic_app/features/appointment/domain/models/appointment_model.dart';

class AppRouter {
  static const String login = '/login';
  static const String register = '/register';
  static const String registrationSuccess = '/registration-success';
  static const String home = '/home';
  static const String clinicManager = '/clinic-manager';
  static const String appointments = '/appointments';
  static const String newAppointment = '/appointment/new';
  static const String newPatient = '/patient/new';
  static const String editPatient = '/patient/edit';
  static const String editAppointment = '/appointment/edit';
  static const String appointmentDetails = '/appointment/details';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case registrationSuccess:
        return MaterialPageRoute(
            builder: (_) => const RegistrationSuccessScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case clinicManager:
        return MaterialPageRoute(
            builder: (_) => const ClinicManagerPanelScreen());
      case appointments:
        return MaterialPageRoute(builder: (_) => const AppointmentsScreen());
      case newAppointment:
        return MaterialPageRoute(builder: (_) => const NewAppointmentScreen());
      case newPatient:
        return MaterialPageRoute(builder: (_) => const NewPatientScreen());
      case editPatient:
        final patientId = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => EditPatientScreen(patientId: patientId),
        );
      case editAppointment:
        final appointment = settings.arguments as AppointmentModel;
        return MaterialPageRoute(
          builder: (_) => EditAppointmentScreen(appointment: appointment),
        );
      case appointmentDetails:
        final appointment = settings.arguments as AppointmentModel;
        return MaterialPageRoute(
          builder: (_) => AppointmentDetailsScreen(appointment: appointment),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }
}
