import 'dart:math';

import 'package:adminnut4health/src/features/authentication/presentation/splash/splash_screen_controller.dart';
import 'package:adminnut4health/src/utils/async_value_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../constants/keys.dart';
import '../../../../routing/app_router.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  static const Key emailPasswordButtonKey = Key(Keys.emailPassword);
  static const Key anonymousButtonKey = Key(Keys.anonymous);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen<AsyncValue>(
      splashScreenControllerProvider,
      (_, state) => state.showAlertDialogOnError(context),
    );
    Future.delayed(const Duration(seconds: 2), () {
      context.goNamed(AppRoute.emailPassword.name);
    });
    return Scaffold(
      body: Center(
        child: LayoutBuilder(builder: (context, constraints) {
          return Container(
            width: min(constraints.maxWidth, 600),
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(height: 32.0),
                Image.asset("assets/logo.png"),
                // Sign in text or loading UI
              ],
            ),
          );
        }),
      ),
    );
  }
}
