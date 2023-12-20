import 'package:drift/drift.dart' as d;
import 'package:drift/extensions/json1.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:tools/tools.dart';

import '../../../single_dialog/showSelectMemoryModelInMemoryGroupDialog.dart';
import 'MemoryGroupGizmoEditPageAbController.dart';

class CurrentCircleWidget extends StatelessWidget {
  const CurrentCircleWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              _titleWidget(),
              SizedBox(height: 10),
              _memoryModelWidget(),
              // _selectFragmentWidget(),
              Divider(color: Colors.black12, height: 30),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text("学习数量", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  _newLearnCountWidget(),
                  const ReviewIntervalWidget(),
                ],
              ),
              Divider(color: Colors.black12, height: 30),
              Column(
                children: [
                  Row(
                    children: [
                      SizedBox(width: 10),
                      Text("碎片展示顺序", style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                  SizedBox(height: 10),
                  _newReviewDisplayOrder(),
                  _newDisplayOrder(),
                  _reviewDisplayOrder(),
                ],
              ),
              floatingRoundCornerButtonPlaceholderBox(60),
            ],
          ),
        );
      },
    );
  }

  Widget _titleWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('名称：'),
              Expanded(
                child: TextField(
                  controller: c.titleTextEditingController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: '请输入...',
                    hintStyle: TextStyle(fontSize: 14),
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                  scrollPadding: EdgeInsets.zero,
                  onChanged: (v) {
                    c.memoryGroupAb.refreshInevitable((obj) => obj..title = v);
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _memoryModelWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('记忆算法：'),
              TextButton(
                style: ButtonStyle(visualDensity: kMinVisualDensity),
                child: AbBuilder<MemoryGroupGizmoEditPageAbController>(
                  builder: (gzC, gzAbw) {
                    return Text(gzC.memoryModelAb(gzAbw)?.title ?? '点击选择');
                  },
                ),
                onPressed: () async {
                  await showSelectMemoryModelInMemoryGroupDialog(mg: c.memoryGroupAb, selectedMemoryModelAb: c.memoryModelAb);
                  c.memoryGroupAb.refreshInevitable((obj) => obj..memory_model_id = c.memoryModelAb()?.id);
                },
              ),
              // TODO:
              // Text("模拟(验证算法的正确性)"),
            ],
          ),
        );
      },
    );
  }

  Widget _selectFragmentWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('碎片数量：'),
              TextButton(
                style: ButtonStyle(visualDensity: kMinVisualDensity),
                child: Text('共 ${c.fragmentCountAb(abw)} 个', style: const TextStyle(fontSize: 16)),
                onPressed: () {
                  // Navigator.of(c.context).push(
                  //   DefaultSheetRoute(
                  //     bodySliver0: () {
                  //       return SliverToBoxAdapter(
                  //         child: AbBuilder<MemoryGroupGizmoEditPageAbController>(
                  //           builder: (sController, sAbw) {
                  //             return Material(
                  //               child: Container(
                  //                 padding: const EdgeInsets.all(10),
                  //                 child: SingleChildScrollView(
                  //                   physics: const NeverScrollableScrollPhysics(),
                  //                   child: Column(
                  //                     mainAxisSize: MainAxisSize.max,
                  //                     children: [
                  //                       ...(sController.selectedFragmentCountAb(sAbw).isEmpty
                  //                           ? [Container()]
                  //                           : sController.selectedFragmentCountAb(sAbw).map(
                  //                                 (e) => Row(
                  //                                   children: [
                  //                                     SizedBox(
                  //                                       height: 200,
                  //                                       child: Text(e(abw).content.toString()),
                  //                                     )
                  //                                   ],
                  //                                 ),
                  //                               )),
                  //                     ],
                  //                   ),
                  //                 ),
                  //               ),
                  //             );
                  //           },
                  //         ),
                  //       );
                  //     },
                  //   ),
                  // );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _newLearnCountWidget() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              const Text('新学数量：'),
              Expanded(
                child: StfBuilder1<int>(
                  // 保留上一次的设置
                  initValue: c.memoryGroupAb(abw).will_new_learn_count,
                  builder: (int value, BuildContext context, ResetValue<int> resetValue) {
                    int changeValue = value;

                    // 不能超过最大值
                    if (changeValue > c.remainNeverFragmentsCount(abw)) {
                      changeValue = c.remainNeverFragmentsCount(abw);
                    }
                    // 如果没有 space，则 0/300，其中 0 字符长度会动态的变宽成 10 或 100，从而导致刷新的时候滑块抖动。
                    // space 意味着将 0 前面添加两个 0，即 000/300。
                    int space = c.remainNeverFragmentsCount().toString().length - changeValue.toInt().toString().length;
                    return Row(
                      children: [
                        Expanded(
                          child: Slider(
                            label: changeValue.toInt().toString(),
                            min: 0,
                            max: c.remainNeverFragmentsCount().toDouble(),
                            value: changeValue.toDouble(),
                            divisions: c.remainNeverFragmentsCount() == 0 ? null : c.remainNeverFragmentsCount(),
                            onChanged: (n) {
                              resetValue(n.toInt(), true);
                            },
                            onChangeEnd: (n) {
                              c.memoryGroupAb().will_new_learn_count = n.floor();
                              c.memoryGroupAb.refreshForce();
                            },
                          ),
                        ),
                        Text('${'0' * space}${changeValue.toInt()}/${c.remainNeverFragmentsCount()}')
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _newReviewDisplayOrder() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              const Text('新 | 复习碎片：'),
              Spacer(),
              CustomDropdownBodyButton<NewReviewDisplayOrder>(
                initValue: c.memoryGroupAb(abw).new_review_display_order,
                items: [
                  CustomItem(value: NewReviewDisplayOrder.mix, text: '混合'),
                  CustomItem(value: NewReviewDisplayOrder.new_review, text: '优先新碎片'),
                  CustomItem(value: NewReviewDisplayOrder.review_new, text: '优先复习碎片'),
                ],
                onChanged: (v) {
                  c.memoryGroupAb.refreshInevitable((obj) => obj..new_review_display_order = v!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _newDisplayOrder() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              const Text('新碎片：'),
              Spacer(),
              CustomDropdownBodyButton<NewDisplayOrder>(
                initValue: c.memoryGroupAb(abw).new_display_order,
                items: [
                  CustomItem(value: NewDisplayOrder.random, text: '随机'),
                  CustomItem(value: NewDisplayOrder.title_a_2_z, text: '标题首字母A~Z顺序'),
                  CustomItem(value: NewDisplayOrder.create_early_2_late, text: '创建时间'),
                ],
                onChanged: (v) {
                  c.memoryGroupAb.refreshInevitable((obj) => obj..new_display_order = v!);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reviewDisplayOrder() {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
          child: Row(
            children: [
              const Text('复习碎片：'),
              Spacer(),
              CustomDropdownBodyButton<ReviewDisplayOrder>(
                initValue: c.memoryGroupAb(abw).review_display_order,
                items: [
                  CustomItem(value: ReviewDisplayOrder.expire_first, text: '过期优先'),
                  CustomItem(value: ReviewDisplayOrder.no_expire_first, text: '未过期优先'),
                  CustomItem(value: ReviewDisplayOrder.ignore_expire, text: '忽略过期'),
                ],
                onChanged: (v) {
                  c.memoryGroupAb.refreshInevitable((obj) => obj..review_display_order = v!);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class ReviewIntervalWidget extends StatefulWidget {
  const ReviewIntervalWidget({super.key});

  @override
  State<ReviewIntervalWidget> createState() => _ReviewIntervalWidgetState();
}

class _ReviewIntervalWidgetState extends State<ReviewIntervalWidget> {
  int reviewTotalCount = 0;

  final MemoryGroupGizmoEditPageAbController memoryGroupGizmoEditPageAbController = Aber.find<MemoryGroupGizmoEditPageAbController>();

  @override
  void initState() {
    super.initState();
    queryReviewTotalCount();
  }

  Future<void> queryReviewTotalCount() async {
    print(memoryGroupGizmoEditPageAbController.memoryGroupAb().start_time);
    if (memoryGroupGizmoEditPageAbController.memoryGroupAb().start_time == null) {
      reviewTotalCount = 0;
      setState(() {});
      return;
    }
    final diff = memoryGroupGizmoEditPageAbController.memoryGroupAb().review_interval.difference(memoryGroupGizmoEditPageAbController.memoryGroupAb().start_time!);
    final count = driftDb.fragmentMemoryInfos.id.count();
    final sel = driftDb.selectOnly(driftDb.fragmentMemoryInfos);
    sel.where(
      driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroupGizmoEditPageAbController.memoryGroupId) &
          driftDb.fragmentMemoryInfos.study_status.equalsValue(StudyStatus.review) &
          driftDb.fragmentMemoryInfos.next_plan_show_time.jsonExtract(r"$[#-1]").dartCast<int>().isSmallerOrEqualValue(diff.inSeconds),
    );
    sel.addColumns([count]);
    final result = await sel.get();
    reviewTotalCount = result.first.read(count)!;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return AbBuilder<MemoryGroupGizmoEditPageAbController>(
      builder: (c, abw) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 10),
          child: Row(
            children: [
              Expanded(
                child: RichText(
                  text: TextSpan(
                    text: "复习接下来 ",
                    children: [
                      TextSpan(
                        text: time2TextTime(
                          longSeconds: c.memoryGroupAb(abw).review_interval.difference(DateTime.now()).inSeconds,
                          canNegative: true,
                        ),
                        style: TextStyle(decoration: TextDecoration.underline),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            DatePicker.showDateTimePicker(
                              c.context,
                              locale: LocaleType.zh,
                              minTime: DateTime.now(),
                              currentTime: c.memoryGroupAb().review_interval,
                              onConfirm: (v) {
                                c.memoryGroupAb.refreshInevitable((obj) => obj..review_interval = v);
                                queryReviewTotalCount();
                              },
                            );
                          },
                      ),
                      TextSpan(
                        text: " 前需要复习的 ",
                      ),
                      TextSpan(
                        text: "$reviewTotalCount",
                      ),
                      TextSpan(text: " 个碎片")
                    ],
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
