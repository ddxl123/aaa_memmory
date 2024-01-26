import 'package:aaa_memory/page/edit/MemoryGroupGizmoEditPage/MemoryGroupGizmoEditPageAbController.dart';
import 'package:drift/drift.dart';
import 'package:drift/extensions/json1.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../algorithm_parser/AlgorithmException.dart';
import '../../algorithm_parser/parser.dart';
import '../edit/MemoryGroupGizmoEditPage/MemoryGroupGizmoEditPage.dart';
import '../edit/edit_page_type.dart';

enum DownloadStatus {
  /// 正在加载中
  other_loading,

  /// 加载失败
  other_load_fail,

  /// 本地和云端数量都为 0
  zero,

  /// 本地和云端数量都不为 0，且数量相同
  all_downloaded,

  /// 本地数量为 0，云端数量不为 0
  never_downloaded,

  /// 本地和云端数量都不为 0，但数量不一致
  /// 1. 已下载过，但是云端存在一些未下载的，需要下载云端未下载的
  /// 2. 需要删除本地多余的，只删除记忆信息，不删除碎片，因为其他记忆组内可能使用了。
  different_download,
}

class StatusButton extends StatelessWidget {
  StatusButton({
    super.key,
    required this.listPageC,
    required this.editPageC,
    required this.singleMemoryGroupAb,
  }) {
    if (editPageC == null) {
      customOnPressed = () {
        listPageC.onStatusTap(singleMemoryGroupAb);
      };
    }
  }

  final MemoryGroupListPageAbController listPageC;
  final MemoryGroupGizmoEditPageAbController? editPageC;
  final Ab<SingleMemoryGroup> singleMemoryGroupAb;
  late final void Function()? customOnPressed;

  @override
  Widget build(BuildContext context) {
    switch (singleMemoryGroupAb().downloadStatus) {
      case DownloadStatus.other_loading:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("获取中"),
          color: Colors.white,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () {
                  SmartDialog.showToast("正在获取中...");
                },
        );
      case DownloadStatus.other_load_fail:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("获取失败", style: TextStyle(color: Colors.red)),
          color: Colors.white,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () {
                  SmartDialog.showToast("正在重新获取...");
                  listPageC.refreshController.requestRefresh();
                },
        );
      case DownloadStatus.zero:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("添加碎片"),
          color: Colors.amber,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () {
                  SmartDialog.showToast("请在知识碎片页面中添加");
                },
        );
      case DownloadStatus.never_downloaded:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("未下载"),
          color: Colors.grey,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () async {
                  await showCustomDialog(
                    builder: (ctx) => OkAndCancelDialogWidget(
                      text: "是否下载碎片？",
                      okText: "下载",
                      cancelText: "稍后下载",
                      onOk: () async {
                        await editPageC?.allDownloadFragmentAndMemoryInfos();
                      },
                    ),
                  );
                },
        );
      case DownloadStatus.different_download:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("未下载完整"),
          color: Colors.grey,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () async {
                  await showCustomDialog(
                    builder: (ctx) => OkAndCancelDialogWidget(
                      text: "碎片数量不同步，是否进行数量同步？",
                      okText: "同步",
                      cancelText: "稍后同步",
                      onOk: () async {
                        await editPageC?.differentFragmentAndMemoryInfos();
                      },
                    ),
                  );
                },
        );
      case DownloadStatus.all_downloaded:
        return allDownloadedWidget();

      default:
        throw "未处理 ${singleMemoryGroupAb().downloadStatus}";
    }
  }

  Widget allDownloadedWidget() {
    switch (singleMemoryGroupAb().memoryGroup.study_status) {
      case StudyStatus.not_startup:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("启动任务"),
          color: Colors.green,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () async {
                  final result = await editPageC?.startup();
                  if (result == true) {
                    SmartDialog.showToast("任务已启动");
                    await listPageC.refreshController.requestRefresh();
                    SmartDialog.dismiss(status: SmartStatus.dialog);
                  }
                },
        );
      case StudyStatus.studying_for_this_cycle:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("继续本周期"),
          color: Colors.green,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () async {
                  await editPageC?.createOrContinueSmallCycle();
                },
        );
      case StudyStatus.not_study_for_this_cycle:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("开始本周期"),
          color: Colors.green,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null
              ? customOnPressed!
              : () async {
                  await editPageC?.createOrContinueSmallCycle();
                },
        );
      case StudyStatus.completed_for_this_cycle:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("本周期已完成·加量学习"),
          color: Colors.green,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null ? customOnPressed! : () async {},
        );
      case StudyStatus.incomplete_for_last_cycle:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("上周期未完成"),
          color: Colors.green,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null ? customOnPressed! : () async {},
        );

      case StudyStatus.completed_for_group:
        return CustomRoundCornerButton(
          isMinVisualDensity: editPageC == null ? true : false,
          text: Text("本组已完成"),
          color: Colors.green,
          isElevated: editPageC == null ? false : true,
          onPressed: editPageC == null ? customOnPressed! : () async {},
        );
      default:
        throw "未处理 ${singleMemoryGroupAb().memoryGroup.study_status}";
    }
  }
}

