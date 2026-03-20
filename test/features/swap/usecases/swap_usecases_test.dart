import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/shared/domain/models/swap_proposal.dart';
import 'package:swap/features/swap/domain/usecases/accept_swap.dart';
import 'package:swap/features/swap/domain/usecases/propose_swap.dart';
import 'package:swap/features/swap/domain/usecases/reject_swap.dart';
import 'package:swap/features/swap/domain/usecases/watch_swap_proposals.dart';

import '../../../helpers/fake_swap_repository.dart';

void main() {
  SwapProposal buildProposal({
    required String id,
    required String proposerId,
    required String receiverId,
  }) {
    return SwapProposal(
      id: id,
      proposerId: proposerId,
      receiverId: receiverId,
      offeredProductId: 'offer_1',
      requestedProductId: 'request_1',
      status: 'pending',
      createdAt: DateTime.now(),
    );
  }

  test('propose swap adds pending proposal', () async {
    final repo = FakeSwapRepository();
    await ProposeSwap(repo).call(
      buildProposal(id: '', proposerId: 'u1', receiverId: 'u2'),
    );

    final list = await WatchSwapProposals(repo).call('u1').first;
    expect(list.length, 1);
    expect(list.first.status, 'pending');
  });

  test('accept swap updates status', () async {
    final repo = FakeSwapRepository(seed: [
      buildProposal(id: 'sp_1', proposerId: 'u1', receiverId: 'u2'),
    ]);

    await AcceptSwap(repo).call('sp_1');
    final list = await WatchSwapProposals(repo).call('u1').first;
    expect(list.first.status, 'accepted');
  });

  test('reject swap updates status', () async {
    final repo = FakeSwapRepository(seed: [
      buildProposal(id: 'sp_1', proposerId: 'u1', receiverId: 'u2'),
    ]);

    await RejectSwap(repo).call('sp_1');
    final list = await WatchSwapProposals(repo).call('u1').first;
    expect(list.first.status, 'rejected');
  });
}
