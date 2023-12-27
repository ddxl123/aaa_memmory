import 'package:aaa_memory/algorithm_parser/parser.dart';
import 'package:aaa_memory/global/GlobalAbController.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../../../push_page/push_page.dart';
import '../../list/MemoryGroupListPageAbController.dart';

class MemoryGroupGizmoEditPageAbController extends AbController {
  /// 把 gizmo 内所以信息打包成一个对象进行传入。
  /// 如果只传入 [cloneMemoryGroupAndOtherAb] 的话，会缺少 [bSelectedMemoryModelStorage]、[fragmentCountAb] 等，修改它们后， gizmo 外的数据并没有被刷新。
  MemoryGroupGizmoEditPageAbController({
    required this.cloneMemoryGroupAndOtherAb,
    required this.listPageC,
  });

  final MemoryGroupListPageAbController listPageC;

  final Ab<MemoryGroupAndOther> cloneMemoryGroupAndOtherAb;

  final titleTextEditingController = TextEditingController();

  final reviewIntervalTextEditingController = TextEditingController();

  /// 是否全部展开
  final isExpandAll = false.ab;

  @override
  void onDispose() {
    super.onDispose();
    titleTextEditingController.dispose();
    reviewIntervalTextEditingController.dispose();
  }

  @override
  Future<bool> backListener(bool hasRoute) async {
    if (!await checkIsExistModify()) {
      return false;
    }
    bool isBack = false;
    await showCustomDialog(
      builder: (_) => OkAndCancelDialogWidget(
        title: '内容存在修改，是否要丢弃？',
        okText: '丢弃',
        cancelText: '继续编辑',
        text: null,
        onOk: () async {
          SmartDialog.dismiss();
          isBack = true;
        },
        onCancel: () {
          SmartDialog.dismiss();
        },
      ),
    );
    return !isBack;
  }

  @override
  bool get isEnableLoading => true;

  @override
  Widget loadingWidget() => const Material(child: Center(child: Text('加载中...')));

  @override
  void onInit() {
    super.onInit();
    titleTextEditingController.text = cloneMemoryGroupAndOtherAb().memoryGroup.title;
    reviewIntervalTextEditingController.text = timeDifference(
      target: cloneMemoryGroupAndOtherAb().memoryGroup.review_interval,
      start: DateTime.now(),
    ).toString();
  }

  /// 返回 true 则存在修改
  Future<bool> checkIsExistModify() async {
    final mg = await driftDb.generalQueryDAO.queryOrNullMemoryGroup(memoryGroupId: cloneMemoryGroupAndOtherAb().memoryGroup.id);
    if (mg != cloneMemoryGroupAndOtherAb().memoryGroup) {
      return true;
    } else {
      return false;
    }
  }

  /// 验证
  ///
  /// 返回 true，则验证通过。
  bool verify() {
    if (cloneMemoryGroupAndOtherAb().memoryGroup.title.trim() == "") {
      SmartDialog.showToast("名称不能为空");
      return false;
    }
    if (cloneMemoryGroupAndOtherAb().getMemoryAlgorithm == null) {
      SmartDialog.showToast("必须选择一个记忆算法！");
      return false;
    }
    if (cloneMemoryGroupAndOtherAb().getMemoryAlgorithm!.suggest_loop_cycle == null) {
      SmartDialog.showToast("循环周期不能为空！");
      return false;
    }
    // TODO：检查循环周期是否存在变动，获取当前时间点以及对应的循环时间点，如果只存在一个对应的，则直接用这个对应的，如果存在多个对应的，则让用户选择一个对应的。
    // TODO: 进行语法检查
    return true;
  }

  /// 只进行存储。
  Future<bool> onlySave({bool isVerify = true}) async {
    if (isVerify) {
      final result = verify();
      if (!result) {
        return false;
      }
    }
    await driftDb.updateDAO.resetMemoryGroupAutoSyncVersion(entity: cloneMemoryGroupAndOtherAb().memoryGroup);
    cloneMemoryGroupAndOtherAb.refreshForce();
    listPageC.refreshController.requestRefresh();
    return true;
  }

  /// 启动任务
  ///
  /// 启动任务时，会清除该记忆组的全部 记忆周期信息。
  ///
  /// 返回是否启动成功。
  Future<bool> startup() async {
    final result = verify();
    if (!result) {
      return false;
    }
    cloneMemoryGroupAndOtherAb().memoryGroup.start_time = DateTime.now();
    cloneMemoryGroupAndOtherAb().memoryGroup.study_status = StudyStatus.not_study_for_this_cycle;
    await driftDb.updateDAO.resetMemoryGroupAutoSyncVersion(entity: cloneMemoryGroupAndOtherAb().memoryGroup);
    return true;
  }

