import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/observability/observability_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../notifications/presentation/providers/notifications_providers.dart';
import '../../../shared/domain/models/swap_proposal.dart';
import '../../data/firebase_swap_repository.dart';
import '../../domain/repositories/swap_repository.dart';
import '../../domain/usecases/accept_swap.dart';
import '../../domain/usecases/propose_swap.dart';
import '../../domain/usecases/reject_swap.dart';
import '../../domain/usecases/watch_swap_proposals.dart';

final swapFirestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final swapRepositoryProvider = Provider<SwapRepository>((ref) {
  return FirebaseSwapRepository(
    ref.watch(swapFirestoreProvider),
    ref.watch(notificationRepositoryProvider),
    ref.watch(appAnalyticsProvider),
  );
});

final watchSwapProposalsProvider = Provider<WatchSwapProposals>((ref) {
  return WatchSwapProposals(ref.watch(swapRepositoryProvider));
});

final proposeSwapProvider = Provider<ProposeSwap>((ref) {
  return ProposeSwap(ref.watch(swapRepositoryProvider));
});

final acceptSwapProvider = Provider<AcceptSwap>((ref) {
  return AcceptSwap(ref.watch(swapRepositoryProvider));
});

final rejectSwapProvider = Provider<RejectSwap>((ref) {
  return RejectSwap(ref.watch(swapRepositoryProvider));
});

final swapProposalsProvider = StreamProvider.family<List<SwapProposal>, String>(
  (ref, userId) {
    final currentUserId = ref.watch(authControllerProvider).user?.id;
    if (currentUserId == null || currentUserId != userId) {
      return Stream.value(const <SwapProposal>[]);
    }
    return ref.watch(watchSwapProposalsProvider).call(userId);
  },
);
