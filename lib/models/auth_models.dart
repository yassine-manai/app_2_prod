enum AuthStatus {
  uninitialized,
  authenticated,
  unauthenticated,
  authenticating,
  registering
}

class AuthModel {
  AuthStatus _status = AuthStatus.uninitialized;
  String? _token;
  String? _userId;

  AuthStatus get status => _status;
  String? get token => _token;
  String? get userId => _userId;

  void setStatus(AuthStatus status) {
    _status = status;
  }

  void setToken(String? token) {
    _token = token;
  }

  void setUserId(String? userId) {
    _userId = userId;
  }
}