class SmallCycleInfo {
  SmallCycleInfo({required this.singleMemoryGroup, required this.memoryGroupSmartCycleInfo});

  final SingleMemoryGroup singleMemoryGroup;

  /// 如果为 null，则表示当前没有正在执行的小周期。
  final MemoryGroupSmartCycleInfo? memoryGroupSmartCycleInfo;
}

class CurrentSmallCycleInfo extends SmallCycleInfo {
  CurrentSmallCycleInfo({required super.singleMemoryGroup, required super.memoryGroupSmartCycleInfo});

  /// 当前记忆组的记忆算法，注意是查询云端并覆盖本地后的
  ///
  /// 如果记忆模型是被删除掉而未查询到，则直接赋值为 null
  MemoryAlgorithm? _memoryAlgorithm;

  MemoryAlgorithm? get getMemoryAlgorithm => _memoryAlgorithm;

  set setMemoryAlgorithm(MemoryAlgorithm? newMemoryAlgorithm) {
    _memoryAlgorithm = newMemoryAlgorithm;
    singleMemoryGroup.memoryGroup.memory_algorithm_id = _memoryAlgorithm?.id;
  }

  /// 算法结果数量，当前小周期需要学习和复习的数量。
  ///
  /// 为 null 表示算法为空或算法计算异常 // TODO：将为空和计算异常分开提示
  NewAndReviewCount? shouldNewAndReviewCount = NewAndReviewCount(newCount: 0, reviewCount: 0);

  /// 增量数量，当前小周期需要增量新学和复习的数量。
  NewAndReviewCount shouldIncrementalNewAndReviewCount = NewAndReviewCount(newCount: 0, reviewCount: 0);

  /// 当前小周期已学习和已复习的数量。
  ///
  /// 注意是在当前小周期内，即应在当前小周期的应新学和应复习的碎片中的已学习和已复习的数量。
  NewAndReviewCount learnedNewAndReviewCount = NewAndReviewCount(newCount: 0, reviewCount: 0);

  /// 当前小周期计算出的循环周期结果。
  ///
  /// 为 null 表示算法为空或算法计算异常 // TODO：将为空和计算异常分开提示
  LoopCycle? loopCycle;

  /// 为 null 表示算法计算异常。// TODO：将为空和计算异常分开提示
  ///
  /// 注意是在当前小周期内，即应在当前小周期的应新学和应复习的碎片中的未学习和未复习的数量。
  NewAndReviewCount? get getNotLearnNewAndReviewCount {
    if (shouldNewAndReviewCount == null) {
      return null;
    }
    return NewAndReviewCount(
      newCount: shouldNewAndReviewCount!.newCount - learnedNewAndReviewCount.newCount,
      reviewCount: shouldNewAndReviewCount!.reviewCount - learnedNewAndReviewCount.reviewCount,
    );
  }

