import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:tools/tools.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../algorithm_parser/AlgorithmException.dart';
import '../../../algorithm_parser/parser.dart';
import 'MemoryAlgorithmGizmoEditPageAbController.dart';

class AlgorithmEditPageAbController extends AbController {
  AlgorithmEditPageAbController({required this.name});

  final String name;
  final memoryModelGizmoEditPageAbController = Aber.findLast<MemoryAlgorithmGizmoEditPageAbController>();

  final freeBoxController = FreeBoxController();
  final currentAlgorithmWrapper = Ab<AlgorithmWrapper>.late();

  /// 是否是文本编辑模式，否则是常规编辑模式
  final isCurrentRaw = false.ab;

  final rawTextEditingController = TextEditingController();

  FreeBoxCamera rawCamera = FreeBoxCamera(expectPosition: Offset(10, 10), expectScale: 1);
  FreeBoxCamera viewCamera = FreeBoxCamera(expectPosition: Offset(10, 10), expectScale: 1);

  @override
  Future<bool> backListener(bool hasRoute) async {
    if (hasRoute) {
      return false;
    }

    final mm = memoryModelGizmoEditPageAbController.memoryAlgorithmAb;
    final currentOrNull = currentAlgorithmWrapper().toJsonStringOrNull();
    final isModified = ClassificationState.filter(
      stateName: name,
      familiarity: () => currentOrNull != mm().familiarity_algorithm,
      buttonData: () => currentOrNull != mm().button_algorithm,
      nextShowTime: () => currentOrNull != mm().next_time_algorithm,
      completeCondition: () => currentOrNull != mm().completed_algorithm,
      suggestCountForNewAndReviewState: () => currentOrNull != mm().suggest_count_for_new_and_review_algorithm,
    );
    if (isModified) {
      apply();
      memoryModelGizmoEditPageAbController.memoryAlgorithmAb.refreshForce();
      SmartDialog.showToast("已修改，请注意保存！");
    }
    return false;
  }

  @override
  void onInit() {
    super.onInit();
    initCurrentAlgorithmWrapper();
  }

  void initCurrentAlgorithmWrapper() {
    final ea = AlgorithmWrapper.emptyAlgorithmWrapper.toJsonString();
    final mm = memoryModelGizmoEditPageAbController.memoryAlgorithmAb;
    currentAlgorithmWrapper.lateAssign(
      AlgorithmWrapper.fromJsonString(
        ClassificationState.filter(
          stateName: name,
          buttonData: () => mm().button_algorithm ?? ea,
          familiarity: () => mm().familiarity_algorithm ?? ea,
          nextShowTime: () => mm().next_time_algorithm ?? ea,
          completeCondition: () => mm().completed_algorithm ?? ea,
          suggestCountForNewAndReviewState: () => mm().suggest_count_for_new_and_review_algorithm ?? ea,
        ),
      ),
    );
  }

  void apply() {
    rawToView();
    final mm = memoryModelGizmoEditPageAbController.memoryAlgorithmAb;
    ClassificationState.filter(
      stateName: name,
      buttonData: () => mm()..button_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      familiarity: () => mm()..familiarity_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      nextShowTime: () => mm()..next_time_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      completeCondition: () => mm()..completed_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      suggestCountForNewAndReviewState: () => mm()..suggest_count_for_new_and_review_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
    );
  }

