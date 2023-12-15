import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import '../../custom_embeds/BlankEmbed.dart';
import 'SingleQuillController.dart';

/// 单个不可编辑的输入框 Widget。
class SingleQuillPreviewWidget extends StatelessWidget {
  const SingleQuillPreviewWidget({
    super.key,
    this.qeKey,
    required this.singleQuillController,
    this.onTapUp,
  });

  final Key? qeKey;

  final SingleQuillController singleQuillController;

  final bool Function(TapUpDetails details, TextPosition Function(Offset offset))? onTapUp;

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      key: qeKey,
      scrollController: singleQuillController.scrollController,
      focusNode: FocusNode(),
      configurations: QuillEditorConfigurations(
        controller: singleQuillController.quillController,
        readOnly: true,
        showCursor: false,
        autoFocus: false,
        expands: false,
        padding: const EdgeInsets.all(0),
        scrollable: false,
        embedBuilders: [
          ...FlutterQuillEmbeds.editorBuilders(),
        ],
        onTapUp: onTapUp,
        customStyleBuilder: (Attribute attribute) {
          if (attribute.key == BlankAttribute.blank) {
            return BlankAttribute.textStyle;
          }
          if (attribute.key == TextTransparentAttribute.textTransparent) {
            return TextTransparentAttribute.textStyle;
          }
          return TextStyle();
        },
      ),
    );
  }
}
