import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:tools/tools.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../algorithm_parser/AlgorithmException.dart';
import '../../../algorithm_parser/parser.dart';
import 'MemoryAlgorithmGizmoEditPageAbController.dart';

class AlgorithmEditPageAbController extends AbController {
  AlgorithmEditPageAbController({required this.stateName});

  final String stateName;
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

    final mm = memoryModelGizmoEditPageAbController.cloneMemoryAlgorithmAb;
    final currentOrNull = currentAlgorithmWrapper().toJsonStringOrNull();
    final isModified = ClassificationState.filter(
      stateName: stateName,
      familiarity: () => currentOrNull != mm().familiarity_algorithm,
      buttonData: () => currentOrNull != mm().button_algorithm,
      nextShowTime: () => currentOrNull != mm().next_time_algorithm,
      completeCondition: () => currentOrNull != mm().completed_algorithm,
      suggestLoopCycle: () => currentOrNull != mm().suggest_loop_cycle_algorithm,
      suggestCountForNewAndReviewState: () => currentOrNull != mm().suggest_count_for_new_and_review_algorithm,
    );
    if (isModified) {
      apply();
      memoryModelGizmoEditPageAbController.cloneMemoryAlgorithmAb.refreshForce();
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
    final mm = memoryModelGizmoEditPageAbController.cloneMemoryAlgorithmAb;
    currentAlgorithmWrapper.lateAssign(
      AlgorithmWrapper.fromJsonString(
        ClassificationState.filter(
          stateName: stateName,
          buttonData: () => mm().button_algorithm ?? ea,
          familiarity: () => mm().familiarity_algorithm ?? ea,
          nextShowTime: () => mm().next_time_algorithm ?? ea,
          completeCondition: () => mm().completed_algorithm ?? ea,
          suggestLoopCycle: () => mm().suggest_loop_cycle_algorithm ?? ea,
          suggestCountForNewAndReviewState: () => mm().suggest_count_for_new_and_review_algorithm ?? ea,
        ),
      ),
    );
  }

  void apply() {
    rawToView();
    final mm = memoryModelGizmoEditPageAbController.cloneMemoryAlgorithmAb;
    ClassificationState.filter(
      stateName: stateName,
      buttonData: () => mm()..button_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      familiarity: () => mm()..familiarity_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      nextShowTime: () => mm()..next_time_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      completeCondition: () => mm()..completed_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      suggestLoopCycle: () => mm()..suggest_loop_cycle_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
      suggestCountForNewAndReviewState: () => mm()..suggest_count_for_new_and_review_algorithm = currentAlgorithmWrapper().toJsonStringOrNull(),
    );
  }

  Future<void> analysis() async {
    changeRawOrView(false);
    rawToView();
    currentAlgorithmWrapper().cancelAllException();

    await ClassificationState.filterFuture(
      stateName: stateName,
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
      suggestLoopCycle: () async => await AlgorithmParser.parse(
        stateFunc: () => SuggestLoopCycleState(
          algorithmWrapper: currentAlgorithmWrapper(),
          simulationType: SimulationType.syntaxCheck,
          externalResultHandler: null,
        ),
        onSuccess: (SuggestLoopCycleState state) async {
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
      final result = AlgorithmBidirectionalParsing.parseFromAlgorithmWrapper(currentAlgorithmWrapper());
      if (result.hasError) {
        SmartDialog.showToast("解析成文本失败：${result.error}");
      } else {
        viewCamera.changeFrom(freeBoxController.freeBoxCamera);
        rawTextEditingController.text = result.content!;
        freeBoxController.targetSlide(targetCamera: rawCamera, rightNow: false);
      }
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
      final result = AlgorithmBidirectionalParsing.parseFromString(rawTextEditingController.text)!;
      if (result.hasError) {
        SmartDialog.showToast("解析成文本失败：${result.error}");
      } else {
        currentAlgorithmWrapper.refreshInevitable((obj) => result.algorithmWrapper!);
      }
    }
  }

  /// raw 格式化
  /// TODO: 当在 "if" 字符中存在其他字符时，例如 "isdadf"，进行 [rawFormatting] 后会把 if-else-use 语句全部归零掉。
  void rawFormatting() {
    final result1 = AlgorithmBidirectionalParsing.parseFromString(rawTextEditingController.text)!;
    if (result1.hasError) {
      SmartDialog.showToast("格式化异常：${result1.error}");
    } else {
      final result2 = AlgorithmBidirectionalParsing.parseFromAlgorithmWrapper(result1.algorithmWrapper!);
      if (result2.hasError) {
        SmartDialog.showToast("格式化异常：${result2.error}");
      } else {
        rawTextEditingController.text = result2.content!;
      }
    }
  }

  /// 将预设的进行粘贴
  void defaultToPaste(String rawContent) {
    if (isCurrentRaw()) {
      rawTextEditingController.text = rawContent;
    } else {
      final result = AlgorithmBidirectionalParsing.parseFromString(rawContent)!;
      if (result.hasError) {
        SmartDialog.showToast("覆盖异常：${result.error}");
      } else {
        currentAlgorithmWrapper.refreshEasy((oldValue) => result.algorithmWrapper!);
      }
    }
    Navigator.pop(context);
    SmartDialog.showToast("替换成功！");
  }

  /// TODO: 把 raw 模式设置成富文本编辑器模式，来提供撤销功能。
}
