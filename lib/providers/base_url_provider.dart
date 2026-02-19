import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/platform.dart';

const _keyBaseUrl = 'api_base_url';

/// Default URL used when none is saved.
const defaultBaseUrl = 'https://brainbashbackend-brainbash.up.railway.app';

/// Preset backend URLs for quick selection.
/// Use "Local (Android emulator)" when running the app in the emulator and backend on host.
const presetBaseUrls = [
  'https://brainbashbackend-brainbash.up.railway.app',
  'http://localhost:8080',
  'http://10.0.2.2:8080', // Android emulator → host machine
];

/// Returns the URL to use for API calls. On Android, replaces localhost with 10.0.2.2
/// so the emulator can reach the host machine's backend.
String effectiveBaseUrl(String? url) {
  final u = url ?? defaultBaseUrl;
  if (isAndroid) {
    if (u.startsWith('http://localhost:')) {
      return u.replaceFirst('http://localhost:', 'http://10.0.2.2:');
    } else if (u.startsWith('https://localhost:')) {
      return u.replaceFirst('https://localhost:', 'https://10.0.2.2:');
    }
  }
  return u;
}

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
