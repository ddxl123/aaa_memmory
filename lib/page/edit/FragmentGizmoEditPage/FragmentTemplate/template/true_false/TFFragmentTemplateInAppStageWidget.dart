import 'package:flutter/material.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/FragmentTemplateInAppStageWidget.dart';
import '../../base/SingleQuillPreviewWidget.dart';
import '../../base/TemplateViewChunkWidget.dart';
import 'TFFragmentTemplate.dart';

/// 单面模板记忆展示状态下的 Widget。
class TFFragmentTemplateInAppStageWidget extends StatefulWidget {
  const TFFragmentTemplateInAppStageWidget({super.key, required this.tfFragmentTemplate});

  final TFFragmentTemplate tfFragmentTemplate;

  @override
  State<TFFragmentTemplateInAppStageWidget> createState() => _TFFragmentTemplateInAppStageWidgetState();
}

class _TFFragmentTemplateInAppStageWidgetState extends State<TFFragmentTemplateInAppStageWidget> {
  bool isShowAnswer = false;

  late final TFFragmentTemplate t;

  @override
  void initState() {
    super.initState();
    t = widget.tfFragmentTemplate;
    widget.tfFragmentTemplate.inAppStageAbController?.isShowBottomButtonAb.refreshEasy((oldValue) => true);
  }

  @override
  Widget build(BuildContext context) {
    final startPage = [
      TemplateViewChunkWidget(
        chunkTitle: "问题",
        children: [
          SingleQuillPreviewWidget(singleQuillController: widget.tfFragmentTemplate.trueFalse),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.tfFragmentTemplate.answerTemp == true ? Colors.green : Colors.grey,
                        width: widget.tfFragmentTemplate.answerTemp == true ? 2 : 1,
                      ),
                    ),
                    child: Text("正确"),
                  ),
                  onTap: () {
                    if (widget.tfFragmentTemplate.answerTemp != true) {
                      widget.tfFragmentTemplate.answerTemp = true;
                    } else {
                      widget.tfFragmentTemplate.answerTemp = null;
                    }
                    setState(() {});
                  },
                ),
              ),
              Expanded(
                child: GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    margin: EdgeInsets.all(10),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.tfFragmentTemplate.answerTemp == false ? Colors.green : Colors.grey,
                        width: widget.tfFragmentTemplate.answerTemp == false ? 2 : 1,
                      ),
                    ),
                    child: Text("错误"),
                  ),
                  onTap: () {
                    if (widget.tfFragmentTemplate.answerTemp != false) {
                      widget.tfFragmentTemplate.answerTemp = false;
                    } else {
                      widget.tfFragmentTemplate.answerTemp = null;
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("双击任意处显示答案", style: TextStyle(color: Colors.grey)),
        ],
      ),
      TemplateViewExtendChunksWidgets(
          extendChunks: widget.tfFragmentTemplate.extendChunks,
          displayWhere: (ExtendChunk ec) {
            if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.only_start || ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.always) {
              return true;
            }
            return false;
          }),
    ];

    Color trueColor = Colors.grey;
    if (t.answer == true) {
      trueColor = Colors.green;
    } else if (t.answer != t.answerTemp && t.answerTemp == true) {
      trueColor = Colors.red;
    }

    Color falseColor = Colors.grey;
    if (t.answer == false) {
      falseColor = Colors.green;
    } else if (t.answer != t.answerTemp && t.answerTemp == false) {
      falseColor = Colors.red;
    }

    final endPage = [
      TemplateViewChunkWidget(
        chunkTitle: "问题",
        children: [
          SingleQuillPreviewWidget(singleQuillController: widget.tfFragmentTemplate.trueFalse),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: trueColor,
                      width: trueColor != Colors.grey ? 2 : 1,
                    ),
                  ),
                  child: Text("正确"),
                ),
              ),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(10),
                  margin: EdgeInsets.all(10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: falseColor,
                      width: falseColor != Colors.grey ? 2 : 1,
                    ),
                  ),
                  child: Text("错误"),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(width: 10),
              Expanded(
                child: t.answer == t.answerTemp ? Text("回答正确", style: TextStyle(color: Colors.green)) : Text("回答错误", style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      TemplateViewExtendChunksWidgets(
        extendChunks: widget.tfFragmentTemplate.extendChunks,
        displayWhere: (ExtendChunk ec) {
          if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.only_end || ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.always) {
            return true;
          }
          return false;
        },
      ),
    ];

    return FragmentTemplateInAppStageWidget(
      fragmentTemplate: widget.tfFragmentTemplate,
      onDoubleTap: () {
        setState(() {
          isShowAnswer = !isShowAnswer;
        });
      },
      columnChildren: isShowAnswer ? endPage : startPage,
    );
  }
}
