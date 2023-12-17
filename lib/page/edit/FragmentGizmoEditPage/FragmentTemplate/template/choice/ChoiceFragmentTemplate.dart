import 'package:flutter/foundation.dart';
import 'package:flutter/src/widgets/editable_text.dart';

import '../../base/FragmentTemplate.dart';
import '../../base/SingleQuillController.dart';
import 'ChoicePrefixType.dart';

enum ChoiceType {
  /// 单选，只有已选选项与答案相匹配的才是正确的，否则是错误的。
  simple,

  /// 多选-完全匹配，只有已选选项完全与答案相匹配的才是正确的，否则是错误的。
  multiple_perfect_match,
}

enum RequiredType {
  /// 无必须展示选项
  not_enabled("无必须展示选项"),

  /// 占比优先
  proportion_first("占比优先"),

  /// 必须优先
  required_first("必须优先");

  const RequiredType(this.displayText);

  final String displayText;
}

/// 选择题模板的数据类。
class ChoiceFragmentTemplate extends FragmentTemplate {
  ChoiceFragmentTemplate({required super.performType});

  final question = SingleQuillController();
  final choices = <SingleQuillController>[];

  /// 答案选项
  ///
  /// [choicesForCorrect.length] 始终等于 [choices.length]，正确选项为 true，错误选项为 false。
  final choicesForCorrect = <bool>[];

  /// 必须展示选项
  ///
  /// [choicesForRequired.length] 始终等于 [choices.length]，必须展示选项为 true，非必须展示选项为 false。
  final choicesForRequired = <bool>[];

  /// 选择类型。
  ChoiceType choiceType = ChoiceType.simple;

  /// 选项前缀类型。
  ChoicePrefixType choicePrefixType = ChoicePrefixType.uppercaseLetter;

  /// 选项是否以乱序的方式展示。
  bool canDisorderly = false;

  /// 随机抽取展示数量的最小值
  int extractionCountMin = 2;

  /// 随机抽取展示数量的最大值
  int extractionCountMax = 0;

  /// 正确选项数量占比
  ///
  /// 限制在 0.0-1.0 范围。
  double correctProportion = 0.5;

  /// 必须展示类型
  RequiredType requiredType = RequiredType.not_enabled;

  /// 展示时所选择的答案，不存储数据。
  final selectedChoices = <SingleQuillController>[];

  /// 展示时的选项，不存储数据。
  final displayChoices = <SingleQuillController>[];

  /// 选项是否足够启用乱序
  bool get isChoiceCountEnough {
    final result = choices.length > 1;
    // 当数量不足够时，自动关闭乱序。
    if (!result) {
      canDisorderly = false;
    }
    return result;
  }

  String get getExtractionCountText => extractionCountMin == extractionCountMax ? extractionCountMin.toString() : "$extractionCountMin-$extractionCountMax";

  bool get isFullChoice => extractionCountMin == extractionCountMax && extractionCountMin == choices.length;

  /// 已选选项是否与正确选项相匹配
  bool get isAnswerCorrect => setEquals(selectedChoices.toSet(), getCorrectChoices.toSet());

  /// 获取 所选择的选项 和 正确的选项 所对应的字符串
  (List<String>, List<String>) getSelectedAndCorrectChoicePrefixType() {
    final selecteds = <String>[];
    final corrects = <String>[];
    for (var dc in displayChoices) {
      if (selectedChoices.contains(dc)) {
        selecteds.add(choicePrefixType.toTypeFrom(displayChoices.indexOf(dc) + 1));
      }
      if (getCorrectChoices.contains(dc)) {
        corrects.add(choicePrefixType.toTypeFrom(displayChoices.indexOf(dc) + 1));
      }
    }
    return (selecteds, corrects);
  }

  /// 获取正确选项的 [SingleQuillController]，只回去正确的选项，非正确的选项不进行获取。
  List<SingleQuillController> get getCorrectChoices {
    final indexResult = <int>[];
    for (int i = 0; i < choicesForCorrect.length; i++) {
      if (choicesForCorrect[i]) {
        indexResult.add(i);
      }
    }
    return indexResult.map((e) => choices[e]).toList();
  }

  /// 获取必选选项的 [SingleQuillController]。
  List<SingleQuillController> get getRequiredChoices {
    final indexResult = <int>[];
    for (int i = 0; i < choicesForRequired.length; i++) {
      if (choicesForRequired[i]) {
        indexResult.add(i);
      }
    }
    return indexResult.map((e) => choices[e]).toList();
  }

  /// [singleQuillController] 是否为正确选项。
  bool isCorrect(SingleQuillController singleQuillController) {
    return choicesForCorrect.elementAt(choices.indexOf(singleQuillController));
  }

  /// [singleQuillController] 是否为必须展示选项。
  bool isRequired(SingleQuillController singleQuillController) {
    return choicesForRequired.elementAt(choices.indexOf(singleQuillController));
  }

  /// 将全部选项设置为未勾选。
  void cancelAllCorrect() {
    for (int i = 0; i < choicesForCorrect.length; i++) {
      choicesForCorrect[i] = false;
    }
  }

  /// 将全部必须展示选项设置为未勾选。
  void cancelAllRequired() {
    for (int i = 0; i < choicesForRequired.length; i++) {
      choicesForRequired[i] = false;
    }
  }

  /// 取消勾选对 [singleQuillController] 的选项。
  void _cancelCorrect(SingleQuillController singleQuillController) {
    choicesForCorrect[choices.indexOf(singleQuillController)] = false;
  }

