import 'dart:convert';

import 'package:drift_main/drift/DriftDb.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' as q;
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:tools/tools.dart';
import '../../global/GlobalAbController.dart';
import '../../global/tool_widgets/CustomImageWidget.dart';
import '../../home/HomeAbController.dart';
import '../../push_page/push_page.dart';
import '../../single_dialog/showAddFragmentToMemoryGroupDialog.dart';
import '../../single_dialog/showCreateFragmentGroupDialog.dart';
import '../../single_dialog/showFragmentGroupConfigDialog.dart';
import 'FragmentGroupListSelfPageController.dart';

class FragmentGroupListSelfPage extends StatelessWidget {
  const FragmentGroupListSelfPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GroupListWidget<FragmentGroup, Fragment, RFragment2FragmentGroup, FragmentGroupListSelfPageController>(
        groupListWidgetController: FragmentGroupListSelfPageController(
          enterUserId: Aber.find<GlobalAbController>().loggedInUser()!.id,
          enterFragmentGroupId: null,
        ),
        groupChainStrings: (group, abw) => group(abw).getDynamicGroupEntity(abw)!.title,
        leftActionBuilder: (c, abw) => Padding(
          padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
          child: Row(
            children: [
              const SizedBox(height: 5, child: VerticalDivider(width: 5)),
              const SizedBox(width: 5),
            ],
          ),
        ),
        headSliver: (c, g, abw) => g(abw).getDynamicGroupEntity(abw) == null ? Container() : _Head(c: c, g: g, abw: abw),
        groupBuilder: (c, group, abw) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Card(
                      margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
                      elevation: 0,
                      child: Row(
                        children: [
                          IconButton(
                            visualDensity: kMinVisualDensity,
                            padding: EdgeInsets.zero,
                            icon: group(abw).isShowSub(abw) ? const Icon(Icons.arrow_drop_down, color: Colors.grey) : const Icon(Icons.arrow_right, color: Colors.grey),
                            onPressed: () async {
                              await c.findEntitiesForSub(group());
                              group.refreshForce();
                              group().isShowSub.refreshEasy((oldValue) => !oldValue);
                            },
                          ),
                          Expanded(
                            child: MaterialButton(
                              visualDensity: kMinVisualDensity,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              child: Container(
                                padding: EdgeInsets.fromLTRB(c.isSelfOfFragmentGroup(dynamicFragmentGroup: group().getDynamicGroupEntity(abw)!) ? 5 : 5, 10, 10, 10),
                                child: Row(
                                  children: [
                                    c.isSelfOfFragmentGroup(dynamicFragmentGroup: group(abw).getDynamicGroupEntity()!)
                                        ? Container()
                                        : Padding(
                                            padding: const EdgeInsets.fromLTRB(0, 0, 5, 0),
                                            child: Transform.scale(
                                              scaleY: -1,
                                              child: const Icon(Icons.turn_slight_right, color: Colors.green),
                                            ),
                                          ),
                                    Expanded(
                                      child: Text(
                                        group(abw).getDynamicGroupEntity()!.title,
                                        style: const TextStyle(color: Colors.black),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    c.longPressedTarget(abw) == group(abw)
                                        ? GestureDetector(
                                            child: const Text("编辑", style: TextStyle(color: Colors.blue)),
                                            onTap: () {
                                              pushToFragmentGroupGizmoEditPage(context: context, fragmentGroupAb: group().getDynamicGroupEntityAb());
                                            },
                                          )
                                        : Container(),
                                    Icon(Icons.chevron_right, color: group().getDynamicGroupEntity()!.be_publish ? Colors.green : Colors.grey),
                                  ],
                                ),
                              ),
                              onPressed: () async {
                                await c.enterGroup(group);
                              },
                              onLongPress: () async {
                                await c.clearAllSelected();
                                c.isSelecting.refreshEasy((oldValue) => !oldValue);
                                if (c.isSelecting()) {
                                  c.longPressedTarget.refreshEasy((oldValue) => group());
                                } else {
                                  c.longPressedTarget.refreshEasy((oldValue) => null);
                                }
                                Aber.find<HomeAbController>().isShowFloating.refreshEasy((oldValue) => !oldValue);
                              },
                            ),
                          ),
                          // c.isSelecting(abw) ? Text('${group(abw).selectedUnitCount(abw)}/${group(abw).allUnitCount(abw)}') : Container(),
                          c.isSelecting(abw)
                              ? (c.selectedFragmentsMap(abw).isEmpty
                                  ? IconButton(
                                      icon: () {
                                        if (c.selectedSurfaceFragmentGroupsMap(abw).containsKey(group(abw).surfaceEntity(abw)!.id)) {
                                          return const SolidCircleIcon();
                                        } else {
                                          if (group(abw).selectedUnitCount(abw) == 0) {
                                            return const SolidCircleGreyIcon();
                                          } else {
                                            return const CircleHalfStrokeIcon();
                                          }
                                        }
                                      }(),
                                      onPressed: () async {
                                        await c.selectFragmentGroup(
                                          targetSurfaceFragmentGroup: group().surfaceEntity()!,
                                          isSelect: !c.selectedSurfaceFragmentGroupsMap(abw).containsKey(group(abw).surfaceEntity(abw)!.id),
                                        );
                                      },
                                    )
                                  : Container())
                              : Container(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              if (group(abw).isShowSub(abw)) c.loopSubGroup(group),
            ],
          );
        },
        unitBuilder: (c, unit, abw) {
          return Card(
            elevation: 0,
            child: Row(
              children: [
                Expanded(
                  child: MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: kMinVisualDensity,
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              unit(abw).unitEntity.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    onLongPress: () async {
                      await c.clearAllSelected();
                      c.isSelecting.refreshEasy((oldValue) => !oldValue);
                      Aber.find<HomeAbController>().isShowFloating.refreshEasy((oldValue) => !oldValue);
                    },
                    onPressed: () async {
                      await pushToMultiFragmentTemplateView(
                        context: context,
                        allFragments: c.getCurrentGroupAb()().units().map((e) => e().unitEntity).toList(),
                        fragment: unit().unitEntity,
                      );
                    },
                  ),
                ),
                c.isSelecting(abw)
                    ? (c.selectedSurfaceFragmentGroupsMap(abw).isEmpty
                        ? IconButton(
                            style: const ButtonStyle(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                            icon: FaIcon(
                              FontAwesomeIcons.solidCircle,
                              color: c.isSelectedUnit(unit: unit(abw), abw: abw) ? Colors.amber : Colors.grey,
                              size: 14,
                            ),
                            onPressed: () async {
                              c.selectFragment(
                                unit: unit(),
                                isSelect: !c.isSelectedUnit(unit: unit()),
                              );
                            },
                          )
                        : Container())
                    : Container(),
              ],
            ),
          );
        },
        rightActionBuilder: (c, abw) {
          return Row(
            children: [
              CustomDropdownBodyButton(
                initValue: 0,
                primaryButton: SizedBox(
                  width: kMinInteractiveDimension,
                  height: kMinInteractiveDimension,
                  child: Icon(Icons.add, color: Theme.of(c.context).primaryColor),
                ),
                itemAlignment: Alignment.centerLeft,
                items: [
                  CustomItem(value: 0, text: '添加碎片'),
                  CustomItem(value: 1, text: '添加碎片组'),
                ],
                onChanged: (v) async {
                  if (v == 0) {
                    final result = await pushToTemplateChoice(context: context);
                    if (result != null) {
                      await pushToFragmentEditView(
                        context: context,
                        initFragmentAb: null,
                        initFragmentTemplate: result,
                        initSomeBefore: [],
                        initSomeAfter: [],
                        enterDynamicFragmentGroups: (c.groupChain().last().getDynamicGroupEntityAb()(), null),
                        isEditableAb: true.ab,
                        isTailNew: true,
                      );
                    }
                  } else if (v == 1) {
                    showCreateFragmentGroupDialog(dynamicGroupEntity: c.getCurrentGroupAb()().getDynamicGroupEntity());
                  }
                },
              ),
            ],
          );
        },
        floatingButtonOnPressed: (c) {
          showAddFragmentToMemoryGroupDialog();
        },
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  Widget _bottomNavigationBar() {
    return AbBuilder<FragmentGroupListSelfPageController>(
      tag: Aber.single,
      builder: (c, abw) {
        if (c.isSelecting(abw)) {
          Widget button({
            required IconData iconData,
            required String label,
            required Function() onPressed,
            Color? color,
          }) {
            return MaterialButton(
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              onPressed: onPressed,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FaIcon(iconData, size: 26, color: color ?? Theme.of(c.context).primaryColor),
                  Text(label, style: TextStyle(fontSize: 12, color: color ?? Theme.of(c.context).primaryColor)),
                ],
              ),
            );
          }

          return Card(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 20),
            child: Container(
              decoration: BoxDecoration(border: Border.all(color: Theme.of(c.context).primaryColor)),
              child: Row(
                children: [
                  button(
                    iconData: Icons.close,
                    label: "关闭",
                    color: Colors.orange,
                    onPressed: () {
                      c.isSelecting.refreshEasy((oldValue) => false);
                      Aber.find<HomeAbController>().isShowFloating.refreshEasy((oldValue) => true);
                    },
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          button(
                            iconData: Icons.select_all_outlined,
                            label: '当前页全选',
                            onPressed: () async {
                              await c.selectAll();
                            },
                          ),
                          button(
                            iconData: Icons.deselect_outlined,
                            label: '当前页全不选',
                            onPressed: () async {
                              await c.deselectAll();
                            },
                          ),
                          button(
                            iconData: Icons.border_clear,
                            label: '清空选择',
                            onPressed: () async {
                              await c.clearAllSelected();
                            },
                          ),
                          button(
                            iconData: Icons.exit_to_app,
                            label: '移动',
                            onPressed: () async {
                              await c.moveSelected();
                            },
                          ),
                          // TODO: 批量克隆
                          // button(
                          //   iconData: FontAwesomeIcons.paste,
                          //   label: '克隆',
                          //   onPressed: () async {
                          //     // await c.cloneSelected();
                          //   },
                          // ),
                          button(
                            iconData: FontAwesomeIcons.clone,
                            label: '复用',
                            onPressed: () async {
                              await c.reuseSelectedOrDownload(reuseOrDownload: ReuseOrDownload.reuse);
                            },
                          ),
                          button(
                            iconData: Icons.delete_forever,
                            label: '删除',
                            color: Colors.red,
                            onPressed: () async {
                              await c.deleteSelected();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return const SizedBox();
      },
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({required this.abw, required this.c, required this.g});

  final FragmentGroupListSelfPageController c;
  final Ab<Group<FragmentGroup, Fragment, RFragment2FragmentGroup>> g;
  final Abw abw;

  bool hasFatherFragmentGroupBePublish() {
    return c.getGroupChainDynamicEntityNotRoot().any((element) => element.id != g().getDynamicGroupEntity()?.id && element.be_publish);
    // return (g().fatherGroup?.jumpTargetEntity()?.be_publish ?? g().fatherGroup?.surfaceEntity()?.be_publish) ?? false;
  }

  Widget publishWidget({required String text, required Color color}) {
    return Row(
      children: [
        Text(text, style: TextStyle(color: color)),
        const SizedBox(width: 5),
        Icon(Icons.settings, color: color, size: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bePublish = g(abw).getDynamicGroupEntity(abw)!.be_publish;
    final small = Row(
      children: [
        const Spacer(),
        Card(
          child: MaterialButton(
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            visualDensity: kMinVisualDensity,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
              child: hasFatherFragmentGroupBePublish() ? publishWidget(text: "已随父组发布", color: Colors.green) : publishWidget(text: "未发布", color: Theme.of(context).primaryColor),
            ),
            onPressed: () async {
              await showFragmentGroupConfigDialog(c: c, currentDynamicFragmentGroupAb: g().getDynamicGroupEntityAb());
            },
          ),
        ),
      ],
    );
    final big = Column(
      children: [
        c.isSelfOfFragmentGroup(dynamicFragmentGroup: g(abw).getDynamicGroupEntity(abw)!)
            ? Row(
                children: [
                  const Spacer(),
                  Card(
                    child: MaterialButton(
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: kMinVisualDensity,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                        child: publishWidget(text: hasFatherFragmentGroupBePublish() ? "已随父组发布 · 并单独发布" : "已发布", color: Colors.green),
                      ),
                      onPressed: () async {
                        await showFragmentGroupConfigDialog(c: c, currentDynamicFragmentGroupAb: g().getDynamicGroupEntityAb());
                      },
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const Spacer(),
                  TextButton(
                    child: const Text("查看源"),
                    onPressed: () {},
                  ),
                ],
              ),
        GestureDetector(
          onTap: () {
            pushToFragmentGroupGizmoEditPage(context: context, fragmentGroupAb: g().getDynamicGroupEntityAb());
          },
          child: Card(
            margin: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            color: Colors.white,
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
              child: Column(
                children: [
                  Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LocalThenCloudImageWidget(
                            size: globalFragmentGroupCoverRatio * 100,
                            localPath: null,
                            cloudPath: g(abw).getDynamicGroupEntity(abw)?.cover_cloud_path,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        g(abw).getDynamicGroupEntity(abw)!.title,
                                        style: Theme.of(context).textTheme.titleLarge,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    )
                                  ],
                                ),
                                const SizedBox(height: 10),
                                (c.currentFragmentGroupInformation(abw)?.fragment_group_tags ?? []).isEmpty
                                    ? Container()
                                    : Wrap(
                                        alignment: WrapAlignment.start,
                                        children: [
                                          ...(c.currentFragmentGroupInformation(abw)?.fragment_group_tags ?? []).map(
                                            (e) {
                                              return Container(
                                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 0),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  border: Border.all(color: Colors.grey),
                                                ),
                                                child: Text(e.tag, style: const TextStyle(color: Colors.grey, fontSize: 14)),
                                              );
                                            },
                                          ),
                                        ],
                                      ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        () {
                                          final text = q.Document.fromJson(jsonDecode(g(abw).getDynamicGroupEntity(abw)!.profile)).toPlainText().trim();
                                          return text.isEmpty ? "无简介" : text;
                                        }(),
                                        style: const TextStyle(color: Colors.grey),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
    return bePublish ? big : small;
  }
}
