import '../local/local_user.dart';

class LocalSession {
  static LocalUser? _user;

  static void setUser(LocalUser user) {
    _user = user;
  }

  static LocalUser? get currentUser => _user;

  static void logout() {
    _user = null;
  }
}

