import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../../base/FragmentTemplateEditWidget.dart';
import '../../base/SingleQuillEditableWidget.dart';
import '../../base/TemplateViewChunkWidget.dart';
import 'BlankFragmentTemplate.dart';

/// 单面模板的编辑 Widget。
class BlankFragmentTemplateEditWidget extends StatefulWidget {
  const BlankFragmentTemplateEditWidget({
    super.key,
    required this.blankFragmentTemplate,
    required this.isEditable,
  });

  final BlankFragmentTemplate blankFragmentTemplate;

  final bool isEditable;

  @override
  State<BlankFragmentTemplateEditWidget> createState() => _BlankFragmentTemplateEditWidgetState();
}

class _BlankFragmentTemplateEditWidgetState extends State<BlankFragmentTemplateEditWidget> {
  @override
  Widget build(BuildContext context) {
    return FragmentTemplateEditWidget(
      fragmentTemplate: widget.blankFragmentTemplate,
      isEditable: widget.isEditable,
      children: [
        TemplateViewChunkWidget(
          chunkTitle: "填空",
          children: [
            SingleQuillEditableWidget(
              singleQuillController: widget.blankFragmentTemplate.blank,
              isEditable: widget.isEditable,
            ),
          ],
        ),
      ],
    );
  }
}
