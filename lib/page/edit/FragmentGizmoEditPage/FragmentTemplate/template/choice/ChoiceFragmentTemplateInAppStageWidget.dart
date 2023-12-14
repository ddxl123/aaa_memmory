import 'dart:math';

import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/SingleQuillController.dart';
import 'package:flutter/material.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/FragmentTemplateInAppStageWidget.dart';
import '../../base/SingleQuillPreviewWidget.dart';
import '../../base/TemplateViewChunkWidget.dart';
import 'ChoiceFragmentTemplate.dart';
import 'ChoicePrefixType.dart';

/// 选择题记忆展示状态下的 Widget。
class ChoiceFragmentTemplateInAppStageWidget extends StatefulWidget {
  const ChoiceFragmentTemplateInAppStageWidget({
    super.key,
    required this.choiceFragmentTemplate,
  });

  final ChoiceFragmentTemplate choiceFragmentTemplate;

  @override
  State<ChoiceFragmentTemplateInAppStageWidget> createState() => _ChoiceFragmentTemplateInAppStageWidgetState();
}

class _ChoiceFragmentTemplateInAppStageWidgetState extends State<ChoiceFragmentTemplateInAppStageWidget> {
  bool isShowAnswer = false;
  late final ChoiceFragmentTemplate t;

  @override
  void initState() {
    super.initState();
    t = widget.choiceFragmentTemplate;
    t.displayChoices.clear();
    initFilter();
  }

  void initFilter() {
    // 正确的选项
    final correctChoices = t.getCorrectChoices..shuffle();
    // 非正确的选项
    final noCorrectChoices = [...t.choices]
      ..removeWhere((element) => correctChoices.contains(element))
      ..shuffle();

    // 必须展示的选项
    final requiredChoices = t.getRequiredChoices..shuffle();
    // 非必须展示的选项
    final noRequiredChoices = [...t.choices]
      ..removeWhere((element) => requiredChoices.contains(element))
      ..shuffle();

    // 必须展示且正确的选项
    final requiredCorrectChoices = [...requiredChoices]
      ..removeWhere((element) => noCorrectChoices.contains(element))
      ..shuffle();
    // 必须展示且非正确的选项
    final requiredNoCorrectChoices = [...requiredChoices]
      ..removeWhere((element) => correctChoices.contains(element))
      ..shuffle();

    // 正确且必须展示的选项
    final correctRequiredChoices = [...correctChoices]
      ..removeWhere((element) => noRequiredChoices.contains(element))
      ..shuffle();
    // 正确且非必须展示的选项
    final correctNoRequiredChoices = [...correctChoices]
      ..removeWhere((element) => requiredChoices.contains(element))
      ..shuffle();

    // 非必须展示且非正确的选项
    final noCorrectNoRequiredChoices = [...noCorrectChoices]
      ..removeWhere((element) => requiredChoices.contains(element))
      ..shuffle();

    // 抽取的总随机数量，假设 2-4 个，则 Random 是在 0-3(不含3)，即 0 1 2，加上 extractionCountMin 即 2，得 2，3，4。
    final int extractionCount = Random().nextInt(t.extractionCountMax - t.extractionCountMin + 1) + t.extractionCountMin;

    // 正常情况下，抽取正确的数量
    // 因为占比始终小于等于 1，因此不会出现抽取正确的数量大于总随机数量
    int extractionCorrectCount = (extractionCount * t.correctProportion).ceil();
    // 抽取的正确数量必须至少一个
    extractionCorrectCount = extractionCorrectCount == 0 ? 1 : extractionCorrectCount;

    if (t.canDisorderly) {
      if (t.requiredType == RequiredType.not_enabled) {
        // 使用正确的选项填充占比。
        t.displayChoices.addAll(correctChoices.take(extractionCorrectCount));
        // 如果总量不够，使用非正确的选项填充。
        t.displayChoices.addAll(noCorrectChoices.take(extractionCount - t.displayChoices.length));
        // 如果总量不够，再使用正确的选项填充，因为可能有剩余的。
        t.displayChoices.addAll(([...correctChoices]
              ..removeWhere((element) => t.displayChoices.contains(element))
              ..shuffle())
            .take(extractionCount - t.displayChoices.length));
      } else if (t.requiredType == RequiredType.proportion_first) {
        // 使用必须且正确的选项填充占比。
        t.displayChoices.addAll(requiredCorrectChoices.take(extractionCorrectCount));
        // 如果必须选项的量不够，使用非必须且正确的选项填充。
        t.displayChoices.addAll(correctNoRequiredChoices.take(extractionCorrectCount - t.displayChoices.length));

        // 以上正确的选项已填充饱和。

        // 如果总量不够，使用必须且非正确的选项填充。
        t.displayChoices.addAll(requiredNoCorrectChoices.take(extractionCount - t.displayChoices.length));
        // 如果总量不够，使用非必须且非正确的选项填充。
        t.displayChoices.addAll(noCorrectNoRequiredChoices.take(extractionCount - t.displayChoices.length));
        // 如果总量不够，使用必须且正确的选项填充，因为可能有剩余的。
        t.displayChoices.addAll(([...requiredCorrectChoices]
              ..removeWhere((element) => t.displayChoices.contains(element))
              ..shuffle())
            .take(extractionCount - t.displayChoices.length));
        // 如果总量不够，使用非必须且正确的选项填充，因为可能有剩余的。
        t.displayChoices.addAll(([...correctNoRequiredChoices]
              ..removeWhere((element) => t.displayChoices.contains(element))
              ..shuffle())
            .take(extractionCount - t.displayChoices.length));
      } else if (t.requiredType == RequiredType.required_first) {
        // 使用必须且正确的选项填充占比。
        t.displayChoices.addAll(requiredCorrectChoices.take(extractionCorrectCount));
        // 如果总量不够，使用必须且非正确的选项填充。
        t.displayChoices.addAll(requiredNoCorrectChoices.take(extractionCount - t.displayChoices.length));
        // 如果总量不够，使用必须且正确的选项再填充填充，因为可能有剩余的。
        t.displayChoices.addAll(([...requiredCorrectChoices]
              ..removeWhere((element) => t.displayChoices.contains(element))
              ..shuffle())
            .take(extractionCount - t.displayChoices.length));

        // 以上必须的选项已填充饱和。

        // 如果总量不够，剩余非必须且正确的选项填充，因为必须且正确的选项可能不够。
        final notEnough = extractionCorrectCount - t.displayChoices.where((element) => requiredCorrectChoices.contains(element)).length;
        if (notEnough > 0) {
          t.displayChoices.addAll(correctNoRequiredChoices.take(notEnough));
        }

        // 以上正确的选项已填充饱和。

        // 如果总量不够，使用非必须且非正确的选项填充。
        t.displayChoices.addAll(noCorrectNoRequiredChoices.take(extractionCount - t.displayChoices.length));
        // 如果总量不够，剩余非必须且正确的选项填充，因为可能有剩余。（因为正确的选项已经饱和，所以放在最后）
        t.displayChoices.addAll(([...correctNoRequiredChoices]
              ..removeWhere((element) => t.displayChoices.contains(element))
              ..shuffle())
            .take(extractionCount - t.displayChoices.length));
      } else {
        throw "未处理 ${t.requiredType}";
      }
      t.displayChoices.shuffle(Random());
    } else {
      t.displayChoices.addAll(t.choices);
    }
  }

