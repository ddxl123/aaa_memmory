import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplate.dart';
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
    required this.fragmentTemplate,
    this.onTapUp,
  });

  final Key? qeKey;

  final FragmentTemplate fragmentTemplate;

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
          if (fragmentTemplate is BlankFragmentTemplate) BlankEmbedBuilder(blankFragmentTemplate: fragmentTemplate as BlankFragmentTemplate),
          ...FlutterQuillEmbeds.editorBuilders(),
        ],
        onTapUp: onTapUp,
      ),
    );
  }
}
