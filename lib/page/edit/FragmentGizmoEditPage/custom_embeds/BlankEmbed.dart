import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as q;

class BlankAttribute extends q.Attribute {
  const BlankAttribute(v) : super(BlankAttribute.blank, q.AttributeScope.inline, v);

  static const String blank = "blank";

  static TextStyle get textStyle => TextStyle(
        background: Paint()
          ..strokeWidth = 5.0 // 画笔宽度
          ..style = PaintingStyle.fill // 画笔样式
          ..color = Colors.blue
          ..strokeCap = StrokeCap.round
          // ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2),
      );
}

class TextTransparentAttribute extends q.Attribute {
  const TextTransparentAttribute(v) : super(TextTransparentAttribute.textTransparent, q.AttributeScope.inline, v);
  static const String textTransparent = "text_transparent";

  static TextStyle get textStyle => const TextStyle(color: Colors.transparent);
}

class BlankToolBar extends StatefulWidget {
  const BlankToolBar(this.quillController, {super.key});

  final q.QuillController quillController;

  @override
  State<BlankToolBar> createState() => _BlankToolBarState();
}

class _BlankToolBarState extends State<BlankToolBar> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text("挖空"),
      onPressed: () {
        final qc = widget.quillController;
        if (qc.getSelectionStyle().attributes.containsKey(BlankAttribute.blank)) {
          // 设为 null 表示去除 BlankAttribute 属性。
          qc.formatSelection(const BlankAttribute(null));
        } else {
          qc.formatSelection(const BlankAttribute(true));
        }

        // TODO: 加粗的同时挖空，在输入字符。会出现这个错误：https://github.com/singerdmx/flutter-quill/issues/1227
      },
    );
  }
}
