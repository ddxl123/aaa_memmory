import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'package:tools/tools.dart';
import '../../base/FragmentTemplateEditWidget.dart';
import '../../base/SingleQuillEditableWidget.dart';
import '../../base/SingleQuillController.dart';
import '../../base/TemplateViewChunkWidget.dart';
import 'ChoiceFragmentTemplate.dart';
import 'ChoicePrefixType.dart';

/// 选择题模板的编辑 Widget。
class ChoiceFragmentTemplateEditWidget extends StatefulWidget {
  const ChoiceFragmentTemplateEditWidget({
    super.key,
    required this.choiceFragmentTemplate,
    required this.isEditable,
  });

  final ChoiceFragmentTemplate choiceFragmentTemplate;

  final bool isEditable;

  @override
  State<ChoiceFragmentTemplateEditWidget> createState() => _ChoiceFragmentTemplateEditWidgetState();
}

class _ChoiceFragmentTemplateEditWidgetState extends State<ChoiceFragmentTemplateEditWidget> {
  @override
  Widget build(BuildContext context) {
    return FragmentTemplateEditWidget(
      fragmentTemplate: widget.choiceFragmentTemplate,
      isEditable: widget.isEditable,
      children: [
        TemplateViewChunkWidget(
          chunkTitle: "问题",
          children: [
            SingleQuillEditableWidget(
              singleQuillController: widget.choiceFragmentTemplate.question,
              isEditable: widget.isEditable,
            ),
          ],
        ),
        TemplateViewChunkWidget(
          chunkTitle: "选项",
          children: [
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDropdownBodyButton(
                      primaryButton: Row(
                        children: [
                          Text("前缀类型："),
                          Spacer(),
                          Text(widget.choiceFragmentTemplate.choicePrefixType.displayName),
                          Icon(Icons.arrow_right_outlined, color: Colors.grey),
                        ],
                      ),
                      initValue: widget.choiceFragmentTemplate.choicePrefixType,
                      items: ChoicePrefixType.values.map(
                        (e) {
                          return CustomItem(value: e, text: e.displayName);
                        },
                      ).toList(),
                      onChanged: (v) {
                        setState(() {
                          widget.choiceFragmentTemplate.choicePrefixType = v!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Expanded(
                    child: CustomDropdownBodyButton(
                      primaryButton: Row(
                        children: [
                          Text("选择类型："),
                          Spacer(),
                          Text(widget.choiceFragmentTemplate.choiceType == ChoiceType.simple ? "单选" : "多选"),
                          Icon(Icons.arrow_right_outlined, color: Colors.grey),
                        ],
                      ),
                      initValue: widget.choiceFragmentTemplate.choiceType,
                      items: [
                        CustomItem(value: ChoiceType.simple, text: "单选"),
                        CustomItem(value: ChoiceType.multiple_perfect_match, text: "多选"),
                      ],
                      onChanged: (v) {
                        setState(() {
                          widget.choiceFragmentTemplate.cancelAllCorrect();
                          widget.choiceFragmentTemplate.choiceType = v!;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Divider(),
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Text("是否可乱序："),
                  Spacer(),
                  Checkbox(
                    visualDensity: kMinVisualDensity,
                    value: widget.choiceFragmentTemplate.canDisorderly,
                    onChanged: (v) {
                      setState(() {
                        widget.choiceFragmentTemplate.canDisorderly = v!;
                      });
                    },
                  ),
                ],
              ),
            ),
            widget.choiceFragmentTemplate.canDisorderly
                ? Container(
                    padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
                    child: StatefulBuilder(
                      builder: (ctx, r) {
                        final wc = widget.choiceFragmentTemplate;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("仅抽取 ${wc.tempExtractionCountMin.toInt()} - ${wc.tempExtractionCountMax.toInt()} 个选项进行展示："),
                            SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  Text(wc.extractionCountMin.toString()),
                                  Expanded(
                                    child: SfRangeSlider(
                                      min: 0,
                                      max: wc.choiceCount.toDouble(),
                                      interval: 1,
                                      stepSize: 1.0,
                                      values: SfRangeValues(wc.tempExtractionCountMin, wc.tempExtractionCountMax),
                                      onChanged: (SfRangeValues value) {
                                        wc.tempExtractionCountMin = value.start;
                                        wc.tempExtractionCountMax = value.end;
                                        if (wc.tempExtractionCorrectCountMax > wc.tempExtractionCountMax) {
                                          wc.tempExtractionCorrectCountMax = wc.tempExtractionCountMax;
                                          if (wc.tempExtractionCorrectCountMin > wc.tempExtractionCorrectCountMax) {
                                            wc.tempExtractionCorrectCountMin = wc.tempExtractionCorrectCountMax;
                                          }
                                        }
                                        r(() {});
                                      },
                                      showDividers: true,
                                    ),
                                  ),
                                  Text(wc.extractionCountMax.toString()),
                                ],
                              ),
                            ),
                            Text("其中正确选项数量占比："),
                            SizedBox(
                              height: 50,
                              child: Row(
                                children: [
                                  Text(wc.extractionCorrectCountMin.toString()),
                                  Expanded(
                                    child: SfRangeSlider(
                                      min: 0,
                                      max: wc.choiceForCorrectCount.toDouble(),
                                      interval: 1,
                                      stepSize: 1.0,
                                      values: SfRangeValues(wc.tempExtractionCorrectCountMin, wc.tempExtractionCorrectCountMax),
                                      onChanged: (SfRangeValues value) {
                                        wc.tempExtractionCorrectCountMin = value.start;
                                        wc.tempExtractionCorrectCountMax = value.end;
                                        r(() {});
                                      },
                                      showDividers: true,
                                    ),
                                  ),
                                  Text(wc.extractionCorrectCountMax.toString()),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  )
                : Container(),
            Padding(
              padding: EdgeInsets.fromLTRB(20, 0, 0, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text("是否启用必须展示选项："),
                      Spacer(),
                      Checkbox(
                        visualDensity: kMinVisualDensity,
                        value: widget.choiceFragmentTemplate.canDisorderly,
                        onChanged: (v) {
                          setState(() {
                            widget.choiceFragmentTemplate.canDisorderly = v!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(40, 0, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text("占比"),
                  Checkbox(
                    visualDensity: kMinVisualDensity,
                    value: widget.choiceFragmentTemplate.canDisorderly,
                    shape: const CircleBorder(),
                    onChanged: (v) {
                      setState(() {
                        widget.choiceFragmentTemplate.canDisorderly = v!;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Text("自动"),
                  Checkbox(
                    visualDensity: kMinVisualDensity,
                    value: widget.choiceFragmentTemplate.canDisorderly,
                    shape: const CircleBorder(),
                    onChanged: (v) {
                      setState(() {
                        widget.choiceFragmentTemplate.canDisorderly = v!;
                      });
                    },
                  ),
                  SizedBox(width: 10),
                  Text("强制"),
                  Checkbox(
                    visualDensity: kMinVisualDensity,
                    value: widget.choiceFragmentTemplate.canDisorderly,
                    shape: const CircleBorder(),
                    onChanged: (v) {
                      setState(() {
                        widget.choiceFragmentTemplate.canDisorderly = v!;
                      });
                    },
                  ),
                ],
              ),
            ),
            Divider(),
            ...widget.choiceFragmentTemplate.choices.map(
              (e) {
                return Container(
                  margin: const EdgeInsets.all(5),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.playlist_remove, color: Colors.red),
                        onPressed: () {
                          widget.choiceFragmentTemplate.removeItem(e);
                          setState(() {});
                        },
                      ),
                      Text(
                        widget.choiceFragmentTemplate.choicePrefixType.toTypeFrom(widget.choiceFragmentTemplate.choices.indexOf(e) + 1),
                        style: TextStyle(color: Colors.amber),
                      ),
                      widget.choiceFragmentTemplate.choicePrefixType == ChoicePrefixType.none ? Container() : const Text("  "),
                      Expanded(
                        child: SingleQuillEditableWidget(singleQuillController: e, isEditable: widget.isEditable),
                      ),
                      Checkbox(
                        value: widget.choiceFragmentTemplate.isCorrect(e),
                        onChanged: (v) {
                          widget.choiceFragmentTemplate.invertCorrect(e);
                          setState(() {});
                        },
                        shape: widget.choiceFragmentTemplate.choiceType == ChoiceType.simple ? const CircleBorder() : null,
                      ),
                    ],
                  ),
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.choiceFragmentTemplate.choices.isEmpty ? "请添加选项" : "右侧勾选正确选项", style: const TextStyle(color: Colors.grey)),
              ],
            ),
            Row(
              children: [
                const Spacer(),
                RawMaterialButton(
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  child: const Row(
                    children: [
                      Text("添加选项"),
                      SizedBox(width: 5),
                      Icon(Icons.add_circle_outline),
                    ],
                  ),
                  onPressed: () {
                    widget.choiceFragmentTemplate.addItem(SingleQuillController());
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
