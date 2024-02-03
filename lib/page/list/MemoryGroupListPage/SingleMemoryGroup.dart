import 'package:drift/drift.dart';
import 'package:drift_main/drift/DriftDb.dart';
import 'package:drift_main/httper/httper.dart';
import 'package:drift_main/share_common/share_enum.dart';
import 'package:tools/tools.dart';

import 'SmallCycleInfo.dart';
import 'StatusButton.dart';

class SingleMemoryGroup {
  SingleMemoryGroup({required this.memoryGroup});

  DownloadStatus downloadStatus = DownloadStatus.other_loading;

  /// 注意是查询云端并覆盖本地后的
  final MemoryGroup memoryGroup;

  /// 当前记忆组的全部小周期，包含了 [currentSmallCycleInfo]。
  final smallCycleInfos = <SmallCycleInfo>[];

  /// 当前正在执行的小周期
  ///   - 如果为 null，说明没有获取成功。
  ///   - 如果没有正在执行的，则为 [CurrentSmallCycleInfo.memoryGroupSmartCycleInfo] 为 null
  CurrentSmallCycleInfo? currentSmallCycleInfo;

  /// 当前记忆组碎片总数量
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalFragmentCount = 0;

  /// [FragmentMemoryInfoStudyStatus.completed]
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalCompletedCount = 0;

  /// [FragmentMemoryInfoStudyStatus.reviewing]
  ///
  /// 注意，先是本地查询后的数量，后进行数量同步后，才是云端同步后的数量。
  int totalReviewingCount = 0;

  Future<void> queryAllSmallCycleInfos() async {
    await driftDb.cloudOverwriteLocalDAO.queryCloudSingleMemoryGroupAllSmallCycleInfoAndOverwriteLocal(
      memoryGroupId: memoryGroup.id,
      onSuccess: (List<MemoryGroupSmartCycleInfo> memoryGroupSmartCycleInfos) async {
        smallCycleInfos.clear();
        currentSmallCycleInfo = CurrentSmallCycleInfo(memoryGroup: memoryGroup, memoryGroupSmartCycleInfo: null);
        smallCycleInfos.addAll(
          memoryGroupSmartCycleInfos.map((e) {
            if (isTimeBetween(target: DateTime.now(), left: e.created_at, right: e.should_small_cycle_end_time)) {
              final c = CurrentSmallCycleInfo(memoryGroup: memoryGroup, memoryGroupSmartCycleInfo: e);
              currentSmallCycleInfo = c;
              return c;
            }
            return SmallCycleInfo(memoryGroup: memoryGroup, memoryGroupSmartCycleInfo: e);
          }),
        );
      },
      onError: (int? code, HttperException httperException, StackTrace st) async {
        logger.outErrorHttp(code: code, showMessage: httperException.showMessage, debugMessage: httperException.debugMessage, st: st);
      },
    );
  }

  /// 从本地查询总计数量
  ///
  /// 不能在该函数内设置 downloadStatus，否则每次调用都会被重新设置，而应该保持 downloadStatus 不变。
  Future<void> queryLocalTotalCount() async {
    totalFragmentCount = await driftDb.generalQueryDAO.queryCount(
      tableInfo: driftDb.fragmentMemoryInfos,
      whereExpr: driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id),
    );

    totalCompletedCount = await driftDb.generalQueryDAO.queryCount(
      tableInfo: driftDb.fragmentMemoryInfos,
      whereExpr: driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) & driftDb.fragmentMemoryInfos.study_status.equalsValue(FragmentMemoryInfoStudyStatus.completed),
    );

    totalReviewingCount = await driftDb.generalQueryDAO.queryCount(
      tableInfo: driftDb.fragmentMemoryInfos,
      whereExpr: driftDb.fragmentMemoryInfos.memory_group_id.equals(memoryGroup.id) & driftDb.fragmentMemoryInfos.study_status.equalsValue(FragmentMemoryInfoStudyStatus.reviewing),
    );
  }

  /// 从云端查询总计数量，同时检测 [downloadStatus]
  ///
  /// TODO：当本地总数量与云端总数量相同时，但是存在修改时，该怎么办？
  Future<void> queryCloudTotalCount() async {
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_FRAGMENTS_COUNT_QUERY,
      dtoData: MemoryGroupFragmentsCountQueryDto(
        memory_group_id: memoryGroup.id,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryGroupFragmentsCountQueryVo.fromJson,
    );
    await result.handleCode(
      code160201: (String showMessage, vo) async {
        if (totalFragmentCount == 0 && vo.count == 0) {
          downloadStatus = DownloadStatus.zero;
          return;
        }
        if (totalFragmentCount == 0 && vo.count > 0) {
          downloadStatus = DownloadStatus.never_downloaded;
          return;
        }
        if (totalFragmentCount != vo.count) {
          downloadStatus = DownloadStatus.different_download;
          return;
        }
        if (totalFragmentCount == vo.count) {
          downloadStatus = DownloadStatus.all_downloaded;
          return;
        }
      },
      otherException: (a, b, c) async {
        logger.outErrorHttp(code: a, showMessage: b.showMessage, debugMessage: b.debugMessage, st: c);
        downloadStatus = DownloadStatus.other_load_fail;
      },
    );
  }
}
