import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthBloc({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        super(const AuthInitial()) {
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthCheckRequested>(_onCheckRequested);
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Create user with email and password
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        // Create user model
        final user = UserModel(
          uid: userCredential.user!.uid,
          email: event.email,
          username: event.username,
        );

        // Save user data to Firestore
        await _firestore.collection('users').doc(user.uid).set(user.toMap());

        emit(AuthAuthenticated(user: user));
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _getErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      // Sign in with email and password
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: event.email,
        password: event.password,
      );

      if (userCredential.user != null) {
        // Fetch user data from Firestore
        final userDoc = await _firestore
            .collection('users')
            .doc(userCredential.user!.uid)
            .get();

        if (userDoc.exists) {
          final user = UserModel.fromMap(userDoc.data()!);
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthError(message: 'User data not found'));
        }
      }
    } on FirebaseAuthException catch (e) {
      emit(AuthError(message: _getErrorMessage(e.code)));
    } catch (e) {
      emit(AuthError(message: 'An unexpected error occurred: ${e.toString()}'));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      await _firebaseAuth.signOut();
      emit(const AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: 'Failed to sign out: ${e.toString()}'));
    }
  }

  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser != null) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(currentUser.uid).get();

        if (userDoc.exists) {
          final user = UserModel.fromMap(userDoc.data()!);
          emit(AuthAuthenticated(user: user));
        } else {
          emit(const AuthUnauthenticated());
        }
      } catch (e) {
        emit(const AuthUnauthenticated());
      }
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'This email is already registered';
      case 'invalid-email':
        return 'Invalid email address';
      case 'weak-password':
        return 'Password is too weak';
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Wrong password';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      default:
        return 'Authentication failed. Please try again';
    }
  }
}

