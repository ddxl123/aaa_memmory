import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';
import '../page/list/MemoryGroupListPageAbController.dart';
import '../page/list/MemoryAlgorithmListPageAbController.dart';
import '../push_page/push_page.dart';
import 'showCreateMemoryAlgorithmDialog.dart';

Future<void> showSelectMemoryAlgorithmInMemoryGroupDialog({required Ab<MemoryGroupAndOther> mgAndOtherAb}) async {
  await showCustomDialog(builder: (_) => SelectMemoryAlgorithmInMemoryGroupDialogWidget(mgAndOtherAb: mgAndOtherAb));
}

class SelectMemoryAlgorithmInMemoryGroupDialogWidget extends StatefulWidget {
  const SelectMemoryAlgorithmInMemoryGroupDialogWidget({super.key, required this.mgAndOtherAb});

  final Ab<MemoryGroupAndOther> mgAndOtherAb;

  @override
  State<SelectMemoryAlgorithmInMemoryGroupDialogWidget> createState() => _SelectMemoryAlgorithmInMemoryGroupDialogWidgetState();
}

class _SelectMemoryAlgorithmInMemoryGroupDialogWidgetState extends State<SelectMemoryAlgorithmInMemoryGroupDialogWidget> {
  final memoryAlgorithms = <MemoryAlgorithm>[];

  final memoryAlgorithmListPageAbController = MemoryAlgorithmListPageAbController();

  MemoryAlgorithm? _selectedMa;

  Future<void> getMms() async {
    await memoryAlgorithmListPageAbController.refreshPage();

    memoryAlgorithms.clear();
    memoryAlgorithms.addAll(memoryAlgorithmListPageAbController.memoryAlgorithmsAb());
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _selectedMa = widget.mgAndOtherAb().getMemoryAlgorithm;
    getMms();
  }

  Widget _topRightAction() {
    return IconButton(
      icon: const Icon(Icons.add),
      style: ButtonStyle(padding: MaterialStateProperty.all(EdgeInsets.zero), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
      onPressed: () async {
        await showCreateMemoryAlgorithmDialog();
        await getMms();
      },
    );
  }

  List<Widget> _columnChildren() {
    return memoryAlgorithms.map(
      (e) {
        return Row(
          children: [
            Expanded(
              child: TextButton(
                style: const ButtonStyle(alignment: Alignment.centerLeft),
                child: Text(e.title),
                onPressed: () async {
                  await pushToMemoryAlgorithmGizmoEditPage(context: context, memoryAlgorithmAb: e.ab);
                  if (mounted) setState(() {});
                },
              ),
            ),
            IconButton(
              padding: const EdgeInsets.all(0),
              icon: () {
                if (_selectedMa?.id == e.id) {
                  return const SolidCircleIcon();
                } else {
                  return const SolidCircleGreyIcon();
                }
              }(),
              onPressed: () {
                if (_selectedMa?.id == e.id) {
                  _selectedMa = null;
                } else {
                  _selectedMa = e;
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
    widget.mgAndOtherAb.refreshInevitable((obj) => obj..setMemoryAlgorithm = _selectedMa);
    if (_selectedMa == null) {
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
      columnChildren: memoryAlgorithms.isEmpty ? const [Text('未创建记忆组', style: TextStyle(color: Colors.grey))] : _columnChildren(),
      cancelText: '稍后',
      okText: '选择',
      onCancel: () async {
        SmartDialog.dismiss();
      },
      onOk: _onOk,
    );
  }
}
