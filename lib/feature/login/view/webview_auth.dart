import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_healthkit/core/app_constants.dart';
import 'package:flutter_healthkit/core/navigation/navigation.gr.dart';
import 'package:flutter_healthkit/core/network/service.dart';
import 'package:flutter_healthkit/feature/health/notifier/data_collectors_notifier.dart';
import 'package:flutter_healthkit/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

@RoutePage()
class AuthWebView extends ConsumerStatefulWidget {
  const AuthWebView({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AuthWebViewState();
}

class _AuthWebViewState extends ConsumerState<AuthWebView> {
  final _authService = AuthService();
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: _onNavigationRequest,
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? true) _goToLogin();
          },
          onSslAuthError: (error) => error.proceed(),
        ),
      )
      ..loadRequest(_authorizeUri);
  }

  Uri get _authorizeUri => Uri.parse(AppConstants.authUrl);

  Future<NavigationDecision> _onNavigationRequest(
    NavigationRequest request,
  ) async {
    final params = Uri.parse(request.url).queryParameters;

    if (params.containsKey('error')) {
      _goToLogin();
      return NavigationDecision.prevent;
    }

    final code = params['code'];
    if (code == null) {
      return NavigationDecision.navigate;
    }

    final token = await _authService.postOAuthToken(code: code);
    if (token != null) {
      if (mounted) {
        ref.invalidate(dataCollectorsNotifierProvider);
        appRouter.replace(const HomeView());
      }
    } else {
      _goToLogin();
    }
    return NavigationDecision.prevent;
  }

  void _goToLogin() {
    if (mounted) appRouter.replace(const LoginView());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: WebViewWidget(controller: _controller)),
    );
  }
}
