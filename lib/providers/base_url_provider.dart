import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _keyBaseUrl = 'api_base_url';

/// Default URL used when none is saved.
const defaultBaseUrl = 'https://brainbashbackend-brainbash.up.railway.app';

/// Preset backend URLs for quick selection.
const presetBaseUrls = [
  'https://brainbashbackend-brainbash.up.railway.app',
  'http://localhost:8080',
];

class BaseUrlNotifier extends StateNotifier<String?> {
  BaseUrlNotifier() : super(null) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getString(_keyBaseUrl);
  }

  Future<void> setBaseUrl(String? url) async {
    final prefs = await SharedPreferences.getInstance();
    if (url == null || url.isEmpty) {
      await prefs.remove(_keyBaseUrl);
      state = null;
    } else {
      final trimmed = url.trim();
      if (trimmed.isEmpty) {
        await prefs.remove(_keyBaseUrl);
        state = null;
      } else {
        await prefs.setString(_keyBaseUrl, trimmed);
        state = trimmed;
      }
    }
  }
}

final baseUrlProvider = StateNotifierProvider<BaseUrlNotifier, String?>((ref) {
  return BaseUrlNotifier();
});
