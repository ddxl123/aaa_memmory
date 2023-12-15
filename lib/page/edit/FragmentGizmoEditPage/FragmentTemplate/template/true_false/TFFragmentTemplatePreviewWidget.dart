import 'package:flutter/material.dart';

import 'TFFragmentTemplate.dart';
import 'TFFragmentTemplateInAppStageWidget.dart';

/// 单面模板预览状态下的 Widget。
class TFFragmentTemplatePreviewWidget extends StatefulWidget {
  const TFFragmentTemplatePreviewWidget({super.key, required this.tfFragmentTemplate});

  final TFFragmentTemplate tfFragmentTemplate;

  @override
  State<TFFragmentTemplatePreviewWidget> createState() => _TFFragmentTemplatePreviewWidgetState();
}

class _TFFragmentTemplatePreviewWidgetState extends State<TFFragmentTemplatePreviewWidget> {
  @override
  Widget build(BuildContext context) {
    return TFFragmentTemplateInAppStageWidget(
      tfFragmentTemplate: widget.tfFragmentTemplate,
    );
  }
}
