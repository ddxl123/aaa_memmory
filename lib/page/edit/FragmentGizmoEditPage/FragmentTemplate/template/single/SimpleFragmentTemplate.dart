import 'package:flutter/src/widgets/editable_text.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/SingleQuillController.dart';

/// 单面模板
class SimpleFragmentTemplate extends FragmentTemplate {
  SimpleFragmentTemplate({required super.performType});

  @override
  FragmentTemplateType get fragmentTemplateType => FragmentTemplateType.simple;

  final simple = SingleQuillController();

  @override
  FragmentTemplate createEmptyInitInstance(PerformType performType) => SimpleFragmentTemplate(performType: performType);

  @override
  FragmentTemplate createEmptyTransferableInstance(PerformType performType) => SimpleFragmentTemplate(performType: performType);

  @override
  String getTitle() => simple.transferToTitle();

  @override
  List<SingleQuillController> listenSingleEditableQuill() => [simple];

  @override
  Map<String, dynamic> toJson() {
    final sp = super.toJson();
    return {
      "type": fragmentTemplateType.name,
      "simple": simple.getContentJsonStringOrNull(),
      sp.keys.first: sp.values.first,
    };
  }

  @override
  void resetFromJson(Map<String, dynamic> json) {
    simple.resetContent(json["simple"]);
    super.resetFromJson(json);
  }

  @override
  (bool, String) isMustContentEmpty() {
    if (simple.isContentEmpty()) {
      return (true, "主内容不能为空！");
    }
    return (false, "...");
  }

  @override
  void dispose() {
    simple.dispose();
  }

  @override
  bool get initIsShowBottomButton => true;

  @override
  void addExtendChunkCallback(TextEditingController textEditingController) {
    addExtendChunk(
      chunkName: textEditingController.text,
      extendsChunkDisplay2Type: null,
      extendChunkDisplayQAType: null,
    );
  }
}
