import 'package:flutter/material.dart';

class AdaptivePlatformScope extends InheritedWidget {
  const AdaptivePlatformScope({
    required this.platform,
    required super.child,
    super.key,
  });

  final TargetPlatform platform;

  static TargetPlatform of(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AdaptivePlatformScope>()
          ?.platform ??
      Theme.of(context).platform;

  @override
  bool updateShouldNotify(AdaptivePlatformScope oldWidget) =>
      oldWidget.platform != platform;
}

bool isCupertinoPlatform(BuildContext context) =>
    AdaptivePlatformScope.of(context) == TargetPlatform.iOS;

bool isCupertinoTarget(TargetPlatform platform) =>
    platform == TargetPlatform.iOS;
