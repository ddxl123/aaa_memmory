import 'package:flutter/src/widgets/editable_text.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/SingleQuillController.dart';

/// 单面模板
class TFFragmentTemplate extends FragmentTemplate {
  TFFragmentTemplate({required super.performType});

  @override
  FragmentTemplateType get fragmentTemplateType => FragmentTemplateType.true_false;

  final trueFalse = SingleQuillController();

  /// true - 正确
  /// false - 错误
  /// null - 未选择
  bool? answer;

  /// 展示时需要。
  ///
  /// true - 正确
  /// false - 错误
  /// null - 未选择
  bool? answerTemp;

  @override
  FragmentTemplate createEmptyInitInstance(PerformType performType) => TFFragmentTemplate(performType: performType);

  @override
  FragmentTemplate createEmptyTransferableInstance(PerformType performType) => TFFragmentTemplate(performType: performType);

  @override
  String getTitle() => trueFalse.transferToTitle();

  @override
  List<SingleQuillController> listenSingleEditableQuill() => [trueFalse];

  @override
  Map<String, dynamic> toJson() {
    final sp = super.toJson();
    return {
      "type": fragmentTemplateType.name,
      "true_false": trueFalse.getContentJsonStringOrNull(),
      "answer": answer,
      sp.keys.first: sp.values.first,
    };
  }

  @override
  void resetFromJson(Map<String, dynamic> json) {
    trueFalse.resetContent(json["true_false"]);
    answer = json["answer"] as bool;
    super.resetFromJson(json);
  }

  @override
  (bool, String) isMustContentEmpty() {
    if (trueFalse.isContentEmpty()) {
      return (true, "问题不能为空！");
    }
    if (answer == null) {
      return (true, "请选择一个答案！");
    }
    return (false, "...");
  }

  @override
  void dispose() {
    trueFalse.dispose();
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
}
