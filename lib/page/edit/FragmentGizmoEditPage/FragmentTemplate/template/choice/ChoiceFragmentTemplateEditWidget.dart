import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            ...widget.choiceFragmentTemplate.choices.map(
              (e) {
                return Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.playlist_remove, color: Colors.red),
                      onPressed: () {
                        widget.choiceFragmentTemplate.removeItem(e);
                        setState(() {});
                      },
                      style: ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                    ),
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                        decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: const BorderRadius.all(Radius.circular(5))),
                        child: Row(
                          children: [
                            SizedBox(width: 10),
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
                      ),
                    ),
                    widget.choiceFragmentTemplate.requiredType != RequiredType.not_enabled
                        ? Checkbox(
                            value: widget.choiceFragmentTemplate.isRequired(e),
                            onChanged: (v) {
                              widget.choiceFragmentTemplate.invertRequired(e);
                              setState(() {});
                            },
                            shape: RoundedRectangleBorder(),
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          )
                        : Container(),
                  ],
                );
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(widget.choiceFragmentTemplate.choices.isEmpty ? "请添加选项" : "请在选项右侧框内勾选正确选项", style: const TextStyle(color: Colors.grey)),
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
            Divider(),
            Padding(
              padding: EdgeInsets.all(5),
              child: Row(
                children: [
                  Text("是否可乱序："),
                  Spacer(),
                  widget.choiceFragmentTemplate.isChoiceCountEnough
                      ? Checkbox(
                          visualDensity: kMinVisualDensity,
                          value: widget.choiceFragmentTemplate.canDisorderly,
                          onChanged: (v) {
                            setState(() {
                              widget.choiceFragmentTemplate.canDisorderly = v!;
                            });
                          },
                        )
                      : Text("选项不足", style: TextStyle(color: Colors.grey)),
                ],
              ),
            ),
            widget.choiceFragmentTemplate.canDisorderly && widget.choiceFragmentTemplate.isChoiceCountEnough
                ? Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.fromLTRB(20, 0, 10, 0),
                        child: StatefulBuilder(
                          builder: (ctx, r) {
                            final wc = widget.choiceFragmentTemplate;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("仅抽取 ${wc.getExtractionCountText} 个选项进行展示："),
                                wc.choices.length == 2
                                    ? Container()
                                    : SizedBox(
                                        height: 50,
                                        child: Row(
                                          children: [
                                            Text("2"),
                                            Expanded(
                                              child: SfRangeSlider(
                                                min: 2.0,
                                                max: wc.choices.length.toDouble(),
                                                interval: 1,
                                                stepSize: 1.0,
                                                values: SfRangeValues(wc.extractionCountMin.toDouble(), wc.extractionCountMax.toDouble()),
                                                onChanged: (SfRangeValues value) {
                                                  wc.extractionCountMin = (value.start as double).toInt();
                                                  wc.extractionCountMax = (value.end as double).toInt();
                                                  setState(() {});
                                                },
                                                showDividers: true,
                                              ),
                                            ),
                                            Text(wc.choices.length.toString()),
                                          ],
                                        ),
                                      ),
                                SizedBox(height: 10),
                                GestureDetector(
                                  child: Row(
                                    children: [
                                      Text("其中正确选项数量占比："),
                                      SizedBox(width: 10),
                                      widget.choiceFragmentTemplate.choiceType == ChoiceType.simple
                                          ? Text("单选有且仅有一个", style: TextStyle(color: Colors.grey))
                                          : (widget.choiceFragmentTemplate.isFullChoice
                                              ? Text("已满选", style: TextStyle(color: Colors.grey))
                                              : Text(
                                                  widget.choiceFragmentTemplate.correctProportion.toString(),
                                                  style: TextStyle(decoration: TextDecoration.underline),
                                                )),
                                    ],
                                  ),
                                  onTap: () async {
                                    await showCustomDialog(
                                      builder: (ctx) {
                                        return TextField1DialogWidget(
                                          text: "请输入 0~1 范围的小数：",
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.allow(RegExp(r'^0(\.\d{0,3})?|1(\.0{0,3})?')),
                                          ],
                                          cancelText: "取消",
                                          okText: "确定",
                                          onOk: (c) {
                                            widget.choiceFragmentTemplate.correctProportion = double.tryParse(c.text) ?? 1.0;
                                            setState(() {});
                                            SmartDialog.dismiss(status: SmartStatus.dialog);
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 10),
                      widget.choiceFragmentTemplate.isFullChoice
                          ? Container()
                          : Padding(
                              padding: EdgeInsets.fromLTRB(20, 0, 10, 0),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: CustomDropdownBodyButton(
                                      primaryButton: Row(
                                        children: [
                                          Text("必须展示方式："),
                                          Spacer(),
                                          Text(widget.choiceFragmentTemplate.requiredType.displayText),
                                          Icon(Icons.arrow_right_outlined, color: Colors.grey),
                                        ],
                                      ),
                                      initValue: widget.choiceFragmentTemplate.requiredType,
                                      items: RequiredType.values.map(
                                        (e) {
                                          return CustomItem(value: e, text: e.displayText);
                                        },
                                      ).toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          widget.choiceFragmentTemplate.requiredType = v!;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                      widget.choiceFragmentTemplate.isFullChoice ? Container() : SizedBox(height: 10),
                      widget.choiceFragmentTemplate.requiredType != RequiredType.not_enabled
                          ? Row(
                              children: [
                                Spacer(),
                                Text(
                                  "请在选项右侧框外勾选必须展示选项",
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ],
                            )
                          : Container(),
                    ],
                  )
                : Container(),
          ],
        ),
      ],
    );
  }
}
