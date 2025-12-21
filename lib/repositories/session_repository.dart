import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/models/session.dart';

/// Repository for managing Session documents in Firestore
class SessionRepository {
  final FirebaseFirestore _firestore;

  /// Collection name in Firestore
  static const String _collectionName = 'sessions';

  SessionRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Reference to sessions collection
  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection(_collectionName);

  /// Save a session to Firestore
  Future<void> saveSession(Session session) async {
    await _collection.doc(session.sessionId).set(session.toJson());
  }

  /// Get a session by ID
  Future<Session?> getSession(String sessionId) async {
    final doc = await _collection.doc(sessionId).get();
    if (!doc.exists || doc.data() == null) return null;
    return Session.fromJson(doc.data()!);
  }

  /// Get all sessions for a user, ordered by most recent first
  Future<List<Session>> getUserSessions(String userId, {int limit = 50}) async {
    final query = await _collection
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .get();

    return query.docs.map((doc) => Session.fromJson(doc.data())).toList();
  }

  /// Get completed sessions for a user
  Future<List<Session>> getCompletedSessions(
    String userId, {
    int limit = 20,
  }) async {
    final query = await _collection
        .where('userId', isEqualTo: userId)
        .where('completedAt', isNull: false)
        .orderBy('completedAt', descending: true)
        .limit(limit)
        .get();

    return query.docs.map((doc) => Session.fromJson(doc.data())).toList();
  }

  /// Delete a session
  Future<void> deleteSession(String sessionId) async {
    await _collection.doc(sessionId).delete();
  }

  /// Clean up expired sessions for a user
  Future<int> cleanupExpiredSessions(String userId) async {
    final now = DateTime.now();
    final query = await _collection
        .where('userId', isEqualTo: userId)
        .where('expiresAt', isLessThan: Timestamp.fromDate(now))
        .get();

    int deleted = 0;
    for (final doc in query.docs) {
      await doc.reference.delete();
      deleted++;
    }
    return deleted;
  }

  /// Update session recording data
  Future<void> updateRecording(String sessionId, Recording recording) async {
    await _collection.doc(sessionId).update({'recording': recording.toJson()});
  }

  /// Stream of user's sessions (for real-time updates)
  Stream<List<Session>> watchUserSessions(String userId, {int limit = 20}) {
    return _collection
        .where('userId', isEqualTo: userId)
        .orderBy('startedAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Session.fromJson(doc.data())).toList(),
        );
  }
}

/// Provider for SessionRepository
final sessionRepositoryProvider = Provider<SessionRepository>((ref) {
  return SessionRepository();
});
