import '../repositories/swap_repository.dart';

class AcceptSwap {
  final SwapRepository _repository;

  const AcceptSwap(this._repository);

  Future<void> call(String proposalId) {
    return _repository.acceptSwap(proposalId);
  }
}
