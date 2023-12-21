import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:flutter/material.dart';
import 'package:tools/tools.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';

import '../global/GlobalAbController.dart';

/// 创建记忆模型的 dialog。
Future<void> showCreateMemoryModelDialog() async {
  await showCustomDialog(
    builder: (_) {
      return TextField1DialogWidget(
        title: '创建记忆算法：',
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
          await driftDb.cloudOverwriteLocalDAO.insertCloudMemoryModelAndOverwriteLocal(
            crtEntity: Crt.memoryModelEntity(
              title: tec.text.trim(),
              creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
              father_memory_model_id: null,
              button_algorithm: null,
              button_algorithm_remark: null,
              familiarity_algorithm: null,
              familiarity_algorithm_remark: null,
              next_time_algorithm: null,
              next_time_algorithm_remark: null,
            ),
            onSuccess: (MemoryModel memoryModel) async {
              SmartDialog.dismiss(status: SmartStatus.dialog);
              SmartDialog.showToast('创建成功！');
            },
            onError: (int? code, HttperException httperException, StackTrace st) async {
              logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
            },
          );
        },
      );
    },
  );
}
