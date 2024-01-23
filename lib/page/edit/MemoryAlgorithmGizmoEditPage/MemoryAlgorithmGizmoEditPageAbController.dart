import 'dart:convert';

import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/SingleQuillController.dart';
import 'package:aaa_memory/page/list/MemoryAlgorithmListPageAbController.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:flutter/material.dart';
import 'package:tools/tools.dart';

class MemoryAlgorithmGizmoEditPageAbController extends AbController {
  MemoryAlgorithmGizmoEditPageAbController({
    required this.cloneMemoryAlgorithmAb,
  });

  final Ab<MemoryAlgorithm> cloneMemoryAlgorithmAb;

  final memoryAlgorithmListPageAbController = Aber.findOrNullLast<MemoryAlgorithmListPageAbController>();

  final titleEditingController = TextEditingController();

  final explainContentSingleQuillController = SingleQuillController();

  // final enterType = Ab<EnterType?>(null);

  final isAlgorithmKeyboard = false.ab;

  @override
  void onInit() {
    super.onInit();
    titleEditingController.text = cloneMemoryAlgorithmAb().title;
    explainContentSingleQuillController.resetContent(cloneMemoryAlgorithmAb().explain_content);
  }

  @override
  Future<bool> backListener(bool hasRoute) async {
    if (hasRoute) {
      return false;
    }

    final oldMa = await driftDb.generalQueryDAO.queryOrNullMemoryAlgorithm(memoryModelId: cloneMemoryAlgorithmAb().id);
    if (oldMa == null) {
      SmartDialog.showToast("当前记忆算法不存在！");
      return false;
    }
    bool isBack = false;
    if (oldMa != cloneMemoryAlgorithmAb()) {
      await showCustomDialog(
        builder: (_) => OkAndCancelDialogWidget(
          title: '存在修改，是否保存？',
          okText: '保存',
          cancelText: '丢弃',
          onOk: () async {
            SmartDialog.dismiss();
            final isSaved = await save();
            isBack = isSaved;
          },
          onCancel: () {
            SmartDialog.dismiss();
            isBack = true;
          },
        ),
      );
    } else {
      isBack = true;
    }
    return !isBack;
  }

  /// 返回是否保存成功
  Future<bool> save() async {
    bool isSaved = false;

    // TODO：不知道为什么 updated_at 总是不一样
    // final oldMa = await driftDb.generalQueryDAO.queryOrNullMemoryAlgorithm(memoryModelId: memoryAlgorithmAb().id);
    // print(oldMa);
    // print(memoryAlgorithmAb());

    await driftDb.cloudOverwriteLocalDAO.updateCloudMemoryAlgorithmAndOverwriteLocal(
      memoryAlgorithm: cloneMemoryAlgorithmAb(),
      onSuccess: (MemoryAlgorithm memoryAlgorithm) async {
        await memoryAlgorithmListPageAbController?.refreshPage();
        SmartDialog.showToast("保存成功！");
        isSaved = true;
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
        isSaved = false;
      },
    );
    return isSaved;
  }

  void changeKeyword() {
    isAlgorithmKeyboard.refreshEasy((oldValue) => !oldValue);
    final pf = FocusManager.instance.primaryFocus;
    if (pf == null) return;
    pf.unfocus();
    Future.delayed(const Duration(milliseconds: 100), () => pf.requestFocus());
  }
}
