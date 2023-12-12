import 'package:flutter/material.dart';

import 'ChoiceFragmentTemplate.dart';
import 'ChoiceFragmentTemplateInAppStageWidget.dart';

/// 选择题预览状态下的 Widget。
class ChoiceFragmentTemplatePreviewWidget extends StatefulWidget {
  const ChoiceFragmentTemplatePreviewWidget({
    super.key,
    required this.choiceFragmentTemplate,
  });

  final ChoiceFragmentTemplate choiceFragmentTemplate;

  @override
  State<ChoiceFragmentTemplatePreviewWidget> createState() => _ChoiceFragmentTemplatePreviewWidgetState();
}

class _ChoiceFragmentTemplatePreviewWidgetState extends State<ChoiceFragmentTemplatePreviewWidget> {

  @override
  Widget build(BuildContext context) {
    return ChoiceFragmentTemplateInAppStageWidget(
      choiceFragmentTemplate: widget.choiceFragmentTemplate,
    );
  }
}
