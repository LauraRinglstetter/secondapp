//Login exceptions
class UserNotFoundAuthException implements Exception {}
class InvalidCredentialsAuthException implements Exception{}

//Register exceptions
class WeakPasswordAuthException implements Exception{}
class EmailAlreadyInUseAuthException implements Exception{}
class InvalidEmailAuthException implements Exception{}

//generic exceptions
class GenericAuthException implements Exception{}
class UserNotLogginInAuthException implements Exception{}