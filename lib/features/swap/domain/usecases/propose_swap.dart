import '../../../shared/domain/models/swap_proposal.dart';
import '../repositories/swap_repository.dart';

class ProposeSwap {
  final SwapRepository _repository;

  const ProposeSwap(this._repository);

  Future<void> call(SwapProposal proposal) {
    return _repository.proposeSwap(proposal);
  }
}