  Future<void> read() async {
    await parseLoopCycle();
    await parseShouldCountForNewAndReview();
    await queryLearnedCountForNewAndReview();
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
        shouldNewAndReviewCount = NewAndReviewCount(newCount: -1, reviewCount: -1);
      },
    );
  }

  /// 解析在当前小周期已学习和已复习的数量
  ///
  /// TODO: 处理当 [FragmentMemoryInfoStudyStatus.paused] 时。
  Future<void> queryLearnedCountForNewAndReview() async {
    late final DateTime memoryGroupStartTime;
    if (singleMemoryGroup.memoryGroup.start_time == null) {
      learnedNewAndReviewCount = NewAndReviewCount(newCount: 0, reviewCount: 0);
      return;
    }

    if (memoryGroupSmartCycleInfo == null) {
      learnedNewAndReviewCount = NewAndReviewCount(newCount: 0, reviewCount: 0);
      return;
    }

    memoryGroupStartTime = singleMemoryGroup.memoryGroup.start_time!;

    // 当前小周期开始时间，距离启动时时间点的秒数
    final smallCycleStartSeconds = timeSecondsDifference(right: memoryGroupSmartCycleInfo!.created_at, left: memoryGroupStartTime);

    // 当前小周期应该结束时间，距离启动时间的秒数
    final smallCycleEndSeconds = timeSecondsDifference(right: memoryGroupSmartCycleInfo!.should_small_cycle_end_time, left: memoryGroupStartTime);

    // 在当前小周期已学习的
    final newCountExpr = driftDb.fragmentMemoryInfos.id.count();
    final newSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    newSel.where(
      driftDb.fragmentMemoryInfos.memory_group_id.equals(singleMemoryGroup.memoryGroup.id) &
          driftDb.fragmentMemoryInfos.click_time.jsonExtract(r"$[0]").dartCast<int>().isBetweenValues(smallCycleStartSeconds, smallCycleEndSeconds),
    );
    newSel.addColumns([newCountExpr]);
    final newCount = (await newSel.getSingle()).read(newCountExpr)!;

    final reviewCountExpr = driftDb.fragmentMemoryInfos.id.count();
    final reviewSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    reviewSel.where(
      driftDb.fragmentMemoryInfos.memory_group_id.equals(singleMemoryGroup.memoryGroup.id) &
          driftDb.fragmentMemoryInfos.click_time.jsonExtract(r"$[0]").dartCast<int>().isSmallerThanValue(smallCycleStartSeconds) &
          driftDb.fragmentMemoryInfos.click_time.jsonArrayLength().isBiggerOrEqualValue(2) &
          driftDb.fragmentMemoryInfos.next_plan_show_time.jsonExtract(r"$[#-1]").dartCast<int>().isBiggerThanValue(smallCycleEndSeconds),
    );
    reviewSel.addColumns([reviewCountExpr]);
    final reviewCount = (await reviewSel.getSingle()).read(reviewCountExpr)!;

    learnedNewAndReviewCount = NewAndReviewCount(newCount: newCount, reviewCount: reviewCount);
  }
}

class SingleMemoryGroup {
  SingleMemoryGroup({required this.memoryGroup});

  DownloadStatus downloadStatus = DownloadStatus.other_loading;

  /// 注意是查询云端并覆盖本地后的
  final MemoryGroup memoryGroup;

  /// 当前记忆组的全部小周期，包含了 [currentSmallCycleInfo]。
  final smallCycleInfos = <SmallCycleInfo>[];

  /// 当前正在执行的小周期，如果没有正在执行的，则为 [CurrentSmallCycleInfo.memoryGroupSmartCycleInfo] 为 null
  late final CurrentSmallCycleInfo currentSmallCycleInfo;

  /// 当前记忆组碎片总数量
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalFragmentCount = 0;

  /// [FragmentMemoryInfoStudyStatus.completed]
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalCompletedCount = 0;

  /// [FragmentMemoryInfoStudyStatus.reviewing]
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalReviewingCount = 0;

  Future<void> queryAllSmallCycleInfos() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudSingleMemoryGroupAllSmallCycleInfoAndOverwriteLocal(
      memoryGroupId: memoryGroup.id,
      onSuccess: (List<MemoryGroupSmartCycleInfo> memoryGroupSmartCycleInfo) async {
        smallCycleInfos.clear();
        currentSmallCycleInfo = CurrentSmallCycleInfo(singleMemoryGroup: this, memoryGroupSmartCycleInfo: null);
        smallCycleInfos.addAll(
          memoryGroupSmartCycleInfo.map((e) {
            if (isTimeBetween(target: DateTime.now(), left: e.created_at, right: e.should_small_cycle_end_time)) {
              final c = CurrentSmallCycleInfo(singleMemoryGroup: this, memoryGroupSmartCycleInfo: e);
              currentSmallCycleInfo = c;
              return c;
            }
            return SmallCycleInfo(singleMemoryGroup: this, memoryGroupSmartCycleInfo: e);
          }),
        );
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );
  }

  Future<void> queryTotalCount() async {
    final fragmentCount = driftDb.fragmentMemoryInfos.id.count();
    final fragmentSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    fragmentSel.where(driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id));
    fragmentSel.addColumns([fragmentCount]);
    totalFragmentCount = (await fragmentSel.getSingle()).read(fragmentCount)!;

