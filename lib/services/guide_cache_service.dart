import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/guide.dart';
import 'base_service.dart';

/// Service for caching parsed guides in Firestore
///
/// Caches guides by URL hash to avoid re-parsing the same content.
/// Includes expiration logic (default 7 days).
class GuideCacheService extends BaseService {
  final FirebaseFirestore _firestore;

  /// Collection name in Firestore
  static const String _collectionName = 'cachedGuides';

  /// Default cache expiration in days
  static const int _defaultExpirationDays = 7;

  GuideCacheService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to cached guides collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  @override
  Future<void> onInitialize() async {
    // No initialization needed
  }

  @override
  Future<void> onDispose() async {
    // No cleanup needed
  }

  /// Generate a hash key from URL for consistent lookups
  String _hashUrl(String url) {
    final bytes = utf8.encode(url.trim().toLowerCase());
    return md5.convert(bytes).toString();
  }

  /// Cache a parsed guide
  Future<void> cacheGuide(Guide guide, String sourceUrl) async {
    ensureInitialized();

    final urlHash = _hashUrl(sourceUrl);
    final now = DateTime.now();
    final expiresAt = now.add(const Duration(days: _defaultExpirationDays));

    await _collection.doc(urlHash).set({
      'guide': guide.toJson(),
      'sourceUrl': sourceUrl,
      'cachedAt': Timestamp.fromDate(now),
      'expiresAt': Timestamp.fromDate(expiresAt),
    });
  }

  /// Retrieve a cached guide by URL
  ///
  /// Returns null if not cached or expired.
  Future<Guide?> getCachedGuide(String url) async {
    ensureInitialized();

    final urlHash = _hashUrl(url);
    final doc = await _collection.doc(urlHash).get();

    if (!doc.exists || doc.data() == null) {
      return null;
    }

    final data = doc.data()!;
    final expiresAt = (data['expiresAt'] as Timestamp).toDate();

    // Check if expired
    if (DateTime.now().isAfter(expiresAt)) {
      // Delete expired cache entry
      await _collection.doc(urlHash).delete();
      return null;
    }

    return Guide.fromJson(data['guide'] as Map<String, dynamic>);
  }

  /// Check if a guide is cached for the given URL
  Future<bool> isCached(String url) async {
    final guide = await getCachedGuide(url);
    return guide != null;
  }

  /// Delete a cached guide by URL
  Future<void> deleteCachedGuide(String url) async {
    ensureInitialized();
    final urlHash = _hashUrl(url);
    await _collection.doc(urlHash).delete();
  }

  /// Clean up all expired cache entries
  Future<int> cleanupExpiredCache() async {
    ensureInitialized();

    final now = DateTime.now();
    final query = await _collection
        .where('expiresAt', isLessThan: Timestamp.fromDate(now))
        .get();

    int deleted = 0;
    for (final doc in query.docs) {
      await doc.reference.delete();
      deleted++;
    }
    return deleted;
  }
}

/// Provider for GuideCacheService
final guideCacheServiceProvider = Provider<GuideCacheService>((ref) {
  final service = GuideCacheService();
  ref.onDispose(() => service.dispose());
  return service;
});