  /// 开始当前周期
  Future<void> startCurrentCycle() async {
    final isSavedSuccess = await onlySave(isVerify: true);
    if (!isSavedSuccess) {
      return;
    }

    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_CYCLE_INFO_HANDLE_QUERY_LAST_ONE,
      dtoData: MemoryGroupCycleInfoQueryLastOneDto(
        memory_group_id: cloneMemoryGroupAndOtherAb().memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryGroupCycleInfoQueryLastOneVo.fromJson,
    );
    await result.handleCode(
      code200101: (String showMessage, MemoryGroupCycleInfoQueryLastOneVo vo) async {
        final nowCycle = cloneMemoryGroupAndOtherAb().getMemoryAlgorithm!.suggest_loop_cycle!.split(" ").map((e) => int.parse(e)).toList();
        if (nowCycle.isEmpty) {
          throw "循环周期不能为 null！";
        }
        // 变成 4 8 12 23 0 3 8 16 22 3...让其始终在 0~23 之间
        final timePoint = <int>[...nowCycle];
        for (int i = 1; i < timePoint.length; i++) {
          timePoint[i] = timePoint[i - 1] + timePoint[i];
          if (timePoint[i] >= 24) {
            timePoint[i] = timePoint[i] % 24;
          }
        }
        final nowPoint = DateTime.now().hour;
        // 当前时间点在 timePoint 的哪个 index 前。
        final nowInnerIndexs = <int>[];
        for (int i = 1; i < timePoint.length; i++) {
          final left = timePoint[i - 1];
          final current = timePoint[i];
          // 在 4~8 期间
          if (left <= nowPoint && current >= nowPoint) {
            nowInnerIndexs.add(i);
          }
          // 在 23~3 期间
          else if (nowPoint >= left && left >= current) {
            nowInnerIndexs.add(i);
          }
        }

        // 说明在两边闭环期间，或者 timePoint 只有一个
        if (nowInnerIndexs.isEmpty) {
          nowInnerIndexs.add(0);
        }

        int? targetPointIndex;
        // 如果只有一个，则直接赋予这一个
        if (nowInnerIndexs.length == 1) {
          targetPointIndex = nowInnerIndexs.single;
        }
        // 如果有多个
        else {
          // 如果循环周期被修改过，则让用户选择要从哪个小周期开始
          if (vo.memory_group_cycle_info?.loop_cycle != cloneMemoryGroupAndOtherAb().getMemoryAlgorithm!.suggest_loop_cycle) {
            await showCustomDialog(
              builder: (ctx) {
                int? selectIndex;
                return OkAndCancelDialogWidget(
                  text: "由于循环周期发生了更改，因此需要你选择一个小周期作为初始周期，请对下面绿色图标进行选择：",
                  columnChildren: [
                    SingleChildScrollView(
                      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: timePoint.map(
                          (e) {
                            return Column(
                              children: [
                                if (timePoint.indexOf(e) != 0) Text("+${nowCycle[timePoint.indexOf(e)]}"),
                                if (nowInnerIndexs.contains(timePoint.indexOf(e)))
                                  Row(
                                    children: [
                                      Text("————"),
                                      GestureDetector(
                                        child: Icon(Icons.circle_outlined, color: Colors.green),
                                        onTap: () {
                                          selectIndex = timePoint.indexOf(e);
                                        },
                                      ),
                                      Text("————"),
                                      Text(e.toString()),
                                      Text("————"),
                                    ],
                                  ),
                                if (!nowInnerIndexs.contains(timePoint.indexOf(e)))
                                  Row(
                                    children: [Text("————"), Text(e.toString()), Text("————")],
                                  ),
                              ],
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ],
                  okText: "确定",
                  cancelText: "取消",
                  onOk: () {
                    targetPointIndex = selectIndex;
                    SmartDialog.dismiss(status: SmartStatus.dialog);
                  },
                );
              },
            );
          }
        }
        if (targetPointIndex == null) {
          SmartDialog.showToast("已取消选择");
          return;
        }

        final nowDateTime = DateTime.now();
        final shouldEndTime = DateTime(nowDateTime.year, nowDateTime.month, nowDateTime.day);
        final nowHour = nowDateTime.hour;
        if (nowHour < timePoint[targetPointIndex!]) {
          shouldEndTime.add(Duration(hours: timePoint[targetPointIndex!]));
        } else {
          shouldEndTime.add(Duration(days: 1, hours: timePoint[targetPointIndex!]));
        }

        await driftDb.cloudOverwriteLocalDAO.insertCloudMemoryGroupCycleInfoAndOverwriteLocal(
          crtEntity: Crt.memoryGroupCycleInfoEntity(
            creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
            memory_algorithm_id: cloneMemoryGroupAndOtherAb().getMemoryAlgorithm!.id,
            memory_group_id: cloneMemoryGroupAndOtherAb().memoryGroup.id,
            should_end_time: shouldEndTime,
            which_small_cycle: targetPointIndex == 0 ? timePoint.length : targetPointIndex!,
            loop_cycle: cloneMemoryGroupAndOtherAb().getMemoryAlgorithm!.suggest_loop_cycle!,
            should_new_learn_count: cloneMemoryGroupAndOtherAb().memoryGroup.will_new_learn_count,
            should_review_count: cloneMemoryGroupAndOtherAb().reviewIntervalCount,
          ),
          onSuccess: (MemoryGroupCycleInfo memoryGroupCycleInfo) async {
            Navigator.pop(context);
            listPageC.refreshController.requestRefresh();
            await pushToInAppStage(context: context, memoryGroupId: cloneMemoryGroupAndOtherAb().memoryGroup.id);
          },
          onError: (int? code, HttperException httperException, StackTrace st) async {
            logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
          },
        );
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );
  }

  /// 模拟记忆模型的准确性。
  Future<void> simulate() async {
    // TODO:
  }

  Future<void> allDownloadFragmentAndMemoryInfos() async {
    //TODO: 加载框
    SmartDialog.showLoading(msg: "下载中...");
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_MEMORY_GROUP_MEMORY_INFO_DOWNLOAD,
      dtoData: MemoryGroupMemoryInfoDownloadDto(
        memory_group_id: cloneMemoryGroupAndOtherAb().memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryGroupMemoryInfoDownloadVo.fromJson,
      onReceiveProgress: (a, b) {
        //TODO: 为什么 onReceiveProgress 不被调用
        print("~~~~ $a-$b");
      },
    );
    await result.handleCode(
      code160801: (message, vo) async {
        await driftDb.insertDAO.insertManyFragmentAndMemoryInfos(fragmentAndMemoryInfos: vo.fragment_and_memory_infos_list);
        SmartDialog.showToast("下载成功！");
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );

    SmartDialog.dismiss(status: SmartStatus.loading);
    SmartDialog.dismiss(status: SmartStatus.dialog);

    cloneMemoryGroupAndOtherAb.refreshForce();
    listPageC.refreshController.requestRefresh();
  }

  Future<void> differentFragmentAndMemoryInfos() async {
    //TODO: 加载框
    SmartDialog.showLoading(msg: "下载中...");
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_MEMORY_INFO_DOWNLOAD_ONLY_ID,
      dtoData: MemoryInfoDownloadOnlyIdDto(
        memory_group_id: cloneMemoryGroupAndOtherAb().memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryInfoDownloadOnlyIdVo.fromJson,
    );
    await result.handleCode(
      code151601: (String showMessage, vo) async {
        final localAll = (await driftDb.generalQueryDAO.queryMemoryInfoIdAndVersion(memoryGroupId: cloneMemoryGroupAndOtherAb().memoryGroup.id)).toSet();
        final cloudAll = vo.memory_info_id_list.toSet();
        // 定义三个空列表，用来存储结果
        List<int> onlyLocal = []; // 仅存在于本地
        List<int> onlyCloud = []; // 仅存在于云端
        onlyLocal.addAll(localAll.difference(cloudAll));
        onlyCloud.addAll(cloudAll.difference(localAll));

        // 处理仅存在于本地
        await driftDb.batch(
          (batch) async {
            batch.deleteWhere(driftDb.fragmentMemoryInfos, (tbl) => tbl.id.isIn(onlyLocal));
          },
        );

        // 处理仅存在于云端
        final result = await request(
          path: HttpPath.POST__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_MEMORY_GROUP_MEMORY_INFO_DOWNLOAD_BY_INFO_IDS,
          dtoData: MemoryGroupMemoryInfoDownloadByInfoIdsDto(
            memory_info_ids_list: onlyCloud,
            dto_padding_1: null,
          ),
          onReceiveProgress: (count, total) {
            // TODO: 下载中...
          },
          parseResponseVoData: MemoryGroupMemoryInfoDownloadByInfoIdsVo.fromJson,
        );
        await result.handleCode(
          code161701: (String showMessage, MemoryGroupMemoryInfoDownloadByInfoIdsVo vo) async {
            await driftDb.insertDAO.insertManyFragmentAndMemoryInfos(fragmentAndMemoryInfos: vo.fragment_and_memory_infos_list);
          },
        );
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );
    cloneMemoryGroupAndOtherAb.refreshForce();
    SmartDialog.dismiss(status: SmartStatus.loading);
    listPageC.refreshController.requestRefresh();
  }
}
