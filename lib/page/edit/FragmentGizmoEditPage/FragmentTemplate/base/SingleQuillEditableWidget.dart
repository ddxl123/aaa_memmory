import 'dart:math';
import 'dart:ui';

import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/custom_embeds/BlankEmbed.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

import 'SingleQuillController.dart';

/// 单个可编辑的输入框 Widget。
class SingleQuillEditableWidget extends StatelessWidget {
  const SingleQuillEditableWidget({
    super.key,
    required this.singleQuillController,
    required this.isEditable,
    required this.fragmentTemplate,
  });

  final SingleQuillController singleQuillController;
  final bool isEditable;
  final FragmentTemplate fragmentTemplate;

  @override
  Widget build(BuildContext context) {
    return QuillEditor(
      scrollController: singleQuillController.scrollController,
      focusNode: singleQuillController.focusNode,
      configurations: QuillEditorConfigurations(
        placeholder: "请输入...",
        customStyles: DefaultStyles(
          placeHolder: DefaultTextBlockStyle(
            const TextStyle(color: Colors.grey),
            const VerticalSpacing(0, 0),
            const VerticalSpacing(0, 0),
            const BoxDecoration(),
          ),
        ),
        controller: singleQuillController.quillController,
        readOnly: !isEditable,
        showCursor: isEditable,
        autoFocus: false,
        expands: false,
        padding: const EdgeInsets.all(0),
        scrollable: false,
        embedBuilders: [
          if (fragmentTemplate is BlankFragmentTemplate) BlankEmbedBuilder(blankFragmentTemplate: fragmentTemplate as BlankFragmentTemplate),
          ...FlutterQuillEmbeds.editorBuilders(),
        ],
        customStyleBuilder: (Attribute attribute) {
          if (attribute.key == BlankHideAttribute.blank_hide) {
            return BlankHideAttribute.textStyle;
          }
          return const TextStyle();
        },
      ),
    );
  }
}