  @override
  Widget build(BuildContext context) {
    final questionWidget = TemplateViewChunkWidget(
      chunkTitle: "问题",
      children: [
        SingleQuillPreviewWidget(
          singleQuillController: t.question,
        ),
      ],
    );

    final choiceSingleWidgets = <Widget>[];
    for (int i = 0; i < t.displayChoices.length; i++) {
      bool isSelected = t.selectedChoices.contains(t.displayChoices[i]);
      bool isCorrect = t.getCorrectChoices.contains(t.displayChoices[i]);
      Color color = Colors.grey;
      if (isShowAnswer) {
        if (isCorrect) {
          color = Colors.green;
        } else {
          if (isSelected) {
            color = Colors.red;
          }
        }
      } else {
        if (isSelected) {
          color = Colors.green;
        }
      }

      choiceSingleWidgets.add(
        GestureDetector(
          onTap: () {
            if (isShowAnswer) {
              return;
            }
            setState(() {
              if (t.choiceType == ChoiceType.simple) {
                t.selectedChoices.clear();
              }
              if (isSelected) {
                t.selectedChoices.remove(t.displayChoices[i]);
              } else {
                t.selectedChoices.add(t.displayChoices[i]);
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              border: Border.all(
                color: color,
                width: color == Colors.grey ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Row(
              children: [
                t.choicePrefixType == ChoicePrefixType.none
                    ? Container()
                    : Container(
                        width: 30,
                        child: Text(t.choicePrefixType.toTypeFrom(i + 1), style: const TextStyle(color: Colors.amber)),
                      ),
                Expanded(
                  child: SingleQuillPreviewWidget(
                    singleQuillController: t.displayChoices[i],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final choicesWidget = TemplateViewChunkWidget(
      chunkTitle: t.choiceType == ChoiceType.simple ? "单选" : "多选",
      children: [
        ...choiceSingleWidgets,
        isShowAnswer
            ? Padding(
                padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                child: Column(
                  children: [
                    t.isAnswerCorrect
                        ? Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "回答正确：${t.getSelectedAndCorrectChoicePrefixType().$1.join(",")}",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          )
                        : Row(
                            children: [
                              Expanded(
                                child: Text(
                                  "回答错误：${t.getSelectedAndCorrectChoicePrefixType().$1.join(",")}",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  "正确答案：${t.getSelectedAndCorrectChoicePrefixType().$2.join(",")}",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                            ],
                          ),
                  ],
                ),
              )
            : Container(),
      ],
    );

    final startPage = [
      questionWidget,
      choicesWidget,
      TemplateViewExtendChunksWidgets(
        extendChunks: t.extendChunks,
        displayWhere: (ExtendChunk ec) {
          if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.always) {
            return true;
          }
          if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.only_start) {
            return true;
          }
          return false;
        },
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [Text("双击任意处显示答案", style: TextStyle(color: Colors.grey))],
      ),
    ];

    final endPage = [
      questionWidget,
      choicesWidget,
      TemplateViewExtendChunksWidgets(
        extendChunks: t.extendChunks,
        displayWhere: (ExtendChunk ec) {
          if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.always) {
            return true;
          }
          if (ec.extendChunkDisplay2Type == ExtendChunkDisplay2Type.only_end) {
            return true;
          }
          return false;
        },
      ),
    ];

    return FragmentTemplateInAppStageWidget(
      fragmentTemplate: t,
      onDoubleTap: () {
        setState(() {
          isShowAnswer = !isShowAnswer;
        });
      },
      columnChildren: isShowAnswer ? endPage : startPage,
    );
  }
}
