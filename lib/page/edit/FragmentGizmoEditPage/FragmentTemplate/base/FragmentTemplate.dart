import 'dart:convert';

import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/true_false/TFFragmentTemplate.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import '../../../../stage/InAppStageAbController.dart';
import '../template/choice/ChoiceFragmentTemplate.dart';
import '../template/question_answer/QAFragmentTemplate.dart';
import '../template/single/SimpleFragmentTemplate.dart';
import 'SingleQuillController.dart';

enum FragmentTemplateType {
  /// 单面
  simple,

  /// 问答
  question_answer,

  /// 选择
  choice,

  /// 判断
  true_false,

  /// 填空
  blank,
}

enum PerformType {
  /// 编辑状态
  edit,

  /// 预览状态
  preview,
}

enum ExtendChunkDisplay2Type {
  /// 无论有没有显示答案，都显示
  always(displayName: "总是显示"),

  /// 仅在未显示答案时显示
  only_start(displayName: "仅在显示问题时显示"),

  /// 仅在显示答案是显示
  only_end(displayName: "仅在显示答案时显示");

  const ExtendChunkDisplay2Type({required this.displayName});

  final String displayName;
}

enum ExtendChunkDisplayQAType {
  /// 无论有没有显示答案，都显示
  always(displayName: "总是显示"),

  /// 仅在未显示答案时显示
  only_start(displayName: "仅在显示问题(问答未交换)时显示"),

  /// 仅在显示答案是显示
  only_end(displayName: "仅在显示答案(问答未交换)时显示"),

  /// 仅在未显示答案时显示
  only_start_exchange(displayName: "仅在显示问题(问答已交换)时显示"),

  /// 仅在显示答案是显示
  only_end_exchange(displayName: "仅在显示答案(问答已交换)时显示");

  const ExtendChunkDisplayQAType({required this.displayName});

  final String displayName;
}

class ExtendChunk {
  ExtendChunk({
    required this.singleQuillController,
    required this.extendChunkDisplay2Type,
    required this.extendChunkDisplayQAType,
    required this.chunkName,
  });

  final SingleQuillController singleQuillController;

  ExtendChunkDisplay2Type? extendChunkDisplay2Type;

  ExtendChunkDisplayQAType? extendChunkDisplayQAType;

  String chunkName;

  (Enum, List<dynamic>)? get target {
    if (extendChunkDisplay2Type != null) {
      return (extendChunkDisplay2Type!, ExtendChunkDisplay2Type.values);
    }
    if (extendChunkDisplayQAType != null) {
      return (extendChunkDisplayQAType!, ExtendChunkDisplayQAType.values);
    }
    return null;
  }

  void resetTarget(dynamic t) {
    if (extendChunkDisplay2Type != null) {
      extendChunkDisplay2Type = t;
      return;
    }
    if (extendChunkDisplayQAType != null) {
      extendChunkDisplayQAType = t;
      return;
    }
  }

  void dispose() {
    singleQuillController.dispose();
  }

  Map<String, dynamic> toJson() {
    return {
      "chunk_name": chunkName,
      "extend_chunk_display_2_type": extendChunkDisplay2Type?.name,
      "extend_chunk_display_qa_type": extendChunkDisplayQAType?.name,
      "content": singleQuillController.getContentJsonStringOrNull(),
    };
  }

  factory ExtendChunk.fromJson(Map<String, dynamic> json) {
    return ExtendChunk(
      singleQuillController: SingleQuillController()..resetContent(json["content"]),
      extendChunkDisplay2Type: ExtendChunkDisplay2Type.values.singleWhereOrNull((element) => element.name == (json["extend_chunk_display_2_type"] as String?)),
      extendChunkDisplayQAType: ExtendChunkDisplayQAType.values.singleWhereOrNull((element) => element.name == (json["extend_chunk_display_qa_type"] as String?)),
      chunkName: json["chunk_name"] as String,
    );
  }
}

/// 碎片模板的数据基类。
abstract class FragmentTemplate {
  FragmentTemplate({
    required this.performType,
  }) {
    listenSingleEditableQuill().forEach(
      (e) {
        e.focusNode.addListener(
          () {
            if (e.focusNode.hasFocus) {
              currentFocusSingleEditableQuill.value = e;
            }
          },
        );
      },
    );
  }

  final PerformType performType;

  FragmentTemplateType get fragmentTemplateType;

  /// 非记忆展示时，这个控制器可为 null。
  InAppStageAbController? inAppStageAbController;

  /// 扩展块。
  final _extendChunks = <ExtendChunk>[];

  List<ExtendChunk> get extendChunks => _extendChunks;

  /// 在记忆展示时，进入碎片时是否需要展示底部的下次记忆按钮。
  bool get initIsShowBottomButton;

  /// 哪个 [SingleQuillController] 获取了焦点。
  ///
  /// 若为 null, 则无焦点。
  final currentFocusSingleEditableQuill = ValueNotifier<SingleQuillController?>(null);

  /// 内容数据。
  ///
  /// 每次操作碎片记忆信息时会使用，而不是针对当前碎片本身的属性。不会保存在 [toJson] 或者 [resetFromJson] 中。
  final memoryInfoData = <String>[];

