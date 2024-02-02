import 'package:drift_main/share_common/share_enum.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';

import '../../edit/MemoryGroupGizmoEditPage/MemoryGroupGizmoEditPageAbController.dart';
import 'MemoryGroupListPageAbController.dart';
import 'SingleMemoryGroup.dart';

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
