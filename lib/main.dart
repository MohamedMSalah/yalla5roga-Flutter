import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:yalla_5roga/app.dart';
import 'package:yalla_5roga/core/di/app_dependencies.dart';
import 'package:yalla_5roga/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final deps = await AppDependencies.create();
  runApp(App(deps: deps));
}
