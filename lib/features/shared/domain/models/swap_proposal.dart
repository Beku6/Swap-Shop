class SwapProposal {
  final String id;
  final String proposerId;
  final String receiverId;
  final String offeredProductId;
  final String requestedProductId;
  final String status;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const SwapProposal({
    required this.id,
    required this.proposerId,
    required this.receiverId,
    required this.offeredProductId,
    required this.requestedProductId,
    required this.status,
    required this.createdAt,
    this.updatedAt,
  });

  SwapProposal copyWith({
    String? id,
    String? proposerId,
    String? receiverId,
    String? offeredProductId,
    String? requestedProductId,
    String? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SwapProposal(
      id: id ?? this.id,
      proposerId: proposerId ?? this.proposerId,
      receiverId: receiverId ?? this.receiverId,
      offeredProductId: offeredProductId ?? this.offeredProductId,
      requestedProductId: requestedProductId ?? this.requestedProductId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
