import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'base_service.dart';

/// Storage service for Firebase Storage operations
///
/// Handles file uploads, downloads, and management for
/// session recordings, profile images, and community content.
class StorageService extends BaseService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  Future<void> onInitialize() async {
    // Firebase Storage is automatically initialized with Firebase.initializeApp()
  }

  @override
  Future<void> onDispose() async {
    // No cleanup needed for Firebase Storage
  }

  /// Upload a file to user's recordings folder
  ///
  /// Returns the download URL of the uploaded file.
  Future<String> uploadRecording({
    required String userId,
    required File file,
    String? customFileName,
    void Function(double progress)? onProgress,
  }) async {
    final fileName = customFileName ?? path.basename(file.path);
    final ref = _storage.ref('users/$userId/recordings/$fileName');

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: _getContentType(fileName),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      ),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    await uploadTask;
    return await ref.getDownloadURL();
  }

  /// Upload a profile image
  ///
  /// Returns the download URL of the uploaded image.
  Future<String> uploadProfileImage({
    required String userId,
    required File file,
  }) async {
    final extension = path.extension(file.path);
    final ref = _storage.ref('users/$userId/profile/avatar$extension');

    await ref.putFile(
      file,
      SettableMetadata(contentType: _getContentType(file.path)),
    );

    return await ref.getDownloadURL();
  }

  /// Upload bytes data (for in-memory data like compressed video)
  Future<String> uploadBytes({
    required String storagePath,
    required Uint8List data,
    required String contentType,
    Map<String, String>? metadata,
  }) async {
    final ref = _storage.ref(storagePath);

    await ref.putData(
      data,
      SettableMetadata(
        contentType: contentType,
        customMetadata: metadata,
      ),
    );

    return await ref.getDownloadURL();
  }

  /// Upload to community shared content
  Future<String> uploadCommunityVideo({
    required String userId,
    required File file,
    required String videoId,
    void Function(double progress)? onProgress,
  }) async {
    final extension = path.extension(file.path);
    final ref = _storage.ref('community/$userId/$videoId$extension');

    final uploadTask = ref.putFile(
      file,
      SettableMetadata(
        contentType: _getContentType(file.path),
        customMetadata: {
          'uploadedAt': DateTime.now().toIso8601String(),
          'userId': userId,
        },
      ),
    );

    if (onProgress != null) {
      uploadTask.snapshotEvents.listen((snapshot) {
        final progress = snapshot.bytesTransferred / snapshot.totalBytes;
        onProgress(progress);
      });
    }

    await uploadTask;
    return await ref.getDownloadURL();
  }

  /// Download a file to local storage
  Future<File> downloadFile({
    required String storagePath,
    required String localPath,
  }) async {
    final ref = _storage.ref(storagePath);
    final file = File(localPath);

    await ref.writeToFile(file);
    return file;
  }

  /// Get download URL for a file
  Future<String> getDownloadUrl(String storagePath) async {
    final ref = _storage.ref(storagePath);
    return await ref.getDownloadURL();
  }

  /// Delete a file from storage
  Future<void> deleteFile(String storagePath) async {
    final ref = _storage.ref(storagePath);
    await ref.delete();
  }

  /// Delete all recordings for a user (used for account deletion)
  Future<void> deleteUserRecordings(String userId) async {
    final ref = _storage.ref('users/$userId/recordings');
    final listResult = await ref.listAll();

    for (final item in listResult.items) {
      await item.delete();
    }

    // Also delete nested folders
    for (final prefix in listResult.prefixes) {
      await _deleteFolder(prefix);
    }
  }

  /// Delete a folder and all its contents recursively
  Future<void> _deleteFolder(Reference ref) async {
    final listResult = await ref.listAll();

    for (final item in listResult.items) {
      await item.delete();
    }

    for (final prefix in listResult.prefixes) {
      await _deleteFolder(prefix);
    }
  }

  /// List all recordings for a user
  Future<List<Reference>> listUserRecordings(String userId) async {
    final ref = _storage.ref('users/$userId/recordings');
    final listResult = await ref.listAll();
    return listResult.items;
  }

  /// Get file metadata
  Future<FullMetadata> getMetadata(String storagePath) async {
    final ref = _storage.ref(storagePath);
    return await ref.getMetadata();
  }

  /// Determine content type from file extension
  String _getContentType(String fileName) {
    final extension = path.extension(fileName).toLowerCase();
    switch (extension) {
      case '.mp4':
        return 'video/mp4';
      case '.mov':
        return 'video/quicktime';
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      case '.json':
        return 'application/json';
      default:
        return 'application/octet-stream';
    }
  }
}
