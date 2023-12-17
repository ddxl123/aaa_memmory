import 'dart:math';

import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/custom_embeds/BlankEmbed.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/FragmentTemplateInAppStageWidget.dart';
import '../../base/SingleQuillPreviewWidget.dart';
import '../../base/TemplateViewChunkWidget.dart';
import 'BlankFragmentTemplate.dart';

/// 单面模板记忆展示状态下的 Widget。
class BlankFragmentTemplateInAppStageWidget extends StatefulWidget {
  const BlankFragmentTemplateInAppStageWidget({super.key, required this.blankFragmentTemplate});

  final BlankFragmentTemplate blankFragmentTemplate;

  @override
  State<BlankFragmentTemplateInAppStageWidget> createState() => _BlankFragmentTemplateInAppStageWidgetState();
}

class _BlankFragmentTemplateInAppStageWidgetState extends State<BlankFragmentTemplateInAppStageWidget> {
  bool isShowEnd = false;

  late final BlankFragmentTemplate t;

  final GlobalKey<QuillEditorState> editorKey = GlobalKey<QuillEditorState>();

  @override
  void initState() {
    super.initState();
    t = widget.blankFragmentTemplate;
    t.inAppStageAbController?.isShowBottomButtonAb.refreshEasy((oldValue) => true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      t.changeAllShowForBlankNodeTemp(isShow: false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final startPage = [
      TemplateViewChunkWidget(
        chunkTitle: "填空",
        children: [
          SingleQuillPreviewWidget(
            qeKey: editorKey,
            fragmentTemplate: widget.blankFragmentTemplate,
            singleQuillController: widget.blankFragmentTemplate.blank,
          ),
          SizedBox(height: 10),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("单击显示答案或双击任意处显示全部答案", style: TextStyle(color: Colors.grey)),
        ],
      ),
      TemplateViewExtendChunksWidgets(
          fragmentTemplate: widget.blankFragmentTemplate,
          extendChunks: widget.blankFragmentTemplate.extendChunks,
          displayWhere: (ExtendChunk ec) {
            if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.only_start || ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.always) {
              return true;
            }
            return false;
          }),
    ];

    final endPage = [
      TemplateViewChunkWidget(
        chunkTitle: "填空",
        children: [
          SingleQuillPreviewWidget(
            singleQuillController: widget.blankFragmentTemplate.blank,
            fragmentTemplate: widget.blankFragmentTemplate,
          ),
        ],
      ),
      TemplateViewExtendChunksWidgets(
        fragmentTemplate: widget.blankFragmentTemplate,
        extendChunks: widget.blankFragmentTemplate.extendChunks,
        displayWhere: (ExtendChunk ec) {
          if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.only_end || ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.always) {
            return true;
          }
          return false;
        },
      ),
    ];

    return FragmentTemplateInAppStageWidget(
      fragmentTemplate: widget.blankFragmentTemplate,
      onDoubleTap: () {
        setState(() {
          isShowEnd = !isShowEnd;
          if (isShowEnd) {
            t.changeAllShowForBlankNodeTemp(isShow: true);
          } else {
            t.changeAllShowForBlankNodeTemp(isShow: false);
          }
        });
      },
      columnChildren: isShowEnd ? endPage : startPage,
    );
  }
}
