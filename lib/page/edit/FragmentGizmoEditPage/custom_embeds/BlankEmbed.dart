import 'dart:math';

import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as q;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';

import '../FragmentTemplate/template/choice/ChoicePrefixType.dart';

class BlankHideAttribute extends q.Attribute {
  const BlankHideAttribute(v) : super(BlankHideAttribute.blank_hide, q.AttributeScope.inline, v);

  static const String blank_hide = "blank_hide";

  static TextStyle get textStyle => TextStyle(
        background: Paint()
          ..strokeWidth = 5.0 // 画笔宽度
          ..style = PaintingStyle.fill // 画笔样式
          ..color = Colors.blue
          ..strokeCap = StrokeCap.round
          // ..strokeJoin = StrokeJoin.round
          ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 2),
      );
}

class TextTransparentAttribute extends q.Attribute {
  const TextTransparentAttribute(v) : super(TextTransparentAttribute.textTransparent, q.AttributeScope.inline, v);
  static const String textTransparent = "text_transparent";

  static TextStyle get textStyle => const TextStyle(color: Colors.transparent);
}

class BlankHideToolBar extends StatefulWidget {
  const BlankHideToolBar(this.quillController, {super.key});

  final q.QuillController quillController;

  @override
  State<BlankHideToolBar> createState() => _BlankHideToolBarState();
}

class _BlankHideToolBarState extends State<BlankHideToolBar> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: const Text("挖空-隐藏"),
      onPressed: () {
        final qc = widget.quillController;
        if (qc.getSelectionStyle().attributes.containsKey(BlankHideAttribute.blank_hide)) {
          // 设为 null 表示去除 BlankAttribute 属性。
          qc.formatSelection(const BlankHideAttribute(null));
        } else {
          qc.formatSelection(const BlankHideAttribute(true));
        }

        // TODO: 加粗的同时挖空，在输入字符。会出现这个错误：https://github.com/singerdmx/flutter-quill/issues/1227
      },
    );
  }
}

/// ====================================================

enum BlankType {
  /// 隐藏或显示
  hide("隐藏"),

  /// 输入
  input("输入"),

  /// 一空一选
  choice_one("一空一选"),

  /// 一空多选
  choice_many("一空多选");

  const BlankType(this.displayName);

  final String displayName;
}

class BlankData {
  BlankData({
    required this.blankType,
    required this.answer,
  });

  BlankType blankType;

  /// 如果是挖空或填空，则为原来的文本。
  ///
  /// 如果是选择，则为 tag 字符。
  String answer;

  Map<String, dynamic> toJson() {
    return {
      "blank_type": blankType.name,
      "answer": answer,
    };
  }

  factory BlankData.fromJson(Map<String, dynamic> json) {
    return BlankData(
      blankType: BlankType.values.singleWhere((element) => element.name == (json["blank_type"] as String)),
      answer: json["answer"] as String,
    );
  }

  bool get hasContent => answer.isEmpty;

  /// 当 [blankType] 为 选择类型时，将 [answer] 解析成 ["tag1","tag2"]，以便能找到对应的 [BlankChoice]。
  List<String> _parseAnswerForChoice() {
    final result = answer.split(",");
    return result.length == 1 && result.single.isEmpty ? [] : result;
  }

  /// 检查 [answer] 内是否存在 [targetTag]
  bool isExistAnswerForChoice({required String targetTag}) {
    return _parseAnswerForChoice().contains(targetTag);
  }

  void removeAnswerForChoice({required String targetTag}) {
    final tags = _parseAnswerForChoice();
    tags.remove(targetTag);
    answer = tags.join(",");
  }

  void addAnswerForChoice({required String targetTag}) {
    List<String> tags = _parseAnswerForChoice();
    tags.add(targetTag);
    answer = tags.join(",");
  }
}

class BlankBlockEmbed extends q.Embeddable {
  BlankBlockEmbed({required BlankData blankData}) : super(BlankBlockEmbed.blankBlock, blankData.toJson());

  static const String blankBlock = 'blank_block';
}

class BlankEmbedBuilder extends q.EmbedBuilder {
  BlankEmbedBuilder({required this.blankFragmentTemplate});

  final BlankFragmentTemplate blankFragmentTemplate;

  @override
  String get key => BlankBlockEmbed.blankBlock;

  @override
  Widget build(BuildContext context, q.QuillController controller, q.Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    final oldBlankData = BlankData.fromJson(node.value.data);
    late final BoxBorder? boxBorder;
    if (oldBlankData.blankType == BlankType.hide) {
      boxBorder = null;
    } else if (oldBlankData.blankType == BlankType.input) {
      boxBorder = const BorderDirectional(bottom: BorderSide(color: Colors.lightGreen, width: 2));
    } else if (oldBlankData.blankType == BlankType.choice_one || oldBlankData.blankType == BlankType.choice_many) {
      boxBorder = const BorderDirectional(
        start: BorderSide(color: Colors.lightGreen, width: 2),
        end: BorderSide(color: Colors.lightGreen, width: 2),
      );
    } else {
      boxBorder = null;
    }

    return Listener(
      child: IntrinsicWidth(
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 4),
          margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
          constraints: BoxConstraints(minWidth: kMinInteractiveDimension),
          decoration: BoxDecoration(
            color: Color.fromRGBO(250, 192, 0, 0.4),
            borderRadius: BorderRadius.all(Radius.circular(5)),
            border: boxBorder,
          ),
          child: oldBlankData.hasContent ? const Text("?", style: TextStyle(color: Colors.grey)) : Text(oldBlankData.answer),
        ),
      ),
      onPointerUp: (_) {
        showCustomDialog(
          builder: (ctx) => BlackDialog(
            quillController: controller,
            blankFragmentTemplate: blankFragmentTemplate,
            oldBlankData: oldBlankData,
            node: node,
          ),
        );
      },
    );
  }
}

