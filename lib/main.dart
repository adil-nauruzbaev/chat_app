import 'package:chat_app_test/pages/login_page.dart';
import 'package:chat_app_test/utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

void main() async {
  await setup();
  runApp(MyApp());
}

Future<void> setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupFirebase();
  await registeredServices();
}

class MyApp extends StatelessWidget {
  final GetIt _getIt = GetIt.instance;
  MyApp({super.key}) {}

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Gilroy',
      ),
      home: LoginPage(),
    );
  }
}
