import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:spk_mobile/HomeScreen/TabelHasilPage.dart';
import 'package:spk_mobile/HomeScreen/inputdata.dart';
import 'package:spk_mobile/HomeScreen/profile.dart';
import 'package:spk_mobile/loginpage/login_page.dart';
import 'package:spk_mobile/SplashScreen/Splash.dart';
import 'package:spk_mobile/loginpage/register.dart';
import 'package:spk_mobile/tutorial/tutor.dart';
import 'HomeScreen/dashboard_page.dart';
import 'HomeScreen/hasil_akhir_page.dart';
import 'main_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SPK SMART',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
routes: {
  '/': (context) => const mainpage(),
  '/login': (context) => const LoginPage(),
  '/register': (context) => const RegisterPage(),
  '/dashboard': (context) => const DashboardPage(),
  '/tutorial': (context) => const TutorialPage(),
  '/input-data': (context) => const InputDataPage(),
  '/hasil-akhir': (context) => const HasilAkhirPage(), 
  '/profile': (context) => const ProfilePage(),
},

      onGenerateRoute: (settings) {
  if (settings.name == '/tabel-hasil') {
    final args = settings.arguments;

    if (args is Map<String, dynamic>) {
      return MaterialPageRoute(
        builder: (_) => TabelHasilPage(
          hasil: List<Map<String, dynamic>>.from(args['hasil'] ?? []),
          alternatif: List<Map<String, dynamic>>.from(args['alternatif'] ?? []),
          kriteria: List<Map<String, dynamic>>.from(args['kriteria'] ?? []),
        ),
      );
    } else {
      // Tangani jika arguments null atau salah format
      return MaterialPageRoute(
        builder: (_) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: const Center(child: Text('Data tidak valid untuk TabelHasilPage')),
        ),
      );
    }
  }

  return null; // default jika route tidak ditemukan
},
    );
  }
}