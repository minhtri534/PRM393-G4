import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../models/annotator/annotator_models.dart';

class BboxLabelingCanvas extends StatefulWidget {
  final Uint8List? imageBytes;
  final int imageWidth;
  final int imageHeight;
  final List<LabelingBox> boxes;
  final List<AnnotatorLabelModel> labels;
  final String? selectedLabelId;
  final int? selectedBoxIndex;
  final bool drawMode;
  final bool readOnly;
  final ValueChanged<LabelingBox> onBoxCreated;
  final ValueChanged<int> onBoxSelected;

  const BboxLabelingCanvas({
    super.key,
    required this.imageBytes,
    required this.imageWidth,
    required this.imageHeight,
    required this.boxes,
    required this.labels,
    required this.selectedLabelId,
    required this.selectedBoxIndex,
    required this.drawMode,
    required this.readOnly,
    required this.onBoxCreated,
    required this.onBoxSelected,
  });

  @override
  State<BboxLabelingCanvas> createState() => _BboxLabelingCanvasState();
}

class _BboxLabelingCanvasState extends State<BboxLabelingCanvas> {
  Offset? _startPoint;
  Rect? _previewRect;

  AnnotatorLabelModel? _labelFor(String labelId) {
    for (final label in widget.labels) {
      if (label.id == labelId) return label;
    }
    return null;
  }

