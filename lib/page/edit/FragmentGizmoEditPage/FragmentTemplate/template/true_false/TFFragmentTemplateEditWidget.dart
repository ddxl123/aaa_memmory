import 'package:flutter/material.dart';

import '../../base/FragmentTemplateEditWidget.dart';
import '../../base/SingleQuillEditableWidget.dart';
import '../../base/TemplateViewChunkWidget.dart';
import 'TFFragmentTemplate.dart';

/// 单面模板的编辑 Widget。
class TFFragmentTemplateEditWidget extends StatefulWidget {
  const TFFragmentTemplateEditWidget({
    super.key,
    required this.tfFragmentTemplate,
    required this.isEditable,
  });

  final TFFragmentTemplate tfFragmentTemplate;

  final bool isEditable;

  @override
  State<TFFragmentTemplateEditWidget> createState() => _TFFragmentTemplateEditWidgetState();
}

class _TFFragmentTemplateEditWidgetState extends State<TFFragmentTemplateEditWidget> {
  @override
  Widget build(BuildContext context) {
    return FragmentTemplateEditWidget(
      fragmentTemplate: widget.tfFragmentTemplate,
      isEditable: widget.isEditable,
      children: [
        TemplateViewChunkWidget(
          chunkTitle: "问题",
          children: [
            SingleQuillEditableWidget(
              fragmentTemplate: widget.tfFragmentTemplate,
              singleQuillController: widget.tfFragmentTemplate.trueFalse,
              isEditable: widget.isEditable,
            ),
            SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.tfFragmentTemplate.answer == true ? Colors.green : Colors.grey,
                          width: widget.tfFragmentTemplate.answer == true ? 2 : 1,
                        ),
                      ),
                      child: Text("正确"),
                    ),
                    onTap: () {
                      if (widget.tfFragmentTemplate.answer != true) {
                        widget.tfFragmentTemplate.answer = true;
                      } else {
                        widget.tfFragmentTemplate.answer = null;
                      }
                      setState(() {});
                    },
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    child: Container(
                      padding: EdgeInsets.all(10),
                      margin: EdgeInsets.all(10),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: widget.tfFragmentTemplate.answer == false ? Colors.green : Colors.grey,
                          width: widget.tfFragmentTemplate.answer == false ? 2 : 1,
                        ),
                      ),
                      child: Text("错误"),
                    ),
                    onTap: () {
                      if (widget.tfFragmentTemplate.answer != false) {
                        widget.tfFragmentTemplate.answer = false;
                      } else {
                        widget.tfFragmentTemplate.answer = null;
                      }
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.tfFragmentTemplate.answer == null ? "请选择一个答案" : (widget.tfFragmentTemplate.answer == true ? "已选\"正确\"" : "已选\"错误\""),
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
