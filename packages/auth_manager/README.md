# Auth Manager 🔒

This package is used by Unwired library to manage the authentication process. You can create your own auth manager by extending AuthManager class.

## Manages

1. Auth Objects - tokens or credentials used in Authorization header
2. User Data - user data such as name, email, etc. of the user that is currently logged in

## Functions

- [x] authenticate - saves the token and user data to the storage
- [x] unauthenticate - removes the token and user data from the storage
- [x] get isAuthenticated - returns true if the user is authenticated
- [x] get authObject - returns the auth object if it exists
- [x] get authStateChanges - returns the stream of auth state changes
- [x] get userData - returns the user data if it exists
- [x] get parsedAuthObject - returns the String to be embedded in the Authorization header

## Usage

AuthManager can be used with [Unwired](https://github.com/Ayush-Suman/unwired) library to manage the authentication process. 
You can also use it as a standalone package to manage authentication in your app.

```dart
class TokenAuthManager extends NoUserAuthManager<String> {
  TokenAuthManager({required this.secureStorage}) {
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

  String _key = 'random_key';

  String? _token;

  @override
  String? get authObject => _token;
  
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSink get _sink => _controller.sink;
  
  @override
  Stream<bool> get authStateChanges => _controller.stream;

  @override
  Future authenticate(String authObject) async {
    await secureStorage.write(key: _key, value: token);
    _token = token;
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
```



