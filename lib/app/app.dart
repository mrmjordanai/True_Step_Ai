import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'routes.dart';
import 'theme.dart';

/// Root application widget for TrueStep
class TrueStepApp extends ConsumerWidget {
  const TrueStepApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'TrueStep',
      debugShowCheckedModeBanner: false,
      theme: TrueStepTheme.darkTheme,
      routerConfig: router,
    );
  }
}
