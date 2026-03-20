import '../../../shared/domain/models/swap_proposal.dart';
import '../repositories/swap_repository.dart';

class WatchSwapProposals {
  final SwapRepository _repository;

  const WatchSwapProposals(this._repository);

  Stream<List<SwapProposal>> call(String userId) {
    return _repository.watchProposals(userId);
  }
}
