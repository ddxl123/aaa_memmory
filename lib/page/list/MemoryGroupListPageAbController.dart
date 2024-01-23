import 'package:aaa_memory/page/edit/MemoryGroupGizmoEditPage/MemoryGroupGizmoEditPageAbController.dart';
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
    required this.memoryGroupAndOtherAb,
  }) {
    if (editPageC == null) {
      customOnPressed = () {
        listPageC.onStatusTap(memoryGroupAndOtherAb);
      };
    }
  }

  final MemoryGroupListPageAbController listPageC;
  final MemoryGroupGizmoEditPageAbController? editPageC;
  final Ab<MemoryGroupAndOther> memoryGroupAndOtherAb;
  late final void Function()? customOnPressed;

  @override
  Widget build(BuildContext context) {
    switch (memoryGroupAndOtherAb().downloadStatus) {
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
        throw "未处理 ${memoryGroupAndOtherAb().downloadStatus}";
    }
  }

  Widget allDownloadedWidget() {
    switch (memoryGroupAndOtherAb().memoryGroup.study_status) {
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
                  await editPageC?.startCurrentCycle();
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
                  await editPageC?.startCurrentCycle();
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
        throw "未处理 ${memoryGroupAndOtherAb().memoryGroup.study_status}";
    }
  }
}

class MemoryGroupAndOther {
  MemoryGroupAndOther({required this.memoryGroup});

  /// 注意是查询云端并覆盖本地后的
  final MemoryGroup memoryGroup;

  DownloadStatus downloadStatus = DownloadStatus.other_loading;

  /// 当前记忆组碎片总数量
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalFragmentCount = 0;

  /// 已完成的总数量，注意是查询云端并覆盖本地后的
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalCompleteCount = 0;

  /// 待新学的总数量，注意是查询云端并覆盖本地后的
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalWaitNewLearnCount = 0;

  /// 待复习的总数量，注意是查询云端并覆盖本地后的
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalWaitReviewCount = 0;

  /// 约定全部完成期限的时间点。
  DateTime totalSetCompletionTime = DateTime.now();

  /// 在学时长。
  Duration totalLearnedDuration = Duration.zero;

  /// 当前周期需要学习的数量
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int cycleFragmentCount = 0;

  /// 当前周期已完成的数量，注意是查询云端并覆盖本地后的
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int cycleCompleteCount = 0;

  /// 当前周期待新学的数量，注意是查询云端并覆盖本地后的
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int cycleWaitNewLearnCount = 0;

  /// 当前周期待复习的数量，注意是查询云端并覆盖本地后的
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int cycleWaitReviewCount = 0;

  /// 当前周期约定完成期限的时间点。
  DateTime cycleSetCompletionTime = DateTime.now();

  /// 当前周期在学时长。
  Duration cycleLearnedDuration = Duration.zero;

  (int, int, int, int) get cycleProportion {
    final one = cycleCompleteCount;
    final two = cycleWaitNewLearnCount;
    final three = cycleWaitReviewCount;
    final four = cycleFragmentCount - one - two - three;
    return (one, two, three, four);
  }

  (int, int, int, int) get totalProportion {
    final one = totalCompleteCount;
    final two = totalWaitNewLearnCount;
    final three = totalWaitReviewCount;
    final four = totalFragmentCount - one - two - three;
    return (one, two, three, four);
  }

  /// 当前记忆组的记忆算法，注意是查询云端并覆盖本地后的
  ///
  /// 如果记忆模型是被删除掉而未查询到，则直接赋值为 null
  MemoryAlgorithm? _memoryAlgorithm;

  MemoryAlgorithm? get getMemoryAlgorithm => _memoryAlgorithm;

  set setMemoryAlgorithm(MemoryAlgorithm? newMemoryAlgorithm) {
    _memoryAlgorithm = newMemoryAlgorithm;
    memoryGroup.memory_algorithm_id = _memoryAlgorithm?.id;
  }

  /// 增量数量
  NewAndReviewCount incrementalNewAndReviewCount = NewAndReviewCount(newLearnCount: 0, reviewCount: 0);

  /// 算法结果数量
  ///
  /// 为 -1 表示算法为空或算法计算异常 // TODO：将为空和计算异常分开提示
  NewAndReviewCount algorithmNewAndReviewCount = NewAndReviewCount(newLearnCount: -1, reviewCount: -1);

  /// 算法结果循环周期
  ///
  /// 为 null 表示算法为空或算法计算异常 // TODO：将为空和计算异常分开提示
  LoopCycle? algorithmLoopCycle;

  Future<void> parseOther() async {
    await parseLoopCycleAlgorithm();
    await parseSmallCycleCountForNewAndReviewAlgorithm();
  }

