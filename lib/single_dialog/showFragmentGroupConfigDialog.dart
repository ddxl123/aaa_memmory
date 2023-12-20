import 'package:aaa_memory/global/GlobalAbController.dart';
import 'package:aaa_memory/push_page/push_page.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_smart_dialog/flutter_smart_dialog.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:just_the_tooltip/just_the_tooltip.dart';
import 'package:tools/tools.dart';
import 'package:intl/intl.dart';

import '../page/edit/FragmentGroupGizmoEditPage.dart';
import '../page/list/FragmentGroupListSelfPageController.dart';

Future<void> showFragmentGroupConfigDialog({required FragmentGroupListSelfPageController c, required Ab<FragmentGroup?> currentDynamicFragmentGroupAb}) async {
  return await showCustomDialog(
    builder: (_) {
      return _PrivatePublishDialogWidget(
        c: c,
        currentDynamicFragmentGroupAb: currentDynamicFragmentGroupAb,
      );
    },
  );
}

class _PrivatePublishDialogWidget extends StatefulWidget {
  const _PrivatePublishDialogWidget({super.key, required this.currentDynamicFragmentGroupAb, required this.c});

  final FragmentGroupListSelfPageController c;
  final Ab<FragmentGroup?> currentDynamicFragmentGroupAb;

  @override
  State<_PrivatePublishDialogWidget> createState() => _PrivatePublishDialogWidgetState();
}

class _PrivatePublishDialogWidgetState extends State<_PrivatePublishDialogWidget> {
  final privateJustTheController = JustTheController();
  final publishJustTheController = JustTheController();

