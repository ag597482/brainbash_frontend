import 'dart:io' show Platform;

/// True when running on Android (e.g. emulator). Use to resolve localhost to 10.0.2.2.
bool get isAndroid => Platform.isAndroid;
