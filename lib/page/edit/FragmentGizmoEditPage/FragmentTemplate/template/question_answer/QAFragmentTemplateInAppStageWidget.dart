import 'dart:math';

import 'package:flutter/material.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/FragmentTemplateInAppStageWidget.dart';
import '../../base/SingleQuillPreviewWidget.dart';
import '../../base/TemplateViewChunkWidget.dart';
import 'QAFragmentTemplate.dart';

/// 问答题记忆展示状态下的 Widget。
class QAFragmentTemplateInAppStageWidget extends StatefulWidget {
  const QAFragmentTemplateInAppStageWidget({super.key, required this.qaFragmentTemplate});

  final QAFragmentTemplate qaFragmentTemplate;

  @override
  State<QAFragmentTemplateInAppStageWidget> createState() => _QAFragmentTemplateInAppStageWidgetState();
}

class _QAFragmentTemplateInAppStageWidgetState extends State<QAFragmentTemplateInAppStageWidget> {
  bool isShowAnswer = false;

  /// 问答交换时的随机值
  bool isExchanged = Random().nextBool();

  @override
  void initState() {
    super.initState();
    // 只有在勾选问答可交换时，才赋予随机值，否则直接赋予 false 值
    if (!widget.qaFragmentTemplate.interchangeable) {
      isExchanged = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final question = TemplateViewChunkWidget(
      chunkTitle: "问题${widget.qaFragmentTemplate.interchangeable ? (isExchanged ? " · 问答已交换" : " · 问答未交换") : ""}",
      children: [
        SingleQuillPreviewWidget(
          fragmentTemplate: widget.qaFragmentTemplate,
          singleQuillController: isExchanged ? widget.qaFragmentTemplate.answer : widget.qaFragmentTemplate.question,
        ),
      ],
    );

    final answer = TemplateViewChunkWidget(
      chunkTitle: "答案",
      children: [
        SingleQuillPreviewWidget(
          fragmentTemplate: widget.qaFragmentTemplate,
          singleQuillController: isExchanged ? widget.qaFragmentTemplate.question : widget.qaFragmentTemplate.answer,
        ),
      ],
    );

    final startPage = [
      question,
      TemplateViewExtendChunksWidgets(
        fragmentTemplate: widget.qaFragmentTemplate,
        extendChunks: widget.qaFragmentTemplate.extendChunks,
        displayWhere: (ExtendChunk ec) {
          if (ec.extendChunkDisplayQAType == ExtendChunkDisplayQAType.always) {
            return true;
          }
          if (isExchanged) {
            if (ec.extendChunkDisplayQAType == ExtendChunkDisplayQAType.only_start_exchange) {
              return true;
            }
          } else {
            if (ec.extendChunkDisplayQAType == ExtendChunkDisplayQAType.only_start) {
              return true;
            }
          }
          return false;
        },
      ),
      const Row(
        children: [
          Spacer(),
          Text("点击任意处显示答案", style: TextStyle(color: Colors.grey)),
          Spacer(),
        ],
      ),
    ];

    final endPage = [
      question,
      answer,
      TemplateViewExtendChunksWidgets(
        fragmentTemplate: widget.qaFragmentTemplate,
        extendChunks: widget.qaFragmentTemplate.extendChunks,
        displayWhere: (ExtendChunk ec) {
          if (ec.extendChunkDisplayQAType == ExtendChunkDisplayQAType.always) {
            return true;
          }
          if (isExchanged) {
            if (ec.extendChunkDisplayQAType == ExtendChunkDisplayQAType.only_end_exchange) {
              return true;
            }
          } else {
            if (ec.extendChunkDisplayQAType == ExtendChunkDisplayQAType.only_end) {
              return true;
            }
          }
          return false;
        },
      ),
    ];

    return FragmentTemplateInAppStageWidget(
      fragmentTemplate: widget.qaFragmentTemplate,
      onTap: () {
        setState(() {
          isShowAnswer = !isShowAnswer;
          if (isShowAnswer) {
            widget.qaFragmentTemplate.inAppStageAbController?.isShowBottomButtonAb.refreshEasy((oldValue) => true);
          }
        });
      },
      columnChildren: isShowAnswer ? endPage : startPage,
    );
  }
}
