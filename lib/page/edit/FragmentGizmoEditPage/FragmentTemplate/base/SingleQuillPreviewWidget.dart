import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import 'SingleQuillController.dart';

/// 单个不可编辑的输入框 Widget。
class SingleQuillPreviewWidget extends StatelessWidget {
  const SingleQuillPreviewWidget({
    super.key,
    required this.singleQuillController,
  });

  final SingleQuillController singleQuillController;

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      scrollController: singleQuillController.scrollController,
      focusNode: FocusNode(),
      configurations: QuillEditorConfigurations(
        enableInteractiveSelection: false,
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
      ),
    );
  }
}
