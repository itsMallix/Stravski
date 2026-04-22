import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../models/user_model.dart';
import '../../../../core/error/exceptions.dart';

class AuthRepositoryImpl implements AuthRepository {
  final fb.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepositoryImpl({
    fb.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final uid = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromFirestore(doc.data()!, uid);
      }
      // Dokumen Firestore tidak ada → akun dianggap tidak aktif, tolak login
      await _firebaseAuth.signOut();
      throw AuthException(message: 'Akun tidak ditemukan atau telah dihapus');
    } on fb.FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
        throw AuthException(message: 'invalid credential');
      }
      throw AuthException(message: e.message ?? 'Sign in failed');
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user!.updateDisplayName(displayName);
      final user = UserModel(
        id: credential.user!.uid,
        email: email,
        displayName: displayName,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(user.id).set(user.toFirestore());
      return user;
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(message: e.message ?? 'Sign up failed');
    }
  }

  @override
  Future<void> signOut() => _firebaseAuth.signOut();

  @override
  Future<UserEntity?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;
    try {
      // Force a server-side token refresh. Throws if the account was deleted.
      await user.reload();
      final refreshedUser = _firebaseAuth.currentUser;
      if (refreshedUser == null) return null;

      final doc = await _firestore.collection('users').doc(refreshedUser.uid).get();
      if (doc.exists) return UserModel.fromFirestore(doc.data()!, refreshedUser.uid);
      return _userFromFirebase(refreshedUser);
    } on fb.FirebaseAuthException catch (e) {
      // Account was deleted or token is invalid — sign out locally
      if (e.code == 'user-not-found' || e.code == 'user-disabled' || e.code == 'invalid-user-token') {
        await _firebaseAuth.signOut();
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Stream<UserEntity?> authStateChanges() {
    return _firebaseAuth.authStateChanges().asyncMap((user) async {
      if (user == null) return null;
      try {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) return UserModel.fromFirestore(doc.data()!, user.uid);
      } catch (_) {}
      return _userFromFirebase(user);
    });
  }

  UserEntity _userFromFirebase(fb.User user) => UserModel(
        id: user.uid,
        email: user.email ?? '',
        displayName: user.displayName ?? 'User',
        photoUrl: user.photoURL,
        createdAt: DateTime.now(),
      );
}
