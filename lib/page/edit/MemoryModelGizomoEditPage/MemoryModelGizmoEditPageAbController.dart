import 'dart:async';

import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/material.dart';
import 'package:tools/tools.dart';

class MemoryModelGizmoEditPageAbController extends AbController {
  MemoryModelGizmoEditPageAbController({
    required this.memoryModel,
  });

  final MemoryModel memoryModel;

  final titleEditingController = TextEditingController();

  // final enterType = Ab<EnterType?>(null);

  final isAlgorithmKeyboard = false.ab;

  @override
  void onInit() {
    super.onInit();
    titleEditingController.text = memoryModel.title;
  }

  @override
  Future<bool> backListener(bool hasRoute) async {
    bool isBack = false;
    await showCustomDialog(
      builder: (_) => OkAndCancelDialogWidget(
        title: '若存在修改，则将其丢弃？',
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

  /// 将 [copyMemoryModelAb] 的数据传递给 [memoryModel]，并对数据库进行修改。
  Future<void> updateSave() async {
    await driftDb.cloudOverwriteLocalDAO.updateCloudMemoryModelAndOverwriteLocal(
      memoryModel: memoryModel,
      onSuccess: (MemoryModel memoryModel) async {
        SmartDialog.showToast("保存成功！");
        Navigator.pop(context);
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );
  }

  void changeKeyword() {
    isAlgorithmKeyboard.refreshEasy((oldValue) => !oldValue);
    final pf = FocusManager.instance.primaryFocus;
    if (pf == null) return;
    pf.unfocus();
    Future.delayed(const Duration(milliseconds: 100), () => pf.requestFocus());
  }
}
