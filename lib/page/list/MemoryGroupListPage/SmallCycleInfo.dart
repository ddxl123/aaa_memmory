import 'package:aaa_memory/page/list/MemoryGroupListPage/SingleMemoryGroup.dart';
import 'package:drift/drift.dart';
import 'package:drift/extensions/json1.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:tools/tools.dart';

import '../../../algorithm_parser/AlgorithmException.dart';
import '../../../algorithm_parser/parser.dart';
import '../../edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';

class SmallCycleInfo {
  SmallCycleInfo({required this.memoryGroup, required this.memoryGroupSmartCycleInfo});

  final MemoryGroup memoryGroup;

  /// 如果为 null，则表示当前没有正在执行的小周期。
  final MemoryGroupSmartCycleInfo? memoryGroupSmartCycleInfo;
}

class CurrentSmallCycleInfo extends SmallCycleInfo {
  CurrentSmallCycleInfo({required super.memoryGroup, required super.memoryGroupSmartCycleInfo});

  /// 当前记忆组的记忆算法，注意是查询云端并覆盖本地后的
  ///
  /// 如果记忆模型是被删除掉而未查询到，则直接赋值为 null
  MemoryAlgorithm? _memoryAlgorithm;

  MemoryAlgorithm? get getMemoryAlgorithm => _memoryAlgorithm;

  set setMemoryAlgorithm(MemoryAlgorithm? newMemoryAlgorithm) {
    _memoryAlgorithm = newMemoryAlgorithm;
    memoryGroup.memory_algorithm_id = _memoryAlgorithm?.id;
  }

  /// 算法结果数量，当前小周期需要学习和复习的数量。
  ///
  /// 为 null 表示算法为空或算法计算异常 // TODO：将为空和计算异常分开提示
  NewAndReviewCount? shouldNewAndReviewCount;

  /// 增量数量，当前小周期需要增量新学和复习的数量。
  NewAndReviewCount shouldIncrementalNewAndReviewCount = NewAndReviewCount(newCount: 0, reviewCount: 0);

  /// 查询在当前小周期
  ///   - 在当前小周期内 新学过 的数量
  ///   - 在当前小周期内 在当前小周期之前新学过，且在当前小周期内复习完的 的的数量
  ///   - 在当前小周期内 在当前小周期内新学过，且在当前小周期内复习完的  的的数量
  ///
  /// 为 null 什么当前小周期未开始。
  ThirdNewAndReviewCount? learnedThirdNewAndReviewCount;

  /// 过期数量
  ///   - 如果当前小周期未启动，则是按照当前实时时间前算的，在这之前没有按时完成记忆任务的数量。
  ///   - 如果当前小周期已启动，则是按照当前小周期的开始时间前算的，在这之前没有按时完成记忆任务的数量。
  int expireCount = 0;

  /// 当前小周期计算出的循环周期结果。
  ///
  /// 为 null 表示算法为空或算法计算异常 // TODO：将为空和计算异常分开提示
  LoopCycle? loopCycle;

  /// 在当前小周期内，剩余的数量。
  ///
  /// 为 null 表示算法计算异常。// TODO：将为空和计算异常分开提示
  ThirdNewAndReviewCount? get getNotLearnThirdNewAndReviewCount {
    if (shouldNewAndReviewCount == null || learnedThirdNewAndReviewCount == null) {
      return null;
    }

    return ThirdNewAndReviewCount(
      // 在当前小周期内未新学的
      newCount: shouldNewAndReviewCount!.newCount - learnedThirdNewAndReviewCount!.newCount,
      // 在当前小周期之前新学过，但在当前小周期内未复习完的
      reviewCount: shouldNewAndReviewCount!.reviewCount - learnedThirdNewAndReviewCount!.reviewCount,
      // 在当前小周期新学过，且在当前小周期内未复习完的
      newReviewCount: learnedThirdNewAndReviewCount!.newCount - learnedThirdNewAndReviewCount!.newReviewCount,
    );
  }

  /// 当前时间的秒数，距离启动时时间点的秒数
  int? get getNowSeconds => memoryGroup.start_time == null
      ? null
      : timeSecondsDifference(
          left: memoryGroup.start_time!,
          right: DateTime.now(),
        );

  /// 当前小周期开始时间的秒数，距离启动时时间点的秒数
  int? get getSmallCycleStartSeconds => memoryGroup.start_time == null
      ? null
      : timeSecondsDifference(
          right: memoryGroupSmartCycleInfo!.created_at,
          left: memoryGroup.start_time!,
        );

  /// 当前小周期应该结束时间的秒数，距离启动时时间点的秒数
  int? get getSmallCycleEndSeconds => memoryGroup.start_time == null
      ? null
      : timeSecondsDifference(
          right: memoryGroupSmartCycleInfo!.should_small_cycle_end_time,
          left: memoryGroup.start_time!,
        );

  Future<void> read() async {
    await parseLoopCycle();
    await parseShouldCountForNewAndReview();
    await queryLearnedCountForNewAndReview();
    await queryExpireCount();
  }

