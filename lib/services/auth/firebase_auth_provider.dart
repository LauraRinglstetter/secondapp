import 'package:firebase_core/firebase_core.dart';
import 'package:secondapp/firebase_options.dart';
import 'package:secondapp/services/auth/auth_user.dart';
import 'package:secondapp/services/auth/auth_provider.dart';
import 'package:secondapp/services/auth/auth_exceptions.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // ← NEU

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;


class FirebaseAuthProvider implements AuthProvider {
  @override
  Future<AuthUser> createUser({
    required String email, 
    required String password
  }) async {

    try {
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final firebaseUser = userCredential.user;
    if (firebaseUser != null) {
      // E-Mail in Firestore speichern:
      await FirebaseFirestore.instance.collection('users').doc(firebaseUser.uid).set({
        'email': firebaseUser.email,
      });

      return AuthUser.fromFirebase(firebaseUser);
    } else {
      throw UserNotLogginInAuthException();
    }

    } on FirebaseAuthException catch(e) {
      if (e.code == 'weak-password') {
        throw WeakPasswordAuthException();
      } else if (e.code == 'email-already-in-use') {
        throw EmailAlreadyInUseAuthException();
      } else if (e.code == 'invalid-email') {
        throw InvalidEmailAuthException();
      } else {
        throw GenericAuthException();
      }
    } catch (_) {
      throw GenericAuthException();
    }
  }


  @override
  AuthUser? get currentUser {
    final user = FirebaseAuth.instance.currentUser;
    if(user != null) {
      return AuthUser.fromFirebase(user);
    } else {
      return null;
    }
  }

  @override
  Future<AuthUser> logIn({
    required String email, 
    required String password
  }) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, 
        password: password
      );
      final user = currentUser;
      if (user != null) {
        return user;
      } else {
        throw UserNotLogginInAuthException();
      }
    } on FirebaseAuthException catch (e) {
        if (e.code == 'invalid-credential') {
          throw InvalidCredentialsAuthException();
        } else {
          throw GenericAuthException();
        }
      }  catch (e) {
        throw GenericAuthException();
      }      
    }


  @override
  Future<void> logOut() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLogginInAuthException();
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null){
      await user.sendEmailVerification();
    } else {
      throw UserNotLogginInAuthException();
    }
  }
  
  @override
  Future<void> initialize() async {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
  }
}
