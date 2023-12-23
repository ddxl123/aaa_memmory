import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';
import '../page/list/MemoryGroupListPageAbController.dart';
import '../page/list/MemoryModeListPageAbController.dart';
import '../push_page/push_page.dart';
import 'showCreateMemoryModelDialog.dart';

Future<void> showSelectMemoryModelInMemoryGroupDialog({required Ab<MemoryGroupAndOther> mgAndOtherAb}) async {
  await showCustomDialog(builder: (_) => SelectMemoryModelInMemoryGroupDialogWidget(mgAndOtherAb: mgAndOtherAb));
}

class SelectMemoryModelInMemoryGroupDialogWidget extends StatefulWidget {
  const SelectMemoryModelInMemoryGroupDialogWidget({super.key, required this.mgAndOtherAb});

  final Ab<MemoryGroupAndOther> mgAndOtherAb;

  @override
  State<SelectMemoryModelInMemoryGroupDialogWidget> createState() => _SelectMemoryModelInMemoryGroupDialogWidgetState();
}

class _SelectMemoryModelInMemoryGroupDialogWidgetState extends State<SelectMemoryModelInMemoryGroupDialogWidget> {
  final memoryModels = <MemoryModel>[];

  final memoryModeListPageAbController = MemoryModeListPageAbController();

  MemoryModel? _selectedMm;

  Future<void> getMms() async {
    await memoryModeListPageAbController.refreshPage();

    memoryModels.clear();
    memoryModels.addAll(memoryModeListPageAbController.memoryModelsAb());
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedMm = widget.mgAndOtherAb().getMemoryModel;
    getMms();
  }

  Widget _topRightAction() {
    return IconButton(
      icon: const Icon(Icons.add),
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onPressed: () async {
        await showCreateMemoryModelDialog();
        await getMms();
      },
    );
  }

  List<Widget> _columnChildren() {
    return memoryModels.map(
      (e) {
        return Row(
          children: [
            Expanded(
              child: TextButton(
                style: const ButtonStyle(alignment: Alignment.centerLeft),
                child: Text(e.title),
                onPressed: () async {
                  await pushToMemoryModelGizmoEditPage(context: context, memoryModel: e);
                  if (mounted) setState(() {});
                },
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: () {
                if (_selectedMm?.id == e.id) {
                  return const SolidCircleIcon();
                } else {
                  return const SolidCircleGreyIcon();
                }
              }(),
              onPressed: () {
                if (_selectedMm?.id == e.id) {
                  _selectedMm = null;
                } else {
                  _selectedMm = e;
                }
                setState(() {});
              },
            ),
          ],
        );
      },
    ).toList();
  }

  Future<void> _onOk() async {
    widget.mgAndOtherAb.refreshInevitable((obj) => obj..setMemoryModel = _selectedMm);
    if (_selectedMm == null) {
      SmartDialog.showToast('不选择');
    } else {
      SmartDialog.showToast('选择成功！');
    }
    SmartDialog.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return OkAndCancelDialogWidget(
      title: '选择记忆算法：',
      topRightAction: _topRightAction(),
      columnChildren: memoryModels.isEmpty ? const [Text('未创建记忆组', style: TextStyle(color: Colors.grey))] : _columnChildren(),
      cancelText: '稍后',
      okText: '选择',
      onCancel: () async {
        SmartDialog.dismiss();
      },
      onOk: _onOk,
    );
  }
}
