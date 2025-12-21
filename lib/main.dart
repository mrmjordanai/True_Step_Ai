import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:firebase_core/firebase_core.dart';

import 'app/app.dart';
import 'core/utils/error_handler.dart';
import 'core/utils/performance.dart';
import 'firebase_options.dart';

Future<void> main() async {
  // Start profiling
  startupProfiler.markStart();

  WidgetsFlutterBinding.ensureInitialized();
  startupProfiler.markMilestone('Binding');

  // Set preferred orientations (run in parallel with other init)
  final orientationFuture = SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system UI overlay style for dark theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF0A0A0A),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize Hive and Firebase in parallel
  await Future.wait([
    orientationFuture,
    Hive.initFlutter(),
    Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform),
  ]);
  startupProfiler.markMilestone('Services');

  // Initialize error handling (includes Crashlytics integration)
  errorHandler.initialize();

  runApp(const ProviderScope(child: TrueStepApp()));

  // Mark startup complete after first frame
  WidgetsBinding.instance.addPostFrameCallback((_) {
    startupProfiler.markComplete();
  });
}
