import 'package:auto_route/auto_route.dart';
import 'package:flutter_healthkit/core/navigation/navigation.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: SplashView.page, initial: true),
    AutoRoute(page: LoginView.page),
    AutoRoute(page: HomeView.page),
    AutoRoute(page: AuthWebView.page),
    AutoRoute(page: DataCollectorDetailView.page),
  ];
}