  Future<void> analysis() async {
    changeRawOrView(false);
    rawToView();
    currentAlgorithmWrapper().cancelAllException();

    await ClassificationState.filterFuture(
      stateName: name,
      buttonData: () async => await AlgorithmParser.parse(
        stateFunc: () => ButtonDataState(
          algorithmWrapper: currentAlgorithmWrapper(),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        onSuccess: (ButtonDataState state) async {
          SmartDialog.showToast("语法分析正确");
        },
        onError: (AlgorithmException ec) async {
          SmartDialog.showToast("语法分析异常：${ec.error}");
        },
      ),
      familiarity: () async => await AlgorithmParser.parse(
        stateFunc: () => FamiliarityState(
          algorithmWrapper: currentAlgorithmWrapper(),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        onSuccess: (FamiliarityState state) async {
          SmartDialog.showToast("语法分析正确");
        },
        onError: (AlgorithmException ec) async {
          SmartDialog.showToast("语法分析异常：${ec.error}");
        },
      ),
      nextShowTime: () async => await AlgorithmParser.parse(
        stateFunc: () => NextShowTimeState(
          algorithmWrapper: currentAlgorithmWrapper(),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        onSuccess: (NextShowTimeState state) async {
          SmartDialog.showToast("语法分析正确");
        },
        onError: (AlgorithmException ec) async {
          SmartDialog.showToast("语法分析异常：${ec.error}");
        },
      ),
      completeCondition: () async => await AlgorithmParser.parse(
        stateFunc: () => CompleteConditionState(
          algorithmWrapper: currentAlgorithmWrapper(),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        onSuccess: (CompleteConditionState state) async {
          SmartDialog.showToast("语法分析正确");
        },
        onError: (AlgorithmException ec) async {
          SmartDialog.showToast("语法分析异常：${ec.error}");
        },
      ),
      suggestCountForNewAndReviewState: () async => await AlgorithmParser.parse(
        stateFunc: () => SuggestCountForNewAndReviewState(
          algorithmWrapper: currentAlgorithmWrapper(),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        onSuccess: (SuggestCountForNewAndReviewState state) async {
          SmartDialog.showToast("语法分析正确");
        },
        onError: (AlgorithmException ec) async {
          SmartDialog.showToast("语法分析异常：${ec.error}");
        },
      ),
    );
  }

  /// 若 [isToRaw] 为 null，则 raw - view 自动相互切换
  void changeRawOrView(bool? isToRaw) {
    rawToView();

    void toView() {
      rawCamera.changeFrom(freeBoxController.freeBoxCamera);
      rawTextEditingController.text = "";
      freeBoxController.targetSlide(targetCamera: viewCamera, rightNow: false);
    }

    void toRaw() {
      viewCamera.changeFrom(freeBoxController.freeBoxCamera);
      rawTextEditingController.text = AlgorithmBidirectionalParsing.parseFromAlgorithmWrapper(currentAlgorithmWrapper());
      freeBoxController.targetSlide(targetCamera: rawCamera, rightNow: false);
    }

    if (isToRaw == null) {
      if (isCurrentRaw()) {
        toView();
      } else {
        toRaw();
      }
      isCurrentRaw.refreshEasy((oldValue) => !oldValue);
    } else {
      if (isToRaw) {
        isCurrentRaw.refreshEasy((oldValue) => true);
        toRaw();
      } else {
        isCurrentRaw.refreshEasy((oldValue) => false);
        toView();
      }
    }
  }

  /// raw 转 view，以便模式切换、分析、存储等
  void rawToView() {
    if (isCurrentRaw()) {
      currentAlgorithmWrapper.refreshInevitable((obj) => AlgorithmBidirectionalParsing.parseFromString(rawTextEditingController.text));
    }
  }

  /// raw 格式化
  void rawFormatting() {
    rawTextEditingController.text = AlgorithmBidirectionalParsing.parseFromAlgorithmWrapper(
      AlgorithmBidirectionalParsing.parseFromString(rawTextEditingController.text),
    );
  }

  /// 将预设的进行粘贴
  void defaultToPaste(String rawContent) {
    if (isCurrentRaw()) {
      rawTextEditingController.text = rawContent;
    } else {
      currentAlgorithmWrapper.refreshEasy((oldValue) => AlgorithmBidirectionalParsing.parseFromString(rawContent));
    }
    Navigator.pop(context);
    SmartDialog.showToast("替换成功！");
  }

  /// TODO: 把 raw 模式设置成富文本编辑器模式，来提供撤销功能。
}
