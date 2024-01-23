import 'package:aaa_memory/page/edit/MemoryAlgorithmGizmoEditPage/AlgorithmDefaultSelectSheet.dart';
import 'package:aaa_memory/single_page/SingleQuillEditor1Page.dart';
import 'package:aaa_memory/theme/theme.dart';
import 'package:flutter_quill/markdown_quill.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';

import '../../../algorithm_parser/parser.dart';
import 'AlgorithmEditPage.dart';
import 'MemoryAlgorithmGizmoEditPageAbController.dart';

class MemoryAlgorithmGizmoEditPage extends StatelessWidget {
  const MemoryAlgorithmGizmoEditPage({super.key, required this.cloneMemoryAlgorithmAb});

  final Ab<MemoryAlgorithm> cloneMemoryAlgorithmAb;

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryAlgorithmGizmoEditPageAbController>(
      putController: MemoryAlgorithmGizmoEditPageAbController(cloneMemoryAlgorithmAb: cloneMemoryAlgorithmAb),
      builder: (c, abw) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.chevron_left_outlined),
              onPressed: () {
                c.abBack();
              },
            ),
            title: _appBarTitleWidget(),
            actions: [
              _appBarRightButtonWidget(),
            ],
          ),
          body: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              const SliverToBoxAdapter(child: SizedBox(height: 10)),
              SliverToBoxAdapter(child: _titleWidget()),
              SliverToBoxAdapter(child: _explainWidget()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(color: Colors.grey.withOpacity(0.2), height: 2),
                      ),
                      SizedBox(width: 10),
                      Text("碎片算法", style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(color: Colors.grey.withOpacity(0.2), height: 2),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _algorithmWidget(context: c.context, stateName: ButtonDataState.name)),
              SliverToBoxAdapter(child: _algorithmWidget(context: c.context, stateName: FamiliarityState.name)),
              SliverToBoxAdapter(child: _algorithmWidget(context: c.context, stateName: NextShowTimeState.name)),
              SliverToBoxAdapter(child: _algorithmWidget(context: c.context, stateName: CompleteConditionState.name)),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(30, 20, 30, 0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(color: Colors.grey.withOpacity(0.2), height: 2),
                      ),
                      SizedBox(width: 10),
                      Text("周期算法", style: TextStyle(color: Colors.grey)),
                      SizedBox(width: 10),
                      Expanded(
                        child: Container(color: Colors.grey.withOpacity(0.2), height: 2),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: _algorithmWidget(context: c.context, stateName: SuggestLoopCycleState.name)),
              SliverToBoxAdapter(child: _algorithmWidget(context: c.context, stateName: SuggestCountForNewAndReviewState.name)),
              const SliverToBoxAdapter(child: SizedBox(height: 50)),
            ],
          ),
          bottomSheet: Row(
            children: [
              Expanded(
                child: TextButton(
                  child: Text("预置"),
                  onPressed: () {
                    showAlgorithmDefaultSelectSheet(context: context, isWhole: true);
                  },
                ),
              ),
              Expanded(
                child: TextButton(
                  child: Text("分析"),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          // floatingActionButton: AbwBuilder(
          //   builder: (fAbw) {
          //     return c.isAlgorithmKeyboard(fAbw)
          //         ? CustomRoundCornerButton(
          //             text: const FaIcon(FontAwesomeIcons.keyboard),
          //             onPressed: () {
          //               c.changeKeyword();
          //             },
          //             border: const CircleBorder(),
          //           )
          //         : CustomRoundCornerButton(
          //             text: const Text('算法键盘'),
          //             onPressed: () {
          //               c.changeKeyword();
          //             },
          //           );
          //   },
          // ),
        );
      },
    );
  }

  Widget _appBarTitleWidget() {
    return AbBuilder<MemoryAlgorithmGizmoEditPageAbController>(
      builder: (c, abw) {
        return Text(c.cloneMemoryAlgorithmAb(abw).title);
      },
    );
  }

  Widget _appBarRightButtonWidget() {
    return AbBuilder<MemoryAlgorithmGizmoEditPageAbController>(
      builder: (c, abw) {
        return IconButton(
          icon: Icon(Icons.save),
          onPressed: () async {
            final isSaved = await c.save();
            if (isSaved) {
              Navigator.pop(c.context);
            } else {
              SmartDialog.showToast("保存失败！");
            }
          },
        );
      },
    );
  }

  Widget _titleWidget() {
    return AbBuilder<MemoryAlgorithmGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: EdgeInsets.all(10),
          child: Card(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: TextField(
                minLines: 1,
                maxLines: 3,
                controller: c.titleEditingController,
                decoration: const InputDecoration(border: InputBorder.none, labelText: '名称：'),
                autofocus: false,
                onChanged: (v) {
                  c.cloneMemoryAlgorithmAb(abw).title = v;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _explainWidget() {
    return AbBuilder<MemoryAlgorithmGizmoEditPageAbController>(
      builder: (c, abw) {
        c.cloneMemoryAlgorithmAb(abw);
        return Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("说明："),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: c.explainContentSingleQuillController.isContentEmpty()
                              ? Text("无说明", style: TextStyle(color: Colors.grey))
                              : Text("${c.explainContentSingleQuillController.transferToTitle()}..."),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              Navigator.push(
                c.context,
                MaterialPageRoute(
                  builder: (ctx) {
                    return SingleQuillEditor1Page(
                      isEditable: true,
                      initJsonString: c.cloneMemoryAlgorithmAb().explain_content,
                      singleQuillController: c.explainContentSingleQuillController,
                      backListener: (state, hasRoute) async {
                        if (!state.singleQuillController.equalFromJsonString(jsonString: c.cloneMemoryAlgorithmAb().explain_content)) {
                          c.cloneMemoryAlgorithmAb().explain_content = state.singleQuillController.getContentJsonStringOrNull();
                          c.cloneMemoryAlgorithmAb.refreshForce();
                          SmartDialog.showToast("已修改，请注意保存！");
                        }
                        return false;
                      },
                      appBarCallback: (state) {
                        return AppBar(
                          leading: backButton(
                            onPressed: () {
                              state.abBack();
                            },
                            context: c.context,
                          ),
                        );
                      },
                    );
                  },
                ),
              );
            },
          ),
        );
        ;
      },
    );
  }

  Widget _algorithmWidget({
    required BuildContext context,
    required String stateName,
  }) {
    return AbBuilder<MemoryAlgorithmGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.all(10),
          child: GestureDetector(
            child: Card(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(stateName),
                        ClassificationState.filter(
                                  stateName: stateName,
                                  buttonData: () => cloneMemoryAlgorithmAb(abw).button_algorithm,
                                  familiarity: () => cloneMemoryAlgorithmAb(abw).familiarity_algorithm,
                                  nextShowTime: () => cloneMemoryAlgorithmAb(abw).next_time_algorithm,
                                  completeCondition: () => cloneMemoryAlgorithmAb(abw).completed_algorithm,
                                  suggestLoopCycle: () => cloneMemoryAlgorithmAb(abw).suggest_loop_cycle_algorithm,
                                  suggestCountForNewAndReviewState: () => cloneMemoryAlgorithmAb(abw).suggest_count_for_new_and_review_algorithm,
                                ) ==
                                null
                            ? Text(" (未设置)", style: TextStyle(fontSize: 14, color: Colors.red))
                            : Container(),
                        Spacer(),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            ClassificationState.filter(
                                  stateName: stateName,
                                  buttonData: () => cloneMemoryAlgorithmAb(abw).button_algorithm_remark,
                                  familiarity: () => cloneMemoryAlgorithmAb(abw).familiarity_algorithm_remark,
                                  nextShowTime: () => cloneMemoryAlgorithmAb(abw).next_time_algorithm_remark,
                                  completeCondition: () => cloneMemoryAlgorithmAb(abw).completed_algorithm_remark,
                                  suggestLoopCycle: () => cloneMemoryAlgorithmAb(abw).suggest_loop_cycle_algorithm_remark,
                                  suggestCountForNewAndReviewState: () => cloneMemoryAlgorithmAb(abw).suggest_count_for_new_and_review_algorithm_remark,
                                ) ??
                                "无说明",
                            style: const TextStyle(color: Colors.grey, fontSize: 14, overflow: TextOverflow.ellipsis),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (ctx) => AlgorithmEditPage(
                    stateName: stateName,
                    memoryAlgorithmAb: cloneMemoryAlgorithmAb,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
