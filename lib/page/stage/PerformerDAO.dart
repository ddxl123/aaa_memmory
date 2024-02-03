import 'dart:math';
import 'package:drift/drift.dart';
import 'package:drift/extensions/json1.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:tools/tools.dart';

import 'InAppStageAbController.dart';

class PerformerQuery {
  /// 获取新的表演者。
  ///
  /// return null 时表示没有检索到下一个。
  Future<Performer?> getPerformer({required MemoryGroup mg, required InAppStageAbController inAppStageAbController}) async {
    final newPerformer = await getOneNewPerformer(mg: mg, inAppStageAbController: inAppStageAbController);
    final reviewPerformer = await getOneReviewPerformer(mg: mg, inAppStageAbController: inAppStageAbController);

    logger.outNormal(
        print: "获取到的新碎片：\n${newPerformer?.fragmentMemoryInfo}\n${newPerformer?.fragment}"
            "\n"
            "获取到的复习碎片：\n${reviewPerformer?.fragmentMemoryInfo}\n${reviewPerformer?.fragment}");

    late final Performer? performer;
    if (mg.new_review_display_order == NewReviewDisplayOrder.mix) {
      performer = Random().nextBool() == true ? (newPerformer ?? reviewPerformer) : (reviewPerformer ?? newPerformer);
    } else if (mg.new_review_display_order == NewReviewDisplayOrder.review_new) {
      performer = reviewPerformer ?? newPerformer;
    } else if (mg.new_review_display_order == NewReviewDisplayOrder.new_review) {
      performer = newPerformer ?? reviewPerformer;
    } else {
      throw '未处理 ${mg.new_review_display_order}';
    }
    return performer;
  }

  /// 获取新碎片。
  ///
  /// 若没有新碎片了，则返回 null。
  Future<Performer?> getOneNewPerformer({required MemoryGroup mg, required InAppStageAbController inAppStageAbController}) async {
    // 检查是否还需要学习新的
    final have = inAppStageAbController.currentSmallCycleInfo!.getNotLearnThirdNewAndReviewCount!.newCount != 0;
    if (!have) {
      return null;
    }

    // 获取要新学习的碎片
    final selInfo = driftDb.select(driftDb.fragmentMemoryInfos);
    selInfo.where((tbl) => tbl.memory_group_id.equals(mg.id) & tbl.study_status.equalsValue(FragmentMemoryInfoStudyStatus.never));
    if (mg.new_display_order == NewDisplayOrder.random) {
      selInfo.orderBy([(_) => OrderingTerm.random()]);
    } else {
      throw '未处理 ${mg.new_display_order}';
    }
    selInfo.limit(1);

    final infoResult = await selInfo.getSingleOrNull();
    if (infoResult == null) return null;

    final selF = driftDb.select(driftDb.fragments)..where((tbl) => tbl.id.equals(infoResult.fragment_id));
    final fResult = await selF.getSingleOrNull();
    if (fResult == null) {
      logger.outNormal(print: "碎片已经被删除，但是仍然残留了记忆信息！");
      return null;
    }

    return Performer(fragment: fResult, fragmentMemoryInfo: infoResult, inAppStageAbController: inAppStageAbController);
  }