  /// 解析循环周期算法
  Future<void> parseLoopCycle() async {
    await AlgorithmParser.parse(
      stateFunc: () => SuggestLoopCycleState(
        algorithmWrapper: getMemoryAlgorithm?.suggest_loop_cycle_algorithm == null
            ? AlgorithmWrapper.emptyAlgorithmWrapper
            : AlgorithmWrapper.fromJsonString(getMemoryAlgorithm!.suggest_loop_cycle_algorithm!),
        // TODO: 改成 SimulationType.external，以便可获取到内部变量值
        simulationType: SimulationType.syntaxCheck,
        externalResultHandler: null,
      ),
      onSuccess: (SuggestLoopCycleState state) async {
        loopCycle = state.result;
      },
      onError: (AlgorithmException ec) async {
        /// TODO：如何给错误提示
        loopCycle = null;
      },
    );
  }

  /// 解析应该新学和复习数量
  Future<void> parseShouldCountForNewAndReview() async {
    await AlgorithmParser.parse(
      stateFunc: () => SuggestCountForNewAndReviewState(
        algorithmWrapper: getMemoryAlgorithm?.suggest_count_for_new_and_review_algorithm == null
            ? AlgorithmWrapper.emptyAlgorithmWrapper
            : AlgorithmWrapper.fromJsonString(getMemoryAlgorithm!.suggest_count_for_new_and_review_algorithm!),
        // TODO: 改成 SimulationType.external，以便可获取到内部变量值
        simulationType: SimulationType.syntaxCheck,
        externalResultHandler: null,
      ),
      onSuccess: (SuggestCountForNewAndReviewState state) async {
        shouldNewAndReviewCount = state.result;
      },
      onError: (AlgorithmException ec) async {
        shouldNewAndReviewCount = null;
      },
    );
  }

  /// 详细看 [learnedThirdNewAndReviewCount] 注释。
  ///
  /// TODO: 处理当 [FragmentMemoryInfoStudyStatus.paused] 时。
  Future<void> queryLearnedCountForNewAndReview() async {
    if (memoryGroup.start_time == null) {
      learnedThirdNewAndReviewCount = null;
      return;
    }

    if (memoryGroupSmartCycleInfo == null) {
      learnedThirdNewAndReviewCount = ThirdNewAndReviewCount(newCount: 0, reviewCount: 0, newReviewCount: 0);
      return;
    }

    // 在当前小周期内 新学过 的数量
    final newCountExpr = driftDb.fragmentMemoryInfos.id.count();
    final newSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    newSel.where(
      driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) &
          driftDb.fragmentMemoryInfos.click_time.jsonExtract(r"$[0]").dartCast<int>().isBetweenValues(getSmallCycleStartSeconds!, getSmallCycleEndSeconds!),
    );
    newSel.addColumns([newCountExpr]);
    final newCount = (await newSel.getSingle()).read(newCountExpr)!;

    // 在当前小周期内 在当前小周期之前新学过，且在当前小周期内复习完的 的的数量
    final reviewCountExpr = driftDb.fragmentMemoryInfos.id.count();
    final reviewSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    reviewSel.where(
      driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) &
          driftDb.fragmentMemoryInfos.click_time.jsonExtract(r"$[0]").dartCast<int>().isSmallerThanValue(getSmallCycleStartSeconds!) &
          driftDb.fragmentMemoryInfos.click_time.jsonArrayLength().isBiggerOrEqualValue(2) &
          driftDb.fragmentMemoryInfos.next_plan_show_time.jsonExtract(r"$[#-1]").dartCast<int>().isBiggerThanValue(getSmallCycleEndSeconds!),
    );
    reviewSel.addColumns([reviewCountExpr]);
    final reviewCount = (await reviewSel.getSingle()).read(reviewCountExpr)!;

    final newReviewCountExpr = driftDb.fragmentMemoryInfos.id.count();
    final newReviewSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    newReviewSel.where(
      driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) &
          driftDb.fragmentMemoryInfos.click_time.jsonExtract(r"$[0]").dartCast<int>().isBiggerOrEqualValue(getSmallCycleStartSeconds!) &
          driftDb.fragmentMemoryInfos.click_time.jsonArrayLength().isBiggerOrEqualValue(2) &
          driftDb.fragmentMemoryInfos.next_plan_show_time.jsonExtract(r"$[#-1]").dartCast<int>().isBiggerThanValue(getSmallCycleEndSeconds!),
    );
    newReviewSel.addColumns([newReviewCountExpr]);
    final newReviewCount = (await newReviewSel.getSingle()).read(newReviewCountExpr)!;

    learnedThirdNewAndReviewCount = ThirdNewAndReviewCount(newCount: newCount, reviewCount: reviewCount, newReviewCount: newReviewCount);
  }

  /// 查看 [expireCount] 注释。
  Future<void> queryExpireCount() async {
    if (memoryGroup.start_time == null) {
      return;
    }

    int targetTime = memoryGroupSmartCycleInfo == null ? getNowSeconds! : getSmallCycleStartSeconds!;

    final countExpr = driftDb.fragmentMemoryInfos.id.count();
    final sel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    sel.where(
      driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) &
          driftDb.fragmentMemoryInfos.next_plan_show_time.jsonExtract(r"$[#-1]").dartCast<int>().isSmallerThanValue(targetTime),
    );
    sel.addColumns([countExpr]);
    expireCount = (await sel.getSingle()).read(countExpr)!;
  }
}
