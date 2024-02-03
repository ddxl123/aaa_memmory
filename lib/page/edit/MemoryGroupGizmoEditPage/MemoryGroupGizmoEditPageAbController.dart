import 'package:aaa_memory/algorithm_parser/parser.dart';
import 'package:aaa_memory/global/GlobalAbController.dart';
import 'package:aaa_memory/page/list/MemoryGroupListPage/SmallCycleInfo.dart';
import 'package:aaa_memory/page/list/MemoryGroupListPage/StatusButton.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:tools/tools.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:intl/intl.dart';

import '../../../algorithm_parser/AlgorithmException.dart';
import '../../../push_page/push_page.dart';
import '../../list/MemoryGroupListPage/MemoryGroupListPageAbController.dart';
import '../../list/MemoryGroupListPage/SingleMemoryGroup.dart';

class MemoryGroupGizmoEditPageAbController extends AbController {
  /// 把 gizmo 内所以信息打包成一个对象进行传入。
  /// 如果只传入 [cloneSingleMemoryGroup] 的话，会缺少 [bSelectedMemoryModelStorage]、[fragmentCountAb] 等，修改它们后， gizmo 外的数据并没有被刷新。
  MemoryGroupGizmoEditPageAbController({
    required this.cloneSingleMemoryGroup,
    required this.listPageC,
  });

  final MemoryGroupListPageAbController listPageC;

  final Ab<SingleMemoryGroup> cloneSingleMemoryGroup;

  CurrentSmallCycleInfo? get currentSmallCycleInfo => cloneSingleMemoryGroup().currentSmallCycleInfo;

  final titleTextEditingController = TextEditingController();

  /// 是否全部展开
  final isExpandAll = false.ab;

  @override
  void onInit() {
    super.onInit();
    titleTextEditingController.text = cloneSingleMemoryGroup().memoryGroup.title;
  }

