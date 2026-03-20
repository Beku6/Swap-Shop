import 'package:swap/features/shared/domain/models/swap_proposal.dart';
import 'package:swap/features/swap/domain/repositories/swap_repository.dart';

class FakeSwapRepository implements SwapRepository {
  final List<SwapProposal> _proposals;

  FakeSwapRepository({List<SwapProposal> seed = const []}) : _proposals = [...seed];

  @override
  Stream<List<SwapProposal>> watchProposals(String userId) {
    return Stream.value(
      _proposals
          .where((proposal) => proposal.proposerId == userId || proposal.receiverId == userId)
          .toList(),
    );
  }

  @override
  Future<void> proposeSwap(SwapProposal proposal) async {
    final id = proposal.id.isEmpty ? 'sp_${_proposals.length + 1}' : proposal.id;
    _proposals.add(proposal.copyWith(id: id));
  }

  @override
  Future<void> acceptSwap(String proposalId) async {
    _updateStatus(proposalId, 'accepted');
  }

  @override
  Future<void> rejectSwap(String proposalId) async {
    _updateStatus(proposalId, 'rejected');
  }

  void _updateStatus(String proposalId, String status) {
    final index = _proposals.indexWhere((proposal) => proposal.id == proposalId);
    if (index == -1) return;
    _proposals[index] = _proposals[index].copyWith(status: status, updatedAt: DateTime.now());
  }
}
