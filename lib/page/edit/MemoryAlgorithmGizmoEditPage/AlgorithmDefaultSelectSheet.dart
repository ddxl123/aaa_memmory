import 'package:aaa_memory/algorithm_parser/parser.dart';
import 'package:aaa_memory/global/GlobalAbController.dart';
import 'package:aaa_memory/page/edit/MemoryAlgorithmGizmoEditPage/AlgorithmEditPageAbController.dart';
import 'package:aaa_memory/page/edit/MemoryAlgorithmGizmoEditPage/MemoryAlgorithmGizmoEditPageAbController.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:tools/tools.dart';
import 'dart:math';

import '../../../algorithm_parser/default.dart';

Future<void> showAlgorithmDefaultSelectSheet({required BuildContext context, required bool isWhole}) async {
  showMaterialModalBottomSheet(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
    context: context,
    builder: (BuildContext context) {
      return AlgorithmDefault(
        isWhole: isWhole,
      );
    },
  );
}

class AlgorithmDefault extends StatefulWidget {
  const AlgorithmDefault({super.key, required this.isWhole});

  final bool isWhole;

  @override
  State<AlgorithmDefault> createState() => _AlgorithmDefaultState();
}

class _AlgorithmDefaultState extends State<AlgorithmDefault> {
  final user = Aber.find<GlobalAbController>().loggedInUser()!;
  final algorithmEditPageAbController = Aber.findOrNull<AlgorithmEditPageAbController>();
  final memoryAlgorithmGizmoEditPageAbController = Aber.findOrNull<MemoryAlgorithmGizmoEditPageAbController>();

