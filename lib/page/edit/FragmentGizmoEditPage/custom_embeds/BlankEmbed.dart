import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/base/FragmentTemplate.dart';
import 'package:aaa_memory/page/edit/FragmentGizmoEditPage/FragmentTemplate/template/blank/BlankFragmentTemplate.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as q;
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:tools/tools.dart';

import '../FragmentTemplate/template/choice/ChoicePrefixType.dart';

enum BlankType {
  /// 隐藏或显示
  hide("隐藏"),

  /// 输入
  input("输入"),

  /// 一空一选
  choice_one("一空一选"),

  /// 一空多选
  choice_many("一空多选");

  const BlankType(this.displayName);

  final String displayName;
}

class BlankData {
  BlankData({
    required this.blankType,
    required this.answer,
  });

  BlankType blankType;

  /// 如果是挖空或填空，则为原来的文本。
  ///
  /// 如果是选择，则为 tag 字符。
  String answer;

  Map<String, dynamic> toJson() {
    return {
      "blank_type": blankType.name,
      "answer": answer,
    };
  }

  factory BlankData.fromJson(Map<String, dynamic> json) {
    return BlankData(
      blankType: BlankType.values.singleWhere((element) => element.name == (json["blank_type"] as String)),
      answer: json["answer"] as String,
    );
  }

  /// [answer] 是否已经选了多个。
  bool get hasManyAnswerForChoice => _parseAnswerForChoiceToTag().length > 1;

  /// 当 [blankType] 为 选择类型时，将 [answer] 解析成 ["tag1","tag2"]，以便能找到对应的 [BlankChoice]。
  List<String> _parseAnswerForChoiceToTag() {
    final result = answer.split(",");
    return result.length == 1 && result.single.isEmpty ? [] : result;
  }

  /// 检查 [answer] 内是否存在 [targetTag]
  bool isExistAnswerForChoice({required String targetTag}) {
    return _parseAnswerForChoiceToTag().contains(targetTag);
  }

  void removeAnswerForChoice({required String targetTag}) {
    final tags = _parseAnswerForChoiceToTag();
    tags.remove(targetTag);
    answer = tags.join(",");
  }

  /// 同时进行排序。
  void addAnswerForChoice({required String targetTag}) {
    List<String> tags = _parseAnswerForChoiceToTag();
    tags.add(targetTag);
    answer = tags.join(",");
  }

  /// 对 [targetTag] 进行反选
  void invertAnswerForChoice({required String targetTag}) {
    if (isExistAnswerForChoice(targetTag: targetTag)) {
      removeAnswerForChoice(targetTag: targetTag);
    } else {
      addAnswerForChoice(targetTag: targetTag);
    }
  }

  void removeAllAnswerForChoice() {
    answer = "";
  }

  /// 将 [BlankData.answer] 转换成显示文本，
  ///
  /// 如果是非选项，则会返回原文本。
  ///
  /// 如果是选项，则会转换成 显示前缀。
  /// 如果选项前缀为 [ChoicePrefixType.none]，则会显示选项答案。
  String parseAnswerToDisplayText({required List<BlankChoice> choices, required ChoicePrefixType choicePrefixType}) {
    if (blankType == BlankType.hide || blankType == BlankType.input) {
      return answer;
    }
    final tags = _parseAnswerForChoiceToTag();
    final answerWithPrefix = <String>[];

    for (var tag in tags) {
      final choice = choices.where((element) => element.tag == tag).firstOrNull;
      // 如果为 null，则说明选项已被移除，但是答案还保留着被移除的选项，因此在这里进行修复。
      if (choice == null) {
        removeAnswerForChoice(targetTag: tag);
      } else {
        String prefix = choicePrefixType.toTypeFrom(choices.indexOf(choice) + 1);

        // 如果选项前缀为 [ChoicePrefixType.none]，则会显示选项答案。
        if (prefix.isEmpty) {
          prefix = choice.text;
        }
        answerWithPrefix.add(prefix);
      }
    }
    answerWithPrefix.sort();
    return answerWithPrefix.join(",");
  }

  /// 因为需要将 [tempAnswer] 使用 [this] 类中对 [answer] 的操作，因此这个函数可以将 [tempAnswer] 临时赋值给 [answer]，处理完后再赋值回原来的 [answer]。
  ///
  /// [T] - [handle] 的返回值
  /// [String] - [tempAnswer] 被修改后的新结果
  T tempAnswerTransfer<T>({required BlankNodeTemp blankNodeTemp, required T Function(BlankData bd) handle}) {
    final copyAnswer = answer;
    answer = blankNodeTemp.tempAnswer;
    final T handleResult = handle(this);
    blankNodeTemp.tempAnswer = answer;
    answer = copyAnswer;
    return handleResult;
  }
}

