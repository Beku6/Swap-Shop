import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../domain/models/settings_profile.dart';
import '../domain/repositories/settings_repository.dart';

class FirebaseSettingsRepository implements SettingsRepository {
  FirebaseSettingsRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  }) : _auth = auth,
       _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  DocumentReference<Map<String, dynamic>> _userDoc(String userId) {
    return _firestore.collection('users').doc(userId);
  }

  @override
  Stream<SettingsProfile> watchProfile(String userId) {
    if (userId.isEmpty) {
      return Stream.value(
        const SettingsProfile(
          userId: '',
          email: '',
          displayName: 'User',
          pushEnabled: false,
          isPrivate: false,
        ),
      );
    }

    return _userDoc(userId).snapshots().map((snapshot) {
      final data = snapshot.data() ?? const <String, dynamic>{};
      final authUser = _auth.currentUser;
      return SettingsProfile(
        userId: userId,
        email:
            authUser?.email ??
            (data['email'] as String?) ??
            '',
        displayName:
            (data['displayName'] as String?) ??
            authUser?.displayName ??
            'User',
        avatarUrl: data['avatarUrl'] as String?,
        pushEnabled: data['pushEnabled'] as bool? ?? false,
        isPrivate: data['isPrivate'] as bool? ?? false,
      );
    });
  }

  @override
  Future<void> updateDisplayName(String displayName) async {
    final user = _requireUser();
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return;
    }

    await user.updateDisplayName(trimmed);
    await _userDoc(user.uid).set({
      'displayName': trimmed,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateEmail({
    required String email,
    String? currentPassword,
  }) async {
    final user = _requireUser();
    final normalizedEmail = email.trim();
    if (normalizedEmail.isEmpty) {
      return;
    }

    try {
      await _reauthenticateIfNeeded(
        user: user,
        currentPassword: currentPassword,
      );
      // ignore: deprecated_member_use
      await user.updateEmail(normalizedEmail);
      await _userDoc(user.uid).set({
        'email': normalizedEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } on FirebaseAuthException catch (error) {
      if (error.code != 'requires-recent-login') {
        rethrow;
      }
      await _reauthenticateWithPasswordIfAvailable(
        user: user,
        currentPassword: currentPassword,
      );
      // ignore: deprecated_member_use
      await user.updateEmail(normalizedEmail);
      await _userDoc(user.uid).set({
        'email': normalizedEmail,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    final providers = user.providerData.map((item) => item.providerId).toSet();
    if (!providers.contains('password')) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Re-login required to change password for this account.',
      );
    }

    await _reauthenticateWithPasswordIfAvailable(
      user: user,
      currentPassword: currentPassword,
    );
    await user.updatePassword(newPassword);
  }

  @override
  Future<void> setPushEnabled(bool enabled) async {
    final user = _requireUser();
    await _userDoc(user.uid).set({
      'pushEnabled': enabled,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> setPrivateProfile(bool isPrivate) async {
    final user = _requireUser();
    await _userDoc(user.uid).set({
      'isPrivate': isPrivate,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> deleteAccount({String? currentPassword}) async {
    final user = _requireUser();
    await _reauthenticateIfNeeded(user: user, currentPassword: currentPassword);

    await _cleanupUserData(user.uid);
    await user.delete();
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No authenticated user.',
      );
    }
    return user;
  }

  Future<void> _reauthenticateIfNeeded({
    required User user,
    String? currentPassword,
  }) async {
    final providers = user.providerData.map((item) => item.providerId).toSet();
    if (!providers.contains('password')) {
      return;
    }
    await _reauthenticateWithPasswordIfAvailable(
      user: user,
      currentPassword: currentPassword,
    );
  }

  Future<void> _reauthenticateWithPasswordIfAvailable({
    required User user,
    String? currentPassword,
  }) async {
    final providers = user.providerData.map((item) => item.providerId).toSet();
    if (!providers.contains('password')) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Re-login required for this account.',
      );
    }
    final password = currentPassword?.trim();
    final email = user.email;
    if (password == null || password.isEmpty || email == null || email.isEmpty) {
      throw FirebaseAuthException(
        code: 'requires-recent-login',
        message: 'Re-authentication is required.',
      );
    }
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    await user.reauthenticateWithCredential(credential);
  }

  Future<void> _cleanupUserData(String userId) async {
    final subcollections = <String>[
      'cart',
      'favorites',
      'devices',
      'notifications',
      'swapProposals',
      'chatThreads',
    ];

    for (final path in subcollections) {
      await _deleteSubcollection(userId: userId, subcollection: path);
    }

    await _userDoc(userId).delete();
  }

  Future<void> _deleteSubcollection({
    required String userId,
    required String subcollection,
  }) async {
    final collection = _userDoc(userId).collection(subcollection);

    while (true) {
      final snapshot = await collection.limit(200).get();
      if (snapshot.docs.isEmpty) {
        break;
      }
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    }
  }
}
