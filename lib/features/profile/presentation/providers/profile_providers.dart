import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image/image.dart' as img;
import 'package:supabase_flutter/supabase_flutter.dart';

final profileFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final profileSupabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final profileFirebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});

final avatarImageProcessorProvider = Provider<AvatarImageProcessor>((ref) {
  return const AvatarImageProcessor();
});

final profileAvatarServiceProvider = Provider<ProfileAvatarService>((ref) {
  return ProfileAvatarService(
    firestore: ref.watch(profileFirestoreProvider),
    supabase: ref.watch(profileSupabaseProvider),
    firebaseAuth: ref.watch(profileFirebaseAuthProvider),
    avatarProcessor: ref.watch(avatarImageProcessorProvider),
  );
});

final profileUserDataProvider =
    StreamProvider.family<Map<String, dynamic>?, String>((ref, userId) {
      if (userId.isEmpty) {
        return Stream.value(null);
      }
      return ref
          .watch(profileFirestoreProvider)
          .collection('users')
          .doc(userId)
          .snapshots()
          .map((snapshot) => snapshot.data());
    });

class ProfileAvatarService {
  const ProfileAvatarService({
    required FirebaseFirestore firestore,
    required SupabaseClient supabase,
    required FirebaseAuth firebaseAuth,
    required AvatarImageProcessor avatarProcessor,
  }) : _firestore = firestore,
       _supabase = supabase,
       _firebaseAuth = firebaseAuth,
       _avatarProcessor = avatarProcessor;

  static const String _bucket = 'avatars';

  final FirebaseFirestore _firestore;
  final SupabaseClient _supabase;
  final FirebaseAuth _firebaseAuth;
  final AvatarImageProcessor _avatarProcessor;

  String _avatarObjectPath(String userId) => '$userId.jpg';

  Future<String> uploadAvatar({
    required String userId,
    required File file,
  }) async {
    final rawBytes = await file.readAsBytes();
    final bytes = _avatarProcessor.process(rawBytes);
    final objectPath = _avatarObjectPath(userId);
    final version = DateTime.now().millisecondsSinceEpoch;

    await _supabase.storage
        .from(_bucket)
        .uploadBinary(
          objectPath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    final baseAvatarUrl = _supabase.storage
        .from(_bucket)
        .getPublicUrl(objectPath);
    final avatarUrl = '$baseAvatarUrl?v=$version';

    await _firestore.collection('users').doc(userId).set({
      'avatarUrl': avatarUrl,
    }, SetOptions(merge: true));
    await _updateAuthPhotoUrlIfCurrentUser(userId, avatarUrl);

    return avatarUrl;
  }

  Future<void> removeAvatar({required String userId}) async {
    final objectPath = _avatarObjectPath(userId);
    try {
      await _supabase.storage.from(_bucket).remove([objectPath]);
    } on StorageException catch (error) {
      if (!_isMissingStorageObject(error)) {
        rethrow;
      }
    }

    await _firestore.collection('users').doc(userId).set({
      'avatarUrl': FieldValue.delete(),
    }, SetOptions(merge: true));
    await _updateAuthPhotoUrlIfCurrentUser(userId, null);
  }

  bool _isMissingStorageObject(StorageException error) {
    final statusCode = error.statusCode?.toString();
    final message = error.message.toLowerCase();
    return statusCode == '404' ||
        message.contains('not found') ||
        message.contains('does not exist');
  }

  Future<void> _updateAuthPhotoUrlIfCurrentUser(
    String userId,
    String? avatarUrl,
  ) async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null || currentUser.uid != userId) {
      return;
    }
    await currentUser.updatePhotoURL(avatarUrl);
  }
}

class AvatarValidationException implements Exception {
  const AvatarValidationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class AvatarImageProcessor {
  const AvatarImageProcessor({
    this.minSourceDimension = 512,
    this.outputDimension = 1024,
    this.maxFileBytes = 512 * 1024,
    this.preferredMaxBytes = 400 * 1024,
  });

  final int minSourceDimension;
  final int outputDimension;
  final int maxFileBytes;
  final int preferredMaxBytes;

  Uint8List process(Uint8List inputBytes) {
    final decoded = img.decodeImage(inputBytes);
    if (decoded == null) {
      throw const AvatarValidationException(
        'Unable to read selected image. Please choose another photo.',
      );
    }
    if (decoded.width < minSourceDimension ||
        decoded.height < minSourceDimension) {
      throw AvatarValidationException(
        'Photo is too small. Use at least ${minSourceDimension}x$minSourceDimension pixels.',
      );
    }

    final square = _centerCropSquare(decoded);
    final resized = img.copyResize(
      square,
      width: outputDimension,
      height: outputDimension,
      interpolation: img.Interpolation.average,
    );

    return _encodeWithinLimit(resized);
  }

  img.Image _centerCropSquare(img.Image image) {
    final side = image.width < image.height ? image.width : image.height;
    final x = ((image.width - side) / 2).round();
    final y = ((image.height - side) / 2).round();
    return img.copyCrop(image, x: x, y: y, width: side, height: side);
  }

  Uint8List _encodeWithinLimit(img.Image image) {
    Uint8List? underHardLimit;
    for (final quality in const <int>[88, 84, 80, 76, 72, 68, 64, 60]) {
      final encoded = Uint8List.fromList(
        img.encodeJpg(image, quality: quality),
      );
      if (encoded.lengthInBytes <= preferredMaxBytes) {
        return encoded;
      }
      if (encoded.lengthInBytes <= maxFileBytes) {
        underHardLimit ??= encoded;
      }
    }

    var resized = image;
    for (final dimension in const <int>[896, 768, 640, 512]) {
      resized = img.copyResize(
        resized,
        width: dimension,
        height: dimension,
        interpolation: img.Interpolation.average,
      );
      for (final quality in const <int>[80, 76, 72, 68, 64, 60]) {
        final encoded = Uint8List.fromList(
          img.encodeJpg(resized, quality: quality),
        );
        if (encoded.lengthInBytes <= preferredMaxBytes) {
          return encoded;
        }
        if (encoded.lengthInBytes <= maxFileBytes) {
          underHardLimit ??= encoded;
        }
      }
    }

    if (underHardLimit != null) {
      return underHardLimit;
    }
    throw const AvatarValidationException(
      'Selected photo is too large. Please choose another image.',
    );
  }
}