class BlankBlockEmbed extends q.Embeddable {
  BlankBlockEmbed({required BlankData blankData}) : super(BlankBlockEmbed.blankBlock, blankData.toJson());

  static const String blankBlock = 'blank_block';
}

/// TODO: 创建好带有 挖空-input 的碎片后，在碎片列表内打开该碎片，点击 input 节点，再直接点击输入框，会把答案给显示出来！
/// TODO：对错题编辑时什么内容都不填，点击预览后，会出现错误。
class BlankEmbedBuilder extends q.EmbedBuilder {
  BlankEmbedBuilder({required this.blankFragmentTemplate});

  final BlankFragmentTemplate blankFragmentTemplate;

  bool isShowAnswer = true;

  @override
  String get key => BlankBlockEmbed.blankBlock;

  @override
  Widget build(BuildContext context, q.QuillController controller, q.Embed node, bool readOnly, bool inline, TextStyle textStyle) {
    blankFragmentTemplate.addBlankNodeTemp(node: node);

    final oldBlankData = BlankData.fromJson(node.value.data);
    late final BoxBorder? boxBorder;
    if (oldBlankData.blankType == BlankType.hide) {
      boxBorder = null;
    } else if (oldBlankData.blankType == BlankType.input) {
      boxBorder = const BorderDirectional(bottom: BorderSide(color: Colors.lightGreen, width: 2));
    } else if (oldBlankData.blankType == BlankType.choice_one || oldBlankData.blankType == BlankType.choice_many) {
      boxBorder = const BorderDirectional(
        start: BorderSide(color: Colors.lightGreen, width: 2),
        end: BorderSide(color: Colors.lightGreen, width: 2),
      );
    } else {
      boxBorder = null;
    }

    return StatefulBuilder(
      builder: (ctx, r) {
        Widget text = const Text("??");
        // 如果没有答案，则无论什么情况都显示 "?"
        if (oldBlankData.answer.isEmpty) {
          text = const Text("?", style: TextStyle(color: Colors.grey));
        }
        // 如果有答案
        else {
          // 如果在编辑状态下，则始终显示答案
          if (blankFragmentTemplate.performType == PerformType.edit) {
            text = Text(
              oldBlankData.parseAnswerToDisplayText(
                choices: blankFragmentTemplate.choices,
                choicePrefixType: blankFragmentTemplate.choicePrefixType,
              ),
            );
          }
          // 如果在预览状态下
          else if (blankFragmentTemplate.performType == PerformType.preview) {
            // 当不显示正确答案时
            if (!blankFragmentTemplate.getBlankNodeTemp(node: node).isShow) {
              // hide 类型隐藏
              if (oldBlankData.blankType == BlankType.hide) {
                text = const Text("");
              }
              // input 类型显示输入答案
              else if (oldBlankData.blankType == BlankType.input) {
                text = Text(blankFragmentTemplate.getBlankNodeTemp(node: node).tempAnswer);
              }
              // choice_xx 类型时
              else if (oldBlankData.blankType == BlankType.choice_one || oldBlankData.blankType == BlankType.choice_many) {
                // 当手动选择选项时，显示输入答案
                if (blankFragmentTemplate.isShowChoicesForChoice) {
                  text = Text(
                    oldBlankData.tempAnswerTransfer(
                      blankNodeTemp: blankFragmentTemplate.getBlankNodeTemp(node: node),
                      handle: (bd) => bd.parseAnswerToDisplayText(
                        choices: blankFragmentTemplate.choices,
                        choicePrefixType: blankFragmentTemplate.choicePrefixType,
                      ),
                    ),
                  );
                }
                // 当自动选择选项时，进行隐藏
                else {
                  text = Text("");
                }
              } else {
                throw "未处理：${oldBlankData.blankType}";
              }
            }
            // 当显示正确答案时
            else {
              if (oldBlankData.blankType == BlankType.hide ||
                  (oldBlankData.blankType == BlankType.choice_one && !blankFragmentTemplate.isShowChoicesForChoice) ||
                  (oldBlankData.blankType == BlankType.choice_many && !blankFragmentTemplate.isShowChoicesForChoice)) {
                text = Text(
                  oldBlankData.parseAnswerToDisplayText(
                    choices: blankFragmentTemplate.choices,
                    choicePrefixType: blankFragmentTemplate.choicePrefixType,
                  ),
                );
              } else if (oldBlankData.blankType == BlankType.input ||
                  (oldBlankData.blankType == BlankType.choice_one && blankFragmentTemplate.isShowChoicesForChoice) ||
                  (oldBlankData.blankType == BlankType.choice_many && blankFragmentTemplate.isShowChoicesForChoice)) {
                // 答案正确时
                if (oldBlankData.answer == blankFragmentTemplate.getBlankNodeTemp(node: node).tempAnswer) {
                  text = Text(
                    oldBlankData.parseAnswerToDisplayText(
                      choices: blankFragmentTemplate.choices,
                      choicePrefixType: blankFragmentTemplate.choicePrefixType,
                    ),
                    style: const TextStyle(color: Colors.green),
                  );
                }
                // 答案错误时
                else {
                  final tempText = oldBlankData.tempAnswerTransfer(
                    blankNodeTemp: blankFragmentTemplate.getBlankNodeTemp(node: node),
                    handle: (bd) => bd.parseAnswerToDisplayText(
                      choices: blankFragmentTemplate.choices,
                      choicePrefixType: blankFragmentTemplate.choicePrefixType,
                    ),
                  );
                  final correctText = oldBlankData.parseAnswerToDisplayText(
                    choices: blankFragmentTemplate.choices,
                    choicePrefixType: blankFragmentTemplate.choicePrefixType,
                  );
                  text = RichText(
                      text: TextSpan(
                    text: tempText.isEmpty ? "?" : tempText,
                    style: const TextStyle(color: Colors.red),
                    children: [
                      const TextSpan(text: " -> ", style: TextStyle(color: Colors.grey)),
                      TextSpan(text: correctText, style: const TextStyle(color: Colors.green)),
                    ],
                  ));
                }
              }
            }
          } else {
            throw "未处理 ${blankFragmentTemplate.performType}";
          }
        }
        return Listener(
          child: IntrinsicWidth(
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(horizontal: 4),
              margin: EdgeInsets.symmetric(horizontal: 2, vertical: 2),
              constraints: BoxConstraints(minWidth: kMinInteractiveDimension),
              decoration: BoxDecoration(
                color: Color.fromRGBO(250, 192, 0, 0.4),
                borderRadius: BorderRadius.all(Radius.circular(5)),
                border: boxBorder,
              ),
              child: text,
            ),
          ),
          onPointerUp: (_) async {
            if (blankFragmentTemplate.performType == PerformType.edit) {
              await showCustomDialog(
                builder: (ctx) => BlackDialog(
                  quillController: controller,
                  blankFragmentTemplate: blankFragmentTemplate,
                  oldBlankData: oldBlankData,
                  node: node,
                ),
              );
            } else if (blankFragmentTemplate.performType == PerformType.preview) {
              if (oldBlankData.blankType == BlankType.hide) {
                blankFragmentTemplate.changeBlankNodeTemp(node: node, isShow: null);
              } else if (oldBlankData.blankType == BlankType.input) {
                await showCustomDialog(
                  builder: (ctx) {
                    return TextField1DialogWidget(
                      okText: "确定",
                      cancelText: "取消",
                      textEditingController: TextEditingController(
                        text: blankFragmentTemplate.getBlankNodeTemp(node: node).tempAnswer,
                      ),
                      inputDecoration: const InputDecoration(hintText: "请输入答案..."),
                      onOk: (c) {
                        blankFragmentTemplate.getBlankNodeTemp(node: node).tempAnswer = c.text;
                        SmartDialog.dismiss(status: SmartStatus.dialog);
                      },
                    );
                  },
                );
              } else if (oldBlankData.blankType == BlankType.choice_one || oldBlankData.blankType == BlankType.choice_many) {
                if (!blankFragmentTemplate.isShowChoicesForChoice) {
                  blankFragmentTemplate.changeBlankNodeTemp(node: node, isShow: null);
                } else {
                  await showCustomDialog(
                    builder: (ctx) {
                      return StatefulBuilder(
                        builder: (ctx, dialogR) {
                          return OkAndCancelDialogWidget(
                            text: "请选择你的答案：",
                            columnChildren: [
                              if (blankFragmentTemplate.choices.isEmpty) const Row(children: [Text("无选项", style: TextStyle(color: Colors.grey))]),
                              for (int i = 0; i < blankFragmentTemplate.choices.length; i++)
                                TextButton(
                                  style: ButtonStyle(visualDensity: kMinVisualDensity),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        blankFragmentTemplate.choicePrefixType.toTypeFrom(i + 1),
                                        style: const TextStyle(color: Colors.amber),
                                      ),
                                      blankFragmentTemplate.choicePrefixType == ChoicePrefixType.none ? Container() : const Text("  "),
                                      Expanded(child: Text(blankFragmentTemplate.choices[i].text)),
                                      Checkbox(
                                        value: oldBlankData.tempAnswerTransfer(
                                          blankNodeTemp: blankFragmentTemplate.getBlankNodeTemp(node: node),
                                          handle: (bd) {
                                            print(bd.isExistAnswerForChoice(targetTag: blankFragmentTemplate.choices[i].tag));
                                            return bd.isExistAnswerForChoice(targetTag: blankFragmentTemplate.choices[i].tag);
                                          },
                                        ),
                                        onChanged: null,
                                        visualDensity: kMinVisualDensity,
                                        shape: oldBlankData.blankType == BlankType.choice_one ? const CircleBorder() : null,
                                      ),
                                    ],
                                  ),
                                  onPressed: () async {
                                    final targetTag = blankFragmentTemplate.choices[i].tag;
                                    if (oldBlankData.blankType == BlankType.choice_one) {
                                      final isExist = oldBlankData.tempAnswerTransfer(
                                        blankNodeTemp: blankFragmentTemplate.getBlankNodeTemp(node: node),
                                        handle: (bd) => bd.isExistAnswerForChoice(targetTag: targetTag),
                                      );
                                      if (isExist) {
                                        oldBlankData.tempAnswerTransfer(
                                          blankNodeTemp: blankFragmentTemplate.getBlankNodeTemp(node: node),
                                          handle: (bd) => bd.removeAllAnswerForChoice(),
                                        );
                                      } else {
                                        oldBlankData.tempAnswerTransfer(
                                          blankNodeTemp: blankFragmentTemplate.getBlankNodeTemp(node: node),
                                          handle: (bd) {
                                            bd.removeAllAnswerForChoice();
                                            bd.addAnswerForChoice(targetTag: targetTag);
                                          },
                                        );
                                      }
                                    } else if (oldBlankData.blankType == BlankType.choice_many) {
                                      oldBlankData.tempAnswerTransfer(
                                        blankNodeTemp: blankFragmentTemplate.getBlankNodeTemp(node: node),
                                        handle: (bd) => bd.invertAnswerForChoice(targetTag: targetTag),
                                      );
                                    } else {
                                      throw "未处理 ${oldBlankData.blankType}";
                                    }
                                    dialogR(() {});
                                    r(() {});
                                  },
                                ),
                              SizedBox(height: 20),
                            ],
                          );
                        },
                      );
                    },
                  );
                }
              } else {
                throw "未处理：${oldBlankData.blankType}";
              }
            } else {
              throw "未处理：${blankFragmentTemplate.performType}";
            }
            r(() {});
          },
        );
      },
    );
  }
}

