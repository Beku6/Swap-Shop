import 'package:firebase_analytics/firebase_analytics.dart';

class AppAnalytics {
  final FirebaseAnalytics _analytics;

  const AppAnalytics(this._analytics);

  Future<void> logSignUp({required String method}) {
    return _analytics.logEvent(
      name: 'sign_up',
      parameters: <String, Object>{'method': method},
    );
  }

  Future<void> logSignIn({required String method}) {
    return _analytics.logEvent(
      name: 'sign_in',
      parameters: <String, Object>{'method': method},
    );
  }

  Future<void> logAddProduct({
    required String productId,
    required String category,
  }) {
    return _analytics.logEvent(
      name: 'add_product',
      parameters: <String, Object>{
        'product_id': productId,
        'category': category,
      },
    );
  }

  Future<void> logAddToCart({
    required String productId,
    required int quantity,
  }) {
    return _analytics.logAddToCart(
      items: <AnalyticsEventItem>[
        AnalyticsEventItem(itemId: productId, quantity: quantity),
      ],
    );
  }

  Future<void> logAddFavorite({required String productId}) {
    return _analytics.logEvent(
      name: 'add_favorite',
      parameters: <String, Object>{'product_id': productId},
    );
  }

  Future<void> logProposeSwap({
    required String offeredProductId,
    required String requestedProductId,
  }) {
    return _analytics.logEvent(
      name: 'propose_swap',
      parameters: <String, Object>{
        'offered_product_id': offeredProductId,
        'requested_product_id': requestedProductId,
      },
    );
  }

  Future<void> logSendMessage({required String threadId}) {
    return _analytics.logEvent(
      name: 'send_message',
      parameters: <String, Object>{'thread_id': threadId},
    );
  }

  Future<void> logSwapAccept({required String proposalId}) {
    return _analytics.logEvent(
      name: 'swap_accept',
      parameters: <String, Object>{'proposal_id': proposalId},
    );
  }

  Future<void> logSwapReject({required String proposalId}) {
    return _analytics.logEvent(
      name: 'swap_reject',
      parameters: <String, Object>{'proposal_id': proposalId},
    );
  }
}
