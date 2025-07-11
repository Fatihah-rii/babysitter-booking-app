import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

import 'splash_screen.dart';
import 'login.dart';
import 'register.dart';
import 'home.dart';
import 'babysitter_profile.dart';
import 'booking_form.dart';
import 'edit_booking.dart';
import 'my_bookings.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Babysitter Booking App',
      theme: ThemeData(fontFamily: 'Poppins'),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const SplashScreen());
          case '/login':
            return MaterialPageRoute(builder: (_) => const LoginScreen());
          case '/register':
            return MaterialPageRoute(builder: (_) => const RegisterScreen());
          case '/home':
            return MaterialPageRoute(builder: (_) => const HomeScreen());
          case '/myBookings':
            return MaterialPageRoute(builder: (_) => const MyBookingsPage());
          case '/babysitterProfile':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => BabysitterProfile(babysitterData: args),
            );
          case '/editBooking':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => EditBookingPage(docId: args['docId'], data: args['data']),
            );
          case '/bookingForm':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => BookingForm(babysitterData: args),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Page not found')),
              ),
            );
        }
      },
    );
  }
}