class BlankToolBar extends StatefulWidget {
  const BlankToolBar({required this.blankFragmentTemplate, super.key});

  final BlankFragmentTemplate blankFragmentTemplate;

  @override
  State<BlankToolBar> createState() => _BlankToolBarState();
}

class _BlankToolBarState extends State<BlankToolBar> {
  late final q.QuillController quillController;

  @override
  void initState() {
    super.initState();
    quillController = widget.blankFragmentTemplate.currentFocusSingleEditableQuill.value!.quillController;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text("[...]"),
      onPressed: () {
        final index = quillController.selection.baseOffset;
        final length = quillController.selection.extentOffset - index;
        quillController.replaceText(
          index,
          length,
          BlankBlockEmbed(
            blankData: BlankData(
              blankType: BlankType.hide,
              answer: quillController.document.toPlainText().substring(index, index + length),
            ),
          ),
          null,
        );

        quillController.moveCursorToPosition(index + length + 1);
      },
    );
  }
}

class BlackDialog extends StatefulWidget {
  const BlackDialog({
    super.key,
    required this.quillController,
    required this.blankFragmentTemplate,
    required this.oldBlankData,
    required this.node,
  });

  final q.QuillController quillController;
  final BlankFragmentTemplate blankFragmentTemplate;
  final BlankData oldBlankData;
  final q.Embed node;

  @override
  State<BlackDialog> createState() => _BlackDialogState();
}

class _BlackDialogState extends State<BlackDialog> {
  late final BlankFragmentTemplate blankFragmentTemplate;
  late BlankData newBlankData;

  @override
  void initState() {
    super.initState();
    blankFragmentTemplate = widget.blankFragmentTemplate;
    newBlankData = BlankData(blankType: widget.oldBlankData.blankType, answer: widget.oldBlankData.answer);
  }

  String explain() {
    if (newBlankData.blankType == BlankType.hide) {
      return "隐藏或显示答案";
    }
    if (newBlankData.blankType == BlankType.input) {
      return "输入答案";
    }
    if (newBlankData.blankType == BlankType.choice_one) {
      return "选择一个答案";
    }
    if (newBlankData.blankType == BlankType.choice_many) {
      return "选择一个或多个答案";
    }
    throw "未处理 ${newBlankData.blankType}";
  }

  @override
  Widget build(BuildContext context) {
    return TextField1DialogWidget(
      okText: "确定",
      cancelText: '取消',
      mainVerticalColumns: [
        Row(
          children: [
            Text("挖空类型："),
            Spacer(),
            CustomDropdownBodyButton(
              initValue: newBlankData.blankType,
              items: BlankType.values.map(
                (e) {
                  return CustomItem(value: e, text: e.displayName);
                },
              ).toList(),
              onChanged: (v) {
                newBlankData.blankType = v!;
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(children: [Expanded(child: Text("说明：${explain()}", style: const TextStyle(color: Colors.grey)))]),
        const SizedBox(height: 10),
        ...blankFragmentTemplate.choices.isEmpty
            ? [
                const Text("未添加选项", style: TextStyle(color: Colors.red)),
              ]
            : [
                if (newBlankData.blankType == BlankType.choice_one || newBlankData.blankType == BlankType.choice_many)
                  for (int i = 0; i < blankFragmentTemplate.choices.length; i++)
                    TextButton(
                      key: ValueKey(i),
                      style: ButtonStyle(visualDensity: kMinVisualDensity),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            blankFragmentTemplate.choicePrefixType.toTypeFrom(i + 1),
                            style: const TextStyle(color: Colors.amber),
                          ),
                          blankFragmentTemplate.choicePrefixType == ChoicePrefixType.none ? Container() : const Text("  "),
                          Expanded(child: Text(blankFragmentTemplate.choices[i].text)),
                          Checkbox(
                            value: newBlankData.isExistAnswerForChoice(targetTag: blankFragmentTemplate.choices[i].tag),
                            onChanged: null,
                            visualDensity: kMinVisualDensity,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        final targetTag = blankFragmentTemplate.choices[i].tag;
                        if (newBlankData.isExistAnswerForChoice(targetTag: targetTag)) {
                          newBlankData.removeAnswerForChoice(targetTag: targetTag);
                        } else {
                          newBlankData.addAnswerForChoice(targetTag: targetTag);
                        }
                        print(newBlankData.toJson());
                        setState(() {});
                      },
                    ),
              ],
      ],
      isHideTextField: newBlankData.blankType == BlankType.choice_one || newBlankData.blankType == BlankType.choice_many ? true : false,
      textEditingController: TextEditingController(text: newBlankData.answer),
      inputDecoration: const InputDecoration(hintText: "请输入挖空内容..."),
      onOk: (c) {
        if (newBlankData.blankType == BlankType.hide || newBlankData.blankType == BlankType.input) {
          newBlankData.answer = c.text;
        }
        confirmAndPop();
      },
    );
  }

  void confirmAndPop() {
    widget.quillController.replaceText(
      widget.node.offset,
      widget.node.length,
      BlankBlockEmbed(blankData: newBlankData),
      null,
    );
    SmartDialog.dismiss(status: SmartStatus.dialog);
  }
}
