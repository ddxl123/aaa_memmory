import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:flutter/material.dart';
import 'package:tools/tools.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../global/GlobalAbController.dart';
import '../page/list/MemoryGroupListPage/MemoryGroupListPageAbController.dart';

/// 创建记忆组的 dialog。
Future<void> showCreateMemoryGroupDialog() async {
  await showCustomDialog(
    builder: (_) {
      return TextField1DialogWidget(
        title: '创建记忆组：',
        okText: '创建',
        cancelText: '取消',
        text: null,
        inputDecoration: InputDecoration(hintText: '请输入名称'),
        onCancel: () {
          SmartDialog.dismiss();
        },
        onOk: (tec) async {
          if (tec.text.trim().isEmpty) {
            SmartDialog.showToast('名称不能为空！');
            return;
          }
          await driftDb.cloudOverwriteLocalDAO.insertCloudMemoryGroupAndOverwriteLocal(
            crtEntity: Crt.memoryGroupEntity(
              start_time: null,
              memory_algorithm_id: null,
              title: tec.text.trim(),
              new_review_display_order: NewReviewDisplayOrder.mix,
              new_display_order: NewDisplayOrder.random,
              review_display_order: ReviewDisplayOrder.expire_first,
              creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
              sync_version: 0,
              be_synced: false,
              study_status: StudyStatus.not_startup,
            ),
            onSuccess: (result) async {
              Aber.findOrNullLast<MemoryGroupListPageAbController>()?.refreshPage();
              SmartDialog.dismiss(status: SmartStatus.dialog);
              SmartDialog.showToast('创建成功！');
            },
            onError: (a, b, c) async {
              logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
            },
          );
        },
      );
    },
  );
}