  Color _colorForLabel(String labelId) {
    final label = _labelFor(labelId);
    if (label == null) return AppTheme.primaryColor;
    return Color(
      int.parse('FF${label.colorHex.replaceAll('#', '')}', radix: 16),
    );
  }

  Rect _imageRect(Size canvasSize) {
    final srcW = widget.imageWidth > 0 ? widget.imageWidth.toDouble() : 1;
    final srcH = widget.imageHeight > 0 ? widget.imageHeight.toDouble() : 1;
    final imageAspect = srcW / srcH;
    final canvasAspect = canvasSize.width / canvasSize.height;

    if (imageAspect > canvasAspect) {
      final width = canvasSize.width;
      final height = width / imageAspect;
      return Rect.fromLTWH(0, (canvasSize.height - height) / 2, width, height);
    }

    final height = canvasSize.height;
    final width = height * imageAspect;
    return Rect.fromLTWH((canvasSize.width - width) / 2, 0, width, height);
  }

  Offset? _toImagePoint(Offset local, Rect imageRect) {
    if (!imageRect.contains(local)) return null;
    final x =
        ((local.dx - imageRect.left) / imageRect.width) * widget.imageWidth;
    final y =
        ((local.dy - imageRect.top) / imageRect.height) * widget.imageHeight;
    return Offset(x, y);
  }

  Rect _boxCanvasRect(LabelingBox box, Rect imageRect) {
    final left = imageRect.left + (box.x / widget.imageWidth) * imageRect.width;
    final top = imageRect.top + (box.y / widget.imageHeight) * imageRect.height;
    final width = (box.width / widget.imageWidth) * imageRect.width;
    final height = (box.height / widget.imageHeight) * imageRect.height;
    return Rect.fromLTWH(left, top, width, height);
  }

  /// Hit-test from front-most box so overlapping labels remain selectable.
  int? _hitTestBox(Offset localPosition, Rect imageRect) {
    for (var i = widget.boxes.length - 1; i >= 0; i--) {
      if (_boxCanvasRect(widget.boxes[i], imageRect).contains(localPosition)) {
        return i;
      }
    }
    return null;
  }

  void _handlePanStart(DragStartDetails details, Rect imageRect) {
    if (widget.readOnly || !widget.drawMode || widget.selectedLabelId == null) {
      return;
    }

    // Touching an existing box selects it (so old labels can be deleted)
    // instead of starting a new draw gesture.
    final hitIndex = _hitTestBox(details.localPosition, imageRect);
    if (hitIndex != null) {
      widget.onBoxSelected(hitIndex);
      setState(() {
        _startPoint = null;
        _previewRect = null;
      });
      return;
    }

    final point = _toImagePoint(details.localPosition, imageRect);
    if (point == null) return;
    setState(() {
      _startPoint = point;
      _previewRect = null;
    });
  }

  void _handlePanUpdate(DragUpdateDetails details, Rect imageRect) {
    if (_startPoint == null) return;
    final current = _toImagePoint(details.localPosition, imageRect);
    if (current == null) return;

    final x = _startPoint!.dx < current.dx ? _startPoint!.dx : current.dx;
    final y = _startPoint!.dy < current.dy ? _startPoint!.dy : current.dy;
    final width = (_startPoint!.dx - current.dx).abs();
    final height = (_startPoint!.dy - current.dy).abs();

    setState(() {
      _previewRect = Rect.fromLTWH(x, y, width, height);
    });
  }

  void _handlePanEnd() {
    if (_startPoint == null || _previewRect == null) {
      setState(() {
        _startPoint = null;
        _previewRect = null;
      });
      return;
    }

    final preview = _previewRect!;
    if (preview.width >= 5 &&
        preview.height >= 5 &&
        widget.selectedLabelId != null) {
      widget.onBoxCreated(
        LabelingBox(
          labelId: widget.selectedLabelId!,
          x: preview.left,
          y: preview.top,
          width: preview.width,
          height: preview.height,
        ),
      );
    }

    setState(() {
      _startPoint = null;
      _previewRect = null;
    });
  }

  void _handleTap(TapUpDetails details, Rect imageRect) {
    if (widget.readOnly) return;

    final hitIndex = _hitTestBox(details.localPosition, imageRect);
    if (hitIndex != null) {
      widget.onBoxSelected(hitIndex);
      return;
    }

    // Only clear selection on empty taps in select mode so draw mode
    // does not deselect after creating a box.
    if (!widget.drawMode) {
      widget.onBoxSelected(-1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final canvasSize = Size(constraints.maxWidth, constraints.maxHeight);
        final imageRect = _imageRect(canvasSize);

        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: ColoredBox(
            color: const Color(0xFF111827),
            child: Stack(
              children: [
                Positioned(
                  left: imageRect.left,
                  top: imageRect.top,
                  width: imageRect.width,
                  height: imageRect.height,
                  child: widget.imageBytes != null
                      ? Image.memory(widget.imageBytes!, fit: BoxFit.fill)
                      : const Center(
                          child: Icon(
                            Icons.image_outlined,
                            color: Colors.white54,
                            size: 48,
                          ),
                        ),
                ),
                Positioned.fill(
                  child: CustomPaint(
                    painter: _BboxOverlayPainter(
                      imageRect: imageRect,
                      imageWidth: widget.imageWidth,
                      imageHeight: widget.imageHeight,
                      boxes: widget.boxes,
                      selectedBoxIndex: widget.selectedBoxIndex,
                      previewRect: _previewRect,
                      previewLabelId: widget.selectedLabelId,
                      colorForLabel: _colorForLabel,
                      labelNameForId: (id) => _labelFor(id)?.name ?? 'Label',
                    ),
                  ),
                ),
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    // Pan only in draw mode — otherwise pan wins over tap on
                    // touch devices and existing boxes cannot be selected.
                    onPanStart: widget.drawMode && !widget.readOnly
                        ? (d) => _handlePanStart(d, imageRect)
                        : null,
                    onPanUpdate: widget.drawMode && !widget.readOnly
                        ? (d) => _handlePanUpdate(d, imageRect)
                        : null,
                    onPanEnd: widget.drawMode && !widget.readOnly
                        ? (_) => _handlePanEnd()
                        : null,
                    onTapUp: widget.readOnly
                        ? null
                        : (d) => _handleTap(d, imageRect),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _BboxOverlayPainter extends CustomPainter {
  final Rect imageRect;
  final int imageWidth;
  final int imageHeight;
  final List<LabelingBox> boxes;
  final int? selectedBoxIndex;
  final Rect? previewRect;
  final String? previewLabelId;
  final Color Function(String labelId) colorForLabel;
  final String Function(String labelId) labelNameForId;

  _BboxOverlayPainter({
    required this.imageRect,
    required this.imageWidth,
    required this.imageHeight,
    required this.boxes,
    required this.selectedBoxIndex,
    required this.previewRect,
    required this.previewLabelId,
    required this.colorForLabel,
    required this.labelNameForId,
  });

  Rect _toCanvasRect(Rect imageCoords) {
    final left =
        imageRect.left + (imageCoords.left / imageWidth) * imageRect.width;
    final top =
        imageRect.top + (imageCoords.top / imageHeight) * imageRect.height;
    final width = (imageCoords.width / imageWidth) * imageRect.width;
    final height = (imageCoords.height / imageHeight) * imageRect.height;
    return Rect.fromLTWH(left, top, width, height);
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < boxes.length; i++) {
      final box = boxes[i];
      final color = colorForLabel(box.labelId);
      final rect = _toCanvasRect(
        Rect.fromLTWH(box.x, box.y, box.width, box.height),
      );

      final fill = Paint()
        ..color = color.withValues(alpha: 0.18)
        ..style = PaintingStyle.fill;
      final stroke = Paint()
        ..color = i == selectedBoxIndex ? Colors.white : color
        ..style = PaintingStyle.stroke
        ..strokeWidth = i == selectedBoxIndex ? 3 : 2;

      canvas.drawRect(rect, fill);
      canvas.drawRect(rect, stroke);

      final textPainter = TextPainter(
        text: TextSpan(
          text: labelNameForId(box.labelId),
          style: TextStyle(
            color: Colors.white,
            fontSize: 11,
            backgroundColor: color.withValues(alpha: 0.9),
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: rect.width);

      textPainter.paint(canvas, Offset(rect.left + 2, rect.top + 2));
    }

    if (previewRect != null && previewLabelId != null) {
      final rect = _toCanvasRect(previewRect!);
      final stroke = Paint()
        ..color = colorForLabel(previewLabelId!)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;
      canvas.drawRect(rect, stroke);
    }
  }

  @override
  bool shouldRepaint(covariant _BboxOverlayPainter oldDelegate) {
    return oldDelegate.boxes != boxes ||
        oldDelegate.selectedBoxIndex != selectedBoxIndex ||
        oldDelegate.previewRect != previewRect;
  }
}
