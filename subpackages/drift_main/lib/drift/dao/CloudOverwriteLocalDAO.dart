part of '../DriftDb.dart';

@DriftAccessor(
  tables: tableClasses,
)
class CloudOverwriteLocalDAO extends DatabaseAccessor<DriftDb> with _$CloudOverwriteLocalDAOMixin {
  CloudOverwriteLocalDAO(super.attachedDatabase);

  /// 查询云端全部记忆组，并覆盖本地
  ///
  /// [userId] - 查询哪个用户的全部记忆组
  Future<void> queryCloudAllMemoryGroupOverwriteLocal({
    required int userId,
    required Future<void> Function(List<MemoryGroup> memoryGroups) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    final result = await request(
      path: HttpPath.POST__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_MEMORY_GROUPS_QUERY,
      dtoData: MemoryGroupsQueryDto(
        user_id: userId,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryGroupsQueryVo.fromJson,
    );
    await result.handleCode(
      code160101: (String showMessage, MemoryGroupsQueryVo vo) async {
        await driftDb.transaction(
          () async {
            // 因为记忆组可能被本地修改，所以需要判断是否将本地的进行云同步，而不能直接将本地的全部删除后全部覆盖。

            final localAll = await driftDb.generalQueryDAO.queryAll(tableInfo: driftDb.memoryGroups);
            final cloudAll = vo.memory_groups_list;
            final localSet = localAll.map((e) => e.id).toSet();
            final cloudSet = cloudAll.map((e) => e.id).toSet();
            final onlyLocal = localSet.difference(cloudSet);
            final onlyCloud = cloudSet.difference(localSet);

            // 删除 仅 存在于本地的
            await driftDb.deleteDAO.deleteManyMemoryGroups(mgIds: onlyLocal);
            // 下载仅存在于云端的
            await driftDb.insertDAO.insertManyMemoryGroups(mgs: cloudAll.where((element) => onlyCloud.any((c) => c == element.id)).toList());
            // 覆盖下载云端版本至本地（本地版本低于云端版本，或者本地未同步且本地版本等于云端版本）
            final download = cloudAll.where((element) =>
                localAll.any((c) => c.id == element.id && (c.sync_version < element.sync_version) || (c.be_synced == false && c.sync_version == element.sync_version)));
            await driftDb.insertDAO.insertManyMemoryGroups(mgs: download.toList());
            // 覆盖上传本地版本至云端（本地版本高于云端版本）
            final upload = localAll.where((element) => cloudAll.any((c) => c.id == element.id && c.sync_version < element.sync_version));
            final uploadResult = await request(
              path: HttpPath.POST__LOGIN_REQUIRED_MEMORY_GROUP_HANDLE_MEMORY_GROUP_MANY_UPDATE,
              dtoData: MemoryGroupManyUpdateDto(
                memory_groups_list: upload.toList(),
                dto_padding_1: null,
              ),
              parseResponseVoData: MemoryGroupManyUpdateVo.fromJson,
            );
            await uploadResult.handleCode(
              code151401: (String showMessage) async {
                // 记忆组同步成功
                final newLocalAll = await driftDb.generalQueryDAO.queryAll(tableInfo: driftDb.memoryGroups);
                await onSuccess(newLocalAll);
              },
            );
          },
        );
      },
      otherException: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }

  /// 将 [crtEntity] 实体插入云端，并存入本地
  ///
  /// [crtEntity] - 要插入的实体，插入前不带有 id，插入云端后才带有 id
  Future<void> insertCloudMemoryGroupAndOverwriteLocal({
    required MemoryGroup crtEntity,
    required Future<void> Function(MemoryGroup memoryGroup) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    await requestSingleRowInsert(
      isLoginRequired: true,
      singleRowInsertDto: SingleRowInsertDto(
        table_name: driftDb.memoryGroups.actualTableName,
        row: crtEntity,
      ),
      onSuccess: (String showMessage, SingleRowInsertVo vo) async {
        // 插入到本地
        final result = await driftDb.into(memoryGroups).insertReturning(MemoryGroup.fromJson(vo.row), mode: InsertMode.insert);
        await onSuccess(result);
      },
      onError: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }

  /// 查询云端全部记忆算法，并覆盖本地，如本地有多余，则清除
  ///
  /// [userId] - 查询哪个用户的全部记忆算法
  Future<void> queryCloudAllMemoryAlgorithmOverwriteLocal({
    required int userId,
    required Future<void> Function(List<MemoryAlgorithm> memoryAlgorithms) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    final result = await request(
      path: HttpPath.POST__NO_LOGIN_REQUIRED_MEMORY_MODEL_HANDLE_MEMORY_MODELS_QUERY,
      dtoData: MemoryModelsQueryDto(
        user_id: userId,
        dto_padding_1: null,
      ),
      parseResponseVoData: MemoryModelsQueryVo.fromJson,
    );
    await result.handleCode(
      code180101: (String showMessage, vo) async {
        await driftDb.transaction(
          () async {
            await driftDb.batch(
              (batch) {
                batch.deleteAll(memoryAlgorithms);
                batch.insertAll(memoryAlgorithms, vo.memory_models_list);
              },
            );
            final result = driftDb.select(memoryAlgorithms);
            await onSuccess(await result.get());
          },
        );
      },
      otherException: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }

  /// 将 [crtEntity] 实体插入云端，并存入本地
  ///
  /// [crtEntity] - 要插入的实体，插入前不带有 id，插入云端后才带有 id
  Future<void> insertCloudMemoryAlgorithmAndOverwriteLocal({
    required MemoryAlgorithm crtEntity,
    required Future<void> Function(MemoryAlgorithm memoryAlgorithm) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    await requestSingleRowInsert(
      isLoginRequired: true,
      singleRowInsertDto: SingleRowInsertDto(
        table_name: driftDb.memoryAlgorithms.actualTableName,
        row: crtEntity,
      ),
      onSuccess: (String showMessage, SingleRowInsertVo vo) async {
        // 插入到本地
        final result = await driftDb.into(memoryAlgorithms).insertReturning(MemoryAlgorithm.fromJson(vo.row), mode: InsertMode.insert);
        await onSuccess(result);
      },
      onError: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }

  /// 将修改后的 [memoryAlgorithm] 进行云端更新，并覆盖本地。
  Future<void> updateCloudMemoryAlgorithmAndOverwriteLocal({
    required MemoryAlgorithm memoryAlgorithm,
    required Future<void> Function(MemoryAlgorithm memoryAlgorithm) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    await requestSingleRowModify(
      isLoginRequired: true,
      singleRowModifyDto: SingleRowModifyDto(
        table_name: driftDb.memoryAlgorithms.actualTableName,
        row: memoryAlgorithm,
      ),
      onSuccess: (String showMessage, SingleRowModifyVo vo) async {
        final result = MemoryAlgorithm.fromJson(vo.row);
        // 更新到本地
        await driftDb.update(memoryAlgorithms).replace(result);
        await onSuccess(result);
      },
      onError: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }

  /// 查询云端单个记忆组的全部小周期，并覆盖本地，如本地有多余，则清除
  ///
  /// [memoryGroupId] - 查询哪个记忆组
  Future<void> queryCloudSingleMemoryGroupAllSmallCycleInfoAndOverwriteLocal({
    required int memoryGroupId,
    required Future<void> Function(List<MemoryGroupSmartCycleInfo> memoryGroupSmartCycleInfo) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    final result = await request(
      path: HttpPath.GET__LOGIN_REQUIRED_MEMORY_GROUP_CYCLE_INFO_HANDLE_QUERY_SINGLE_MEMORY_GROUP_ALL_SMALL_CYCLE_INFO,
      dtoData: QuerySingleMemoryGroupAllSmallCycleInfoDto(
        memory_group_id: memoryGroupId,
        dto_padding_1: null,
      ),
      parseResponseVoData: QuerySingleMemoryGroupAllSmallCycleInfoVo.fromJson,
    );
    await result.handleCode(
      code200201: (String showMessage, vo) async {
        await driftDb.transaction(
          () async {
            await driftDb.batch(
              (batch) {
                batch.deleteAll(memoryGroupSmartCycleInfos);
                batch.insertAll(memoryGroupSmartCycleInfos, vo.memory_group_small_cycle_infos_list);
              },
            );
            final result = driftDb.select(memoryGroupSmartCycleInfos);
            await onSuccess(await result.get());
          },
        );
      },
      otherException: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }

  /// 将 [crtEntity] 实体插入云端，并存入本地
  ///
  /// [crtEntity] - 要插入的实体，插入前不带有 id，插入云端后才带有 id
  Future<void> insertCloudMemoryGroupSmallCycleInfoAndOverwriteLocal({
    required MemoryGroupSmartCycleInfo crtEntity,
    required Future<void> Function(MemoryGroupSmartCycleInfo memoryGroupSmartCycleInfo) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    await requestSingleRowInsert(
      isLoginRequired: true,
      singleRowInsertDto: SingleRowInsertDto(
        table_name: driftDb.memoryGroupSmartCycleInfos.actualTableName,
        row: crtEntity,
      ),
      onSuccess: (String showMessage, SingleRowInsertVo vo) async {
        // 插入到本地
        final result = await driftDb.into(memoryGroupSmartCycleInfos).insertReturning(MemoryGroupSmartCycleInfo.fromJson(vo.row), mode: InsertMode.insert);
        await onSuccess(result);
      },
      onError: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }

  /// 将修改后的 [memoryGroupCycleInfo] 进行云端更新，并覆盖本地。
  Future<void> updateCloudMemoryGroupSmallCycleInfoAndOverwriteLocal({
    required MemoryGroupSmartCycleInfo memoryGroupSmartCycleInfo,
    required Future<void> Function(MemoryGroupSmartCycleInfo memoryGroupSmartCycleInfo) onSuccess,
    required Future<void> Function(int? code, HttperException httperException, StackTrace st)? onError,
  }) async {
    await requestSingleRowModify(
      isLoginRequired: true,
      singleRowModifyDto: SingleRowModifyDto(
        table_name: driftDb.memoryGroupSmartCycleInfos.actualTableName,
        row: memoryGroupSmartCycleInfo,
      ),
      onSuccess: (String showMessage, SingleRowModifyVo vo) async {
        final result = MemoryGroupSmartCycleInfo.fromJson(vo.row);
        // 更新到本地
        await driftDb.update(memoryGroupSmartCycleInfos).replace(result);
        await onSuccess(result);
      },
      onError: onError == null
          ? null
          : (a, b, c) async {
              await onError(a, b, c);
            },
    );
  }
}
