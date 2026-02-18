import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../providers/base_url_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  static const _customValue = '__custom__';
  String _dropdownValue = presetBaseUrls.first;
  final _customController = TextEditingController();
  final _customFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _syncFromProvider(ref.read(baseUrlProvider));
      }
    });
  }

  @override
  void dispose() {
    _customController.dispose();
    _customFocus.dispose();
    super.dispose();
  }

  void _syncFromProvider(String? savedUrl) {
    if (savedUrl == null || savedUrl.isEmpty) {
      _dropdownValue = presetBaseUrls.first;
      _customController.text = '';
      return;
    }
    final presetIndex = presetBaseUrls.indexOf(savedUrl);
    if (presetIndex >= 0) {
      _dropdownValue = presetBaseUrls[presetIndex];
      _customController.text = '';
    } else {
      _dropdownValue = _customValue;
      _customController.text = savedUrl;
    }
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<String?>(baseUrlProvider, (prev, next) {
      if (mounted) _syncFromProvider(next);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Base URL'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Choose a preset or enter a custom backend URL. All API calls will use this base URL.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                value: presetBaseUrls.contains(_dropdownValue)
                    ? _dropdownValue
                    : _customValue,
                isExpanded: true,
                decoration: InputDecoration(
                  labelText: 'Preset',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                selectedItemBuilder: (context) => [
                  ...presetBaseUrls.map(
                    (url) => Text(
                      url,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  const Text('Custom URL'),
                ],
                items: [
                  ...presetBaseUrls.map(
                    (url) => DropdownMenuItem(
                      value: url,
                      child: Text(
                        url,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ),
                  const DropdownMenuItem(
                    value: _customValue,
                    child: Text('Custom URL'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _dropdownValue = value ?? presetBaseUrls.first;
                    if (_dropdownValue != _customValue) {
                      _customController.clear();
                    }
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_dropdownValue == _customValue) ...[
                TextFormField(
                  controller: _customController,
                  focusNode: _customFocus,
                  decoration: InputDecoration(
                    labelText: 'Custom base URL',
                    hintText: 'https://your-backend.example.com',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  keyboardType: TextInputType.url,
                  autocorrect: false,
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: 24),
              ],
              FilledButton.icon(
                onPressed: () async {
                  final url = _dropdownValue == _customValue
                      ? _customController.text.trim()
                      : _dropdownValue;
                  if (url.isEmpty && _dropdownValue == _customValue) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Enter a URL or choose a preset'),
                      ),
                    );
                    return;
                  }
                  await ref.read(baseUrlProvider.notifier).setBaseUrl(
                        url.isEmpty ? null : url,
                      );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          url.isEmpty
                              ? 'Base URL cleared; using default.'
                              : 'Base URL saved.',
                        ),
                        backgroundColor: AppColors.success,
                      ),
                    );
                    context.pop();
                  }
                },
                icon: const Icon(Icons.save_rounded),
                label: const Text('Save'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
