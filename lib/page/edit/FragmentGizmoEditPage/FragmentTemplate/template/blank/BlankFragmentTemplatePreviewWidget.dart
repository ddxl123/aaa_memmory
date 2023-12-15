import 'package:flutter/material.dart';

import 'BlankFragmentTemplate.dart';
import 'BlankFragmentTemplateInAppStageWidget.dart';

/// 单面模板预览状态下的 Widget。
class BlankFragmentTemplatePreviewWidget extends StatefulWidget {
  const BlankFragmentTemplatePreviewWidget({super.key, required this.blankFragmentTemplate});

  final BlankFragmentTemplate blankFragmentTemplate;

  @override
  State<BlankFragmentTemplatePreviewWidget> createState() => _BlankFragmentTemplatePreviewWidgetState();
}

class _BlankFragmentTemplatePreviewWidgetState extends State<BlankFragmentTemplatePreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return BlankFragmentTemplateInAppStageWidget(
      blankFragmentTemplate: widget.blankFragmentTemplate,
    );
  }
}