    final completedCount = driftDb.fragmentMemoryInfos.id.count();
    final completedSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    completedSel
        .where(driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) & driftDb.fragmentMemoryInfos.study_status.equalsValue(FragmentMemoryInfoStudyStatus.completed));
    completedSel.addColumns([completedCount]);
    totalCompletedCount = (await fragmentSel.getSingle()).read(completedCount)!;

    final reviewingCount = driftDb.fragmentMemoryInfos.id.count();
    final reviewingSel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    reviewingSel
        .where(driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) & driftDb.fragmentMemoryInfos.study_status.equalsValue(FragmentMemoryInfoStudyStatus.reviewing));
    reviewingSel.addColumns([reviewingCount]);
    totalReviewingCount = (await fragmentSel.getSingle()).read(reviewingCount)!;
  }
}

class MemoryGroupListPageAbController extends AbController {
  MemoryGroupListPageAbController({required this.user});

  final User user;
  final RefreshController refreshController = RefreshController(initialRefresh: true);

  final singleMemoryGroupsAb = <Ab<SingleMemoryGroup>>[].ab;

  Future<void> refreshPage() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryGroupOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryGroup> memoryGroups) async {
        singleMemoryGroupsAb.refreshInevitable(
          (obj) => obj
            ..clearBroken(this)
            ..addAll(
              memoryGroups.map((e) => (SingleMemoryGroup(memoryGroup: e)..downloadStatus = DownloadStatus.other_loading).ab),
            ),
        );

        refreshController.refreshCompleted();
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
        refreshController.refreshFailed();
      },
    );

    // 无需 await
    _forOthers();
  }

  Future<void> _forOthers() async {
    bool isSuccess = false;
    final newMemoryAlgorithms = <MemoryAlgorithm>[];
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryAlgorithmOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryAlgorithm> memoryAlgorithms) async {
        newMemoryAlgorithms.addAll(memoryAlgorithms);
        isSuccess = true;
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );

    if (isSuccess) {
      for (var element in singleMemoryGroupsAb()) {
        // 如果记忆模型是被删除掉，则直接赋值为 null
        element().currentSmallCycleInfo.setMemoryAlgorithm = newMemoryAlgorithms.where((mm) => element().memoryGroup.memory_algorithm_id == mm.id).firstOrNull;
        element.refreshForce();

        await element().queryAllSmallCycleInfos();
        element.refreshForce();

        // 无需 await
        _forOtherSingle(mgAndOtherAb: element);
      }
      singleMemoryGroupsAb.refreshForce();
    }
  }

  Future<void> _forOtherSingle({required Ab<SingleMemoryGroup> mgAndOtherAb}) async {
    await _forTotalCount(singleMemoryGroup: mgAndOtherAb());
  }

  /// TODO：当本地总数量与云端总数量相同时，但是存在修改时，该怎么办？
  Future<void> _forTotalCount({required SingleMemoryGroup singleMemoryGroup}) async {
    // 查询本地总数量
    final localTotalCount = await driftDb.generalQueryDAO.queryFragmentMemoryInfosCountByStudyStatus(
      memoryGroupId: singleMemoryGroup.memoryGroup.id,
      studyStatus: null,
    );
    singleMemoryGroup.totalFragmentCount = localTotalCount;
    singleMemoryGroupsAb.refreshForce();

    // 查询云端总数量
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_FRAGMENTS_COUNT_QUERY,
      dtoData: MemoryGroupFragmentsCountQueryDto(
        memory_group_id: singleMemoryGroup.memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryGroupFragmentsCountQueryVo.fromJson,
    );
    await result.handleCode(
      code160201: (String showMessage, vo) async {
        // 数量相关
        if (localTotalCount == 0 && vo.count == 0) {
          singleMemoryGroup.downloadStatus = DownloadStatus.zero;
          singleMemoryGroupsAb.refreshForce();
          return;
        }
        if (localTotalCount == 0 && vo.count > 0) {
          singleMemoryGroup.downloadStatus = DownloadStatus.never_downloaded;
          singleMemoryGroupsAb.refreshForce();
          return;
        }
        if (localTotalCount != vo.count) {
          singleMemoryGroup.downloadStatus = DownloadStatus.different_download;
          singleMemoryGroupsAb.refreshForce();
          return;
        }

        await singleMemoryGroup.queryTotalCount();
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );
  }

  Future<void> onStatusTap(Ab<SingleMemoryGroup> cloneSingleMemoryGroupAb) async {
    await showCustomDialog(
      builder: (ctx) {
        return MemoryGroupGizmoEditPage(
          editPageType: MemoryGroupGizmoEditPageType.modify,
          cloneSingleMemoryGroupAb: cloneSingleMemoryGroupAb,
          listPageC: this,
        );
      },
    );
    // await pushToMemoryGroupGizmoEditPageOfModify(context: context, memoryGroupId: memoryGroupGizmo.id);
    await refreshPage();
  }
}
