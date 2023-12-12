import 'package:flutter/material.dart';

import 'QAFragmentTemplate.dart';
import 'QAFragmentTemplateInAppStageWidget.dart';

/// 问答题预览状态下的 Widget。
class QAFragmentTemplatePreviewWidget extends StatefulWidget {
  const QAFragmentTemplatePreviewWidget({super.key, required this.qaFragmentTemplate});

  final QAFragmentTemplate qaFragmentTemplate;

  @override
  State<QAFragmentTemplatePreviewWidget> createState() => _QAFragmentTemplatePreviewWidgetState();
}

class _QAFragmentTemplatePreviewWidgetState extends State<QAFragmentTemplatePreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return QAFragmentTemplateInAppStageWidget(
      qaFragmentTemplate: widget.qaFragmentTemplate,
    );
  }
}
