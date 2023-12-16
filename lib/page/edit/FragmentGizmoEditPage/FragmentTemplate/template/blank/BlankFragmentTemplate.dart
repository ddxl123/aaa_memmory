import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/choice/ChoicePrefixType.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/editable_text.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/SingleQuillController.dart';

class BlankChoice {
  BlankChoice({
    required this.tag,
    required this.text,
  });

  final String tag;
  String text;

  Map<String, String> toJson() {
    return {tag: text};
  }

  factory BlankChoice.fromJson(Map<String, dynamic> json) {
    return BlankChoice(tag: json.keys.single, text: json.values.single as String);
  }
}

/// 单面模板
///
/// 答案在 [BlankData] 中。
class BlankFragmentTemplate extends FragmentTemplate {
  @override
  FragmentTemplateType get fragmentTemplateType => FragmentTemplateType.blank;

  final blank = SingleQuillController();

  final choices = <BlankChoice>[];

  ChoicePrefixType choicePrefixType = ChoicePrefixType.none;

  /// 是否乱序
  bool canDisorder = false;

  @override
  FragmentTemplate emptyInitInstance() => BlankFragmentTemplate();

  @override
  FragmentTemplate emptyTransferableInstance() => BlankFragmentTemplate();

  @override
  String getTitle() => blank.transferToTitle();

  @override
  List<SingleQuillController> listenSingleEditableQuill() => [blank];

  @override
  Map<String, dynamic> toJson() {
    final sp = super.toJson();
    return {
      "type": fragmentTemplateType.name,
      "blank": blank.getContentJsonString(),
      "choices": choices.map((e) => e.toJson()).toList(),
      "choice_prefix_type": choicePrefixType.displayName,
      "can_disorder": canDisorder,
      sp.keys.first: sp.values.first,
    };
  }

  @override
  void resetFromJson(Map<String, dynamic> json) {
    blank.resetContent(json["blank"]);
    choices
      ..clear()
      ..addAll((json["choices"] as List<dynamic>).map((e) => BlankChoice.fromJson(e)));
    choicePrefixType = ChoicePrefixType.values.singleWhere((element) => element.displayName == (json["choice_prefix_type"] as String));
    canDisorder = json["can_disorder"] as bool;
    super.resetFromJson(json);
  }

  @override
  (bool, String) isMustContentEmpty() {
    if (blank.isContentEmpty()) {
      return (true, "主内容不能为空！");
    }
    return (false, "...");
  }

  @override
  void dispose() {
    blank.dispose();
  }

  @override
  bool get initIsShowBottomButton => false;

  @override
  void addExtendChunkCallback(TextEditingController textEditingController) {
    addExtendChunk(
      chunkName: textEditingController.text,
      extendsChunkDisplay2Type: ExtendChunkDisplay2Type.only_end,
      extendChunkDisplayQAType: null,
    );
  }

  Future<void> addChoice() async {
    await showCustomDialog(
      builder: (ctx) {
        return TextField1DialogWidget(
          text: "当挖空内容是选择题时，可添加选项：",
          okText: "确定",
          cancelText: "取消",
          autoFocus: true,
          inputDecoration: const InputDecoration(hintText: "请输入选项内容..."),
          onOk: (c) {
            choices.add(BlankChoice(tag: Object().hashCode.toString(), text: c.text));
            SmartDialog.dismiss(status: SmartStatus.dialog);
          },
        );
      },
    );
  }

  Future<void> editChoice({required BlankChoice blankChoice}) async {
    await showCustomDialog(
      builder: (ctx) {
        return TextField1DialogWidget(
          textEditingController: blankChoice.text.isEmpty ? TextEditingController() : TextEditingController(text: blankChoice.text),
          okText: "确定",
          cancelText: "取消",
          autoFocus: true,
          inputDecoration: InputDecoration(hintText: blankChoice.text.isEmpty ? "请输入选项内容..." : null),
          isRemoveOkTextStyle: true,
          mainVerticalColumns: [
            Row(
              children: [
                Text("编辑选项："),
                Spacer(),
                TextButton(
                  child: Text("移除", style: TextStyle(color: Colors.red)),
                  onPressed: () {
                    choices.remove(blankChoice);
                    SmartDialog.dismiss(status: SmartStatus.dialog);
                  },
                ),
              ],
            )
          ],
          onOk: (c) {
            blankChoice.text = c.text;
            SmartDialog.dismiss(status: SmartStatus.dialog);
          },
        );
      },
    );
  }
}
