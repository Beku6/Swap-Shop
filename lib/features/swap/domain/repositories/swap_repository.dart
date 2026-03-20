import '../../../shared/domain/models/swap_proposal.dart';

abstract class SwapRepository {
  Stream<List<SwapProposal>> watchProposals(String userId);
  Future<void> proposeSwap(SwapProposal proposal);
  Future<void> acceptSwap(String proposalId);
  Future<void> rejectSwap(String proposalId);
}
