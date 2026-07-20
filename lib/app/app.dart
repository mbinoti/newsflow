import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../core/adaptive/platform.dart';
import '../features/settings/settings_controller.dart';
import 'router.dart';
import 'theme.dart';

class NewsFlowApp extends StatefulWidget {
  const NewsFlowApp({this.platformOverride, super.key});

  final TargetPlatform? platformOverride;

  @override
  State<NewsFlowApp> createState() => _NewsFlowAppState();
}

class _NewsFlowAppState extends State<NewsFlowApp> {
  late final GoRouter _router = createRouter();

  @override
  void dispose() {
    _router.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsController>().settings;
    final platform = widget.platformOverride ?? defaultTargetPlatform;
    final systemBrightness =
        WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final brightness = switch (settings.themeMode) {
      ThemeMode.light => Brightness.light,
      ThemeMode.dark => Brightness.dark,
      ThemeMode.system => systemBrightness,
    };

    Widget mediaBuilder(BuildContext context, Widget? child) {
      final media = MediaQuery.of(context);
      return AdaptivePlatformScope(
        platform: platform,
        child: MediaQuery(
          data: media.copyWith(
            textScaler: TextScaler.linear(settings.textScale),
          ),
          child: child!,
        ),
      );
    }

    if (platform == TargetPlatform.iOS) {
      return CupertinoApp.router(
        title: 'NewsFlow',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.cupertino(brightness),
        routerConfig: _router,
        builder: mediaBuilder,
      );
    }

    return MaterialApp.router(
      title: 'NewsFlow',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.material(Brightness.light),
      darkTheme: AppTheme.material(Brightness.dark),
      themeMode: settings.themeMode,
      routerConfig: _router,
      builder: mediaBuilder,
    );
  }
}