  final selfs = <DefaultAlgorithmOfRaw>[];

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudAllMemoryAlgorithmOverwriteLocal(
      userId: user.id,
      onSuccess: (List<MemoryAlgorithm> memoryAlgorithms) async {
        selfs.clear();
        selfs.addAll(
          memoryAlgorithms.map(
            (e) {
              return DefaultAlgorithmOfRaw(
                defaultTitle: null,
                memoryAlgorithm: e,
                list: ClassificationState.all(
                  buttonData: () {
                    final buttonAlgorithmResult = AlgorithmBidirectionalParsing.parseFromString(e.button_algorithm);
                    return ButtonDataState(
                      algorithmWrapper: buttonAlgorithmResult?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : buttonAlgorithmResult!.algorithmWrapper!,
                      simulationType: SimulationType.syntaxCheck,
                      externalResultHandler: null,
                    );
                  },
                  familiarity: () {
                    final familiarityAlgorithmResult = AlgorithmBidirectionalParsing.parseFromString(e.familiarity_algorithm);
                    return FamiliarityState(
                      algorithmWrapper: familiarityAlgorithmResult?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : familiarityAlgorithmResult!.algorithmWrapper!,
                      simulationType: SimulationType.syntaxCheck,
                      externalResultHandler: null,
                    );
                  },
                  nextShowTime: () {
                    final nextTimeAlgorithmResult = AlgorithmBidirectionalParsing.parseFromString(e.next_time_algorithm);
                    return NextShowTimeState(
                      algorithmWrapper: nextTimeAlgorithmResult?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : nextTimeAlgorithmResult!.algorithmWrapper!,
                      simulationType: SimulationType.syntaxCheck,
                      externalResultHandler: null,
                    );
                  },
                  completeCondition: () {
                    final completedAlgorithmResult = AlgorithmBidirectionalParsing.parseFromString(e.completed_algorithm);
                    return CompleteConditionState(
                      algorithmWrapper: completedAlgorithmResult?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : completedAlgorithmResult!.algorithmWrapper!,
                      simulationType: SimulationType.syntaxCheck,
                      externalResultHandler: null,
                    );
                  },
                  suggestLoopCycle: () {
                    final suggestLoopCycleResult = AlgorithmBidirectionalParsing.parseFromString(e.suggest_loop_cycle_algorithm);
                    return SuggestLoopCycleState(
                      algorithmWrapper: suggestLoopCycleResult?.hasError != false ? AlgorithmWrapper.emptyAlgorithmWrapper : suggestLoopCycleResult!.algorithmWrapper!,
                      simulationType: SimulationType.syntaxCheck,
                      externalResultHandler: null,
                    );
                  },
                  suggestCountForNewAndReviewState: () {
                    final suggestCountForNewAndReviewAlgorithmResult = AlgorithmBidirectionalParsing.parseFromString(e.suggest_count_for_new_and_review_algorithm);
                    return SuggestCountForNewAndReviewState(
                      algorithmWrapper: suggestCountForNewAndReviewAlgorithmResult?.hasError != false
                          ? AlgorithmWrapper.emptyAlgorithmWrapper
                          : suggestCountForNewAndReviewAlgorithmResult!.algorithmWrapper!,
                      simulationType: SimulationType.syntaxCheck,
                      externalResultHandler: null,
                    );
                  },
                ),
                officialDefault: false,
              );
            },
          ),
        );
        setState(() {});
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Row(
            children: [
              Text("请选择一个已有算法", style: TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(
            height: MediaQuery.of(context).size.height / 2,
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(child: Text("默认：", style: TextStyle(color: Colors.grey))),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: DefaultAlgorithmOfRaw.defaultList.length,
                    (context, index) {
                      final e = DefaultAlgorithmOfRaw.defaultList[index];
                      return Column(
                        children: [
                          TextButton(
                            child: Row(
                              children: [
                                e.isExpand ? Transform.rotate(angle: pi / 2, child: Icon(Icons.chevron_right)) : Icon(Icons.chevron_right),
                                Expanded(child: Text(e.getTitle)),
                                if (widget.isWhole)
                                  TextButton(
                                    style: ButtonStyle(visualDensity: kMinVisualDensity),
                                    child: Text("选择"),
                                    onPressed: () {
                                      showCustomDialog(
                                        builder: (ctx) {
                                          return OkAndCancelDialogWidget(
                                            title: "确认要覆盖掉当前页面的全部算法？",
                                            okText: "覆盖",
                                            cancelText: "返回",
                                            onOk: () {
                                              for (var element in e.list) {
                                                ClassificationState.filter(
                                                  stateName: element.stateName,
                                                  buttonData: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().button_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  familiarity: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().familiarity_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  nextShowTime: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().next_time_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  completeCondition: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().completed_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  suggestLoopCycle: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().suggest_loop_cycle_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  suggestCountForNewAndReviewState: () => memoryAlgorithmGizmoEditPageAbController
                                                      ?.cloneMemoryAlgorithmAb()
                                                      .suggest_count_for_new_and_review_algorithm = element.algorithmWrapper.toJsonStringOrNull(),
                                                );
                                              }
                                              memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb.refreshForce();
                                              SmartDialog.dismiss(status: SmartStatus.dialog);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
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
                                              if (!widget.isWhole)
                                                TextButton(
                                                  child: Text("选择"),
                                                  onPressed: () {
                                                    showCustomDialog(
                                                      builder: (ctx) {
                                                        return OkAndCancelDialogWidget(
                                                          title: "确定要覆盖掉当前页面的算法内容？",
                                                          okText: "覆盖",
                                                          cancelText: "返回",
                                                          onOk: () {
                                                            final result = AlgorithmBidirectionalParsing.parseFromAlgorithmWrapper(e.algorithmWrapper);
                                                            if (result.hasError) {
                                                              SmartDialog.showToast("解析成文本失败：${result.error}");
                                                            } else {
                                                              algorithmEditPageAbController?.defaultToPaste(result.content!);
                                                            }
                                                            SmartDialog.dismiss(status: SmartStatus.dialog);
                                                          },
                                                        );
                                                      },
                                                    );
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
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: 20)),
                SliverToBoxAdapter(child: Text("自己创建：", style: TextStyle(color: Colors.grey))),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    childCount: selfs.length,
                    (context, index) {
                      final e = selfs[index];
                      return Column(
                        children: [
                          TextButton(
                            child: Row(
                              children: [
                                e.isExpand ? Transform.rotate(angle: pi / 2, child: Icon(Icons.chevron_right)) : Icon(Icons.chevron_right),
                                Expanded(
                                  child: Row(
                                    children: [
                                      Text(e.getTitle),
                                      if (memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().id == e.memoryAlgorithm!.id)
                                        Text(" (当前 · 未修改前)", style: TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                                if (widget.isWhole)
                                  TextButton(
                                    style: ButtonStyle(visualDensity: kMinVisualDensity),
                                    child: Text("选择"),
                                    onPressed: () {
                                      showCustomDialog(
                                        builder: (ctx) {
                                          return OkAndCancelDialogWidget(
                                            title: "确认要覆盖掉当前页面的全部算法？",
                                            okText: "覆盖",
                                            cancelText: "返回",
                                            onOk: () {
                                              for (var element in e.list) {
                                                ClassificationState.filter(
                                                  stateName: element.stateName,
                                                  buttonData: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().button_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  familiarity: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().familiarity_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  nextShowTime: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().next_time_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  completeCondition: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().completed_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  suggestLoopCycle: () => memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb().suggest_loop_cycle_algorithm =
                                                      element.algorithmWrapper.toJsonStringOrNull(),
                                                  suggestCountForNewAndReviewState: () => memoryAlgorithmGizmoEditPageAbController
                                                      ?.cloneMemoryAlgorithmAb()
                                                      .suggest_count_for_new_and_review_algorithm = element.algorithmWrapper.toJsonStringOrNull(),
                                                );
                                              }
                                              memoryAlgorithmGizmoEditPageAbController?.cloneMemoryAlgorithmAb.refreshForce();
                                              SmartDialog.dismiss(status: SmartStatus.dialog);
                                              Navigator.pop(context);
                                            },
                                          );
                                        },
                                      );
                                    },
                                  ),
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
                                              if (!widget.isWhole)
                                                TextButton(
                                                  child: Text("选择"),
                                                  onPressed: () {
                                                    final result = AlgorithmBidirectionalParsing.parseFromAlgorithmWrapper(e.algorithmWrapper);
                                                    if (result.hasError) {
                                                      SmartDialog.showToast("解析成文本失败：${result.error}");
                                                    } else {
                                                      algorithmEditPageAbController?.defaultToPaste(result.content!);
                                                    }
                                                    SmartDialog.dismiss(status: SmartStatus.dialog);
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
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
