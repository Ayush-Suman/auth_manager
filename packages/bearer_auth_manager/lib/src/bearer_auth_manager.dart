import 'dart:async';

import 'package:auth_manager/auth_manager.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BearerAuthManager extends AuthManager<String> {
  BearerAuthManager({required this.secureStorage, String? key}) {
    _key = key??'bearer_token';
    secureStorage.read(key: _key).then((value) {
      _token = value;
      _sink.add(_token != null);
      _completer.complete();
    });
  }

  final FlutterSecureStorage secureStorage;

  final Completer _completer = Completer();

  @override
  Future synchronize() async {
    await _completer.future;
    return;
  }

  late final String _key;

  String? _token;

  @override
  String? get authObject => _token;

  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSink<bool> get _sink => _controller.sink;

  @override
  Stream<bool> get authStateChanges => _controller.stream;

  @override
  Future authenticate(String authObject) async {
    await secureStorage.write(key: _key, value: authObject);
    _token = authObject;
    _sink.add(true);
  }

  @override
  Future unauthenticate() async {
    await secureStorage.delete(key: _key);
    _token = null;
    _sink.add(false);
  }

  @override
  bool get isAuthenticated => _token != null;

  String _tokenParser(String? token) => token != null ? 'Bearer $token' : '';

  @override
  String get parsedAuthObject => _tokenParser(_token);
}