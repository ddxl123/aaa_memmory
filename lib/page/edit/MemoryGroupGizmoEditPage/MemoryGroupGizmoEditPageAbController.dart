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

  /// 只进行存储。
  Future<bool> onlySave() async {
    if (cloneMemoryGroupAndOtherAb().memoryGroup.title.trim() == "") {
      SmartDialog.showToast("名称不能为空");
      return false;
    }
    if (!await checkIsExistModify()) {
      SmartDialog.showToast("无修改");
      return true;
    }
    await driftDb.updateDAO.resetMemoryGroupAutoSyncVersion(entity: cloneMemoryGroupAndOtherAb().memoryGroup);
    cloneMemoryGroupAndOtherAb.refreshForce();
    listPageC.refreshController.requestRefresh();
    return true;
  }

  Future<void> clickStart() async {
    if (cloneMemoryGroupAndOtherAb().memoryGroup.review_interval.difference(DateTime.now()).inSeconds < 600) {
      SmartDialog.showToast("复习区间至少10分钟(600秒)以上哦~");
      return;
    }
    if (cloneMemoryGroupAndOtherAb().getMemoryAlgorithm == null) {
      SmartDialog.showToast("必须选择一个记忆算法！");
      return;
    }
    if (cloneMemoryGroupAndOtherAb().totalFragmentCount == 0) {
      SmartDialog.showToast("碎片数量不能为 0");
      return;
    }

    cloneMemoryGroupAndOtherAb().memoryGroup.start_time = DateTime.now();
    final isSavedSuccess = await onlySave();
    if (!isSavedSuccess) {
      return;
    }
    Navigator.pop(context);
    await pushToInAppStage(context: context, memoryGroupId: cloneMemoryGroupAndOtherAb().memoryGroup.id);
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