  Widget single({required String number, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$number. "),
        Expanded(child: Text(text)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      mainVerticalWidgets: [
        Text("内容"),
        Row(
          children: [
            Expanded(
              child: TextButton(
                child: Row(
                  children: [
                    Icon(Icons.edit_outlined),
                    SizedBox(width: 20),
                    Expanded(child: Text("编辑内容")),
                    Icon(Icons.chevron_right),
                  ],
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FragmentGroupGizmoEditPage(currentDynamicFragmentGroupAb: widget.currentDynamicFragmentGroupAb),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                child: Row(
                  children: [
                    Icon(Icons.remove_red_eye_outlined),
                    SizedBox(width: 20),
                    Expanded(child: Text("查看详情")),
                    Icon(Icons.chevron_right),
                  ],
                ),
                onPressed: () {
                  pushToFragmentGroupListView(
                    context: context,
                    enterUserId: widget.currentDynamicFragmentGroupAb()!.creator_user_id,
                    enterFragmentGroupId: widget.currentDynamicFragmentGroupAb()!.id,
                  );
                },
              ),
            ),
          ],
        ),
        Divider(color: Colors.black12),
        Text("共享"),
        Row(
          children: [
            Expanded(
              child: TextButton(
                child: Row(
                  children: [
                    Icon(Icons.public),
                    SizedBox(width: 20),
                    Expanded(child: Text("是否共享")),
                    Transform.scale(
                      scaleX: 0.7,
                      scaleY: 0.7,
                      child: Switch(
                        thumbColor:
                            widget.currentDynamicFragmentGroupAb()!.be_publish ? MaterialStatePropertyAll(Theme.of(context).primaryColor) : MaterialStatePropertyAll(Colors.grey),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        value: widget.currentDynamicFragmentGroupAb()!.be_publish,
                        onChanged: null,
                      ),
                    ),
                  ],
                ),
                onPressed: () async {
                  if (widget.currentDynamicFragmentGroupAb()!.be_publish) {
                    await showCustomDialog(
                      builder: (BuildContext context) {
                        return OkAndCancelDialogWidget(
                          okText: "取消共享",
                          cancelText: "返回",
                          title: "取消共享说明：",
                          columnChildren: [
                            single(number: "1", text: "知识库中将不显示且无法搜索到该碎片组。"),
                            single(number: "2", text: "知识库中若其他碎片组内含有该碎片组，则该碎片组将不会在其他碎片组内显示。"),
                            single(number: "3", text: "已下载过的用户仍然留存着该碎片组。"),
                            single(number: "4", text: "即使取消了共享，对该碎片组进行增、删、改、移等操作，已下载过的用户仍然会被通知更新。"),
                          ],
                          onOk: () async {
                            final result = await request(
                              path: HttpPath.POST__LOGIN_REQUIRED_SINGLE_ROW_MODIFY,
                              dtoData: SingleRowModifyDto(
                                table_name: driftDb.fragmentGroups.actualTableName,
                                row: widget.currentDynamicFragmentGroupAb()!..be_publish = false,
                              ),
                              parseResponseVoData: SingleRowModifyVo.fromJson,
                            );
                            await result.handleCode(
                              code110101: (String showMessage, SingleRowModifyVo vo) async {
                                await requestSingleRowInsert(
                                  isLoginRequired: true,
                                  singleRowInsertDto: SingleRowInsertDto(
                                    table_name: driftDb.fragmentGroupInfos.actualTableName,
                                    row: Crt.fragmentGroupInfoEntity(
                                      creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
                                      fragment_group_id: widget.currentDynamicFragmentGroupAb()!.id,
                                      notification_modify_content: HistoryNotificationWidget.closeShare,
                                    ),
                                  ),
                                  onSuccess: (String showMessage, SingleRowInsertVo vo) async {
                                    widget.c.thisRefresh();
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              otherException: (a, b, c) async {
                                logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
                              },
                            );
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  } else {
                    await showCustomDialog(
                      builder: (BuildContext context) {
                        return OkAndCancelDialogWidget(
                          okText: "共享",
                          cancelText: "返回",
                          title: "共享说明：",
                          text: "1. 将会在知识库中显示，并可被搜索到。\n2. 如果父碎片组已共享，则该碎片组将会额外共享一份。",
                          columnChildren: [
                            Text("对作者：", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            single(
                              number: "1",
                              text: "其他用户下载你共享的碎片组，"
                                  "其碎片/碎片组引用的是你共享的碎片本身，"
                                  "而不是拷贝版，因此哪怕你取消了共享，"
                                  "只要对碎片进行任意操作，都会通知给已下载的用户进行更新。",
                            ),
                            single(
                              number: "2",
                              text: "其他用户下载你共享的碎片组，其用户是可以对下载的碎片或碎片组进行更改、删除，"
                                  "但一旦该用户进行更新或重新下载（包括app清除数据），都会被还原成您共享的。",
                            ),
                            single(
                              number: "3",
                              text: "其他用户下载你共享的碎片组，其用户在碎片组内进行新增碎片或碎片组后，"
                                  "进行了更新或重新下载，新增的仍然会被保留。",
                            ),
                            single(
                              number: "4",
                              text: "为考虑已下载的用户，尽可能不对碎片或碎片组进行删除，"
                                  "否则用户进行重新下载或更新时，将会丢失被删除部分。",
                            ),
                            single(
                              number: "4",
                              text: "为考虑已下载的用户，尽可能在内部进行移动，"
                                  "若移动到外部，则用户更新或重新下载会导致移出去的部分丢失。",
                            ),
                            SizedBox(height: 5),
                            Text("对下载者：", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            single(number: "1", text: "删除：更新或重新下载会重新出现。"),
                            single(number: "2", text: "移动：可以移动到任意地方，但更新或重新下载会被归位。"),
                            single(number: "3", text: "修改：更新或重新下载会被复原。"),
                            single(number: "4", text: "新增：更新或重新下载后，新增的会被保留。"),
                          ],
                          onOk: () async {
                            final result = await request(
                              path: HttpPath.POST__LOGIN_REQUIRED_SINGLE_ROW_MODIFY,
                              dtoData: SingleRowModifyDto(
                                table_name: driftDb.fragmentGroups.actualTableName,
                                row: widget.currentDynamicFragmentGroupAb()!..be_publish = true,
                              ),
                              parseResponseVoData: SingleRowModifyVo.fromJson,
                            );
                            await result.handleCode(
                              code110101: (String showMessage, SingleRowModifyVo vo) async {
                                await requestSingleRowInsert(
                                  isLoginRequired: true,
                                  singleRowInsertDto: SingleRowInsertDto(
                                    table_name: driftDb.fragmentGroupInfos.actualTableName,
                                    row: Crt.fragmentGroupInfoEntity(
                                      creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
                                      fragment_group_id: widget.currentDynamicFragmentGroupAb()!.id,
                                      notification_modify_content: HistoryNotificationWidget.openShare,
                                    ),
                                  ),
                                  onSuccess: (String showMessage, SingleRowInsertVo vo) async {
                                    widget.c.thisRefresh();
                                    setState(() {});
                                    Navigator.pop(context);
                                  },
                                );
                              },
                              otherException: (a, b, c) async {
                                logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
                              },
                            );
                          },
                          onCancel: () {
                            Navigator.pop(context);
                          },
                        );
                      },
                    );
                  }
                },
              ),
            ),
            JustTheTooltip(
              controller: publishJustTheController,
              backgroundColor: Colors.grey.shade800,
              content: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("共享：会在首页中被推荐，也可被搜索到", style: TextStyle(color: Colors.white)),
                    Text("不共享：不会在首页中被推荐，也无法被搜索到", style: TextStyle(color: Colors.white)),
                  ],
                ),
              ),
              child: GestureDetector(
                child: Icon(Icons.error, color: Colors.blue, size: 18),
                onTap: () {
                  publishJustTheController.showTooltip();
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                child: Row(
                  children: [
                    Icon(Icons.tips_and_updates_outlined),
                    SizedBox(width: 20),
                    Expanded(child: Text("通知改动")),
                    Icon(Icons.turn_slight_right),
                  ],
                ),
                onPressed: () {
                  showCustomDialog(
                    builder: (ctx) {
                      return TextField1DialogWidget(
                        okText: "通知用户",
                        cancelText: "返回",
                        text: "请描述改动内容：",
                        onOk: (c) async {
                          if (c.text.trim().isEmpty) {
                            SmartDialog.showToast("请写入改动内容！");
                            return;
                          }
                          await requestSingleRowInsert(
                            isLoginRequired: true,
                            singleRowInsertDto: SingleRowInsertDto(
                              table_name: driftDb.fragmentGroupInfos.actualTableName,
                              row: Crt.fragmentGroupInfoEntity(
                                creator_user_id: Aber.find<GlobalAbController>().loggedInUser()!.id,
                                fragment_group_id: widget.currentDynamicFragmentGroupAb()!.id,
                                notification_modify_content: c.text,
                              ),
                            ),
                            onSuccess: (String showMessage, SingleRowInsertVo vo) async {
                              logger.outNormal(show: "通知成功！");
                              SmartDialog.dismiss(status: SmartStatus.dialog);
                            },
                            onError: (a, b, c) async {
                              logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
                            },
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
        Row(
          children: [
            Expanded(
              child: TextButton(
                child: Row(
                  children: [
                    Icon(Icons.history),
                    SizedBox(width: 20),
                    Expanded(child: Text("历史通知")),
                    Icon(Icons.chevron_right),
                  ],
                ),
                onPressed: () {
                  showCustomDialog(
                    builder: (ctx) {
                      return HistoryNotificationWidget(fragmentGroup: widget.currentDynamicFragmentGroupAb()!);
                    },
                  );
                },
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
      bottomHorizontalButtonWidgets: [],
    );
  }
}

class HistoryNotificationWidget extends StatefulWidget {
  const HistoryNotificationWidget({super.key, required this.fragmentGroup});

  final FragmentGroup fragmentGroup;

  static String openShare = ":::打开了共享";
  static String closeShare = ":::关闭了共享";

  @override
  State<HistoryNotificationWidget> createState() => _HistoryNotificationWidgetState();
}

class _HistoryNotificationWidgetState extends State<HistoryNotificationWidget> {
  final infos = <FragmentGroupInfo>[];

  @override
  void initState() {
    super.initState();
    _future();
  }

  Future<void> _future() async {
    final result = await request(
      path: HttpPath.GET__NO_LOGIN_REQUIRED_FRAGMENT_GROUP_HANDLE_FRAGMENT_GROUP_INFOS_QUERY,
      dtoData: FragmentGroupInfosQueryDto(
        fragment_group_id: widget.fragmentGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: FragmentGroupInfosQueryVo.fromJson,
    );

    await result.handleCode(
      code151701: (String showMessage, vo) async {
        infos
          ..clear()
          ..addAll(vo.fragment_group_infos_list);
        infos.sort((a, b) => b.created_at.compareTo(a.created_at));
        if (mounted) setState(() {});
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DialogWidget(
      mainVerticalWidgets: [
        const SizedBox(height: 10),
        ...infos.isEmpty
            ? [const Text("无记录")]
            : infos.map(
                (e) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: (e.notification_modify_content == HistoryNotificationWidget.openShare || e.notification_modify_content == HistoryNotificationWidget.closeShare)
                                ? Text(e.notification_modify_content.substring(3, e.notification_modify_content.length), style: TextStyle(color: Colors.orange))
                                : Text(e.notification_modify_content),
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          Spacer(),
                          Text(
                            DateFormat("y/M/d H:mm").format(e.created_at),
                            style: TextStyle(color: Theme.of(context).primaryColor),
                          ),
                          if (infos.indexOf(e) == 0) Text("  ~最新", style: TextStyle(color: Colors.blue)),
                        ],
                      ),
                      Divider(color: Colors.grey.withOpacity(0.3)),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("创建", style: TextStyle(color: Colors.orange)),
            Row(
              children: [
                Spacer(),
                Text(
                  DateFormat("y/M/d H:mm").format(widget.fragmentGroup.created_at),
                  style: TextStyle(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ],
        ),
        SizedBox(height: 20),
      ],
      bottomHorizontalButtonWidgets: [
        TextButton(
          child: Text("关闭"),
          onPressed: () {
            SmartDialog.dismiss(status: SmartStatus.dialog);
          },
        ),
      ],
    );
  }
}
