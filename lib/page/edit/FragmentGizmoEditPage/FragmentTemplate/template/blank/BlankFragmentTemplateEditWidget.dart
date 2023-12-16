import 'package:flutter/material.dart';
import 'package:reorderables/reorderables.dart';
import 'package:tools/tools.dart';

import '../../base/FragmentTemplateEditWidget.dart';
import '../../base/SingleQuillEditableWidget.dart';
import '../../base/TemplateViewChunkWidget.dart';
import '../choice/ChoicePrefixType.dart';
import 'BlankFragmentTemplate.dart';

/// 单面模板的编辑 Widget。
class BlankFragmentTemplateEditWidget extends StatefulWidget {
  const BlankFragmentTemplateEditWidget({
    super.key,
    required this.blankFragmentTemplate,
    required this.isEditable,
  });

  final BlankFragmentTemplate blankFragmentTemplate;

  final bool isEditable;

  @override
  State<BlankFragmentTemplateEditWidget> createState() => _BlankFragmentTemplateEditWidgetState();
}

class _BlankFragmentTemplateEditWidgetState extends State<BlankFragmentTemplateEditWidget> {
  late final BlankFragmentTemplate t;

  @override
  void initState() {
    super.initState();
    t = widget.blankFragmentTemplate;
  }

  @override
  Widget build(BuildContext context) {
    return FragmentTemplateEditWidget(
      fragmentTemplate: t,
      isEditable: widget.isEditable,
      children: [
        TemplateViewChunkWidget(
          chunkTitle: "填空",
          children: [
            SingleQuillEditableWidget(
              singleQuillController: t.blank,
              isEditable: widget.isEditable,
              fragmentTemplate: t,
            ),
            SizedBox(height: 10),
            Divider(),
            SizedBox(height: 10),
            Column(
              children: [
                t.choices.isEmpty
                    ? Container()
                    : Row(
                        children: [
                          SizedBox(width: 10),
                          Text("选项前缀类型："),
                          Spacer(),
                          CustomDropdownBodyButton(
                            initValue: t.choicePrefixType,
                            items: ChoicePrefixType.values.map(
                              (e) {
                                return CustomItem(value: e, text: e.displayName);
                              },
                            ).toList(),
                            onChanged: (v) {
                              t.choicePrefixType = v!;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                t.choices.isEmpty
                    ? Container()
                    : Row(
                        children: [
                          SizedBox(width: 10),
                          Text("选项是否乱序："),
                          Spacer(),
                          Checkbox(
                            value: t.canDisorder,
                            onChanged: (v) {
                              t.canDisorder = v!;
                              setState(() {});
                            },
                          ),
                        ],
                      ),
                ReorderableColumn(
                  onReorder: (int oldIndex, int newIndex) {
                    final target = t.choices.removeAt(oldIndex);
                    t.choices.insert(newIndex, target);
                    setState(() {});
                  },
                  buildDraggableFeedback: (context, constraints, child) => ConstrainedBox(
                    //If you want the size to be consistent
                    constraints: constraints,
                    //You can modify however you want the child to be here e.g. red background
                    child: Card(
                      child: child,
                    ),
                  ),
                  children: [
                    for (int i = 0; i < t.choices.length; i++)
                      TextButton(
                        key: ValueKey(i),
                        style: ButtonStyle(visualDensity: kMinVisualDensity),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.choicePrefixType.toTypeFrom(i + 1),
                              style: const TextStyle(color: Colors.amber),
                            ),
                            t.choicePrefixType == ChoicePrefixType.none ? Container() : const Text("  "),
                            Expanded(child: Text(t.choices[i].text)),
                          ],
                        ),
                        onPressed: () async {
                          await t.editChoice(blankChoice: t.choices[i]);
                          setState(() {});
                        },
                      ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 10),
            Row(
              children: [
                SizedBox(width: 10),
                t.choices.isEmpty ? Container() : Text("单击编辑，长按交换位置", style: TextStyle(color: Colors.grey)),
                Spacer(),
                TextButton(
                  style: ButtonStyle(visualDensity: kMinVisualDensity),
                  child: Text("＋ 增加选项"),
                  onPressed: () async {
                    await t.addChoice();
                    setState(() {});
                  },
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
