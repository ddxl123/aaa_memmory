import 'package:aaa_memory/algorithm_parser/parser.dart';
import 'package:aaa_memory/global/GlobalAbController.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';

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

    if (cloneMemoryGroupAndOtherAb().loopCycle == null) {
      SmartDialog.showToast("循环周期不能为空！");
      return false;
    }
    // TODO：检查循环周期是否存在变动，获取当前时间点以及对应的循环时间点，如果只存在一个对应的，则直接用这个对应的，如果存在多个对应的，则让用户选择一个对应的。
    // TODO：进行语法检查
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
    // TODO：检查启动时，是否已存在记忆信息，如果存在，则需要提醒用户清除，或者重写创建一个记忆组。
    cloneMemoryGroupAndOtherAb().memoryGroup.start_time = DateTime.now();
    cloneMemoryGroupAndOtherAb().memoryGroup.study_status = StudyStatus.not_study_for_this_cycle;
    await driftDb.updateDAO.resetMemoryGroupAutoSyncVersion(entity: cloneMemoryGroupAndOtherAb().memoryGroup);
    cloneMemoryGroupAndOtherAb.refreshForce();
    return true;
  }

  /// 开始本周期
  Future<void> startCurrentCycle() async {
    final isVerifySuccess = verify();
    if (!isVerifySuccess) {
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
        LoopCycle;
        // 当前周期所设置的循环周期
        final oldCycleSetting = vo.memory_group_cycle_info?.loop_cycle;
        // 新设置的循环周期
        final newCycleSetting = cloneMemoryGroupAndOtherAb().getMemoryAlgorithm!.suggest_loop_cycle_algorithm!;

        final LoopCycle? oldCycle = oldCycleSetting == null ? null : LoopCycle.fromText(text: oldCycleSetting);
        final LoopCycle newCycle = LoopCycle.fromText(text: newCycleSetting);
        final List<SmallCycle> targets = newCycle.nowBeforeWhich();

        SmallCycle? target;
        // 如果只有一个，则直接赋予这一个
        if (targets.length == 1) {
          target = targets.single;
        }
        // 如果有多个
        else {
          // 如果循环周期被修改过，则让用户选择要从哪个小周期开始
          if (!newCycle.equal(target: oldCycle)) {
            final controller = ScrollController();
            SmallCycle? selected;
            await showCustomDialog(
              stfBuilder: (ctx, r) {
                return OkAndCancelDialogWidget(
                  columnChildren: [
                    Row(
                      children: [
                        Expanded(
                          child: Text("由于循环周期发生了更改，因此需要你选择一个小周期作为初始周期："),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "原循环周期：${oldCycleSetting ?? "无"}",
                            style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [Expanded(child: Text("现循环周期：${newCycleSetting}", style: TextStyle(color: Colors.green)))]),
                    SizedBox(height: 10),
                    Row(children: [Expanded(child: Text("请点击橙色圆圈对区间进行选择", style: TextStyle(color: Colors.grey)))]),
                    Container(
                      decoration: BoxDecoration(border: Border.all(color: Theme.of(context).primaryColor)),
                      child: Scrollbar(
                        controller: controller,
                        thumbVisibility: true,
                        child: SingleChildScrollView(
                          controller: controller,
                          padding: EdgeInsets.all(10),
                          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              ...newCycle.completeSmallCycles.map(
                                (e) {
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (e.rawDelta != null) Text("+${e.rawDelta}", style: TextStyle(color: Colors.green)),
                                      Row(
                                        children: [
                                          Text("———", style: TextStyle(color: Colors.grey)),
                                          Text(e.cumulative24Sys.toString(), style: TextStyle(color: Theme.of(context).primaryColor)),
                                          Text("———", style: TextStyle(color: Colors.grey)),
                                        ],
                                      ),
                                      if (e.rawDelta == null) Text("", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                      if (e.rawDelta != null) Text(e.order.toString(), style: TextStyle(color: Colors.grey, fontSize: 12)),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            "当前时间：${DateFormat("y/M/d H:mm").format(DateTime.now())}",
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Text("已选择第 ${selected?.order ?? "[未选择]"} 个小周期"),
                  ],
                  okText: "确定",
                  cancelText: "取消",
                  onOk: () {
                    target = selected;
                    SmartDialog.dismiss(status: SmartStatus.dialog);
                  },
                );
              },
            );
            controller.dispose();
          }
        }
        if (target == null) {
          SmartDialog.showToast("已取消选择");
          return;
        }

        await driftDb.cloudOverwriteLocalDAO.insertCloudMemoryGroupCycleInfoAndOverwriteLocal(
          crtEntity: Crt.memoryGroupSmartCycleInfoEntity(
            creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
            memory_algorithm_id: cloneMemoryGroupAndOtherAb().getMemoryAlgorithm!.id,
            memory_group_id: cloneMemoryGroupAndOtherAb().memoryGroup.id,
            loop_cycle: cloneMemoryGroupAndOtherAb().loopCycle!.toText(),
            small_cycle_order: target!.order,
            small_cycle_should_new_learn_count: cloneMemoryGroupAndOtherAb().memoryGroup.will_new_learn_count,
            small_cycle_should_review_count: cloneMemoryGroupAndOtherAb().reviewIntervalCount,
          ),
          onSuccess: (MemoryGroupSmartCycleInfo memoryGroupSmartCycleInfo) async {
            // TODO: 在这之前得有个加载界面
            cloneMemoryGroupAndOtherAb().memoryGroup.study_status = StudyStatus.studying_for_this_cycle;
            await onlySave(isVerify: false);

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