class BlankToolBar extends StatefulWidget {
  const BlankToolBar({required this.blankFragmentTemplate, super.key});

  final BlankFragmentTemplate blankFragmentTemplate;

  @override
  State<BlankToolBar> createState() => _BlankToolBarState();
}

class _BlankToolBarState extends State<BlankToolBar> {
  late final q.QuillController quillController;

  @override
  void initState() {
    super.initState();
    quillController = widget.blankFragmentTemplate.currentFocusSingleEditableQuill.value!.quillController;
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      child: Text("[...]"),
      onPressed: () {
        final index = quillController.selection.baseOffset;
        final length = quillController.selection.extentOffset - index;
        quillController.replaceText(
          index,
          length,
          BlankBlockEmbed(
            blankData: BlankData(
              blankType: BlankType.hide,
              answer: quillController.document.toPlainText().substring(index, index + length),
            ),
          ),
          null,
        );

        quillController.moveCursorToPosition(index + length + 1);
      },
    );
  }
}

class BlackDialog extends StatefulWidget {
  const BlackDialog({
    super.key,
    required this.quillController,
    required this.blankFragmentTemplate,
    required this.oldBlankData,
    required this.node,
  });

  final q.QuillController quillController;
  final BlankFragmentTemplate blankFragmentTemplate;
  final BlankData oldBlankData;
  final q.Embed node;

