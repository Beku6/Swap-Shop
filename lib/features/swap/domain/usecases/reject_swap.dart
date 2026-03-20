import '../repositories/swap_repository.dart';

class RejectSwap {
  final SwapRepository _repository;

  const RejectSwap(this._repository);

  Future<void> call(String proposalId) {
    return _repository.rejectSwap(proposalId);
  }
}
