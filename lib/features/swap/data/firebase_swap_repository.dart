import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/observability/app_analytics.dart';
import '../../notifications/domain/repositories/notification_repository.dart';
import '../../shared/domain/models/app_notification.dart';
import '../../shared/domain/models/swap_proposal.dart';
import '../domain/repositories/swap_repository.dart';

class FirebaseSwapRepository implements SwapRepository {
  final FirebaseFirestore _firestore;
  final NotificationRepository _notificationRepository;
  final AppAnalytics _analytics;

  FirebaseSwapRepository(
    this._firestore,
    this._notificationRepository,
    this._analytics,
  );

  CollectionReference<Map<String, dynamic>> get _proposals =>
      _firestore.collection('swapProposals');

  CollectionReference<Map<String, dynamic>> _userProposals(String userId) =>
      _firestore.collection('users').doc(userId).collection('swapProposals');

  @override
  Stream<List<SwapProposal>> watchProposals(String userId) {
    return _userProposals(userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map(_fromDoc).toList());
  }

  @override
  Future<void> proposeSwap(SwapProposal proposal) async {
    final docRef = proposal.id.isEmpty
        ? _proposals.doc()
        : _proposals.doc(proposal.id);
    final id = docRef.id;
    final payload = <String, dynamic>{
      'proposerId': proposal.proposerId,
      'receiverId': proposal.receiverId,
      'offeredProductId': proposal.offeredProductId,
      'requestedProductId': proposal.requestedProductId,
      'status': proposal.status,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(payload, SetOptions(merge: true));
    await _userProposals(
      proposal.proposerId,
    ).doc(id).set(payload, SetOptions(merge: true));
    await _userProposals(
      proposal.receiverId,
    ).doc(id).set(payload, SetOptions(merge: true));
    try {
      await _notificationRepository.createNotification(
        AppNotification(
          id: '',
          userId: proposal.receiverId,
          type: 'offer',
          title: 'New Swap Proposal',
          body: 'You received a new swap proposal.',
          data: <String, dynamic>{
            'proposalId': id,
            'proposerId': proposal.proposerId,
            'offeredProductId': proposal.offeredProductId,
            'requestedProductId': proposal.requestedProductId,
          },
          createdAt: DateTime.now(),
          isRead: false,
        ),
      );
    } catch (_) {
      // Notification persistence must not block swap creation.
    }
    await _analytics.logProposeSwap(
      offeredProductId: proposal.offeredProductId,
      requestedProductId: proposal.requestedProductId,
    );
  }

  @override
  Future<void> acceptSwap(String proposalId) {
    return _updateStatus(proposalId, 'accepted');
  }

  @override
  Future<void> rejectSwap(String proposalId) {
    return _updateStatus(proposalId, 'rejected');
  }

  Future<void> _updateStatus(String proposalId, String status) async {
    final docRef = _proposals.doc(proposalId);
    final snapshot = await docRef.get();
    if (!snapshot.exists) return;
    final data = snapshot.data() ?? const {};
    final proposerId = data['proposerId'] as String? ?? '';
    final receiverId = data['receiverId'] as String? ?? '';
    final payload = <String, dynamic>{
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    await docRef.set(payload, SetOptions(merge: true));
    if (proposerId.isNotEmpty) {
      await _userProposals(
        proposerId,
      ).doc(proposalId).set(payload, SetOptions(merge: true));
    }
    if (receiverId.isNotEmpty) {
      await _userProposals(
        receiverId,
      ).doc(proposalId).set(payload, SetOptions(merge: true));
    }

    if (proposerId.isNotEmpty) {
      final title = status == 'accepted'
          ? 'Proposal Accepted'
          : 'Proposal Rejected';
      final body = status == 'accepted'
          ? 'Your swap proposal was accepted.'
          : 'Your swap proposal was rejected.';
      try {
        await _notificationRepository.createNotification(
          AppNotification(
            id: '',
            userId: proposerId,
            type: 'offer',
            title: title,
            body: body,
            data: <String, dynamic>{
              'proposalId': proposalId,
              'status': status,
              'receiverId': receiverId,
            },
            createdAt: DateTime.now(),
            isRead: false,
          ),
        );
      } catch (_) {
        // Notification persistence must not block swap updates.
      }
    }

    if (status == 'accepted') {
      await _analytics.logSwapAccept(proposalId: proposalId);
    } else if (status == 'rejected') {
      await _analytics.logSwapReject(proposalId: proposalId);
    }
  }

  SwapProposal _fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? const {};
    final createdAtRaw = data['createdAt'];
    final updatedAtRaw = data['updatedAt'];
    return SwapProposal(
      id: doc.id,
      proposerId: data['proposerId'] as String? ?? '',
      receiverId: data['receiverId'] as String? ?? '',
      offeredProductId: data['offeredProductId'] as String? ?? '',
      requestedProductId: data['requestedProductId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: createdAtRaw is Timestamp
          ? createdAtRaw.toDate()
          : DateTime.now(),
      updatedAt: updatedAtRaw is Timestamp ? updatedAtRaw.toDate() : null,
    );
  }
}
