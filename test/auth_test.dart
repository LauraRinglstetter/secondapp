// import 'package:secondapp/services/auth/auth_exceptions.dart';
// import 'package:secondapp/services/auth/auth_provider.dart';
// import 'package:secondapp/services/auth/auth_user.dart';
// import 'package:test/test.dart';

// void main(){
//   group('Mock Authentication', () {
//     final provider = MockAuthProvider();
//     test('Should not be initialized to begin with', () {
//       expect(provider.isInitialized, false);
//     });
//     test('Cannot log out if not initialized', () {
//       expect(provider.logOut(),
//       throwsA(const TypeMatcher<NotInitializedException>()),
//       );
//     });
//     test('Should be able to be initialized', () async {
//       await provider.initialize();
//       expect(provider.isInitialized, true);
//     });
//     test('User should be null', () {
//       expect(provider.currentUser, null);
//     });

//     test('Should be able to initialize in less than 2 seconds', () async{
//       await provider.initialize();
//       expect(provider.isInitialized, true);
//     }, timeout: const Timeout(Duration(seconds: 2))
//     );
//     test('Create user should delegate to login function', () async {
//       final badEmailUser = provider.createUser(
//         email: 'foo@bar.com', 
//         password: 'Password',
//       );
//       expect(badEmailUser, throwsA(const TypeMatcher<UserNotFoundAuthException>()));
//     });
//   });
// }

// class NotInitializedException implements Exception{}

// class MockAuthProvider implements AuthProvider {
//   AuthUser? _user;
//   var _isInitialized = false;
//   bool get isInitialized => _isInitialized;

//   @override
//   Future<AuthUser> createUser({
//     required String email, 
//     required String password,
//   }) async {
//     if (!isInitialized) throw NotInitializedException();
//     await Future.delayed(const Duration(seconds: 1));
//     return logIn(email: email, password: password);
//   }

//   @override
//   AuthUser? get currentUser => _user;

//   @override
//   Future<void> initialize() async{
//     await Future.delayed(const Duration(seconds: 1));
//     _isInitialized = true;
//   }

//   @override
//   Future<AuthUser> logIn({
//     required String email, 
//     required String password,
//   }) {
//     if (!isInitialized) throw NotInitializedException();
//     if (email == 'foo@bar.com') throw InvalidCredentialsAuthException();
//     if (password == 'Password') throw InvalidCredentialsAuthException();
//     const user = AuthUser(
//       id: 'random_id',
//       isEmailVerified: false, 
//       email: 'foo@bar.com',
//     );
//     _user = user;
//     return Future.value(user);
//   }

//   @override
//   Future<void> logOut() async{
//     if (!isInitialized) throw NotInitializedException();
//     if(_user == null) throw UserNotFoundAuthException();
//     await Future.delayed(const Duration(seconds: 1));
//     _user = null;
//   }

//   @override
//   Future<void> sendEmailVerification() async{
//     if (!isInitialized) throw NotInitializedException();
//     final user = _user;
//     if (user == null) throw UserNotFoundAuthException();
//     const newUser = AuthUser(
//       id: 'random_id',
//       isEmailVerified: true, 
//       email: 'foo@bar.com',
//     );
//     _user = newUser;
//   }

// }