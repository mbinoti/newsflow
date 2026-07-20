import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/adaptive/adaptive_widgets.dart';
import '../../core/adaptive/platform.dart';
import '../news/presentation/news_providers.dart';
import 'settings_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<SettingsController>();
    final settings = controller.settings;
    if (isCupertinoPlatform(context)) {
      return AdaptivePageScaffold(
        title: 'Ajustes',
        body: ListView(
          children: [
            CupertinoListSection.insetGrouped(
              header: const Text('APARÊNCIA'),
              children: [
                CupertinoListTile(
                  title: const Text('Tema'),
                  additionalInfo: Text(_themeLabel(settings.themeMode)),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () =>
                      _selectTheme(context, controller, settings.themeMode),
                ),
                CupertinoListTile(
                  title: const Text('Tamanho do texto'),
                  additionalInfo: Text(
                    '${(settings.textScale * 100).round()}%',
                  ),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _selectTextScale(context, controller),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('NOTÍCIAS'),
              children: [
                CupertinoListTile(
                  title: const Text('País padrão'),
                  additionalInfo: Text(settings.country.toUpperCase()),
                  trailing: const CupertinoListTileChevron(),
                  onTap: () => _selectCountry(context, controller),
                ),
              ],
            ),
            CupertinoListSection.insetGrouped(
              header: const Text('SOBRE'),
              children: const [
                CupertinoListTile(
                  title: Text('NewsFlow'),
                  subtitle: Text('Notícias fornecidas por NewsAPI.org'),
                  additionalInfo: Text('1.0.0'),
                ),
              ],
            ),
          ],
        ),
      );
    }
    return AdaptivePageScaffold(
      title: 'Configurações',
      body: ListView(
        children: [
          const _SectionTitle('Aparência'),
          ListTile(
            leading: const Icon(Icons.brightness_6_outlined),
            title: const Text('Tema'),
            subtitle: Text(_themeLabel(settings.themeMode)),
            onTap: () => _selectTheme(context, controller, settings.themeMode),
          ),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Tamanho do texto'),
            subtitle: Text('${(settings.textScale * 100).round()}%'),
            onTap: () => _selectTextScale(context, controller),
          ),
          const Divider(),
          const _SectionTitle('Notícias'),
          ListTile(
            leading: const Icon(Icons.public),
            title: const Text('País padrão'),
            subtitle: Text(settings.country.toUpperCase()),
            onTap: () => _selectCountry(context, controller),
          ),
          const Divider(),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('NewsFlow'),
            subtitle: Text(
              'Notícias fornecidas por NewsAPI.org • versão 1.0.0',
            ),
          ),
        ],
      ),
    );
  }

  String _themeLabel(ThemeMode mode) => switch (mode) {
    ThemeMode.system => 'Sistema',
    ThemeMode.light => 'Claro',
    ThemeMode.dark => 'Escuro',
  };

  Future<void> _selectTheme(
    BuildContext context,
    SettingsController controller,
    ThemeMode selected,
  ) async {
    final value = await _choose<ThemeMode>(
      context,
      title: 'Tema',
      values: ThemeMode.values,
      label: _themeLabel,
    );
    if (value != null) await controller.setThemeMode(value);
  }

  Future<void> _selectCountry(
    BuildContext context,
    SettingsController controller,
  ) async {
    final value = await _choose<String>(
      context,
      title: 'País padrão',
      values: const ['br', 'us', 'pt', 'gb'],
      label: (value) => const {
        'br': 'Brasil',
        'us': 'Estados Unidos',
        'pt': 'Portugal',
        'gb': 'Reino Unido',
      }[value]!,
    );
    if (value != null) {
      await controller.setCountry(value);
      if (context.mounted) {
        await context.read<HeadlinesController>().setCountry(value);
      }
    }
  }

  Future<void> _selectTextScale(
    BuildContext context,
    SettingsController controller,
  ) async {
    final value = await _choose<double>(
      context,
      title: 'Tamanho do texto',
      values: const [0.9, 1, 1.15, 1.3],
      label: (value) => '${(value * 100).round()}%',
    );
    if (value != null) await controller.setTextScale(value);
  }

  Future<T?> _choose<T>(
    BuildContext context, {
    required String title,
    required List<T> values,
    required String Function(T value) label,
  }) {
    if (isCupertinoPlatform(context)) {
      return showCupertinoModalPopup<T>(
        context: context,
        builder: (context) => CupertinoActionSheet(
          title: Text(title),
          actions: values
              .map(
                (value) => CupertinoActionSheetAction(
                  onPressed: () => Navigator.pop(context, value),
                  child: Text(label(value)),
                ),
              )
              .toList(),
          cancelButton: CupertinoActionSheetAction(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ),
      );
    }
    return showDialog<T>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(title),
        children: values
            .map(
              (value) => SimpleDialogOption(
                onPressed: () => Navigator.pop(context, value),
                child: Text(label(value)),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
    child: Text(
      text.toUpperCase(),
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
        color: Theme.of(context).colorScheme.primary,
      ),
    ),
  );
}