  /// 获取要复习的碎片。
  ///
  /// 若没有复习碎片了，则返回 null。
  Future<Performer?> getOneReviewPerformer({required MemoryGroup mg, required InAppStageAbController inAppStageAbController}) async {
    // 检查是否还需要学习新的
    final have1 = inAppStageAbController.currentSmallCycleInfo!.getNotLearnThirdNewAndReviewCount!.reviewCount != 0;
    final have2 = inAppStageAbController.currentSmallCycleInfo!.getNotLearnThirdNewAndReviewCount!.newReviewCount != 0;
    if (!have1 && !have2) {
      return null;
    }

    // [isExpire] 查询的是否为过期类型。
    Future<FragmentMemoryInfo?> query(bool isExpire) async {
      final lastNextPlanedShowTimeExpr = driftDb.fragmentMemoryInfos.next_plan_show_time.jsonExtract<int>(r'$[#-1]');
      final selInfo = driftDb.select(driftDb.fragmentMemoryInfos);
      selInfo.addColumns([lastNextPlanedShowTimeExpr]);
      selInfo.where(
        (tbl) {
          final expr = tbl.memory_group_id.equals(mg.id) & tbl.study_status.equalsValue(FragmentMemoryInfoStudyStatus.reviewing);
          if (isExpire) {
            return expr & lastNextPlanedShowTimeExpr.isSmallerThanValue(inAppStageAbController.currentSmallCycleInfo!.getSmallCycleStartSeconds!);
          } else {
            return expr &
                lastNextPlanedShowTimeExpr.isBiggerOrEqualValue(inAppStageAbController.currentSmallCycleInfo!.getSmallCycleStartSeconds!) &
                lastNextPlanedShowTimeExpr.isSmallerOrEqualValue(inAppStageAbController.currentSmallCycleInfo!.getSmallCycleEndSeconds!);
          }
        },
      );
      // 升序
      selInfo.orderBy([(o) => OrderingTerm(expression: lastNextPlanedShowTimeExpr, mode: OrderingMode.asc)]);
      selInfo.limit(1);
      return await selInfo.getSingleOrNull();
    }

    late final FragmentMemoryInfo? finalResult;
    final resultNoExpire = await query(false);
    final resultExpire = await query(true);
    if (mg.review_display_order == ReviewDisplayOrder.expire_first) {
      finalResult = resultExpire ?? resultNoExpire;
    } else if (mg.review_display_order == ReviewDisplayOrder.no_expire_first) {
      finalResult = resultNoExpire ?? resultExpire;
    } else if (mg.review_display_order == ReviewDisplayOrder.ignore_expire) {
      finalResult = resultNoExpire;
    } else {
      throw "未处理 ${mg.review_display_order}";
    }
    if (finalResult == null) return null;

    final selF = driftDb.select(driftDb.fragments)..where((tbl) => tbl.id.equals(finalResult!.fragment_id));
    final fResult = await selF.getSingleOrNull();
    if (fResult == null) {
      logger.outNormal(print: "碎片已经被删除，但是仍然残留了记忆信息！");
      return null;
    }

    return Performer(fragment: fResult, fragmentMemoryInfo: finalResult, inAppStageAbController: inAppStageAbController);
  }

  /// ========================================================================================

  /// [InternalVariableConstantHandler.k1FCountAllConst]
  Future<int> getCountAll({required int memoryGroupId}) async {
    return await driftDb.generalQueryDAO.queryCount(
      tableInfo: driftDb.fragmentMemoryInfos,
      whereExpr: driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroupId),
    );
  }

  /// [InternalVariableConstantHandler.k2CountNewConst]
  Future<int> queryFragmentCountByStudyStatus({required int memoryGroupId, required FragmentMemoryInfoStudyStatus studyStatus}) async {
    return await driftDb.generalQueryDAO.queryCount(
      tableInfo: driftDb.fragmentMemoryInfos,
      whereExpr: driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroupId) & driftDb.fragmentMemoryInfos.study_status.equalsValue(studyStatus),
    );
  }

  /// TODO:
  // Future<List<int>> getCountLearned({required MemoryGroup memoryGroup}) async {
  //   return [await db.generalQueryDAO.getNewFragmentsCount(memoryGroup: memoryGroup)];
  // }

  /// [InternalVariableConstantHandler.k3StudiedTimesConst]
  Future<int> getStudiedTimes({required Performer performer}) async {
    return strToList(performer.fragmentMemoryInfo.click_time).length;
  }

  /// [InternalVariableConstantHandler.k4CurrentShowTimeConst]
  Future<int> getCurrentShowTime({required MemoryGroup memoryGroup}) async {
    return timeSecondsDifference(right: DateTime.now(), left: memoryGroup.start_time!);
  }

  /// [InternalVariableConstantHandler.i1ActualShowTimeConst]
  Future<List<int>> getActualShowTime({required Performer performer}) async {
    return strToList(performer.fragmentMemoryInfo.actual_show_time);
  }

  /// [InternalVariableConstantHandler.i2NextPlanShowTimeConst]
  Future<List<int>> getNextPlanedShowTime({required Performer performer}) async {
    return strToList(performer.fragmentMemoryInfo.next_plan_show_time);
  }

  /// [InternalVariableConstantHandler.i3ShowFamiliarityConst]
  Future<List<double>> getShowFamiliarity({required Performer performer}) async {
    return strToList(performer.fragmentMemoryInfo.show_familiarity);
  }

  /// [InternalVariableConstantHandler.i4ClickFamiliarityConst]
  Future<List<double>> getClickFamiliarity({required Performer performer}) async {
    return strToList(performer.fragmentMemoryInfo.click_familiarity);
  }

  /// [InternalVariableConstantHandler.i5ClickTimeConst]
  Future<List<int>> getClickTime({required Performer performer}) async {
    return strToList(performer.fragmentMemoryInfo.click_time);
  }

  /// [InternalVariableConstantHandler.i6ClickValueConst]
  Future<List<double>> getClickValue({required Performer performer}) async {
    return strToList(performer.fragmentMemoryInfo.click_value);
  }

  /// [InternalVariableConstantHandler.i7ButtonValuesConst]
  Future<List<List<double>>> getButtonValues({required Performer performer}) async {
    return strToList<List<dynamic>>(performer.fragmentMemoryInfo.button_values).cast<List<double>>();
  }
}