  @override
  void onDispose() {
    super.onDispose();
    titleTextEditingController.dispose();
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

  /// 返回 true 则存在修改
  Future<bool> checkIsExistModify() async {
    final mg = await driftDb.generalQueryDAO.querySingleOrNullById(tableInfo: driftDb.memoryGroups, id: cloneSingleMemoryGroup().memoryGroup.id);
    if (mg != cloneSingleMemoryGroup().memoryGroup) {
      return true;
    } else {
      return false;
    }
  }

  /// 仅保存时的验证。
  ///
  /// 返回 true，则验证通过。
  bool verifyForOnlySave() {
    if (cloneSingleMemoryGroup().memoryGroup.title.trim() == "") {
      SmartDialog.showToast("名称不能为空");
      return false;
    }
    // TODO：检查循环周期是否存在变动，获取当前时间点以及对应的循环时间点，如果只存在一个对应的，则直接用这个对应的，如果存在多个对应的，则让用户选择一个对应的。
    // TODO：进行语法检查
    return true;
  }

  /// 重新读取，并启动记忆组时的验证。
  ///
  /// 返回 true，则验证通过。
  bool verifyForStartup() {
    // TODO：是否需要重新读取
    if (cloneSingleMemoryGroup().memoryGroup.title.trim() == "") {
      SmartDialog.showToast("名称不能为空");
      return false;
    }
    if (currentSmallCycleInfo?.getMemoryAlgorithm == null) {
      SmartDialog.showToast("必须选择一个记忆算法！");
      return false;
    }
    if (currentSmallCycleInfo?.loopCycle == null) {
      SmartDialog.showToast("循环周期不能为空！");
      return false;
    }
    if (currentSmallCycleInfo?.shouldNewAndReviewCount == null || currentSmallCycleInfo?.learnedThirdNewAndReviewCount == null) {
      SmartDialog.showToast("数量不能为空！");
      return false;
    }
    // TODO：检查循环周期是否存在变动，获取当前时间点以及对应的循环时间点，如果只存在一个对应的，则直接用这个对应的，如果存在多个对应的，则让用户选择一个对应的。
    // TODO：进行语法检查
    return true;
  }

  /// 重新读取，并开始新的小周期时的验证。
  ///
  /// 返回 true，则验证通过。
  Future<bool> verifyForCreateSmallCycle() async {
    await currentSmallCycleInfo?.read();
    if (cloneSingleMemoryGroup().memoryGroup.title.trim() == "") {
      SmartDialog.showToast("名称不能为空");
      return false;
    }
    if (currentSmallCycleInfo?.getMemoryAlgorithm == null) {
      SmartDialog.showToast("必须选择一个记忆算法！");
      return false;
    }
    if (currentSmallCycleInfo?.loopCycle == null) {
      SmartDialog.showToast("循环周期不能为空！");
      return false;
    }
    if (currentSmallCycleInfo?.shouldNewAndReviewCount == null || currentSmallCycleInfo?.learnedThirdNewAndReviewCount == null) {
      SmartDialog.showToast("数量不能为空！");
      return false;
    }
    // TODO：检查循环周期是否存在变动，获取当前时间点以及对应的循环时间点，如果只存在一个对应的，则直接用这个对应的，如果存在多个对应的，则让用户选择一个对应的。
    // TODO：进行语法检查
    return true;
  }

  /// 重新读取，并继续当前小周期时的验证。
  Future<bool> verifyForContinueCurrentSmallCycle() async {
    await currentSmallCycleInfo?.read();

    if (cloneSingleMemoryGroup().memoryGroup.title.trim() == "") {
      SmartDialog.showToast("名称不能为空");
      return false;
    }
    if (currentSmallCycleInfo?.getMemoryAlgorithm == null) {
      SmartDialog.showToast("必须选择一个记忆算法！");
      return false;
    }

    if (currentSmallCycleInfo?.loopCycle == null) {
      SmartDialog.showToast("循环周期不能为空！");
      return false;
    }
    if (currentSmallCycleInfo?.shouldNewAndReviewCount == null || currentSmallCycleInfo?.learnedThirdNewAndReviewCount == null) {
      SmartDialog.showToast("数量不能为空！");
      return false;
    }
    // TODO：检查循环周期是否存在变动，获取当前时间点以及对应的循环时间点，如果只存在一个对应的，则直接用这个对应的，如果存在多个对应的，则让用户选择一个对应的。
    // TODO：进行语法检查
    return true;
  }

  /// 只进行存储。
  Future<bool> onlySave() async {
    bool isVerify = verifyForOnlySave();
    if (!isVerify) {
      return false;
    }
    await driftDb.updateDAO.resetMemoryGroupAutoSyncVersion(entity: cloneSingleMemoryGroup().memoryGroup);
    cloneSingleMemoryGroup.refreshForce();
    listPageC.refreshController.requestRefresh();
    return true;
  }

  /// 启动任务
  ///
  /// 启动任务时，会清除该记忆组的全部 记忆周期信息。
  ///
  /// 返回是否启动成功。
  Future<bool> startup() async {
    final result = verifyForStartup();
    if (!result) {
      return false;
    }
    // TODO：检查启动时，是否已存在记忆信息，如果存在，则需要提醒用户清除，或者重写创建一个记忆组。
    cloneSingleMemoryGroup().memoryGroup.start_time = DateTime.now();
    cloneSingleMemoryGroup().memoryGroup.study_status = StudyStatus.not_study_for_this_cycle;
    await driftDb.updateDAO.resetMemoryGroupAutoSyncVersion(entity: cloneSingleMemoryGroup().memoryGroup);
    cloneSingleMemoryGroup.refreshForce();
    return true;
  }

  /// 创建或继续小周期
  Future<void> createOrContinueSmallCycle() async {
    // 如果为 true，则为创建，如果为 false，则为继续
    bool isCreate = cloneSingleMemoryGroup().currentSmallCycleInfo!.memoryGroupSmartCycleInfo == null;

    if (isCreate) {
      final isVerifySuccess = await verifyForCreateSmallCycle();
      if (!isVerifySuccess) {
        return;
      }
    } else {
      // 验证的是原来小周期修改后的
      final isVerifySuccess = await verifyForContinueCurrentSmallCycle();
      if (!isVerifySuccess) {
        return;
      }
    }

    // 查询云端的，即修改前的
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_CYCLE_INFO_HANDLE_QUERY_CURRENT_MEMORY_GROUP_SMALL_CYCLE_INFO,
      dtoData: QueryCurrentMemoryGroupSmallCycleInfoDto(
        memory_group_id: cloneSingleMemoryGroup().memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: QueryCurrentMemoryGroupSmallCycleInfoVo.fromJson,
    );
    await result.handleCode(
      code200101: (String showMessage, QueryCurrentMemoryGroupSmallCycleInfoVo vo) async {
        // 新设置的循环周期
        final newCycleSettingAlgorithm = cloneSingleMemoryGroup().currentSmallCycleInfo!.getMemoryAlgorithm!.suggest_loop_cycle_algorithm!;
        late final LoopCycle newLoopCycle;
        await AlgorithmParser.parse(
          stateFunc: () => SuggestLoopCycleState(
            algorithmWrapper: AlgorithmWrapper.fromJsonString(newCycleSettingAlgorithm),
            // TODO: 改成 SimulationType.external 类型
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          ),
          onSuccess: (SuggestLoopCycleState state) async {
            newLoopCycle = state.result;
          },
          onError: (AlgorithmException ec) async {
            throw ec;
          },
        );

        // 当前周期所设置的循环周期
        // 这个为 null 说明当前不存在正在执行的小周期
        final oldLoopCycleSetting = vo.memory_group_small_cycle_info?.loop_cycle;
        final LoopCycle? oldLoopCycle = oldLoopCycleSetting == null ? null : LoopCycle.fromText(text: oldLoopCycleSetting);

        final List<SmallCycle> targets = newLoopCycle.nowBeforeWhich();

        SmallCycle? target;
        // 第几个可选的 00:00 前
        DateTime? selectedDateTime;

        // 如果只有一个，则直接赋予这一个
        if (targets.length == 1) {
          target = targets.single;
        }
        // 如果有多个
        else {
          // 如果循环周期被修改过，则让用户选择要从哪个小周期开始
          // 如果 oldLoopCycle 为 null，也按照已修改的处理方式进行处理
          if (!newLoopCycle.equal(target: oldLoopCycle)) {
            final controller = ScrollController();
            SmallCycle? tempSelected;
            DateTime? tempSelectedDateTime;
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
                            "原循环周期：$oldLoopCycleSetting",
                            style: TextStyle(color: Colors.grey, decoration: TextDecoration.lineThrough),
                          ),
                        ),
                      ],
                    ),
                    Row(children: [Expanded(child: Text("现循环周期：${newLoopCycle.toText()}", style: TextStyle(color: Colors.green)))]),
                    SizedBox(height: 10),
                    Row(children: [Expanded(child: Text("请点击橙色字体对区间进行选择", style: TextStyle(color: Colors.grey)))]),
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
                              ...newLoopCycle.completeSmallCycles.map(
                                (e) {
                                  final zeroList = e.cross0PointFromLastForNowCount();
                                  return Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (e.rawDelta != null) Text("+${e.rawDelta}", style: TextStyle(color: Colors.green)),
                                      Row(
                                        children: [
                                          Text("——", style: TextStyle(color: Colors.grey)),
                                          for (int i = 0; i < zeroList.length; i++)
                                            Row(
                                              children: [
                                                Text(zeroList[i].$2 ? "00:00——" : "——", style: TextStyle(color: Colors.grey)),
                                                GestureDetector(
                                                  child: Text("选择", style: TextStyle(color: Colors.orange)),
                                                  onTap: () {
                                                    tempSelected = e;
                                                    tempSelectedDateTime = zeroList[i].$1;
                                                  },
                                                ),
                                                Text(zeroList.length == 1 && zeroList[i].$2 ? "——" : "——00:00", style: TextStyle(color: Colors.grey)),
                                              ],
                                            ),
                                          Text("——", style: TextStyle(color: Colors.grey)),
                                          Text(e.cumulative24Sys.toString(), style: TextStyle(color: Theme.of(context).primaryColor)),
                                          Text("————", style: TextStyle(color: Colors.grey)),
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
                    Text("已选择第 ${tempSelected?.order ?? "[未选择]"} 个小周期"),
                  ],
                  okText: "确定",
                  cancelText: "取消",
                  onOk: () {
                    target = tempSelected;
                    selectedDateTime = tempSelectedDateTime;
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
        NewAndReviewCount? shouldNewAndReviewCount = NewAndReviewCount(newCount: 0, reviewCount: 0);
        await AlgorithmParser.parse(
          stateFunc: () => SuggestCountForNewAndReviewState(
            algorithmWrapper: AlgorithmWrapper.fromJsonString(cloneSingleMemoryGroup().currentSmallCycleInfo!.getMemoryAlgorithm!.suggest_count_for_new_and_review_algorithm!),
            // TODO: 改成 SimulationType.external
            simulationType: SimulationType.syntaxCheck,
            externalResultHandler: null,
          ),
          onSuccess: (SuggestCountForNewAndReviewState state) async {
            shouldNewAndReviewCount = state.result;
          },
          onError: (AlgorithmException ec) async {
            shouldNewAndReviewCount = null;
            logger.outError(show: ec.error, stackTrace: ec.stackTrace);
          },
        );
        if (shouldNewAndReviewCount == null) {
          return;
        }

        late final int loopCycleOrder;

        final newMemoryGroupSmallCycleInfo = Crt.memoryGroupSmartCycleInfoEntity(
          creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
          memory_algorithm_id: cloneSingleMemoryGroup().currentSmallCycleInfo!.getMemoryAlgorithm!.id,
          memory_group_id: cloneSingleMemoryGroup().memoryGroup.id,
          loop_cycle: newLoopCycle.toText(),
          small_cycle_order: target!.order,
          loop_cycle_order: newLoopCycle.getLoopCycleOrder(target!),
          should_small_cycle_end_time: selectedDateTime!,
          should_new_learn_count: shouldNewAndReviewCount!.newCount,
          should_review_count: shouldNewAndReviewCount!.reviewCount,
          incremental_new_learn_count: cloneSingleMemoryGroup().currentSmallCycleInfo!.shouldIncrementalNewAndReviewCount.newCount,
          incremental_review_count: cloneSingleMemoryGroup().currentSmallCycleInfo!.shouldIncrementalNewAndReviewCount.reviewCount,
        );
        if (vo.memory_group_small_cycle_info == null) {
          await driftDb.cloudOverwriteLocalDAO.insertCloudMemoryGroupSmallCycleInfoAndOverwriteLocal(
            crtEntity: newMemoryGroupSmallCycleInfo,
            onSuccess: (MemoryGroupSmartCycleInfo memoryGroupSmartCycleInfo) async {
              cloneSingleMemoryGroup().memoryGroup.study_status = StudyStatus.studying_for_this_cycle;
              SmartDialog.showLoading(msg: "保存中...");
              await onlySave();
              await listPageC.refreshPage();
              SmartDialog.dismiss(status: SmartStatus.loading);
              SmartDialog.showToast("保存成功！");

              Navigator.pop(context);
              await pushToInAppStage(context: context, memoryGroupId: cloneSingleMemoryGroup().memoryGroup.id);
            },
            onError: (int? code, HttperException httperException, StackTrace st) async {
              logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
            },
          );
        } else {
          await driftDb.cloudOverwriteLocalDAO.updateCloudMemoryGroupSmallCycleInfoAndOverwriteLocal(
            memoryGroupSmartCycleInfo: newMemoryGroupSmallCycleInfo..id = cloneSingleMemoryGroup().currentSmallCycleInfo!.memoryGroupSmartCycleInfo!.id,
            onSuccess: (MemoryGroupSmartCycleInfo memoryGroupSmartCycleInfo) async {
              SmartDialog.showLoading(msg: "保存中...");
              await onlySave();
              await listPageC.refreshPage();
              SmartDialog.dismiss(status: SmartStatus.loading);
              SmartDialog.showToast("保存成功！");

              Navigator.pop(context);
              await pushToInAppStage(context: context, memoryGroupId: cloneSingleMemoryGroup().memoryGroup.id);
            },
            onError: (int? code, HttperException httperException, StackTrace st) async {
              logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
            },
          );
        }
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
        memory_group_id: cloneSingleMemoryGroup().memoryGroup.id,
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
        cloneSingleMemoryGroup().downloadStatus = DownloadStatus.all_downloaded;
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );

    SmartDialog.dismiss(status: SmartStatus.loading);
    SmartDialog.dismiss(status: SmartStatus.dialog);
    SmartDialog.dismiss(status: SmartStatus.dialog);

    cloneSingleMemoryGroup.refreshForce();
    listPageC.refreshController.requestRefresh();
  }

  Future<void> differentFragmentAndMemoryInfos() async {
    //TODO: 加载框
    SmartDialog.showLoading(msg: "下载中...");
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_MEMORY_INFO_DOWNLOAD_ONLY_ID,
      dtoData: MemoryInfoDownloadOnlyIdDto(
        memory_group_id: cloneSingleMemoryGroup().memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryInfoDownloadOnlyIdVo.fromJson,
    );
    await result.handleCode(
      code151601: (String showMessage, vo) async {
        final localAll = (await driftDb.generalQueryDAO.queryMemoryInfoIdAndVersion(memoryGroupId: cloneSingleMemoryGroup().memoryGroup.id)).toSet();
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
    cloneSingleMemoryGroup.refreshForce();
    SmartDialog.dismiss(status: SmartStatus.loading);
    listPageC.refreshController.requestRefresh();
  }
}
