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
  bool isShowAnswer = false;

  late final BlankFragmentTemplate t;

  final GlobalKey<QuillEditorState> editorKey = GlobalKey<QuillEditorState>();

  @override
  void initState() {
    super.initState();
    t = widget.blankFragmentTemplate;
    widget.blankFragmentTemplate.inAppStageAbController?.isShowBottomButtonAb.refreshEasy((oldValue) => true);
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // 将文档转换为Delta对象
      Delta delta = t.blank.quillController.document.toDelta();
      // 创建一个变量，用于累加每个Operation对象的长度
      int offset = 0;

      // 遍历Delta对象的ops属性，检查每个Operation对象的attributes属性
      for (Operation op in delta.operations) {
        if (op.attributes != null && op.attributes!.containsKey(BlankAttribute.blank)) {
          t.blank.quillController.formatText(offset, op.length!, const TextTransparentAttribute(true));
        }
        // 累加当前Operation对象的长度，以便计算下一个Operation对象的位置
        offset += op.length!;
      }
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
            singleQuillController: widget.blankFragmentTemplate.blank,
            onTapUp: (TapUpDetails details, _) {
              final qc = t.blank.quillController;
              // 将点击位置转换为原本的光标位置
              final textPosition = editorKey.currentState?.editableTextKey.currentState?.renderEditor.getPositionForOffset(details.globalPosition);
              if (textPosition != null) {
                // 获取点击位置的块
                final leaf = qc.queryNode(textPosition.offset);
                if (leaf != null) {
                  // 进行显示或隐藏
                  if (leaf.style.attributes.containsKey(TextTransparentAttribute.textTransparent)) {
                    qc.formatText(leaf.offset, leaf.length, const TextTransparentAttribute(null));
                  } else {
                    if (leaf.style.attributes.containsKey(BlankAttribute.blank)) {
                      qc.formatText(leaf.offset, leaf.length, const TextTransparentAttribute(true));
                    }
                  }
                }
              }
              return true;
            },
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
          SingleQuillPreviewWidget(singleQuillController: widget.blankFragmentTemplate.blank),
        ],
      ),
      TemplateViewExtendChunksWidgets(
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
          isShowAnswer = !isShowAnswer;
        });
      },
      columnChildren: isShowAnswer ? endPage : startPage,
    );
  }
}