  @override
  State<BlackDialog> createState() => _BlackDialogState();
}

class _BlackDialogState extends State<BlackDialog> {
  late final BlankFragmentTemplate blankFragmentTemplate;
  late BlankData newBlankData;

  @override
  void initState() {
    super.initState();
    blankFragmentTemplate = widget.blankFragmentTemplate;
    newBlankData = BlankData(blankType: widget.oldBlankData.blankType, answer: widget.oldBlankData.answer);
  }

  @override
  Widget build(BuildContext context) {
    return TextField1DialogWidget(
      okText: "确定",
      cancelText: '取消',
      mainVerticalColumns: [
        Row(
          children: [
            Text("挖空类型："),
            Spacer(),
            CustomDropdownBodyButton(
              initValue: newBlankData.blankType,
              items: BlankType.values.map(
                (e) {
                  return CustomItem(value: e, text: e.displayName);
                },
              ).toList(),
              onChanged: (v) {
                newBlankData.blankType = v!;
                setState(() {});
              },
            ),
          ],
        ),
        const SizedBox(height: 10),
        ...(blankFragmentTemplate.choices.isEmpty && (newBlankData.blankType == BlankType.choice_one || newBlankData.blankType == BlankType.choice_many))
            ? [
                const Text("未添加选项", style: TextStyle(color: Colors.red)),
              ]
            : [
                if (newBlankData.blankType == BlankType.choice_one || newBlankData.blankType == BlankType.choice_many)
                  for (int i = 0; i < blankFragmentTemplate.choices.length; i++)
                    TextButton(
                      key: ValueKey(i),
                      style: ButtonStyle(visualDensity: kMinVisualDensity),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            blankFragmentTemplate.choicePrefixType.toTypeFrom(i + 1),
                            style: const TextStyle(color: Colors.amber),
                          ),
                          blankFragmentTemplate.choicePrefixType == ChoicePrefixType.none ? Container() : const Text("  "),
                          Expanded(child: Text(blankFragmentTemplate.choices[i].text)),
                          Checkbox(
                            value: newBlankData.isExistAnswerForChoice(targetTag: blankFragmentTemplate.choices[i].tag),
                            onChanged: null,
                            visualDensity: kMinVisualDensity,
                            shape: newBlankData.blankType == BlankType.choice_one ? const CircleBorder() : null,
                          ),
                        ],
                      ),
                      onPressed: () async {
                        final targetTag = blankFragmentTemplate.choices[i].tag;
                        if (newBlankData.blankType == BlankType.choice_one) {
                          if (newBlankData.isExistAnswerForChoice(targetTag: targetTag)) {
                            newBlankData.removeAllAnswerForChoice();
                          } else {
                            newBlankData.removeAllAnswerForChoice();
                            newBlankData.addAnswerForChoice(targetTag: targetTag);
                          }
                        } else if (newBlankData.blankType == BlankType.choice_many) {
                          newBlankData.invertAnswerForChoice(targetTag: targetTag);
                        } else {
                          throw "未处理 ${newBlankData.blankType}";
                        }
                        setState(() {});
                      },
                    ),
              ],
      ],
      isHideTextField: newBlankData.blankType == BlankType.choice_one || newBlankData.blankType == BlankType.choice_many ? true : false,
      textEditingController: TextEditingController(
        text: newBlankData.parseAnswerToDisplayText(
          choices: blankFragmentTemplate.choices,
          choicePrefixType: blankFragmentTemplate.choicePrefixType,
        ),
      ),
      inputDecoration: const InputDecoration(hintText: "请输入挖空内容..."),
      onOk: (c) {
        if (newBlankData.blankType == BlankType.hide || newBlankData.blankType == BlankType.input) {
          newBlankData.answer = c.text;
        }
        if (newBlankData.blankType == BlankType.choice_one && newBlankData.hasManyAnswerForChoice) {
          SmartDialog.showToast("一空一选答案不能选择多个！");
          return;
        }
        confirmAndPop();
      },
    );
  }

  void confirmAndPop() {
    widget.quillController.replaceText(
      widget.node.offset,
      widget.node.length,
      BlankBlockEmbed(blankData: newBlankData),
      null,
    );
    SmartDialog.dismiss(status: SmartStatus.dialog);
  }
}
