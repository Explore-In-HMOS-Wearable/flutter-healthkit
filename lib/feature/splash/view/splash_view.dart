import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/navigation/navigation.gr.dart';
import 'package:flutter_healthkit/core/network/service.dart';
import 'package:flutter_healthkit/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

@RoutePage()
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> {
  final _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _routeAfterSessionCheck();
  }

  Future<void> _routeAfterSessionCheck() async {
    final results = await Future.wait([
      _authService.hasSession(),
      Future.delayed(const Duration(seconds: 2)),
    ]);
    if (!mounted) return;

    final hasSession = results[0] as bool;
    appRouter.replace(hasSession ? const HomeView() : const LoginView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          'assets/lottie/splash_animation.json',
          width: 100,
          height: 100,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
