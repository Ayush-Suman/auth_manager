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
      _completer.complete(_token != null);
    });
  }

  final FlutterSecureStorage secureStorage;

  final Completer<bool> _completer = Completer<bool>();

  Future synchronize() async {
    final authState = await _completer.future;
    _sink.add(authState);
    return;
  }

  String _key = 'random_key';
  set key(String k) {
    _key = k;
  }

  String? _token;

  @override
  String? get authObject => _token;
  
  final StreamController<bool> _controller = StreamController<bool>.broadcast();
  StreamSink get _sink => _controller.sink;
  
  @override
  Stream<bool> get authStateChanges => _controller.stream;

  Future authenticate(String token) async {
    await secureStorage.write(key: _key, value: token);
    _token = token;
    _sink.add(true);
  }

  Future unauthenticate() async {
    await secureStorage.delete(key: _key);
    _token = null;
    _sink.add(false);
  }

  @override
  bool get isAuthenticated => _token != null;

  String Function(String? token) _tokenParser =
      (token) => token != null ? 'Bearer $token' : '';

  /// This function is used to parse the [authObject] to include any keyword
  /// such as 'Bearer ' along with the [String] token in the `Authorization`
  /// header of a request depending on the type of token.
  set tokenParser(String Function(String? token) parser) {
    _tokenParser = parser;
  }

  @override
  String get parsedAuthObject => _tokenParser(_token);
}
```



