import 'package:flutter/src/widgets/editable_text.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/SingleQuillController.dart';

/// 单面模板
class BlankFragmentTemplate extends FragmentTemplate {
  @override
  FragmentTemplateType get fragmentTemplateType => FragmentTemplateType.blank;

  final blank = SingleQuillController();

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
      sp.keys.first: sp.values.first,
    };
  }

  @override
  void resetFromJson(Map<String, dynamic> json) {
    blank.resetContent(json["blank"]);
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
}