  /// 解析循环周期算法
  Future<void> parseLoopCycleAlgorithm() async {
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
        algorithmLoopCycle = state.result;
      },
      onError: (AlgorithmException ec) async {
        /// TODO：如何给错误提示
        algorithmLoopCycle = null;
      },
    );
  }

  /// 解析当前小周期新学和复习数量算法
  Future<void> parseSmallCycleCountForNewAndReviewAlgorithm() async {
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
        algorithmNewAndReviewCount = state.result;
      },
      onError: (AlgorithmException ec) async {
        algorithmNewAndReviewCount = NewAndReviewCount(newLearnCount: -1, reviewCount: -1);
      },
    );
  }

  MemoryGroupAndOther clone() {
    return MemoryGroupAndOther(memoryGroup: memoryGroup.copyWith())
      ..downloadStatus = downloadStatus
      ..totalFragmentCount = totalFragmentCount
      ..totalWaitNewLearnCount = totalWaitNewLearnCount
      ..setMemoryAlgorithm = getMemoryAlgorithm?.copyWith();
  }
}

class MemoryGroupListPageAbController extends AbController {
  MemoryGroupListPageAbController({required this.user});

  final User user;
  final RefreshController refreshController = RefreshController(initialRefresh: true);

  final memoryGroupAndOthersAb = <Ab<MemoryGroupAndOther>>[].ab;

  Future<void> refreshPage() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryGroupOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryGroup> memoryGroups) async {
        memoryGroupAndOthersAb.refreshInevitable(
          (obj) => obj
            ..clearBroken(this)
            ..addAll(
              memoryGroups.map((e) => (MemoryGroupAndOther(memoryGroup: e)..downloadStatus = DownloadStatus.other_loading).ab),
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
      for (var element in memoryGroupAndOthersAb()) {
        // 如果记忆模型是被删除掉，则直接赋值为 null
        element().setMemoryAlgorithm = newMemoryAlgorithms.where((mm) => element().memoryGroup.memory_algorithm_id == mm.id).firstOrNull;
        element.refreshForce();

        await element().parseOther();
        element.refreshForce();

        // 无需 await
        _forOtherSingle(mgAndOtherAb: element);
      }
      memoryGroupAndOthersAb.refreshForce();
    }
  }

  Future<void> _forOtherSingle({required Ab<MemoryGroupAndOther> mgAndOtherAb}) async {
    await _forTotalCount(memoryGroupAndOther: mgAndOtherAb());
  }

  /// TODO：当本地总数量与云端总数量相同时，但是存在修改时，该怎么办？
  Future<void> _forTotalCount({required MemoryGroupAndOther memoryGroupAndOther}) async {
    // 查询本地总数量
    final localTotalCount = await driftDb.generalQueryDAO.queryFragmentInMemoryGroupCount(memoryGroupId: memoryGroupAndOther.memoryGroup.id);
    memoryGroupAndOther.totalFragmentCount = localTotalCount;
    memoryGroupAndOthersAb.refreshForce();

    // 查询云端总数量
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_FRAGMENTS_COUNT_QUERY,
      dtoData: MemoryGroupFragmentsCountQueryDto(
        memory_group_id: memoryGroupAndOther.memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryGroupFragmentsCountQueryVo.fromJson,
    );
    await result.handleCode(
      code160201: (String showMessage, vo) async {
        // 数量相关
        if (localTotalCount == 0 && vo.count == 0) {
          memoryGroupAndOther.downloadStatus = DownloadStatus.zero;
          memoryGroupAndOthersAb.refreshForce();
          return;
        }
        if (localTotalCount == 0 && vo.count > 0) {
          memoryGroupAndOther.downloadStatus = DownloadStatus.never_downloaded;
          memoryGroupAndOthersAb.refreshForce();
          return;
        }
        if (localTotalCount != vo.count) {
          memoryGroupAndOther.downloadStatus = DownloadStatus.different_download;
          memoryGroupAndOthersAb.refreshForce();
          return;
        }

        await _forRemainNeverStudyCount(memoryGroupAndOther: memoryGroupAndOther);
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );
  }

  Future<void> _forRemainNeverStudyCount({required MemoryGroupAndOther memoryGroupAndOther}) async {
    final count = await driftDb.generalQueryDAO.queryManyFragmentByStudyStatusCount(
      memoryGroupId: memoryGroupAndOther.memoryGroup.id,
      studyStatus: FragmentMemoryInfoStudyStatus.never,
    );
    memoryGroupAndOther.totalWaitNewLearnCount = count;
    memoryGroupAndOther.downloadStatus = DownloadStatus.all_downloaded;
    memoryGroupAndOthersAb.refreshForce();
  }

  Future<void> onStatusTap(Ab<MemoryGroupAndOther> cloneMemoryGroupAndOtherAb) async {
    await showCustomDialog(
      builder: (ctx) {
        return MemoryGroupGizmoEditPage(
          editPageType: MemoryGroupGizmoEditPageType.modify,
          cloneMemoryGroupAndOtherAb: cloneMemoryGroupAndOtherAb,
          listPageC: this,
        );
      },
    );
    // await pushToMemoryGroupGizmoEditPageOfModify(context: context, memoryGroupId: memoryGroupGizmo.id);
    await refreshPage();
  }
}