  /// 动态添加对焦点的监听。
  void dynamicAddFocusListener(SingleQuillController singleEditableQuill) {
    singleEditableQuill.focusNode.addListener(
      () {
        if (singleEditableQuill.focusNode.hasFocus) {
          currentFocusSingleEditableQuill.value = singleEditableQuill;
        }
      },
    );
  }

  /// 添加扩展块。
  void addExtendChunk({
    required String chunkName,
    required ExtendChunkDisplay2Type? extendsChunkDisplay2Type,
    required ExtendChunkDisplayQAType? extendChunkDisplayQAType,
  }) {
    final s = SingleQuillController();
    _extendChunks.add(
      ExtendChunk(
        singleQuillController: s,
        extendChunkDisplay2Type: extendsChunkDisplay2Type,
        extendChunkDisplayQAType: extendChunkDisplayQAType,
        chunkName: chunkName,
      ),
    );
    dynamicAddFocusListener(s);
  }

  /// 调用 [addExtendChunk]。
  void addExtendChunkCallback(TextEditingController textEditingController);

  /// 移除扩展块。
  void removeExtendChunk(ExtendChunk extendChunk) {
    extendChunk.dispose();
    _extendChunks.remove(extendChunk);
  }

  String getTitle();

  /// 创建当前对象的崭新的空实例。
  FragmentTemplate createEmptyInitInstance(PerformType performType);

  /// 创建当前对象的可传递空实例。
  ///
  /// 在创建碎片时，下一次创建要保留的配置数据。
  FragmentTemplate createEmptyTransferableInstance(PerformType performType);

  /// 子类必须使用，不然存储时会漏掉。
  @mustCallSuper
  Map<String, dynamic> toJson() {
    return {"extend_chunks": _extendChunks.map((e) => e.toJson()).toList()};
  }

  String toFragmentContent() => jsonEncode(toJson());

  void resetFromFragmentContent(String fragmentContent) => resetFromJson(jsonDecode(fragmentContent));

  /// 重新设置当前对象的数据。
  ///
  /// 子类必须调用，不然存储时会漏掉。
  @mustCallSuper
  void resetFromJson(Map<String, dynamic> json) {
    for (var element in _extendChunks) {
      element.dispose();
    }
    _extendChunks.clear();
    final list = json["extend_chunks"] as List;
    for (var l in list) {
      _extendChunks.add(ExtendChunk.fromJson(l));
    }
  }

  /// 返回值第一个参数：必须不为空的内容是否为空
  /// 返回值第二个参数：为空的信息
  (bool, String) isMustContentEmpty();

  void dispose();

  /// 比较两者的 [toJson] 是否完全相同。
  static bool equalFrom(FragmentTemplate a, FragmentTemplate b) => const DeepCollectionEquality().equals(a.toJson(), b.toJson());

  /// 获取子类所配置的全部 [SingleQuillController]，以便对焦点进行切换操作。
  ///
  /// [extendChunks] 由 [addExtendChunk] 进行添加操作。
  List<SingleQuillController> listenSingleEditableQuill();

  /// 将 [Fragment.content] 转换成 [FragmentTemplate]。
  static FragmentTemplate newInstanceFromFragmentContent({required String fragmentContent, required PerformType performType}) {
    final Map<String, dynamic> contentJson = jsonDecode(fragmentContent);
    // 出现 type 异常有可能是 toJson 时没有写 type 字段。
    final type = FragmentTemplateType.values.firstWhere((element) => element.name == (contentJson["type"] as String));
    return templateSwitch(
      type,
      questionAnswer: () => QAFragmentTemplate(performType: performType)..resetFromJson(contentJson),
      choice: () => ChoiceFragmentTemplate(performType: performType)..resetFromJson(contentJson),
      simple: () => SimpleFragmentTemplate(performType: performType)..resetFromJson(contentJson),
      trueFalse: () => TFFragmentTemplate(performType: performType)..resetFromJson(contentJson),
      blank: () => BlankFragmentTemplate(performType: performType)..resetFromJson(contentJson),
    );
  }

  static R templateSwitch<R>(
    FragmentTemplateType type, {
    required R Function() simple,
    required R Function() questionAnswer,
    required R Function() choice,
    required R Function() trueFalse,
    required R Function() blank,
  }) {
    switch (type) {
      case FragmentTemplateType.question_answer:
        return questionAnswer();
      case FragmentTemplateType.choice:
        return choice();
      case FragmentTemplateType.simple:
        return simple();
      case FragmentTemplateType.true_false:
        return trueFalse();
      case FragmentTemplateType.blank:
        return blank();
      default:
        throw "未处理类型：$type";
    }
  }

  static Future<R> templateSwitchFuture<R>(
    FragmentTemplateType type, {
    required Future<R> Function() simple,
    required Future<R> Function() questionAnswer,
    required Future<R> Function() choice,
    required Future<R> Function() trueFalse,
    required Future<R> Function() blank,
  }) async {
    switch (type) {
      case FragmentTemplateType.question_answer:
        return await questionAnswer();
      case FragmentTemplateType.choice:
        return await choice();
      case FragmentTemplateType.simple:
        return await simple();
      case FragmentTemplateType.true_false:
        return await trueFalse();
      case FragmentTemplateType.blank:
        return await blank();
      default:
        throw "未处理类型：$type";
    }
  }
}
