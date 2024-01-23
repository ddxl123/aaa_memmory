import 'package:aaa_memory/page/edit/MemoryAlgorithmGizmoEditPage/AlgorithmDefaultSelectSheet.dart';
import 'package:aaa_memory/theme/theme.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tools/tools.dart';

import 'AlgorithmEditPageAbController.dart';
import 'MemoryAlgorithmGizmoEditPageAbController.dart';

class AlgorithmEditPage extends StatefulWidget {
  const AlgorithmEditPage({
    super.key,
    required this.stateName,
    required this.memoryAlgorithmAb,
  });

  final String stateName;
  final Ab<MemoryAlgorithm> memoryAlgorithmAb;

  @override
  State<AlgorithmEditPage> createState() => _AlgorithmEditPageState();
}

class _AlgorithmEditPageState extends State<AlgorithmEditPage> {
  late final AlgorithmEditPageAbController algorithmEditPageAbController;

  @override
  void initState() {
    super.initState();
    algorithmEditPageAbController = AlgorithmEditPageAbController(stateName: widget.stateName);
  }

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryAlgorithmGizmoEditPageAbController>(
      builder: (c, abw) {
        return AbBuilder<AlgorithmEditPageAbController>(
          putController: algorithmEditPageAbController,
          builder: (fc, fAbw) {
            return Scaffold(
              appBar: AppBar(
                leading: backButton(
                  context: context,
                  onPressed: () {
                    algorithmEditPageAbController.abBack();
                  },
                ),
                title: Text(
                  widget.stateName,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                titleSpacing: 0,
              ),
              body: AbBuilder<AlgorithmEditPageAbController>(
                builder: (c, abw) {
                  return FreeBox(
                    freeBoxController: fc.freeBoxController,
                    moveScaleLayerWidgets: FreeBoxMoveScaleLayerStack(
                      children: [
                        c.isCurrentRaw(abw)
                            ? FreeBoxMoveScaleLayerPositioned(
                                expectPosition: Offset(10, 10),
                                child: SizedBox(
                                  width: 1000,
                                  child: TextField(
                                    controller: c.rawTextEditingController,
                                    minLines: 20,
                                    maxLines: 1000,
                                    decoration: InputDecoration(
                                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                                    ),
                                  ),
                                ),
                              )
                            : FreeBoxMoveScaleLayerPositioned(
                                expectPosition: Offset(10, 10),
                                child: SizedBox(
                                  width: 2500,
                                  child: c.currentAlgorithmWrapper(abw).toWidget(),
                                ),
                              ),
                      ],
                    ),
                    fixedLayerWidgets: [
                      FreeBoxFixedLayerPositioned(
                        bottom: 50,
                        right: 25,
                        child: Column(
                          children: [
                            AbwBuilder(
                              builder: (abw) {
                                return IconButton(
                                  icon: Icon(FontAwesomeIcons.locationCrosshairs, size: 28),
                                  onPressed: () {
                                    fc.freeBoxController.targetSlide(
                                      targetCamera: FreeBoxCamera(expectPosition: Offset.zero, expectScale: 1.0),
                                      rightNow: false,
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),
              bottomNavigationBar: AbBuilder<AlgorithmEditPageAbController>(
                builder: (AlgorithmEditPageAbController bnC, Abw bnAbw) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: AbBuilder<AlgorithmEditPageAbController>(
                              builder: (AlgorithmEditPageAbController c, Abw abw) {
                                return TextButton(
                                  child: c.isCurrentRaw(abw) ? Text("切换至常规编辑") : Text("切换至纯文本编辑"),
                                  onPressed: () {
                                    c.changeRawOrView(null);
                                  },
                                );
                              },
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              child: Text("格式化"),
                              onPressed: () {
                                bnC.rawFormatting();
                              },
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              child: Text("语法分析"),
                              onPressed: () {
                                bnC.analysis();
                              },
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              child: Text("查看内置成员"),
                              onPressed: () {},
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              child: Text("预置"),
                              onPressed: () {
                                showAlgorithmDefaultSelectSheet(context: context, isWhole: false);
                              },
                            ),
                          ),
                          Expanded(
                            child: TextButton(
                              child: Text("帮助"),
                              onPressed: () {},
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