  /// 取消勾选对 [singleQuillController] 的必须展示选项。
  void _cancelRequired(SingleQuillController singleQuillController) {
    choicesForRequired[choices.indexOf(singleQuillController)] = false;
  }

  /// 勾选对 [singleQuillController] 的选项。
  void _chooseCorrect(SingleQuillController singleQuillController) {
    if (choiceType == ChoiceType.simple) {
      cancelAllCorrect();
      choicesForCorrect[choices.indexOf(singleQuillController)] = true;
      return;
    } else if (choiceType == ChoiceType.multiple_perfect_match) {
      choicesForCorrect[choices.indexOf(singleQuillController)] = true;
    } else {
      throw "未知 $choiceType";
    }
  }

  /// 勾选对 [singleQuillController] 的必须展示选项。
  void _chooseRequired(SingleQuillController singleQuillController) {
    choicesForRequired[choices.indexOf(singleQuillController)] = true;
  }

  /// 对 [singleQuillController] 选项的反选。
  void invertCorrect(SingleQuillController singleQuillController) {
    if (isCorrect(singleQuillController)) {
      _cancelCorrect(singleQuillController);
    } else {
      _chooseCorrect(singleQuillController);
    }
  }

  /// 对 [singleQuillController] 必须展示选项的反选。
  void invertRequired(SingleQuillController singleQuillController) {
    if (isRequired(singleQuillController)) {
      _cancelRequired(singleQuillController);
    } else {
      _chooseRequired(singleQuillController);
    }
  }

  /// 移除 [singleQuillController] 选项。
  void removeItem(SingleQuillController singleQuillController) {
    singleQuillController.dispose();
    final index = choices.indexOf(singleQuillController);
    choices.removeAt(index);
    choicesForCorrect.removeAt(index);
    choicesForRequired.removeAt(index);

    if (extractionCountMin < extractionCountMax) {
      extractionCountMax--;
    } else if (extractionCountMin == extractionCountMax) {
      if (extractionCountMin != 2) {
        extractionCountMin--;
      }
      extractionCountMax--;
    }
  }

  /// 添加新选项。
  void addItem(SingleQuillController singleQuillController) {
    choices.add(singleQuillController);
    choicesForCorrect.add(false);
    choicesForRequired.add(false);

    if (extractionCountMax == choices.length - 1) {
      extractionCountMax++;
    }

    dynamicAddFocusListener(singleQuillController);
  }

  @override
  FragmentTemplateType get fragmentTemplateType => FragmentTemplateType.choice;

  @override
  void dispose() {
    question.dispose();
    for (var value in choices) {
      value.dispose();
    }
  }

  @override
  FragmentTemplate createEmptyInitInstance(PerformType performType) => ChoiceFragmentTemplate(performType: performType);

  @override
  FragmentTemplate createEmptyTransferableInstance(PerformType performType) => ChoiceFragmentTemplate(performType: performType);

  @override
  List<SingleQuillController> listenSingleEditableQuill() => [question, ...choices];

  @override
  String getTitle() => question.transferToTitle();

  @override
  (bool, String) isMustContentEmpty() {
    if (question.isContentEmpty()) {
      return (true, "问题不能为空！");
    }
    if (choices.isEmpty) {
      return (true, "必须至少有两个选项");
    }
    for (var c in choices) {
      if (c.isContentEmpty()) {
        return (true, "选项内容不能为空！");
      }
    }
    if (choicesForCorrect.isEmpty) {
      return (true, "请至少选择一个正确选项！");
    }
    return (false, "...");
  }

  @override
  void resetFromJson(Map<String, dynamic> json) {
    question.resetContent(json["question"]);

    final choicesList = json["choices"] as List<dynamic>;
    choices.clear();
    for (var c in choicesList) {
      choices.add(SingleQuillController()..resetContent(c as String));
    }

    choiceType = ChoiceType.values.firstWhere((element) => element.name == (json["choice_type"] as String));
    choicePrefixType = ChoicePrefixType.values.firstWhere((element) => element.name == (json["choice_prefix_type"] as String));

    canDisorderly = json["can_disorderly"] as bool;
    extractionCountMin = json["extraction_count_min"] as int;
    extractionCountMax = json["extraction_count_max"] as int;
    correctProportion = json["correct_proportion"] as double;
    requiredType = RequiredType.values.firstWhere((element) => element.name == (json["required_type"] as String));

    choicesForRequired.clear();
    choicesForRequired.addAll((json["choices_for_required"] as List<dynamic>).map((e) => e as bool));

    choicesForCorrect.clear();
    choicesForCorrect.addAll((json["choices_for_correct"] as List<dynamic>).map((e) => e as bool));

    super.resetFromJson(json);
  }

  @override
  Map<String, dynamic> toJson() {
    final sp = super.toJson();
    return {
      "type": fragmentTemplateType.name,
      "question": question.getContentJsonString(),
      "choices": choices.map((e) => e.getContentJsonString()).toList(),
      "choice_type": choiceType.name,
      "choice_prefix_type": choicePrefixType.name,
      "can_disorderly": canDisorderly,
      "extraction_count_min": extractionCountMin,
      "extraction_count_max": extractionCountMax,
      "correct_proportion": correctProportion,
      "required_type": requiredType.name,
      "choices_for_required": choicesForRequired,
      "choices_for_correct": choicesForCorrect,
      sp.keys.first: sp.values.first,
    };
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
