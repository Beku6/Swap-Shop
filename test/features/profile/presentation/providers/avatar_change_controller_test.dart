import 'package:flutter_test/flutter_test.dart';
import 'package:swap/features/profile/presentation/providers/avatar_change_controller.dart';

void main() {
  group('AvatarChangeController', () {
    test('starts in idle state', () {
      final controller = AvatarChangeController();

      expect(controller.state.status, AvatarChangeStatus.idle);
      expect(controller.state.isBusy, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('transitions through pick/crop/upload/success', () {
      final controller = AvatarChangeController();

      controller.beginPick();
      expect(controller.state.status, AvatarChangeStatus.picking);
      expect(controller.state.isBusy, isTrue);

      controller.beginCrop();
      expect(controller.state.status, AvatarChangeStatus.cropping);
      expect(controller.state.isBusy, isTrue);

      controller.beginUpload();
      expect(controller.state.status, AvatarChangeStatus.uploading);
      expect(controller.state.isBusy, isTrue);

      controller.completeSuccess(avatarUrl: 'https://cdn/avatar.jpg?v=1');
      expect(controller.state.status, AvatarChangeStatus.success);
      expect(controller.state.avatarUrl, 'https://cdn/avatar.jpg?v=1');
      expect(controller.state.isBusy, isFalse);
      expect(controller.state.errorMessage, isNull);
    });

    test('stores error and can reset', () {
      final controller = AvatarChangeController();

      controller.fail('Upload failed');
      expect(controller.state.status, AvatarChangeStatus.error);
      expect(controller.state.errorMessage, 'Upload failed');
      expect(controller.state.isBusy, isFalse);

      controller.reset();
      expect(controller.state.status, AvatarChangeStatus.idle);
      expect(controller.state.errorMessage, isNull);
      expect(controller.state.avatarUrl, isNull);
    });
  });
}
