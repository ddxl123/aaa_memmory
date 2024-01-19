import 'package:aaa_memory/algorithm_parser/parser.dart';
import 'package:aaa_memory/page/edit/MemoryAlgorithmGizmoEditPage/AlgorithmEditPageAbController.dart';
import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tools/tools.dart';
import 'dart:math';

import '../../../algorithm_parser/default.dart';

Future<void> showAlgorithmDefaultSelectSheet({required BuildContext context}) async {
  showMaterialModalBottomSheet(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    context: context,
    builder: (BuildContext context) {
      return AlgorithmDefault();
    },
  );
}

class AlgorithmDefault extends StatefulWidget {
  const AlgorithmDefault({super.key});

  @override
  State<AlgorithmDefault> createState() => _AlgorithmDefaultState();
}

class _AlgorithmDefaultState extends State<AlgorithmDefault> {
  final algorithmEditPageAbController = Aber.find<AlgorithmEditPageAbController>();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              Text("请选择一个算法预设", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: ListView(
              children: DefaultAlgorithmOfRaw.defaultList.map(
                (e) {
                  return Column(
                    children: [
                      TextButton(
                        child: Row(
                          children: [
                            Expanded(child: Text(e.title)),
                            e.isExpand ? Transform.rotate(angle: -pi / 2, child: Icon(Icons.chevron_left)) : Icon(Icons.chevron_left),
                          ],
                        ),
                        onPressed: () {
                          e.isExpand = !e.isExpand;
                          setState(() {});
                        },
                      ),
                      if (e.isExpand)
                        Padding(
                          padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                          child: Column(
                            children: [
                              ...e.list.map(
                                (e) {
                                  return Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextButton(
                                              style: ButtonStyle(alignment: Alignment.centerLeft),
                                              child: Text(e.stateName, style: TextStyle(color: Colors.black)),
                                              onPressed: () {
                                                // TODO: 编辑
                                              },
                                            ),
                                          ),
                                          TextButton(
                                            child: Text("选择"),
                                            onPressed: () {
                                              algorithmEditPageAbController.defaultToPaste(AlgorithmBidirectionalParsing.parseFromAlgorithmWrapper(e.algorithmWrapper));
                                            },
                                          ),
                                        ],
                                      ),
                                      Divider(height: 2, color: Colors.grey.withOpacity(0.2)),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                    ],
                  );
                },
              ).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
