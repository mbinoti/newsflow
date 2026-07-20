import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'platform.dart';

class AdaptivePageScaffold extends StatelessWidget {
  const AdaptivePageScaffold({
    required this.title,
    required this.body,
    this.actions = const [],
    this.previousPageTitle,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget> actions;
  final String? previousPageTitle;

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(context)) {
      return CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          middle: Text(title),
          previousPageTitle: previousPageTitle,
          trailing: actions.isEmpty
              ? null
              : Row(mainAxisSize: MainAxisSize.min, children: actions),
        ),
        child: SafeArea(bottom: false, child: body),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(title), actions: actions),
      body: body,
    );
  }
}

class AdaptiveIconButton extends StatelessWidget {
  const AdaptiveIconButton({
    required this.onPressed,
    required this.materialIcon,
    required this.cupertinoIcon,
    required this.tooltip,
    super.key,
  });

  final VoidCallback? onPressed;
  final IconData materialIcon;
  final IconData cupertinoIcon;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(context)) {
      return Semantics(
        button: true,
        label: tooltip,
        child: CupertinoButton(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          onPressed: onPressed,
          child: Icon(cupertinoIcon, size: 23),
        ),
      );
    }
    return IconButton(
      onPressed: onPressed,
      icon: Icon(materialIcon),
      tooltip: tooltip,
    );
  }
}

class AdaptiveButton extends StatelessWidget {
  const AdaptiveButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(context)) {
      return CupertinoButton.filled(
        onPressed: onPressed,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 19),
              const SizedBox(width: 8),
            ],
            Text(label),
          ],
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onPressed,
      icon: icon == null ? const SizedBox.shrink() : Icon(icon),
      label: Text(label),
    );
  }
}

class AdaptiveLoadingIndicator extends StatelessWidget {
  const AdaptiveLoadingIndicator({super.key});

  @override
  Widget build(BuildContext context) => Center(
    child: isCupertinoPlatform(context)
        ? const CupertinoActivityIndicator(radius: 14)
        : const CircularProgressIndicator(),
  );
}

class AdaptiveSearchField extends StatelessWidget {
  const AdaptiveSearchField({
    required this.controller,
    required this.onChanged,
    this.placeholder = 'Pesquisar notícias',
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    if (isCupertinoPlatform(context)) {
      return CupertinoSearchTextField(
        controller: controller,
        placeholder: placeholder,
        onChanged: onChanged,
      );
    }
    return SearchBar(
      controller: controller,
      hintText: placeholder,
      leading: const Icon(Icons.search),
      trailing: [
        if (controller.text.isNotEmpty)
          IconButton(
            tooltip: 'Limpar pesquisa',
            onPressed: () {
              controller.clear();
              onChanged('');
            },
            icon: const Icon(Icons.close),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

class AdaptiveErrorView extends StatelessWidget {
  const AdaptiveErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isCupertinoPlatform(context)
                ? CupertinoIcons.exclamationmark_triangle
                : Icons.error_outline,
            size: 42,
          ),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 20),
          AdaptiveButton(label: 'Tentar novamente', onPressed: onRetry),
        ],
      ),
    ),
  );
}

Future<bool> showAdaptiveConfirmation(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool destructive = false,
}) async {
  if (isCupertinoPlatform(context)) {
    return await showCupertinoDialog<bool>(
          context: context,
          builder: (context) => CupertinoAlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              CupertinoDialogAction(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              CupertinoDialogAction(
                isDestructiveAction: destructive,
                onPressed: () => Navigator.pop(context, true),
                child: Text(confirmLabel),
              ),
            ],
          ),
        ) ??
        false;
  }
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: destructive
                  ? TextButton.styleFrom(foregroundColor: Colors.red)
                  : null,
              child: Text(confirmLabel),
            ),
          ],
        ),
      ) ??
      false;
}

void showAdaptiveMessage(BuildContext context, String message) {
  if (isCupertinoPlatform(context)) {
    showCupertinoDialog<void>(
      context: context,
      builder: (context) => CupertinoAlertDialog(
        content: Text(message),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  } else {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
