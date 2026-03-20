import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/painting.dart';

class AppShaderWarmUp extends ShaderWarmUp {
  const AppShaderWarmUp();

  @override
  Future<void> warmUpOnCanvas(ui.Canvas canvas) async {
    const size = ui.Size(360, 640);
    final rect = ui.Offset.zero & size;

    final basePaint = ui.Paint()..color = const ui.Color(0xFFF3F0EB);
    canvas.drawRect(rect, basePaint);

    final gradientPaint = ui.Paint()
      ..shader = ui.Gradient.linear(
        const ui.Offset(24, 64),
        const ui.Offset(336, 284),
        const <ui.Color>[
          ui.Color(0xFF1A1A1A),
          ui.Color(0xFF2E2E2E),
          ui.Color(0xFF1A1A1A),
        ],
      );

    final card = ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTWH(24, 64, 312, 220),
      const ui.Radius.circular(28),
    );
    canvas.drawRRect(card, gradientPaint);

    final avatarPaint = ui.Paint()..color = const ui.Color(0xFFFFFFFF);
    canvas.drawCircle(const ui.Offset(56, 320), 20, avatarPaint);

    final chipPaint = ui.Paint()..color = const ui.Color(0xFF2C2420);
    final chip = ui.RRect.fromRectAndRadius(
      const ui.Rect.fromLTWH(24, 560, 150, 44),
      const ui.Radius.circular(16),
    );
    canvas.drawRRect(chip, chipPaint);
  }
}

void configureShaderWarmupIfEnabled() {
  const enabled = bool.fromEnvironment('SHADER_WARMUP', defaultValue: false);
  if (!enabled || kReleaseMode || defaultTargetPlatform != TargetPlatform.android) {
    return;
  }
  PaintingBinding.shaderWarmUp = const AppShaderWarmUp();
}
